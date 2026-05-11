//===- MdArrayPasses.h - MdArray passes -------------------------*- C++ -*-===//
//
// This file is licensed under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#ifndef MDARRAY_MDARRAYPASSES_H
#define MDARRAY_MDARRAYPASSES_H

#include "MdArray/MdArrayDialect.h"
#include "MdArray/MdArrayOps.h"
#include "mlir/Pass/Pass.h"
#include <memory>

namespace mlir {
namespace mdarray {
#define GEN_PASS_DECL
#include "MdArray/MdArrayPasses.h.inc"

#define GEN_PASS_REGISTRATION
#include "MdArray/MdArrayPasses.h.inc"
} // namespace mdarray
} // namespace mlir

#endif // MDARRAY_MDARRAYPASSES_H
