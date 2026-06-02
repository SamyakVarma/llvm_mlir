# MdArray — Custom MLIR Dialect for Multi-Dimensional Array Operations

A custom MLIR dialect (`mdarray`) that provides high-level tensor operations
and a lowering pass to convert them into MLIR's standard `memref` dialect.

## What It Does

Defines five operations:

| Op | Syntax | Lowered To |
|----|--------|-----------|
| `mdarray.alloc` | `mdarray.alloc(%n, %m) : tensor<?x?xf32>` | `memref.alloc` |
| `mdarray.load` | `mdarray.load %t[%i, %j] : tensor<?x?xf32> -> f32` | `memref.load` |
| `mdarray.store` | `mdarray.store %v, %t[%i, %j] : tensor<?x?xf32>` | `memref.store` |
| `mdarray.slice` | `mdarray.slice %t[%o0,%o1][%s0,%s1] : ... -> ...` | `memref.subview` |
| `mdarray.transpose` | `mdarray.transpose %t : tensor<?x?xf32> -> tensor<?x?xf32>` | `memref.alloc` + `scf.for` loop nest |

The `--convert-mdarray-to-memref` pass converts all five ops in one step using
MLIR's `DialectConversion` framework, replacing tensor types with memref types
throughout the IR.

## Repository Layout

```
mlir/examples/MDArray/
├── README.md               ← this file
├── DESIGN.md               ← design decisions and alternatives
├── IMPLEMENTATION.md       ← LLVM/MLIR implementation details
├── EVALUATION.md           ← metrics, test cases, baseline comparison
├── REPORT.md               ← full combined report
├── scripts/
│   ├── build.sh            ← configure + compile mdarray-opt
│   └── run.sh              ← run all test cases through the lowering pass
├── include/MdArray/
│   ├── MdArrayDialect.td   ← dialect definition (TableGen)
│   ├── MdArrayOps.td       ← all 5 op definitions (TableGen)
│   └── MdArrayPasses.td    ← lowering pass definition (TableGen)
├── lib/MdArray/
│   ├── MdArrayDialect.cpp  ← dialect initialization
│   ├── MdArrayOps.cpp      ← op verifiers
│   └── MdArrayPasses.cpp   ← ConversionPattern implementations
├── mdarray-opt/
│   └── mdarray-opt.cpp     ← CLI driver tool
└── test/
    ├── test_lowering.mlir       ← 5 working lowering tests
    └── test_failure_cases.mlir  ← verifier error / failure cases
```

## Prerequisites

- LLVM monorepo cloned (this dialect lives inside `mlir/examples/`)
- CMake ≥ 3.20
- Ninja
- C++17 compiler (GCC ≥ 9, Clang ≥ 11, or MSVC 2019+)

## How to Build

```bash
cd mlir/examples/MDArray
./scripts/build.sh
```

By default the build output goes to `<repo-root>/build/`. Override with:

```bash
BUILD_DIR=/path/to/build ./scripts/build.sh
```

## How to Run

```bash
cd mlir/examples/MDArray
./scripts/run.sh
```

This runs every test case (working and failure) and prints the before/after IR.

### Manual single-file run

```bash
# From the build directory:
./bin/mdarray-opt --convert-mdarray-to-memref \
    ../mlir/examples/MDArray/test/test_lowering.mlir
```

### Expected output

All `mdarray.*` ops are replaced. For example, `@test_alloc_load` becomes:

```mlir
func.func @test_alloc_load(%arg0: index, %arg1: index, %arg2: index, %arg3: index) -> f32 {
  %alloc = memref.alloc(%arg0, %arg1) : memref<?x?xf32>
  %0 = memref.load %alloc[%arg2, %arg3] : memref<?x?xf32>
  return %0 : f32
}
```

No `mdarray.*` operations appear in the output.

## Demo

See `EVALUATION.md` for screenshots of the lowering output and failure cases.
