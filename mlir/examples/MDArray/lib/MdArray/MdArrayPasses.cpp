//===- MdArrayPasses.cpp - MdArray to MemRef lowering pass -------*- C++ -*-===//
//
// This file is licensed under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// This file implements the conversion pass that lowers MdArray dialect
// operations to the standard MemRef dialect. Each MdArray op has a
// corresponding ConversionPattern:
//
//   mdarray.alloc     -> memref.alloc
//   mdarray.load      -> memref.load
//   mdarray.store     -> memref.store
//   mdarray.slice     -> memref.subview
//   mdarray.transpose -> memref.alloc + scf.for nest (copy with swapped indices)
//
// This demonstrates MLIR's progressive lowering approach where high-level
// domain-specific ops are converted step-by-step into lower-level dialects.
//
//===----------------------------------------------------------------------===//

#include "MdArray/MdArrayDialect.h"
#include "MdArray/MdArrayOps.h"
#include "MdArray/MdArrayPasses.h"

#include "mlir/Dialect/Arith/IR/Arith.h"
#include "mlir/Dialect/Func/IR/FuncOps.h"
#include "mlir/Dialect/MemRef/IR/MemRef.h"
#include "mlir/Dialect/SCF/IR/SCF.h"
#include "mlir/IR/BuiltinOps.h"
#include "mlir/IR/PatternMatch.h"
#include "mlir/Pass/Pass.h"
#include "mlir/Transforms/DialectConversion.h"

using namespace mlir;
using namespace mlir::mdarray;

namespace mlir::mdarray {
#define GEN_PASS_DEF_CONVERTMDARRAYTOMEMREF
#include "MdArray/MdArrayPasses.h.inc"
} // namespace mlir::mdarray

//===----------------------------------------------------------------------===//
// Type Converter: tensor<?x?xf32> -> memref<?x?xf32>
//===----------------------------------------------------------------------===//

namespace {

/// Converts ranked tensor types to memref types. All other types are kept
/// as-is. This is the key type conversion that makes the dialect lowering
/// work: MdArray ops traffic in tensor types, while memref ops traffic in
/// memref types.
class MdArrayTypeConverter : public TypeConverter {
public:
  MdArrayTypeConverter() {
    // Keep non-tensor types unchanged.
    addConversion([](Type type) { return type; });

    // Convert RankedTensorType -> MemRefType with the same shape and
    // element type.
    addConversion([](RankedTensorType type) -> Type {
      return MemRefType::get(type.getShape(), type.getElementType());
    });

    // Materialization: if a converted value needs to be used where a tensor
    // is expected (e.g., at function boundaries), insert an unrealized cast.
    addTargetMaterialization(
        [](OpBuilder &builder, Type type, ValueRange inputs,
           Location loc) -> Value {
          return UnrealizedConversionCastOp::create(builder, loc, type, inputs)
              .getResult(0);
        });
    addSourceMaterialization(
        [](OpBuilder &builder, Type type, ValueRange inputs,
           Location loc) -> Value {
          return UnrealizedConversionCastOp::create(builder, loc, type, inputs)
              .getResult(0);
        });
  }
};

//===----------------------------------------------------------------------===//
// Conversion Patterns
//===----------------------------------------------------------------------===//

/// Lower mdarray.alloc -> memref.alloc
///
/// mdarray.alloc(%n, %m) : tensor<?x?xf32>
/// becomes:
/// memref.alloc(%n, %m) : memref<?x?xf32>
struct AllocOpLowering : public OpConversionPattern<AllocOp> {
  using OpConversionPattern<AllocOp>::OpConversionPattern;

  LogicalResult
  matchAndRewrite(AllocOp op, OpAdaptor adaptor,
                  ConversionPatternRewriter &rewriter) const override {
    auto tensorType = llvm::cast<RankedTensorType>(op.getResult().getType());
    auto memrefType =
        MemRefType::get(tensorType.getShape(), tensorType.getElementType());

    rewriter.replaceOp(op, memref::AllocOp::create(rewriter, op.getLoc(), memrefType,
                                                   adaptor.getDynamicSizes()));
    return success();
  }
};

/// Lower mdarray.load -> memref.load
///
/// %v = mdarray.load %t[%i, %j] : tensor<?x?xf32> -> f32
/// becomes:
/// %v = memref.load %m[%i, %j] : memref<?x?xf32>
struct LoadOpLowering : public OpConversionPattern<LoadOp> {
  using OpConversionPattern<LoadOp>::OpConversionPattern;

  LogicalResult
  matchAndRewrite(LoadOp op, OpAdaptor adaptor,
                  ConversionPatternRewriter &rewriter) const override {
    rewriter.replaceOp(op, memref::LoadOp::create(rewriter, op.getLoc(), adaptor.getTensor(),
                                                  adaptor.getIndices()));
    return success();
  }
};

/// Lower mdarray.store -> memref.store
///
/// mdarray.store %val, %t[%i, %j] : tensor<?x?xf32>
/// becomes:
/// memref.store %val, %m[%i, %j] : memref<?x?xf32>
struct StoreOpLowering : public OpConversionPattern<StoreOp> {
  using OpConversionPattern<StoreOp>::OpConversionPattern;

