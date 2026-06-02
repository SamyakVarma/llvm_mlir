#!/usr/bin/env bash
# Run all MdArray dialect test cases (passing lowering + verifier failure).
#
# Usage:
#   ./scripts/run.sh
#   BUILD_DIR=/tmp/mybuild ./scripts/run.sh
#
# Requires mdarray-opt to be built first (./scripts/build.sh).
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../../../.." && pwd)"
BUILD_DIR="${BUILD_DIR:-$REPO_ROOT/build}"
OPT="$BUILD_DIR/bin/mdarray-opt"
TEST_DIR="$SCRIPT_DIR/../test"
LOWERING_FILE="$TEST_DIR/test_lowering.mlir"
FAIL_FILE="$TEST_DIR/test_failure_cases.mlir"

PASS=0
FAIL=0

# ---------------------------------------------------------------------------
# Preflight
# ---------------------------------------------------------------------------
if [[ ! -x "$OPT" ]]; then
  echo "ERROR: mdarray-opt not found at $OPT"
  echo "       Run ./scripts/build.sh first."
  exit 1
fi

echo "mdarray-opt : $OPT"
echo "Test dir    : $TEST_DIR"

# ---------------------------------------------------------------------------
# Helper
# ---------------------------------------------------------------------------
header() {
  echo ""
  echo "========================================================"
  echo "  $1"
  echo "========================================================"
}

# Run the lowering pass on $LOWERING_FILE; grep for the given function.
# Verifies no mdarray.* ops remain in the full output.
run_lowering_test() {
  local num="$1"
  local label="$2"
  local func="$3"

  header "TEST $num — $label"

  echo "[ INPUT — mdarray ops ]"
  awk "/func\.func @${func}/,/^}/" "$LOWERING_FILE" | head -25
  echo ""

  set +e
  lowered=$("$OPT" --convert-mdarray-to-memref "$LOWERING_FILE" 2>&1)
  ec=$?
  set -e

  if [[ $ec -ne 0 ]]; then
    echo "[ FAIL ] mdarray-opt returned exit code $ec"
    echo "$lowered"
    FAIL=$((FAIL + 1))
    return
  fi

  echo "[ OUTPUT — lowered to memref ]"
  echo "$lowered" | awk "/func\.func @${func}/,/^}/" | head -40
  echo ""

  remaining=$(echo "$lowered" | grep -c 'mdarray\.' || true)
  if [[ "$remaining" -eq 0 ]]; then
    echo "[ PASS ] No mdarray.* ops remain."
    PASS=$((PASS + 1))
  else
    echo "[ FAIL ] $remaining mdarray.* op(s) still present after lowering."
    FAIL=$((FAIL + 1))
  fi
}

# Run --verify-diagnostics on the entire failure file in one shot.
# All 5 expected-error annotations must match actual verifier errors.
run_all_failure_tests() {
  header "FAILURE TESTS F1–F10 (verifier rejection)"

  echo "File: $FAIL_FILE"
  echo ""
  echo "Running: mdarray-opt --verify-diagnostics $FAIL_FILE"
  echo ""

  # Show the test functions (inputs only — no lowering expected)
  grep -E "^func\.func @bad|// FAILURE|// expected-error" "$FAIL_FILE" | head -30
  echo ""

  set +e
  err_output=$("$OPT" --verify-diagnostics "$FAIL_FILE" 2>&1)
  ec=$?
  set -e

  echo "[ TOOL OUTPUT ]"
  echo "$err_output"
  echo ""

  # --verify-diagnostics exits 0 when ALL expected-error annotations match
  # their actual verifier errors (every error is expected, every expectation
  # is satisfied). Any mismatch causes non-zero exit.
  if [[ $ec -eq 0 ]]; then
    echo "[ PASS ] All 10 expected verifier errors matched annotations."
    PASS=$((PASS + 10))
  else
    echo "[ FAIL ] --verify-diagnostics failed (some annotation unmatched or"
    echo "         an unexpected error appeared). Exit code: $ec"
    FAIL=$((FAIL + 10))
  fi
}

# ---------------------------------------------------------------------------
# Passing lowering tests (5 functions in test_lowering.mlir)
# ---------------------------------------------------------------------------
run_lowering_test  1 "alloc + load"                  "test_alloc_load"
run_lowering_test  2 "alloc + store + load"          "test_store_load"
run_lowering_test  3 "alloc + slice"                 "test_slice"
run_lowering_test  4 "alloc + transpose"             "test_transpose"
run_lowering_test  5 "combined pipeline"             "test_combined"
run_lowering_test  6 "1-D tensor (rank 1)"           "test_1d_alloc_load"
run_lowering_test  7 "i32 element type"              "test_i32_tensor"
run_lowering_test  8 "slice then load"               "test_slice_then_load"
run_lowering_test  9 "double transpose"              "test_double_transpose"
run_lowering_test 10 "multiple stores"               "test_multiple_stores"

# ---------------------------------------------------------------------------
# Verifier failure tests (all 5 in one --verify-diagnostics call)
# ---------------------------------------------------------------------------
run_all_failure_tests

# ---------------------------------------------------------------------------
# Summary
# ---------------------------------------------------------------------------
header "SUMMARY"
printf "  Passed : %d\n" "$PASS"
printf "  Failed : %d\n" "$FAIL"
printf "  Total  : %d\n" "$((PASS + FAIL))"
echo ""
if [[ "$FAIL" -eq 0 ]]; then
  echo "  All tests passed."
  exit 0
else
  echo "  Some tests FAILED. See output above."
  exit 1
fi
