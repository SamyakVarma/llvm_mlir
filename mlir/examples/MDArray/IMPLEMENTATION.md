# MdArray Dialect — Implementation Details

## 1. File-by-File Breakdown

### TableGen files (`include/MdArray/`)

#### `MdArrayDialect.td`
Defines the dialect record and the base op class:

```tablegen
def MdArray_Dialect : Dialect {
    let name = "mdarray";
    let cppNamespace = "::mlir::mdarray";
}

class MdArray_Op<string mnemonic, list<Trait> traits = []> :
        Op<MdArray_Dialect, mnemonic, traits>;
```

The `cppNamespace` maps to the C++ namespace used in all generated headers and
the source files. Every op class inherits from `MdArray_Op`.

#### `MdArrayOps.td`
Defines all five operations. Key TableGen mechanisms used:

- **`Variadic<Index>`** — variable-length list of `index`-typed operands (for
  dynamic sizes, indices, offsets, sizes).
- **`TypesMatchWith`** — a static trait that enforces the value type matches
  the tensor element type at parse/verify time without writing extra C++.
- **`AttrSizedOperandSegments`** — required on `SliceOp` because it has two
  variadic operand groups; without it, the generated parser cannot tell where
  `offsets` end and `sizes` begin.
- **`assemblyFormat`** — declarative custom syntax. MLIR's `mlir-tblgen` tool
  generates the printer and parser from this string automatically.
- **`hasVerifier = 1`** — signals that `Op::verify()` is implemented in C++.

#### `MdArrayPasses.td`
Declares the conversion pass:

```tablegen
def ConvertMdArrayToMemRef : Pass<"convert-mdarray-to-memref", "::mlir::ModuleOp"> {
  let dependentDialects = [
    "mlir::memref::MemRefDialect", "mlir::arith::ArithDialect",
    "mlir::scf::SCFDialect",       "mlir::func::FuncDialect"
  ];
}
```

`mlir-tblgen --gen-pass-decls` generates the `ConvertMdArrayToMemRefBase` CRTP
base class, the pass registration function, and the pass pipeline CLI flag
`--convert-mdarray-to-memref`.

---

### Generated files (produced by CMake at build time)

| Generated file | Source | Content |
|---------------|--------|---------|
| `MdArrayOps.h.inc` | `MdArrayOps.td` | Op class declarations |
| `MdArrayOps.cpp.inc` | `MdArrayOps.td` | Op printer/parser/builders |
| `MdArrayOpsDialect.h.inc` | `MdArrayOps.td` | `MdArrayDialect` class declaration |
| `MdArrayOpsDialect.cpp.inc` | `MdArrayOps.td` | `MdArrayDialect::initialize()` body |
| `MdArrayPasses.h.inc` | `MdArrayPasses.td` | Pass base class + registration |

CMake integration uses `add_mlir_dialect(MdArrayOps mdarray)` which calls
`mlir-tblgen` with all required `--gen-*` flags automatically.

---

### C++ source files (`lib/MdArray/`)

#### `MdArrayDialect.cpp`
Minimal — registers all ops via the TableGen-generated op list:

```cpp
void MdArrayDialect::initialize() {
  addOperations<
#define GET_OP_LIST
#include "MdArray/MdArrayOps.cpp.inc"
  >();
}
```

#### `MdArrayOps.cpp`
Implements five `Op::verify()` methods. Each checks:
1. Operand counts match the tensor rank (for indexed ops).
2. Type compatibility (value type == element type for load/store).
3. Rank constraints (transpose requires exactly rank 2).

#### `MdArrayPasses.cpp`
The core of the implementation. Key MLIR APIs used:

**`TypeConverter`** (`MdArrayTypeConverter`):
```cpp
addConversion([](RankedTensorType type) -> Type {
  return MemRefType::get(type.getShape(), type.getElementType());
});
```
Converts `tensor<?x?xf32>` to `memref<?x?xf32>`. Source/target materializations
insert `unrealized_conversion_cast` ops at type boundaries.

**`OpConversionPattern<Op>`** — one subclass per MdArray op:

| Pattern | Key API calls |
|---------|--------------|
| `AllocOpLowering` | `memref::AllocOp::create(rewriter, loc, memrefType, dynamicSizes)` |
| `LoadOpLowering` | `memref::LoadOp::create(rewriter, loc, memref, indices)` |
| `StoreOpLowering` | `memref::StoreOp::create(rewriter, loc, value, memref, indices)` |
| `SliceOpLowering` | `memref::SubViewOp::create(...)` + optional `memref::CastOp::create(...)` |
| `TransposeOpLowering` | `memref::DimOp`, `memref::AllocOp`, `scf::ForOp`, `memref::LoadOp`, `memref::StoreOp` |

**`ConversionTarget`**:
```cpp
target.addIllegalDialect<MdArrayDialect>();    // all MdArray ops must go
target.addLegalDialect<memref::MemRefDialect>(); // target is legal
target.addDynamicallyLegalOp<func::FuncOp>([&](func::FuncOp op) {
  return typeConverter.isSignatureLegal(op.getFunctionType());
});
```

**`applyPartialConversion`**: Applies all patterns. Fails and calls
`signalPassFailure()` if any illegal op remains after the conversion.

---

## 2. CMake Build System

### In-tree build (as part of LLVM)

