#!/usr/bin/env bash
# Build the MdArray MLIR dialect example.
#
# Usage:
#   ./scripts/build.sh              # default build dir: <repo-root>/build
#   BUILD_DIR=/tmp/mybuild ./scripts/build.sh
#
# Prerequisites: CMake >= 3.20, Ninja, C++17 compiler.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# Repo root is 4 levels up: scripts/ -> MDArray/ -> examples/ -> mlir/ -> repo/
REPO_ROOT="$(cd "$SCRIPT_DIR/../../../.." && pwd)"
BUILD_DIR="${BUILD_DIR:-$REPO_ROOT/build}"

echo "============================================"
echo "  MdArray Dialect — Build Script"
echo "============================================"
echo "  Repo root : $REPO_ROOT"
echo "  Build dir : $BUILD_DIR"
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
  -DMLIR_ENABLE_EXECUTION_ENGINE=OFF

# ---------------------------------------------------------------------------
# Step 2: Build only the mdarray-opt target (avoids building all of LLVM)
# ---------------------------------------------------------------------------
echo ""
echo "==> Building mdarray-opt (this may take several minutes on first run) ..."
cmake --build "$BUILD_DIR" --target mdarray-opt -j"$(nproc 2>/dev/null || sysctl -n hw.logicalcpu 2>/dev/null || echo 4)"

OPT="$BUILD_DIR/bin/mdarray-opt"
if [[ -x "$OPT" ]]; then
  echo ""
  echo "==> Build successful."
  echo "    Binary: $OPT"
else
  echo ""
  echo "ERROR: mdarray-opt not found after build. Check CMake output above."
  exit 1
fi
