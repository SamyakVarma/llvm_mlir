#ifndef MDARRAY_OPS
#define MDARRAY_OPS

include "MdArray/MdArrayDialect.td"
include "mlir/Interfaces/SideEffectInterfaces.td"

def MdArray_AllocOp : MdArray_Op<"alloc"> {
    let summary = "Allocate a multi-dimensional array.";
    let description = [{
        The `mdarray.alloc` operation allocates a new multi-dimensional array
        with the given dynamic dimensions. The result is a ranked tensor type
        with dynamic shape.

        Example:
        ```mlir
        %0 = mdarray.alloc(%n, %m) : tensor<?x?xf32>
        ```
    }];

    let arguments = (ins Variadic<Index>:$dynamicSizes);
    let results = (outs AnyRankedTensor:$result);

    let assemblyFormat = [{
        `(` $dynamicSizes `)` attr-dict `:` type($result)
    }];

    let hasVerifier = 1;
}

//===----------------------------------------------------------------------===//
// MdArray_StoreOp
//===----------------------------------------------------------------------===//

def MdArray_StoreOp : MdArray_Op<"store", [
  TypesMatchWith<"value type matches tensor element type",
                 "tensor", "value",
                 "llvm::cast<RankedTensorType>($_self).getElementType()">
]> {
    let summary = "Store a value into a multi-dimensional array element.";
    let description = [{
        The `mdarray.store` operation stores a scalar value into the element
        of a multi-dimensional array at the given indices.

        Example:
        ```mlir
        mdarray.store %val, %tensor[%i, %j] : tensor<?x?xf32>
        ```
    }];

    let arguments = (ins
        AnyType:$value,
        AnyRankedTensor:$tensor,
        Variadic<Index>:$indices
    );
    let results = (outs);

    let assemblyFormat = [{
        $value `,` $tensor `[` $indices `]` attr-dict `:` type($tensor)
    }];

    let hasVerifier = 1;
}

//===----------------------------------------------------------------------===//
// MdArray_LoadOp
//===----------------------------------------------------------------------===//

def MdArray_LoadOp : MdArray_Op<"load", [
  TypesMatchWith<"result type matches tensor element type",
                 "tensor", "result",
                 "llvm::cast<RankedTensorType>($_self).getElementType()">
]> {
    let summary = "Load a value from a multi-dimensional array element.";
    let description = [{
        The `mdarray.load` operation extracts a scalar value from the element
        of a multi-dimensional array at the given indices.

        Example:
        ```mlir
        %val = mdarray.load %tensor[%i, %j] : tensor<?x?xf32> -> f32
        ```
    }];

    let arguments = (ins
        AnyRankedTensor:$tensor,
        Variadic<Index>:$indices
    );
    let results = (outs AnyType:$result);

    let assemblyFormat = [{
        $tensor `[` $indices `]` attr-dict `:` type($tensor) `->` type($result)
    }];

    let hasVerifier = 1;
}

//===----------------------------------------------------------------------===//
// MdArray_SliceOp
//===----------------------------------------------------------------------===//

def MdArray_SliceOp : MdArray_Op<"slice", [AttrSizedOperandSegments]> {
    let summary = "Extract a sub-array (slice) from a multi-dimensional array.";
    let description = [{
        The `mdarray.slice` operation extracts a contiguous sub-region from
        a multi-dimensional array. Offsets and sizes are specified per
        dimension. Strides are assumed to be 1.

        Example:
        ```mlir
        %1 = mdarray.slice %0[%off0, %off1][%sz0, %sz1]
             : tensor<?x?xf32> -> tensor<?x?xf32>
        ```
    }];

    let arguments = (ins
        AnyRankedTensor:$source,
        Variadic<Index>:$offsets,
        Variadic<Index>:$sizes
    );
    let results = (outs AnyRankedTensor:$result);

    let assemblyFormat = [{
        $source `[` $offsets `]` `[` $sizes `]` attr-dict
        `:` type($source) `->` type($result)
    }];

    let hasVerifier = 1;
}

//===----------------------------------------------------------------------===//
// MdArray_TransposeOp
//===----------------------------------------------------------------------===//

def MdArray_TransposeOp : MdArray_Op<"transpose"> {
    let summary = "Transpose a 2-D multi-dimensional array.";
    let description = [{
        The `mdarray.transpose` operation transposes a 2-D array by swapping
        its two dimensions.

        Example:
        ```mlir
        // %0 : tensor<?x?xf32>  (NxM)
        %1 = mdarray.transpose %0 : tensor<?x?xf32> -> tensor<?x?xf32>
        // %1 : tensor<?x?xf32>  (MxN)
        ```
    }];

    let arguments = (ins AnyRankedTensor:$input);
    let results = (outs AnyRankedTensor:$result);

    let assemblyFormat = [{
        $input attr-dict `:` type($input) `->` type($result)
    }];

    let hasVerifier = 1;
}

#endif // MDARRAY_OPS
