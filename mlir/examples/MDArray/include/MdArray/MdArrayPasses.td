#ifndef MDARRAY_PASS
#define MDARRAY_PASS

include "mlir/Pass/PassBase.td"

def ConvertMdArrayToMemRef : Pass<"convert-mdarray-to-memref", "::mlir::ModuleOp"> {
  let summary = "Lower MdArray dialect ops to the MemRef dialect.";
  let description = [{
    This pass converts operations from the MdArray dialect into equivalent
    operations using MLIR's built-in MemRef dialect. This demonstrates
    MLIR's progressive lowering approach:

      mdarray.alloc  -> memref.alloc
      mdarray.load   -> memref.load
      mdarray.store  -> memref.store
      mdarray.slice  -> memref.subview
      mdarray.transpose -> memref.alloc + scf.for loops (copy with transposed indices)

    After this pass, all MdArray operations are eliminated and the IR
    uses only standard MLIR dialects (memref, arith, scf, func).
  }];

  let dependentDialects = [
    "mlir::memref::MemRefDialect",
    "mlir::arith::ArithDialect",
    "mlir::scf::SCFDialect",
    "mlir::func::FuncDialect"
  ];
}

#endif // MDARRAY_PASS
