# Assignment 10 — MdArray: Custom MLIR Dialect for Tensor Operations

**Course**: Compiler Design / Systems Programming
**Author**: Nischal (nischal2805)

---

## What This Project Does

This project implements a custom **MLIR dialect** called `mdarray` (Multi-Dimensional
Array) that provides five high-level tensor operations, and a **lowering pass** that
converts all of them into MLIR's standard `memref` dialect using the `DialectConversion`
framework.

This mimics how ML framework frontends (PyTorch, TensorFlow) lower high-level tensor
operations through MLIR's dialect hierarchy before reaching machine code — the core
concept of MLIR's **progressive lowering** model, as opposed to LLVM's single-IR model.

### The Five Operations

| Operation | High-level IR | Lowered To |
|-----------|--------------|------------|
| `mdarray.alloc` | `mdarray.alloc(%n, %m) : tensor<?x?xf32>` | `memref.alloc` |
| `mdarray.load` | `mdarray.load %t[%i,%j] : tensor<?x?xf32> -> f32` | `memref.load` |
| `mdarray.store` | `mdarray.store %v, %t[%i,%j] : tensor<?x?xf32>` | `memref.store` |
| `mdarray.slice` | `mdarray.slice %t[%o0,%o1][%s0,%s1] : ...` | `memref.subview` |
| `mdarray.transpose` | `mdarray.transpose %t : tensor<?x?xf32> -> tensor<?x?xf32>` | `memref.alloc` + `scf.for` loop nest |

### Example Lowering

Input (`mdarray` dialect):
```mlir
func.func @example(%n: index, %m: index) -> tensor<?x?xf32> {
  %0 = mdarray.alloc(%n, %m) : tensor<?x?xf32>
  %1 = mdarray.transpose %0 : tensor<?x?xf32> -> tensor<?x?xf32>
  return %1 : tensor<?x?xf32>
}
```

After `--convert-mdarray-to-memref`:
```mlir
func.func @example(%arg0: index, %arg1: index) -> memref<?x?xf32> {
  %c0 = arith.constant 0 : index
  %c1 = arith.constant 1 : index
  %alloc = memref.alloc(%arg0, %arg1) : memref<?x?xf32>
  %dim0 = memref.dim %alloc, %c0 : memref<?x?xf32>
  %dim1 = memref.dim %alloc, %c1 : memref<?x?xf32>
  %out  = memref.alloc(%dim1, %dim0) : memref<?x?xf32>   // swapped dims
  scf.for %i = %c0 to %dim0 step %c1 {
    scf.for %j = %c0 to %dim1 step %c1 {
      %val = memref.load %alloc[%i, %j] : memref<?x?xf32>
      memref.store %val, %out[%j, %i] : memref<?x?xf32>  // swapped indices
    }
  }
  return %out : memref<?x?xf32>
}
```

Zero `mdarray.*` ops remain — all converted to standard `memref` + `scf` + `arith`.

---

## Repository Structure

This repository is the **LLVM monorepo** used as the base. The project-specific
code is entirely contained in one directory:

```
mlir/examples/MDArray/          ← ALL project code lives here
```

### What Was Added (New Files)

```
mlir/examples/MDArray/
├── README.md                   ← dialect-specific README
├── DESIGN.md                   ← design decisions + alternatives considered
├── IMPLEMENTATION.md           ← LLVM/MLIR API details (TableGen, DialectConversion)
├── EVALUATION.md               ← metrics, baseline comparison, test case table
├── REPORT.md                   ← full combined report (all deliverables)
│
├── scripts/
│   ├── build.sh                ← configure CMake + build mdarray-opt
│   └── run.sh                  ← run all 10 tests, print PASS/FAIL summary
│
├── include/MdArray/
│   ├── MdArrayDialect.td       ← [TableGen] dialect + base op class
│   ├── MdArrayDialect.h        ← [C++] dialect header (includes generated .inc)
│   ├── MdArrayOps.td           ← [TableGen] all 5 op definitions
│   ├── MdArrayOps.h            ← [C++] ops header
│   ├── MdArrayPasses.td        ← [TableGen] lowering pass declaration
│   └── MdArrayPasses.h         ← [C++] pass header
│
├── lib/MdArray/
│   ├── MdArrayDialect.cpp      ← dialect initialization
│   ├── MdArrayOps.cpp          ← op verifiers (one per op)
│   └── MdArrayPasses.cpp       ← ConversionPattern implementations (the lowering)
│
├── mdarray-opt/
│   └── mdarray-opt.cpp         ← CLI driver tool (registers dialect + pass)
│
└── test/
    ├── test_lowering.mlir      ← 5 passing tests (alloc/load/store/slice/transpose)
    └── test_failure_cases.mlir ← 5 verifier rejection tests (failure cases)
```

### What Was Modified in the Existing LLVM/MLIR Tree

Only **one line** was added to the existing MLIR codebase:

```
mlir/examples/CMakeLists.txt   ← added: add_subdirectory(MDArray)
```

Everything else in `mlir/`, `llvm/`, `clang/`, etc. is the unmodified upstream
LLVM monorepo.

---

## How to Build

### Prerequisites

- CMake ≥ 3.20
- Ninja
- C++17 compiler (GCC ≥ 9, Clang ≥ 11, or MSVC 2019+)
- ~10 GB disk space for the build

