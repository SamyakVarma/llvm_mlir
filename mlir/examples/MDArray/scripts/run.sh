#!/usr/bin/env bash
# Run all MdArray dialect test cases through the C → LLVM → MLIR → lowering pipeline.
#
# Pipeline (passing tests):
#   1. C source          (test/src/*.c)
#   2. LLVM IR           (clang -emit-llvm)
#   3. MLIR llvm dialect (mlir-translate --import-llvm)
#   4. MdArray MLIR      (scripts/ll_to_mdarray.py)
#   5. MemRef MLIR       (mdarray-opt --convert-mdarray-to-memref)
#
# Verifier failure tests still use hand-written MLIR (test/test_failure_cases.mlir).
#
# Usage:
#   ./scripts/run.sh
#   BUILD_DIR=/tmp/mybuild ./scripts/run.sh
#
# Requires mdarray-opt and mlir-translate to be built (./scripts/build.sh).
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../../../.." && pwd)"
BUILD_DIR="${BUILD_DIR:-$REPO_ROOT/build}"
OPT="$BUILD_DIR/bin/mdarray-opt"
TRANSLATE="$BUILD_DIR/bin/mlir-translate"
TEST_DIR="$SCRIPT_DIR/../test"
SRC_DIR="$TEST_DIR/src"
INCLUDE_DIR="$TEST_DIR/include"
GEN_DIR="$TEST_DIR/generated"
FAIL_FILE="$TEST_DIR/test_failure_cases.mlir"
LL_TO_MDARRAY="$SCRIPT_DIR/ll_to_mdarray.py"

PASS=0
FAIL=0

# Resolve clang: CLANG env var, then common install / build locations.
find_clang() {
  if [[ -n "${CLANG:-}" ]]; then
    if [[ -x "$CLANG" ]] || command -v "$CLANG" &>/dev/null; then
      echo "$CLANG"
      return 0
    fi
    echo "ERROR: CLANG=$CLANG was set but is not executable or not in PATH." >&2
    return 1
  fi

  local candidate
  for candidate in \
      "$BUILD_DIR/bin/clang" \
      "$BUILD_DIR/bin/clang.exe" \
      "/mingw64/bin/clang" \
      "/usr/bin/clang" \
      "/c/Program Files/LLVM/bin/clang.exe"; do
    if [[ -x "$candidate" ]]; then
      echo "$candidate"
      return 0
    fi
  done

  if command -v clang &>/dev/null; then
    command -v clang
    return 0
  fi

  echo "ERROR: clang not found." >&2
  echo "" >&2
  echo "The C test pipeline needs Clang to emit LLVM IR (-emit-llvm)." >&2
  echo "Install one of:" >&2
  echo "  MSYS2:  pacman -S mingw-w64-x86_64-clang" >&2
  echo "  LLVM:   https://github.com/llvm/llvm-project/releases (add bin/ to PATH)" >&2
  echo "  Or set CLANG=/path/to/clang before running this script." >&2
  return 1
}

CLANG="$(find_clang)" || exit 1

# Resolve Python: PYTHON env var, then common install locations.
find_python() {
  if [[ -n "${PYTHON:-}" ]]; then
    if [[ -x "$PYTHON" ]] || command -v "$PYTHON" &>/dev/null; then
      echo "$PYTHON"
      return 0
    fi
    echo "ERROR: PYTHON=$PYTHON was set but is not executable or not in PATH." >&2
    return 1
  fi

  local candidate
  for candidate in \
      python3 python \
      "/mingw64/bin/python3" \
      "/mingw64/bin/python" \
      "/usr/bin/python3" \
      "/usr/bin/python" \
      "/c/Python312/python.exe" \
      "/c/Python311/python.exe" \
      "/c/Python310/python.exe"; do
    if [[ "$candidate" == python3 || "$candidate" == python ]]; then
      if command -v "$candidate" &>/dev/null; then
        command -v "$candidate"
        return 0
      fi
    elif [[ -x "$candidate" ]]; then
      echo "$candidate"
      return 0
    fi
  done

  echo "ERROR: Python not found (required by ll_to_mdarray.py)." >&2
  echo "" >&2
  echo "Install one of:" >&2
  echo "  MSYS2:  pacman -S mingw-w64-x86_64-python" >&2
  echo "  Windows: https://www.python.org/downloads/ (check Add to PATH)" >&2
  echo "  Or set PYTHON=/path/to/python before running this script." >&2
  return 1
}

PYTHON="$(find_python)" || exit 1

# All passing-test C sources (basename without .c)
TESTS=(
  test_alloc_load
  test_store_load
  test_slice
  test_transpose
  test_combined
  test_1d_alloc_load
  test_i32_tensor
  test_slice_then_load
  test_double_transpose
  test_multiple_stores
)

TEST_LABELS=(
  "alloc + load"
  "alloc + store + load"
  "alloc + slice"
  "alloc + transpose"
  "combined pipeline"
  "1-D tensor (rank 1)"
  "i32 element type"
  "slice then load"
  "double transpose"
  "multiple stores"
)

# ---------------------------------------------------------------------------
# Preflight
# ---------------------------------------------------------------------------
if [[ ! -x "$OPT" ]]; then
  echo "ERROR: mdarray-opt not found at $OPT"
  echo "       Run ./scripts/build.sh first."
  exit 1
fi

if [[ ! -x "$TRANSLATE" ]]; then
  echo "ERROR: mlir-translate not found at $TRANSLATE"
  echo "       Run ./scripts/build.sh first."
  exit 1
fi