  LogicalResult
  matchAndRewrite(StoreOp op, OpAdaptor adaptor,
                  ConversionPatternRewriter &rewriter) const override {
    rewriter.replaceOp(op, memref::StoreOp::create(
        rewriter, op.getLoc(), adaptor.getValue(), adaptor.getTensor(), adaptor.getIndices()));
    return success();
  }
};

/// Lower mdarray.slice -> memref.subview
///
/// %1 = mdarray.slice %0[%off0, %off1][%sz0, %sz1]
///        : tensor<?x?xf32> -> tensor<?x?xf32>
/// becomes:
/// %1 = memref.subview %0[%off0, %off1][%sz0, %sz1][1, 1]
///        : memref<?x?xf32> to memref<?x?xf32, ...>
struct SliceOpLowering : public OpConversionPattern<SliceOp> {
  using OpConversionPattern<SliceOp>::OpConversionPattern;

  LogicalResult
  matchAndRewrite(SliceOp op, OpAdaptor adaptor,
                  ConversionPatternRewriter &rewriter) const override {
    Location loc = op.getLoc();
    Value source = adaptor.getSource();
    auto sourceMemRefType = llvm::cast<MemRefType>(source.getType());
    int64_t rank = sourceMemRefType.getRank();

    // Build offset, size, and stride arrays for memref.subview.
    SmallVector<OpFoldResult> offsets, sizes, strides;
    for (int64_t i = 0; i < rank; ++i) {
      offsets.push_back(adaptor.getOffsets()[i]);
      sizes.push_back(adaptor.getSizes()[i]);
      // Stride is always 1.
      strides.push_back(rewriter.getIndexAttr(1));
    }

    // Create the subview operation.
    auto subviewOp = memref::SubViewOp::create(
        rewriter, loc, source, offsets, sizes, strides);

    // The subview result type might have a strided layout. We need to cast
    // it to the expected result memref type (without layout).
    auto resultTensorType =
        llvm::cast<RankedTensorType>(op.getResult().getType());
    auto expectedMemRefType = MemRefType::get(resultTensorType.getShape(),
                                               resultTensorType.getElementType());

    // If the types don't match exactly, insert a memref.cast.
    Value result = subviewOp.getResult();
    if (result.getType() != expectedMemRefType) {
      result = memref::CastOp::create(rewriter, loc, expectedMemRefType, result);
    }

    rewriter.replaceOp(op, result);
    return success();
  }
};

/// Lower mdarray.transpose -> memref.alloc + scf.for loop nest
///
/// %1 = mdarray.transpose %0 : tensor<?x?xf32> -> tensor<?x?xf32>
/// becomes:
///   %d0 = memref.dim %0, 0
///   %d1 = memref.dim %0, 1
///   %out = memref.alloc(%d1, %d0) : memref<?x?xf32>   // swapped dims
///   scf.for %i = 0 to %d0 step 1 {
///     scf.for %j = 0 to %d1 step 1 {
///       %v = memref.load %0[%i, %j]
///       memref.store %v, %out[%j, %i]                  // swapped indices
///     }
///   }
struct TransposeOpLowering : public OpConversionPattern<TransposeOp> {
  using OpConversionPattern<TransposeOp>::OpConversionPattern;

  LogicalResult
  matchAndRewrite(TransposeOp op, OpAdaptor adaptor,
                  ConversionPatternRewriter &rewriter) const override {
    Location loc = op.getLoc();
    Value input = adaptor.getInput();
    auto inputType = llvm::cast<MemRefType>(input.getType());

    // Constants for loop bounds.
    Value zero = arith::ConstantIndexOp::create(rewriter, loc, 0);
    Value one = arith::ConstantIndexOp::create(rewriter, loc, 1);

    // Get dimensions of the input (NxM).
    Value dim0 = memref::DimOp::create(rewriter, loc, input, zero);
    Value dim1 = memref::DimOp::create(rewriter, loc, input, one);

    // Allocate output with swapped dimensions (MxN).
    auto outType = MemRefType::get({ShapedType::kDynamic, ShapedType::kDynamic},
                                    inputType.getElementType());
    Value output =
        memref::AllocOp::create(rewriter, loc, outType, ValueRange{dim1, dim0});

    // Build a 2-level scf.for loop nest to copy elements with
    // transposed indices: out[j][i] = in[i][j].
    auto outerLoop =
        scf::ForOp::create(rewriter, loc, zero, dim0, one);
    rewriter.setInsertionPointToStart(outerLoop.getBody());

    Value iv0 = outerLoop.getInductionVar();

    auto innerLoop =
        scf::ForOp::create(rewriter, loc, zero, dim1, one);
    rewriter.setInsertionPointToStart(innerLoop.getBody());

    Value iv1 = innerLoop.getInductionVar();

    // Load from input[i][j], store to output[j][i].
    Value val =
        memref::LoadOp::create(rewriter, loc, input, ValueRange{iv0, iv1});
    memref::StoreOp::create(rewriter, loc, val, output, ValueRange{iv1, iv0});

    // Set insertion point after the loop nest.
    rewriter.setInsertionPointAfter(outerLoop);

    rewriter.replaceOp(op, output);
    return success();
  }
};

//===----------------------------------------------------------------------===//
// Function signature conversion patterns
//===----------------------------------------------------------------------===//

/// Pattern to convert func.func argument/result types from tensor to memref.
struct FuncOpConversion : public OpConversionPattern<func::FuncOp> {
  using OpConversionPattern<func::FuncOp>::OpConversionPattern;

