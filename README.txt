# README

## Project Title

**MLIR Dialect for Tensor Operations **

---

## 1. Project Overview

This project implements a custom MLIR dialect called **MdArray (Multi-Dimensional Array)** for tensor operations. The dialect provides high-level operations for manipulating multi-dimensional arrays and demonstrates MLIR's progressive lowering mechanism by converting these operations into the standard **MemRef dialect**.

The project is inspired by modern machine learning compiler infrastructures such as TensorFlow and PyTorch, where high-level tensor operations are gradually lowered into lower-level representations before code generation.

---

## 2. Features

The MdArray dialect supports the following tensor operations:

* **mdarray.alloc** – Allocates a multi-dimensional tensor.
* **mdarray.load** – Loads an element from a tensor.
* **mdarray.store** – Stores a value into a tensor.
* **mdarray.slice** – Extracts a sub-region from a tensor.
* **mdarray.transpose** – Transposes a two-dimensional tensor.

A custom conversion pass lowers all MdArray operations into equivalent operations from the MLIR MemRef, SCF, and Arith dialects.

---

## 3. Project Structure

```text
MDArray/
│
├── README.docx
├── DESIGN.docx
├── IMPLEMENTATION.docx
├── EVALUATION.docx
│
├── scripts/
│   ├── build.sh
│   └── run.sh
│
├── src/
│   ├── include/
│   │   └── MdArray/
│   │       ├── MdArrayDialect.td
│   │       ├── MdArrayOps.td
│   │       └── MdArrayPasses.td
│   │
│   ├── lib/
│   │   └── MdArray/
│   │       ├── MdArrayDialect.cpp
│   │       ├── MdArrayOps.cpp
│   │       └── MdArrayPasses.cpp
│   │
│   └── mdarray-opt/
│       └── mdarray-opt.cpp
│
└── testcases/
    └── test_lowering.mlir
```

---

## 4. Software Requirements

* LLVM Project with MLIR support
* CMake (Version 3.20 or higher)
* C++17 Compatible Compiler
* Ninja Build System
* Linux / Windows Environment

---

## 5. How to Build the Project

### Step 1: Create Build Directory

```bash
mkdir build
cd build
```

### Step 2: Configure LLVM and MLIR

```bash
cmake -G Ninja ../llvm \
-DLLVM_ENABLE_PROJECTS="mlir" \
-DLLVM_TARGETS_TO_BUILD="host" \
-DCMAKE_BUILD_TYPE=Release
```

### Step 3: Build the Project

```bash
ninja mdarray-opt
```

After successful compilation, the executable **mdarray-opt** will be generated.

---

## 6. How to Run the Project

Execute the lowering pass on the test file:

```bash
./bin/mdarray-opt --convert-mdarray-to-memref \
../mlir/examples/MDArray/test/test_lowering.mlir
```

---

## 7. Expected Output

The output should contain only standard MLIR operations such as:

```text
memref.alloc
memref.load
memref.store
memref.subview
scf.for
arith.*
```

All custom MdArray operations:

```text
mdarray.alloc
mdarray.load
mdarray.store
mdarray.slice
mdarray.transpose
```

should be completely lowered and removed from the final IR.

---

## 8. Test Cases

The following test cases are included:

1. Allocation and Load Operation
2. Store and Load Operation
3. Slice Operation
4. Transpose Operation
5. Combined Tensor Pipeline

These tests verify the correctness of the dialect operations and the lowering pass.

---

## 9. Conclusion

This project successfully demonstrates the design and implementation of a custom MLIR dialect for tensor operations and its conversion into the MemRef dialect using MLIR's Dialect Conversion Framework. The project highlights MLIR's progressive lowering approach and its advantages over traditional single-level compiler IRs.
