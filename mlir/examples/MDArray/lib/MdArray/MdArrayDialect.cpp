//===- MdArrayDialect.cpp - MdArray dialect ----------------------*- C++ -*-===//
//
// This file is licensed under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#include "MdArray/MdArrayDialect.h"
#include "MdArray/MdArrayOps.h"

using namespace mlir;
using namespace mlir::mdarray;

#include "MdArray/MdArrayOpsDialect.cpp.inc"

//===----------------------------------------------------------------------===//
// MdArray dialect.
//===----------------------------------------------------------------------===//

void MdArrayDialect::initialize() {
  addOperations<
#define GET_OP_LIST
#include "MdArray/MdArrayOps.cpp.inc"
      >();
}