  LogicalResult
  matchAndRewrite(func::FuncOp op, OpAdaptor adaptor,
                  ConversionPatternRewriter &rewriter) const override {
    auto *converter = getTypeConverter();

    // Convert the function signature.
    TypeConverter::SignatureConversion signatureConversion(
        op.getNumArguments());
    for (unsigned i = 0, e = op.getNumArguments(); i < e; ++i) {
      auto convertedType = converter->convertType(op.getArgument(i).getType());
      if (!convertedType)
        return failure();
      signatureConversion.addInputs(i, convertedType);
    }

    SmallVector<Type> convertedResults;
    if (failed(converter->convertTypes(op.getResultTypes(), convertedResults)))
      return failure();

    auto newFuncType = rewriter.getFunctionType(
        signatureConversion.getConvertedTypes(), convertedResults);

    // Create a new function with the converted signature.
    auto newFunc =
        func::FuncOp::create(rewriter, op.getLoc(), op.getName(), newFuncType);
    rewriter.inlineRegionBefore(op.getBody(), newFunc.getBody(),
                                newFunc.end());

    // Convert the block argument types.
    if (failed(rewriter.convertRegionTypes(&newFunc.getBody(), *converter,
                                            &signatureConversion)))
      return failure();

    rewriter.eraseOp(op);
    return success();
  }
};

/// Pattern to convert func.return operand types.
struct ReturnOpConversion : public OpConversionPattern<func::ReturnOp> {
  using OpConversionPattern<func::ReturnOp>::OpConversionPattern;

  LogicalResult
  matchAndRewrite(func::ReturnOp op, OpAdaptor adaptor,
                  ConversionPatternRewriter &rewriter) const override {
    rewriter.replaceOp(op, func::ReturnOp::create(rewriter, op.getLoc(), adaptor.getOperands()));
    return success();
  }
};

//===----------------------------------------------------------------------===//
// Pass implementation
//===----------------------------------------------------------------------===//

class ConvertMdArrayToMemRefPass
    : public mlir::mdarray::impl::ConvertMdArrayToMemRefBase<ConvertMdArrayToMemRefPass> {
public:
  using mlir::mdarray::impl::ConvertMdArrayToMemRefBase<
      ConvertMdArrayToMemRefPass>::ConvertMdArrayToMemRefBase;

  void runOnOperation() final {
    ModuleOp module = getOperation();
    MLIRContext *context = &getContext();

    // Set up the type converter.
    MdArrayTypeConverter typeConverter;

    // Define the conversion target: everything in the MdArray dialect is
    // illegal (must be lowered); everything in memref, arith, scf, func
    // is legal.
    ConversionTarget target(*context);
    target.addIllegalDialect<MdArrayDialect>();
    target.addLegalDialect<memref::MemRefDialect>();
    target.addLegalDialect<arith::ArithDialect>();
    target.addLegalDialect<scf::SCFDialect>();

    // func.func is legal only if its types have been converted.
    target.addDynamicallyLegalOp<func::FuncOp>([&](func::FuncOp op) {
      return typeConverter.isSignatureLegal(op.getFunctionType());
    });

    // func.return is legal only if its operand types are legal.
    target.addDynamicallyLegalOp<func::ReturnOp>([&](func::ReturnOp op) {
      return typeConverter.isLegal(op.getOperandTypes());
    });

    target.addLegalOp<UnrealizedConversionCastOp>();

    // Populate the pattern set with our conversion patterns.
    RewritePatternSet patterns(context);
    patterns.add<AllocOpLowering, LoadOpLowering, StoreOpLowering,
                 SliceOpLowering, TransposeOpLowering, FuncOpConversion,
                 ReturnOpConversion>(typeConverter, context);

    // Apply the conversion.
    if (failed(applyPartialConversion(module, target, std::move(patterns))))
      signalPassFailure();
  }
};

} // namespace
