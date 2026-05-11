//===- mdarray-opt.cpp - MdArray optimizer driver ----------------*- C++ -*-===//
//
// This file is licensed under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// Main entry point for the mdarray-opt tool. This tool can parse .mlir files
// containing MdArray dialect operations and run passes over them, including
// the --convert-mdarray-to-memref lowering pass.
//
//===----------------------------------------------------------------------===//

#include "mlir/Dialect/Arith/IR/Arith.h"
#include "mlir/Dialect/Func/IR/FuncOps.h"
#include "mlir/Dialect/MemRef/IR/MemRef.h"
#include "mlir/Dialect/SCF/IR/SCF.h"
#include "mlir/IR/MLIRContext.h"
#include "mlir/InitAllDialects.h"
#include "mlir/InitAllPasses.h"
#include "mlir/Support/FileUtilities.h"
#include "mlir/Tools/mlir-opt/MlirOptMain.h"

#include "MdArray/MdArrayDialect.h"
#include "MdArray/MdArrayPasses.h"

int main(int argc, char **argv) {
  mlir::registerAllPasses();
  mlir::mdarray::registerPasses();

  mlir::DialectRegistry registry;
  registry.insert<mlir::mdarray::MdArrayDialect,
                  mlir::memref::MemRefDialect,
                  mlir::arith::ArithDialect,
                  mlir::scf::SCFDialect,
                  mlir::func::FuncDialect>();

  // Register all MLIR core dialects for maximum flexibility.
  mlir::registerAllDialects(registry);

  return mlir::asMainReturnCode(
      mlir::MlirOptMain(argc, argv, "MdArray optimizer driver\n", registry));
}
