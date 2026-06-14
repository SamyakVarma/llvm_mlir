# MdArray Dialect: Implementation Report

## Table of Contents
1. [Project Overview](#1-project-overview)
2. [Architecture & File Structure](#2-architecture--file-structure)
3. [Deliverable (a): Custom Dialect Definition](#3-deliverable-a-custom-dialect-definition)
4. [Deliverable (b): TableGen Definitions](#4-deliverable-b-tablegen-definitions)
5. [Deliverable (c): Conversion Pass (MdArray → MemRef)](#5-deliverable-c-conversion-pass-mdarray--memref)
6. [Deliverable (d): Test Program](#6-deliverable-d-test-program)
7. [Report: MLIR Progressive Lowering vs. LLVM Single-IR Model](#7-report-mlir-progressive-lowering-vs-llvm-single-ir-model)
8. [Build & Run Instructions](#8-build--run-instructions)

---

## 1. Project Overview

This project implements a custom MLIR dialect called **MdArray** (Multi-Dimensional
Array) that provides high-level operations for tensor manipulation. The dialect
includes five core operations — `alloc`, `load`, `store`, `slice`, and `transpose`
— and a lowering pass that converts them all into MLIR's standard `memref` dialect.

The implementation is structured as an in-tree MLIR example under
`mlir/examples/MDArray/`, following the same conventions as the existing
`standalone` example dialect.

---

## 2. Architecture & File Structure

```
mlir/examples/MDArray/
├── CMakeLists.txt                          # Root CMake (project setup, include paths)
├── REPORT.md                               # This report
│
├── include/
│   ├── CMakeLists.txt                      # Routes to MdArray subdirectory
│   └── MdArray/
│       ├── CMakeLists.txt                  # TableGen code generation rules
│       ├── MdArrayDialect.td               # [TD] Dialect definition
│       ├── MdArrayDialect.h                # [C++] Dialect header
│       ├── MdArrayOps.td                   # [TD] All 5 operation definitions
│       ├── MdArrayOps.h                    # [C++] Ops header
│       ├── MdArrayPasses.td                # [TD] Lowering pass definition
│       └── MdArrayPasses.h                 # [C++] Pass header
│
├── lib/
│   ├── CMakeLists.txt                      # Routes to MdArray subdirectory
│   └── MdArray/
│       ├── CMakeLists.txt                  # Library build rules + link deps
│       ├── MdArrayDialect.cpp              # Dialect initialization
│       ├── MdArrayOps.cpp                  # Op verifiers + builders
│       └── MdArrayPasses.cpp               # ** THE LOWERING PASS **
│
├── mdarray-opt/
│   ├── CMakeLists.txt                      # Tool build rules
│   └── mdarray-opt.cpp                     # CLI driver tool
│
└── test/
    └── test_lowering.mlir                  # Test IR showing all 5 ops + lowering
```

---

## 3. Deliverable (a): Custom Dialect Definition

### Dialect: `mdarray`

Defined in `MdArrayDialect.td`, the dialect is registered under the name
`"mdarray"` with C++ namespace `::mlir::mdarray`.

### Operations

| Operation | Syntax | Description |
|-----------|--------|-------------|
| `mdarray.alloc` | `mdarray.alloc(%n, %m) : tensor<?x?xf32>` | Allocates a dynamically-shaped multi-dimensional array |
| `mdarray.load` | `mdarray.load %t[%i, %j] : tensor<?x?xf32> -> f32` | Loads a scalar element from the array at given indices |
| `mdarray.store` | `mdarray.store %v, %t[%i, %j] : tensor<?x?xf32>` | Stores a scalar value into the array at given indices |
| `mdarray.slice` | `mdarray.slice %t[%o0,%o1][%s0,%s1] : tensor<?x?xf32> -> tensor<?x?xf32>` | Extracts a contiguous sub-region (offsets + sizes) |
| `mdarray.transpose` | `mdarray.transpose %t : tensor<?x?xf32> -> tensor<?x?xf32>` | Transposes a 2-D array by swapping dimensions |

All operations use **ranked tensor types** (`tensor<?x?xf32>`) at the MdArray
level. The type converter in the lowering pass maps these to `memref<?x?xf32>`.

### Verification

Each operation has a custom verifier (implemented in `MdArrayOps.cpp`) that checks:

- **AllocOp**: Number of dynamic size operands matches the number of dynamic
  dimensions in the result tensor type.
- **LoadOp**: Index count matches tensor rank; result element type matches
  the tensor's element type.
- **StoreOp**: Index count matches tensor rank; stored value type matches
  the tensor's element type.
- **SliceOp**: Offset and size counts both match the source rank; result rank
  equals source rank; element types match.
- **TransposeOp**: Both input and result must be exactly 2-D; element types match.

---

## 4. Deliverable (b): TableGen Definitions

Three `.td` files define the dialect:

### `MdArrayDialect.td`
- Defines the `MdArray_Dialect` record with name `"mdarray"`.
- Defines the base operation class `MdArray_Op<mnemonic, traits>`.

### `MdArrayOps.td`
- Defines all five operations with:
  - `arguments` and `results` specifying operand/result types.
  - `assemblyFormat` for the custom textual syntax.
  - `hasVerifier = 1` enabling the C++ verifier hooks.
  - `description` blocks with usage examples.

### `MdArrayPasses.td`
- Defines the `ConvertMdArrayToMemRef` pass that operates on `ModuleOp`.
- Declares dependent dialects: `MemRefDialect`, `ArithDialect`, `SCFDialect`,
  `FuncDialect`.

### CMake TableGen Integration
The `include/MdArray/CMakeLists.txt` invokes:
- `add_mlir_dialect(MdArrayOps mdarray)` — generates `MdArrayOps.h.inc`,
  `MdArrayOps.cpp.inc`, `MdArrayOpsDialect.h.inc`, `MdArrayOpsDialect.cpp.inc`.
- `mlir_tablegen(MdArrayPasses.h.inc --gen-pass-decls)` — generates the pass
  declaration and registration boilerplate.

---

## 5. Deliverable (c): Conversion Pass (MdArray → MemRef)

The lowering pass is implemented in `MdArrayPasses.cpp` using MLIR's
**DialectConversion** framework. It consists of three major components:

### 5.1 Type Converter (`MdArrayTypeConverter`)

Converts `RankedTensorType` → `MemRefType` with identical shape and element type:
```
tensor<?x?xf32>  →  memref<?x?xf32>
```
Source and target materializations insert `unrealized_conversion_cast` ops
at conversion boundaries.

### 5.2 Conversion Patterns (one per op)

| Pattern | Source Op | Target Op(s) |
|---------|----------|--------------|
| `AllocOpLowering` | `mdarray.alloc` | `memref.alloc` |
| `LoadOpLowering` | `mdarray.load` | `memref.load` |
| `StoreOpLowering` | `mdarray.store` | `memref.store` |
| `SliceOpLowering` | `mdarray.slice` | `memref.subview` + `memref.cast` |
| `TransposeOpLowering` | `mdarray.transpose` | `memref.alloc` + `memref.dim` + `scf.for` nest + `memref.load/store` |
| `FuncOpConversion` | `func.func` | `func.func` (with converted signature) |
| `ReturnOpConversion` | `func.return` | `func.return` (with converted operands) |

#### Transpose Lowering (most complex)

The transpose is lowered to an explicit element-wise copy with swapped indices:

```
// Input: NxM memref
%d0 = memref.dim %input, 0          // N
%d1 = memref.dim %input, 1          // M
%output = memref.alloc(%d1, %d0)    // MxN (swapped)
scf.for %i = 0 to %d0 step 1 {
  scf.for %j = 0 to %d1 step 1 {
    %val = memref.load %input[%i, %j]
    memref.store %val, %output[%j, %i]   // swapped indices
  }
}
```

#### Slice Lowering

The slice is lowered to `memref.subview` with unit strides. Since `subview`
may produce a strided layout type, a `memref.cast` is inserted if needed to
match the expected unstrided result type.

### 5.3 Conversion Target

The pass declares:
- **Illegal**: The entire `MdArray` dialect (all ops must be converted).
- **Legal**: `memref`, `arith`, `scf` dialects.
- **Dynamically Legal**: `func.func` (legal only when signature types are
  already converted); `func.return` (legal only when operand types are
  already converted).

### 5.4 Function Signature Conversion

Two additional patterns (`FuncOpConversion`, `ReturnOpConversion`) handle
converting function argument and return types from `tensor` to `memref`.
This is crucial because MdArray functions accept/return tensors but the
lowered IR must traffic in memrefs.

---

## 6. Deliverable (d): Test Program

The test file `test/test_lowering.mlir` contains 5 test functions:

| Test | What it exercises |
|------|-------------------|
| `@test_alloc_load` | `alloc` + `load` (basic allocation and element access) |
| `@test_store_load` | `alloc` + `store` + `load` (write then read-back) |
| `@test_slice` | `alloc` + `slice` (sub-region extraction) |
| `@test_transpose` | `alloc` + `transpose` (dimension swapping) |
| `@test_combined` | `alloc` + `store` + `transpose` + `load` (realistic pipeline) |

### Running the test:

```bash
# From the build directory, after building:
./bin/mdarray-opt --convert-mdarray-to-memref \
    ../mlir/examples/MDArray/test/test_lowering.mlir
```

### 6.1 System Workflow
The test suite operates through `mdarray-opt`, the MLIR CLI driver. The workflow is as follows:
1. **Parsing**: The MLIR parser reads `test_lowering.mlir` and constructs the in-memory MLIR Module, identifying `mdarray` operations.
2. **Pass Execution**: Invoking `--convert-mdarray-to-memref` triggers the `ConvertMdArrayToMemRef` conversion pass.
3. **Pattern Rewriting**: The `DialectConversion` infrastructure sequentially matches `mdarray` ops and executes their rewrite patterns to emit `memref` and `scf` operations.
4. **Validation & Output**: The transformed IR is validated by target dialect verifiers and emitted to standard output.

### 6.2 Core MLIR/LLVM APIs Utilized
To facilitate the tests and the lowering pass they validate, several core MLIR APIs are engaged:
- **`mlir::ConversionPatternRewriter`**: Manages the safe insertion, deletion, and replacement of operations during the lowering of the test cases.
- **`mlir::TypeConverter`**: Automatically converts `tensor<?x?xf32>` used in the test signatures to `memref<?x?xf32>`.
- **`mlir::OpAdaptor`**: Retrieves the newly converted operands (like memrefs) when lowering ops like `mdarray.store` and `mdarray.load`.
- **`mlir::DialectConversion`**: The umbrella framework evaluating target legality and resolving type conflicts via `unrealized_conversion_cast`.

### 6.3 Handling Special Cases
The test program purposefully exercises several edge cases:
- **Dynamic Shapes**: All tests use `?x?` dimensions, ensuring the lowering patterns can process dynamic, runtime-defined extents using `memref.dim`.
- **Type Casting in Slices**: In `@test_slice`, `memref.subview` might yield a strided layout. The lowering handles this by inserting a `memref.cast` to safely bridge back to the expected contiguous type.
- **Multi-Op Chains**: `@test_combined` tests transitive lowering, ensuring that a memref yielded by the transposed loop nest properly flows into the subsequent `load` operation.

### 6.4 Final Results
When executing `test_lowering.mlir`, the pass successfully achieves full progressive lowering:
- High-level tensor allocations and memory accesses map cleanly to `memref.alloc`, `memref.load`, and `memref.store`.
- The complex `@test_transpose` operation expands correctly into a `memref.alloc` target buffer and an `scf.for` nested loop that performs coordinate-swapped element copies.
- Function signatures systematically transition from accepting and returning `tensor`s to `memref`s.
- Zero `mdarray` operations remain in the output IR, indicating a complete conversion.

### 6.5 Limitations of Implementation
While the tests prove the correctness of the conversion, there are some clear limitations in the current implementation:
- **Element Type Restriction**: The tests and dialect operations currently assume `f32` (32-bit float) data types exclusively.
- **Rank Limitations**: The `mdarray.transpose` operation is hardcoded to support only 2-D arrays. Support for N-D permutation is not implemented.
- **Memory Management**: The lowered IR performs `memref.alloc` but lacks corresponding `memref.dealloc` calls. In a full compilation pipeline (down to LLVM IR and binary), this would result in memory leaks. An additional bufferization or deallocation pass would be required.
- **Suboptimal Transpose**: The generated loop nest for `transpose` is a naive copy. It does not employ advanced optimizations like cache tiling or vectorization, leaving performance on the table.

---

## 7. Report: MLIR Progressive Lowering vs. LLVM Single-IR Model

### 7.1 LLVM's Single-IR Model

LLVM uses a **single, monolithic intermediate representation** (LLVM IR) for all
optimizations and code generation:

- **One IR level**: All frontends (Clang, Rust, Swift, etc.) lower to the same
  LLVM IR, which has a fixed set of types (integers, floats, pointers, vectors)
  and instructions (add, load, store, branch, etc.).
- **Fixed abstraction level**: LLVM IR sits at roughly the level of C — it has
  no concept of tensors, loops-as-values, or domain-specific types.
- **All-at-once lowering**: A frontend must lower high-level constructs (e.g.,
  Python list comprehensions, Fortran array slicing) all the way down to LLVM IR
  in one step. There is no intermediate stopping point.
- **Optimization happens at one level**: All optimization passes operate on the
  same IR. High-level semantic information (e.g., "this is a matrix multiply")
  is lost during the single lowering step.

### 7.2 MLIR's Progressive (Multi-Level) Lowering Model

MLIR takes a fundamentally different approach with **multiple levels of
abstraction coexisting in the same infrastructure**:

- **Dialect hierarchy**: Instead of one IR, MLIR has a system of **dialects**,
  each capturing a specific level of abstraction. For example:
  ```
  Custom dialect (e.g., MdArray)      ← highest level, domain-specific
       ↓
  linalg / tensor dialect             ← structured linear algebra operations
       ↓
  memref / scf / affine dialect       ← memory references and loops
       ↓
  LLVM dialect                        ← 1:1 mapping to LLVM IR
       ↓
  Machine code                        ← final target
  ```

- **Gradual lowering**: Instead of jumping from high-level source to low-level
  IR in one step, MLIR lowers **progressively** through intermediate dialects.
  Each lowering step removes one layer of abstraction while preserving others.

- **Optimization at every level**: Because higher-level semantics are preserved
  in intermediate dialects, optimizations can be applied at the most appropriate
  level. For example:
  - **Matrix multiply fusion** can happen at the `linalg` level where the
    operation structure is explicit.
  - **Loop tiling** can happen at the `affine` or `scf` level.
  - **Register allocation** can happen at the LLVM level.

- **Mixed dialects**: MLIR allows operations from **different dialects to coexist
  in the same module**. A function can contain both `mdarray.alloc` and
  `memref.load` during an intermediate lowering step. This is key to incremental,
  partial lowering.

### 7.3 How This Project Demonstrates Progressive Lowering

This MdArray implementation is a concrete example of one lowering step in the
MLIR pipeline:

```
              MdArray Dialect                    MemRef + SCF Dialects
        ┌──────────────────────┐           ┌──────────────────────────────┐
        │  mdarray.alloc       │           │  memref.alloc                │
        │  mdarray.load        │    →      │  memref.load                 │
        │  mdarray.store       │  (pass)   │  memref.store                │
        │  mdarray.slice       │           │  memref.subview              │
        │  mdarray.transpose   │           │  memref.alloc + scf.for nest │
        └──────────────────────┘           └──────────────────────────────┘
```

In a real ML compiler pipeline, there would be additional lowering steps:
1. **PyTorch/TF Frontend** → Custom high-level dialect (like MdArray)
2. **Custom dialect** → `linalg` / `tensor` (structured ops)
3. **linalg** → `memref` + `scf` / `affine` (loops + memory) ← **we did this step**
4. **memref + scf** → `LLVM` dialect
5. **LLVM dialect** → LLVM IR → machine code

### 7.4 Key Advantages of Progressive Lowering

| Aspect | LLVM (Single-IR) | MLIR (Progressive) |
|--------|-------------------|---------------------|
| **Abstraction preservation** | High-level semantics lost immediately | Semantics preserved at each level |
| **Optimization opportunities** | Only at one IR level | At every intermediate level |
| **Domain-specific passes** | Must encode in low-level patterns | Natural at the right abstraction |
| **Reuse across domains** | Limited (same IR for everything) | Dialects shared across projects |
| **Debugging** | Hard to trace back to source | Intermediate IRs aid debugging |
| **Extensibility** | Adding new types/ops is difficult | Dialects are plug-and-play |

### 7.5 The DialectConversion Framework

MLIR provides the `DialectConversion` framework (used in this project) to
systematically implement lowering passes:

1. **TypeConverter**: Defines how types from the source dialect map to the
   target dialect (e.g., `tensor<?x?xf32>` → `memref<?x?xf32>`).

2. **ConversionPattern**: One pattern per source operation, defining how to
   rewrite it using target operations. The `OpAdaptor` provides access to
   already-converted operands.

3. **ConversionTarget**: Declares which ops/dialects are legal (target) and
   which are illegal (must be converted). Supports dynamic legality checks.

4. **applyPartialConversion**: The driver that applies all patterns, handling
   the complexity of mixed-dialect IR during the conversion process.

This framework ensures that lowering is **correct by construction** — the pass
either converts all illegal operations or reports failure, preventing partially-
lowered IR from silently escaping.

---

## 8. Build & Run Instructions

### Prerequisites
- LLVM/MLIR built from source (this project is in-tree under `mlir/examples/`)
- CMake ≥ 3.20, C++17 compiler

### Build (in-tree, as part of the LLVM build)

The `MDArray` example is already registered in `mlir/examples/CMakeLists.txt`:
```cmake
add_subdirectory(MDArray)
```

To build:
```bash
cd llvm-project/build
cmake -G Ninja ../llvm \
  -DLLVM_ENABLE_PROJECTS="mlir" \
  -DLLVM_TARGETS_TO_BUILD="host" \
  -DCMAKE_BUILD_TYPE=Release
ninja mdarray-opt
```

### Run the lowering pass on the test file:
```bash
./bin/mdarray-opt --convert-mdarray-to-memref \
    ../mlir/examples/MDArray/test/test_lowering.mlir
```

### output:
All `mdarray.*` operations are replaced with `memref.*`, `scf.*`, and
`arith.*` operations. Function signatures change from `tensor<...>` to
`memref<...>`.

---
