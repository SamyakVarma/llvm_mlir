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
