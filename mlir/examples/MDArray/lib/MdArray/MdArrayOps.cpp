//===- MdArrayOps.cpp - MdArray dialect ops ----------------------*- C++ -*-===//
//
// This file is licensed under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#include "MdArray/MdArrayOps.h"
#include "MdArray/MdArrayDialect.h"
#include "mlir/IR/Builders.h"
#include "mlir/IR/OpImplementation.h"

using namespace mlir;
using namespace mlir::mdarray;

//===----------------------------------------------------------------------===//
// AllocOp verification
//===----------------------------------------------------------------------===//

LogicalResult AllocOp::verify() {
  auto tensorType = llvm::cast<RankedTensorType>(getResult().getType());

  // The number of dynamic sizes provided must match the number of dynamic
  // dimensions in the result tensor type.
  int64_t numDynamic = tensorType.getNumDynamicDims();
  if (static_cast<int64_t>(getDynamicSizes().size()) != numDynamic)
    return emitOpError("expected ")
           << numDynamic << " dynamic size(s) for result type "
           << tensorType << ", but got " << getDynamicSizes().size();

  return success();
}

//===----------------------------------------------------------------------===//
// LoadOp verification
//===----------------------------------------------------------------------===//

LogicalResult LoadOp::verify() {
  auto tensorType = llvm::cast<RankedTensorType>(getTensor().getType());

  // Number of indices must match the tensor rank.
  if (static_cast<int64_t>(getIndices().size()) != tensorType.getRank())
    return emitOpError("expected ")
           << tensorType.getRank() << " index operand(s) for tensor of rank "
           << tensorType.getRank() << ", but got " << getIndices().size();

  // Result element type must match the tensor element type.
  if (getResult().getType() != tensorType.getElementType())
    return emitOpError("result type ")
           << getResult().getType()
           << " does not match tensor element type "
           << tensorType.getElementType();

  return success();
}

//===----------------------------------------------------------------------===//
// StoreOp verification
//===----------------------------------------------------------------------===//

LogicalResult StoreOp::verify() {
  auto tensorType = llvm::cast<RankedTensorType>(getTensor().getType());

  // Number of indices must match the tensor rank.
  if (static_cast<int64_t>(getIndices().size()) != tensorType.getRank())
    return emitOpError("expected ")
           << tensorType.getRank() << " index operand(s) for tensor of rank "
           << tensorType.getRank() << ", but got " << getIndices().size();

  // Value type must match the tensor element type.
  if (getValue().getType() != tensorType.getElementType())
    return emitOpError("value type ")
           << getValue().getType()
           << " does not match tensor element type "
           << tensorType.getElementType();

  return success();
}

//===----------------------------------------------------------------------===//
// SliceOp verification and builder
//===----------------------------------------------------------------------===//

LogicalResult SliceOp::verify() {
  auto sourceType = llvm::cast<RankedTensorType>(getSource().getType());
  auto resultType = llvm::cast<RankedTensorType>(getResult().getType());
  int64_t rank = sourceType.getRank();

  // Offsets and sizes must each match the source rank.
  if (static_cast<int64_t>(getOffsets().size()) != rank)
    return emitOpError("expected ")
           << rank << " offset(s) for source tensor of rank " << rank
           << ", but got " << getOffsets().size();

  if (static_cast<int64_t>(getSizes().size()) != rank)
    return emitOpError("expected ")
           << rank << " size(s) for source tensor of rank " << rank
           << ", but got " << getSizes().size();

  // Source and result must have the same rank.
  if (resultType.getRank() != rank)
    return emitOpError("result rank ")
           << resultType.getRank() << " must match source rank " << rank;

  // Element types must match.
  if (resultType.getElementType() != sourceType.getElementType())
    return emitOpError("result element type ")
           << resultType.getElementType()
           << " must match source element type "
           << sourceType.getElementType();

  return success();
}

//===----------------------------------------------------------------------===//
// TransposeOp verification
//===----------------------------------------------------------------------===//

LogicalResult TransposeOp::verify() {
  auto inputType = llvm::cast<RankedTensorType>(getInput().getType());
  auto resultType = llvm::cast<RankedTensorType>(getResult().getType());

  // Only 2-D tensors are supported.
  if (inputType.getRank() != 2)
    return emitOpError("expected 2-D input tensor, but got rank ")
           << inputType.getRank();

  if (resultType.getRank() != 2)
    return emitOpError("expected 2-D result tensor, but got rank ")
           << resultType.getRank();

  // Element types must match.
  if (resultType.getElementType() != inputType.getElementType())
    return emitOpError("result element type ")
           << resultType.getElementType()
           << " must match input element type "
           << inputType.getElementType();

  return success();
}

//===----------------------------------------------------------------------===//
// TableGen generated op definitions
//===----------------------------------------------------------------------===//

#define GET_OP_CLASSES
#include "MdArray/MdArrayOps.cpp.inc"
