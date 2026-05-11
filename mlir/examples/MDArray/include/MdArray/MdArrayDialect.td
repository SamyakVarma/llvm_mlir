#ifndef MDARRAY_DIALECT
#define MDARRAY_DIALECT

include "mlir/IR/OpBase.td"

def MdArray_Dialect : Dialect {
    let name = "mdarray";
    let summary = "A dialect for multi-dimensional array operations.";
    let description = [{
        The MdArray dialect provides high-level operations for working with
        multi-dimensional arrays (tensors). It includes operations for
        allocation, element access, slicing, and transposition. These
        operations are designed to be progressively lowered to MLIR's
        standard memref dialect through a conversion pass.

        This dialect mimics how ML framework frontends (e.g., TensorFlow,
        PyTorch) lower high-level tensor operations to MLIR's dialect
        hierarchy.
    }];
    let cppNamespace = "::mlir::mdarray";
}

class MdArray_Op<string mnemonic, list<Trait> traits = []> :
        Op<MdArray_Dialect, mnemonic, traits>;

#endif // MDARRAY_DIALECT
