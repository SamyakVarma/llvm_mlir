#!/usr/bin/env bash
# Build the MdArray MLIR dialect example.
#
# Usage:
#   ./scripts/build.sh              # default build dir: <repo-root>/build
#   BUILD_DIR=/tmp/mybuild ./scripts/build.sh
#   BUILD_JOBS=1 ./scripts/build.sh # low-memory / MinGW (recommended on Windows)
#
# Prerequisites: CMake >= 3.20, Ninja, C++17 compiler.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# Repo root is 4 levels up: scripts/ -> MDArray/ -> examples/ -> mlir/ -> repo/
REPO_ROOT="$(cd "$SCRIPT_DIR/../../../.." && pwd)"
BUILD_DIR="${BUILD_DIR:-$REPO_ROOT/build}"

# MinGW/MSYS builds of MLIR are memory-hungry (GPU/OpenMP dialect TUs can OOM
# when compiled in parallel). Default to 1 job on Windows; override with BUILD_JOBS.
if [[ -n "${BUILD_JOBS:-}" ]]; then
  JOBS="$BUILD_JOBS"
elif [[ "$(uname -s 2>/dev/null || echo unknown)" == MINGW* ]] \
     || [[ "$(uname -s 2>/dev/null || echo unknown)" == MSYS* ]] \
     || [[ "${OS:-}" == Windows_NT ]]; then
  JOBS=1
else
  JOBS="$(nproc 2>/dev/null || sysctl -n hw.logicalcpu 2>/dev/null || echo 4)"
fi

echo "============================================"
echo "  MdArray Dialect — Build Script"
echo "============================================"
echo "  Repo root : $REPO_ROOT"
echo "  Build dir : $BUILD_DIR"
echo "  Jobs      : $JOBS (set BUILD_JOBS to override)"
echo ""

# ---------------------------------------------------------------------------
# Step 1: Configure
# ---------------------------------------------------------------------------
echo "==> Configuring CMake ..."
cmake -G Ninja \
  -S "$REPO_ROOT/llvm" \
  -B "$BUILD_DIR" \
  -DLLVM_ENABLE_PROJECTS="mlir" \
  -DLLVM_TARGETS_TO_BUILD="host" \
  -DCMAKE_BUILD_TYPE=Release \
  -DLLVM_ENABLE_ASSERTIONS=ON \
  -DLLVM_INCLUDE_TESTS=OFF \
  -DMLIR_INCLUDE_TESTS=OFF \
  -DLLVM_INCLUDE_EXAMPLES=ON \
  -DLLVM_ENABLE_BINDINGS_PYTHON=OFF \
  -DLLVM_PARALLEL_COMPILE_JOBS="$JOBS" \
  -DLLVM_PARALLEL_LINK_JOBS=1

# ---------------------------------------------------------------------------
# Step 2: Build only the mdarray-opt target (avoids building all of LLVM)
# ---------------------------------------------------------------------------
echo ""
echo "==> Building mdarray-opt and mlir-translate ..."
echo "    (first run builds ~4000 dependency targets; use BUILD_JOBS=1 on MinGW)"
cmake --build "$BUILD_DIR" --target mdarray-opt mlir-translate -j"$JOBS"

OPT="$BUILD_DIR/bin/mdarray-opt"
TRANSLATE="$BUILD_DIR/bin/mlir-translate"
if [[ -x "$OPT" && -x "$TRANSLATE" ]]; then
  echo ""
  echo "==> Build successful."
  echo "    mdarray-opt    : $OPT"
  echo "    mlir-translate : $TRANSLATE"
else
  echo ""
  echo "ERROR: expected binaries not found after build. Check CMake output above."
  exit 1
fi