mkdir -p "$GEN_DIR"

echo "mdarray-opt    : $OPT"
echo "mlir-translate : $TRANSLATE"
echo "clang          : $CLANG"
echo "python         : $PYTHON"
echo "Test src dir   : $SRC_DIR"
echo "Generated IR   : $GEN_DIR"

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------
header() {
  echo ""
  echo "========================================================"
  echo "  $1"
  echo "========================================================"
}

# Full pipeline for one C test source.
run_c_pipeline_test() {
  local num="$1"
  local label="$2"
  local base="$3"

  local c_file="$SRC_DIR/${base}.c"
  local ll_file="$GEN_DIR/${base}.ll"
  local llvm_mlir="$GEN_DIR/${base}.llvm.mlir"
  local mdarray_mlir="$GEN_DIR/${base}.mdarray.mlir"

  header "TEST $num — $label ($base)"

  if [[ ! -f "$c_file" ]]; then
    echo "[ FAIL ] Missing C source: $c_file"
    FAIL=$((FAIL + 1))
    return
  fi

  # Stage 1: C source
  echo "[ STAGE 1 — C source ]"
  head -20 "$c_file"
  echo ""

  # Stage 2: C → LLVM IR
  echo "[ STAGE 2 — LLVM IR (clang -emit-llvm) ]"
  set +e
  clang_err=$("$CLANG" -S -emit-llvm -O0 "$c_file" -o "$ll_file" 2>&1)
  clang_ec=$?
  set -e
  if [[ $clang_ec -ne 0 ]]; then
    echo "[ FAIL ] clang returned exit code $clang_ec"
    echo "$clang_err"
    FAIL=$((FAIL + 1))
    return
  fi
  grep -E "define|call|declare @mdarray" "$ll_file" | head -15
  echo ""

  # Stage 3: LLVM IR → MLIR (llvm dialect)
  echo "[ STAGE 3 — MLIR llvm dialect (mlir-translate --import-llvm) ]"
  set +e
  translate_err=$("$TRANSLATE" --import-llvm "$ll_file" -o "$llvm_mlir" 2>&1)
  translate_ec=$?
  set -e
  if [[ $translate_ec -ne 0 ]]; then
    echo "[ FAIL ] mlir-translate returned exit code $translate_ec"
    echo "$translate_err"
    FAIL=$((FAIL + 1))
    return
  fi
  grep -E "llvm\.func|llvm\.call|llvm\.return" "$llvm_mlir" | head -12
  echo ""

  # Stage 4: LLVM IR → MdArray dialect MLIR
  echo "[ STAGE 4 — MdArray MLIR (ll_to_mdarray.py) ]"
  set +e
  gen_err=$("$PYTHON" "$LL_TO_MDARRAY" "$ll_file" -o "$mdarray_mlir" 2>&1)
  gen_ec=$?
  set -e
  if [[ $gen_ec -ne 0 ]]; then
    echo "[ FAIL ] ll_to_mdarray.py returned exit code $gen_ec"
    echo "$gen_err"
    FAIL=$((FAIL + 1))
    return
  fi
  cat "$mdarray_mlir"
  echo ""

  # Stage 5: MdArray → MemRef lowering
  echo "[ STAGE 5 — MemRef MLIR (mdarray-opt --convert-mdarray-to-memref) ]"
  set +e
  lowered=$("$OPT" --convert-mdarray-to-memref "$mdarray_mlir" 2>&1)
  opt_ec=$?
  set -e

  if [[ $opt_ec -ne 0 ]]; then
    echo "[ FAIL ] mdarray-opt returned exit code $opt_ec"
    echo "$lowered"
    FAIL=$((FAIL + 1))
    return
  fi

  echo "$lowered" | head -35
  echo ""

  remaining=$(echo "$lowered" | grep -c 'mdarray\.' || true)
  if [[ "$remaining" -eq 0 ]]; then
    echo "[ PASS ] Full pipeline succeeded; no mdarray.* ops remain."
    PASS=$((PASS + 1))
  else
    echo "[ FAIL ] $remaining mdarray.* op(s) still present after lowering."
    FAIL=$((FAIL + 1))
  fi
}

# Verifier failure tests (hand-written MLIR — invalid IR cannot start from C).
run_all_failure_tests() {
  header "FAILURE TESTS F1–F10 (verifier rejection, hand-written MLIR)"

  echo "File: $FAIL_FILE"
  echo ""
  echo "Running: mdarray-opt --verify-diagnostics $FAIL_FILE"
  echo ""

  grep -E "^func\.func @bad|// FAILURE|// expected-error" "$FAIL_FILE" | head -30
  echo ""

  set +e
  err_output=$("$OPT" --verify-diagnostics "$FAIL_FILE" 2>&1)
  ec=$?
  set -e

  echo "[ TOOL OUTPUT ]"
  echo "$err_output"
  echo ""

  if [[ $ec -eq 0 ]]; then
    echo "[ PASS ] All 10 expected verifier errors matched annotations."
    PASS=$((PASS + 10))
  else
    echo "[ FAIL ] --verify-diagnostics failed. Exit code: $ec"
    FAIL=$((FAIL + 10))
  fi
}

# ---------------------------------------------------------------------------
# Passing tests — C → LLVM → MLIR → MdArray → MemRef
# ---------------------------------------------------------------------------
for i in "${!TESTS[@]}"; do
  run_c_pipeline_test "$((i + 1))" "${TEST_LABELS[$i]}" "${TESTS[$i]}"
done

# ---------------------------------------------------------------------------
# Verifier failure tests
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