### Quick Build

```bash
cd mlir/examples/MDArray
chmod +x scripts/build.sh scripts/run.sh
./scripts/build.sh
```

This runs:
```
cmake -G Ninja -S <repo>/llvm -B <repo>/build \
      -DLLVM_ENABLE_PROJECTS="mlir"            \
      -DLLVM_TARGETS_TO_BUILD="host"           \
      -DCMAKE_BUILD_TYPE=Release
ninja mdarray-opt          # builds only our tool, not all of LLVM
```

Override the build directory:
```bash
BUILD_DIR=/path/to/build ./scripts/build.sh
```

---

## How to Run

```bash
cd mlir/examples/MDArray
./scripts/run.sh
```

Runs all 10 tests (5 passing lowerings + 5 verifier rejection cases) and prints
a PASS/FAIL summary. Exits 0 on success, 1 if any test fails.

### Manual single run

```bash
# From the build output directory:
./bin/mdarray-opt --convert-mdarray-to-memref \
    mlir/examples/MDArray/test/test_lowering.mlir
```

---

## Deliverables

| Deliverable | Location |
|-------------|----------|
| TableGen `.td` file (dialect + ops + pass) | `mlir/examples/MDArray/include/MdArray/` |
| C++ `ConversionPattern` per op | `mlir/examples/MDArray/lib/MdArray/MdArrayPasses.cpp` |
| Test `.mlir` file (5 ops + lowering) | `mlir/examples/MDArray/test/test_lowering.mlir` |
| Failure test cases | `mlir/examples/MDArray/test/test_failure_cases.mlir` |
| Report (progressive lowering vs LLVM) | `mlir/examples/MDArray/REPORT.md` |
| Design document | `mlir/examples/MDArray/DESIGN.md` |
| Implementation details | `mlir/examples/MDArray/IMPLEMENTATION.md` |
| Evaluation / metrics | `mlir/examples/MDArray/EVALUATION.md` |
| Build script | `mlir/examples/MDArray/scripts/build.sh` |
| Run script | `mlir/examples/MDArray/scripts/run.sh` |

---

## Key Concepts Demonstrated

### MLIR Progressive Lowering vs. LLVM Single-IR

| Aspect | LLVM IR | MLIR (this project) |
|--------|---------|---------------------|
| Abstraction levels | 1 (assembly-like) | Multiple (dialect hierarchy) |
| When tensor semantics are lost | Immediately at frontend | Preserved through lowering steps |
| Optimization opportunities | After all info discarded | At every dialect level |
| Transpose implementation | Manual GEP arithmetic in IR | `mdarray.transpose` → explicit loop nest |
| Extensibility | New instructions = LLVM patch | New ops = new dialect |

MLIR lets a single `mdarray.transpose` op lower to ~11 `memref`+`scf`+`arith` ops.
The programmer expresses intent; the compiler generates the mechanism.

### The DialectConversion Framework

The lowering pass uses three MLIR components:
1. **`TypeConverter`** — maps `tensor<?x?xf32>` → `memref<?x?xf32>`
2. **`OpConversionPattern<Op>`** — one pattern per MdArray op
3. **`ConversionTarget`** — marks MdArray ops illegal, memref/scf/arith legal

`applyPartialConversion` guarantees: either ALL illegal ops are eliminated, or
the pass fails loudly. No silent partial conversion.

---

## Test Results Summary (20 total)

### Passing lowering tests (`test/test_lowering.mlir`)

| # | Function | Ops Exercised |
|---|----------|--------------|
| 1 | `@test_alloc_load` | `alloc` + `load` |
| 2 | `@test_store_load` | `alloc` + `store` + `load` |
| 3 | `@test_slice` | `alloc` + `slice` |
| 4 | `@test_transpose` | `alloc` + `transpose` |
| 5 | `@test_combined` | All five ops together |
| 6 | `@test_1d_alloc_load` | Rank-1 tensor ops |
| 7 | `@test_i32_tensor` | i32 element type |
| 8 | `@test_slice_then_load` | `slice` result fed into `load` |
| 9 | `@test_double_transpose` | Two chained transposes |
| 10 | `@test_multiple_stores` | Two stores + one load |

### Verifier rejection tests (`test/test_failure_cases.mlir`)

| # | Violation | Expected Error |
|---|-----------|---------------|
| F1 | `alloc` — wrong dynamic size count | `expected 2 dynamic size(s)` |
| F2 | `load` — wrong index count | `expected 2 index operand(s)` |
| F3 | `store` — wrong index count | `expected 2 index operand(s)` |
| F4 | `slice` — wrong offset count | `expected 2 offset(s)` |
| F5 | `transpose` — 1-D input | `expected 2-D input tensor` |
| F6 | `slice` — wrong sizes count | `expected 2 size(s)` |
| F7 | `slice` — result element type mismatch (f64 vs f32) | `result element type 'f64' must match source element type 'f32'` |
| F8 | `transpose` — 3-D input | `expected 2-D input tensor, but got rank 3` |
| F9 | `alloc` — static tensor with dynamic sizes | `expected 0 dynamic size(s)` |
| F10 | `slice` — result rank mismatch (1 vs 2) | `result rank 1 must match source rank 2` |