The `CMakeLists.txt` at the MDArray root handles both in-tree and out-of-tree
builds. When built in-tree:

```cmake
add_mlir_dialect(MdArrayOps mdarray)
```
This macro (from `AddMLIR.cmake`) runs `mlir-tblgen` to generate all `.inc` files
and creates the `MLIRMdArrayOpsIncGen` target.

```cmake
add_mlir_library(MLIRMdArray
  MdArrayDialect.cpp MdArrayOps.cpp MdArrayPasses.cpp
  LINK_LIBS PUBLIC MLIRMemRefDialect MLIRArithDialect MLIRSCFDialect
             MLIRFuncDialect MLIRTransforms MLIRPass
)
```

The tool target:
```cmake
add_llvm_executable(mdarray-opt mdarray-opt.cpp)
target_link_libraries(mdarray-opt PRIVATE MLIRMdArray MLIROptLib ...)
```

---

## 3. LLVM API Patterns Used

### `Op::create` static factory (MLIR ≥ 19)
All op creation uses the new `Op::create(rewriter, loc, ...)` pattern instead
of the deprecated `rewriter.create<Op>(loc, ...)`. This is the current MLIR
API convention.

### `OpAdaptor`
Each `matchAndRewrite` receives an `OpAdaptor` that provides already-converted
operands. For example, `adaptor.getTensor()` returns the converted `memref<>`
value rather than the original `tensor<>` value. This is how the conversion
framework threads type changes through the IR.

### `OpFoldResult` for subview
`memref::SubViewOp` expects `SmallVector<OpFoldResult>` for offsets/sizes/strides,
not raw `Value`. An `OpFoldResult` can be either a `Value` (dynamic) or an
`IntegerAttr` (static). Dynamic offsets are wrapped as `Value`; static strides
(always 1) use `rewriter.getIndexAttr(1)`.

### `scf::ForOp` construction
```cpp
auto loop = scf::ForOp::create(rewriter, loc, lb, ub, step);
rewriter.setInsertionPointToStart(loop.getBody());
Value iv = loop.getInductionVar();
```
This creates a for loop and positions the rewriter inside it. Nested loops are
built by calling `scf::ForOp::create` again while the insertion point is inside
the outer loop body.

---

## 4. Verifier Error Messages

Verifiers use `emitOpError()` which formats the error with the op location:

```
test_lowering.mlir:5:10: error: 'mdarray.alloc' op expected 2 dynamic size(s)
for result type 'tensor<?x?xf32>', but got 1
```

This is a standard MLIR diagnostic pattern — the framework captures the source
location from the op's `Location` attribute and prepends it automatically.

---

## 5. Testing: C → LLVM → MLIR → MdArray Lowering

Passing tests follow a multi-stage pipeline. Verifier failure tests remain
hand-written MLIR (`test/test_failure_cases.mlir`) because invalid mdarray IR
cannot be expressed through the C API.

### 5.1 Pipeline

```
test/src/*.c
    │  clang -S -emit-llvm -O0
    ▼
test/generated/*.ll              (LLVM IR)
    │  mlir-translate --import-llvm
    ▼
test/generated/*.llvm.mlir       (MLIR llvm dialect)
    │  scripts/ll_to_mdarray.py
    ▼
test/generated/*.mdarray.mlir    (MdArray dialect)
    │  mdarray-opt --convert-mdarray-to-memref
    ▼
MemRef + SCF MLIR
```

| Stage | Tool | Role |
|-------|------|------|
| 1 | `clang` | Compile normal C to LLVM IR (`@malloc`, loads/stores, loops) |
| 2 | `mlir-translate --import-llvm` | Import LLVM IR into MLIR's `llvm` dialect |
| 3 | `ll_to_mdarray.py` | Raise LLVM IR semantics to `mdarray.*` ops |
| 4 | `mdarray-opt --convert-mdarray-to-memref` | Lower MdArray dialect to MemRef + SCF |

Stage 3 is the bridge from generic LLVM IR to the custom dialect. Normal C uses
`malloc`, pointer indexing, and loops — Clang does not emit mdarray ops. The
bridge script checks for `@malloc` in the LLVM IR and maps each test function
to equivalent mdarray operations (matching the C semantics).

### 5.2 Example

C source (`test/src/test_alloc_load.c`):

```c
#include <stdlib.h>
#include <stdint.h>

float test_alloc_load(int64_t n, int64_t m, int64_t i, int64_t j) {
  float *a = (float *)malloc((size_t)(n * m) * sizeof(float));
  return a[i * m + j];
}
```

Generated MdArray MLIR:

```mlir
func.func @test_alloc_load(%arg0: index, %arg1: index, %arg2: index, %arg3: index) -> f32 {
  %0 = mdarray.alloc(%arg0, %arg1) : tensor<?x?xf32>
  %1 = mdarray.load %0[%arg2, %arg3] : tensor<?x?xf32> -> f32
  return %1 : f32
}
```

After lowering, all `mdarray.*` ops are replaced with `memref.*` and `scf.*`.

### 5.3 Running Tests

```bash
cd mlir/examples/MDArray
./scripts/build.sh    # builds mdarray-opt + mlir-translate
./scripts/run.sh      # runs full pipeline for all 10 passing tests
```

`test/test_lowering.mlir` is retained as a reference for the expected MdArray
IR. The automated pipeline generates equivalent IR from C at run time.
