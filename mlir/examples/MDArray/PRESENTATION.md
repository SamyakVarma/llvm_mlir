# Slide 1: MdArray Dialect: A Custom MLIR Implementation
- **Presenter**: [Your Name]
- **Topic**: Implementing an out-of-tree MLIR dialect for multi-dimensional arrays, with a progressive lowering pipeline to MemRef.

---

# Slide 2: What is LLVM?
- **Single-IR Model**: LLVM uses a monolithic intermediate representation (LLVM IR) for all optimizations and code generation.
- **Fixed Abstraction**: IR sits at the level of C (integers, floats, pointers); lacks high-level concepts like tensors or domain-specific types.
- **All-at-Once Lowering**: Frontends must lower high-level constructs entirely in one step.
- **Limitations**: High-level semantic information (e.g., "matrix multiply") is lost, preventing optimizations at the appropriate abstraction level.

---

# Slide 3: What is MLIR?
- **Multi-Level Intermediate Representation**: A modern compiler infrastructure under the LLVM umbrella.
- **Dialect System**: Supports multiple IRs (dialects) coexisting in the same module, capturing specific abstraction levels.
- **Progressive Lowering**: Code is lowered gradually through intermediate dialects rather than in one giant leap.
- **Optimization Everywhere**: Optimizations can be applied at the most appropriate level before semantics are lost.

---

# Slide 4: MLIR vs LLVM (Progressive vs Single-IR)
| Aspect | LLVM (Single-IR) | MLIR (Progressive) |
|--------|------------------|--------------------|
| **Abstraction** | Lost immediately | Preserved at each level |
| **Optimizations** | At one low level | At every intermediate level |
| **Extensibility** | Hard to add types/ops | Dialects are plug-and-play |
| **Mixed IR** | Single IR only | Multiple dialects can coexist |

---

# Slide 5: Project Overview & Assignment
- **Goal**: Implement a custom MLIR dialect called **MdArray** (Multi-Dimensional Array) for high-level tensor manipulation.
- **Core Operations**: `alloc`, `load`, `store`, `slice`, and `transpose`.
- **Lowering Pass**: Progressively lower MdArray operations down to MLIR's standard `memref` and `scf` dialects.
- **Deliverables**:
  1. Custom Dialect Definition
  2. TableGen (.td) Definitions
  3. Conversion Pass (MdArray → MemRef)
  4. Test Program evaluating the lowering

---

# Slide 6: Architecture & File Structure
- Implemented as an in-tree MLIR example (`mlir/examples/MDArray/`).
- **`include/MdArray/`**: TableGen definitions (`.td`) and generated C++ headers.
- **`lib/MdArray/`**: 
  - `MdArrayDialect.cpp` (Initialization)
  - `MdArrayOps.cpp` (Verifiers)
  - `MdArrayPasses.cpp` (The Lowering Pass)
- **`mdarray-opt/`**: The CLI driver tool for running passes.
- **`test/`**: MLIR test cases for lowering validation.

---

# Slide 7: Custom Dialect Definition (MdArray)
- **Dialect Name**: `"mdarray"`
- **Types**: Operates exclusively on ranked tensor types (e.g., `tensor<?x?xf32>`).
- **Operations**:
  - `mdarray.alloc`: Dynamically-shaped array allocation.
  - `mdarray.load` / `mdarray.store`: Element-wise memory access.
  - `mdarray.slice`: Sub-region extraction.
  - `mdarray.transpose`: 2-D dimension swapping.
- **Custom Verifiers**: C++ hooks validating dynamic sizes, indices vs ranks, and element types.

---

# Slide 8: TableGen Definitions (ODS)
- Uses MLIR's Operation Definition Specification (ODS) framework.
- **`MdArrayDialect.td`**: Defines the `MdArray_Dialect`.
- **`MdArrayOps.td`**: Defines all 5 operations:
  - Specifies `arguments` (operands) and `results`.
  - Defines `assemblyFormat` for custom syntax.
  - Hooks into C++ verifiers.
- **`MdArrayPasses.td`**: Declares the `ConvertMdArrayToMemRef` pass and dependent dialects (`MemRef`, `Arith`, `SCF`, `Func`).

---

# Slide 9: Conversion Pass (MdArray → MemRef)
- Implemented using the **DialectConversion** framework.
- **Type Converter**: Automatically maps `tensor<?x?xf32>` → `memref<?x?xf32>`.
- **Conversion Patterns**:
  - `alloc` → `memref.alloc`
  - `load` / `store` → `memref.load` / `memref.store`
  - `slice` → `memref.subview` + `memref.cast`
  - `transpose` → `memref.alloc` + `scf.for` loop nest
- **Signature Conversion**: Also transforms `func.func` and `func.return` signatures to use memrefs instead of tensors.

---

# Slide 10: Deep Dive: Transpose Lowering
- Transpose represents a complex lowering step from a high-level op to an explicit element-wise copy.

**Source (MdArray):**
```mlir
%1 = mdarray.transpose %0 : tensor<?x?xf32> -> tensor<?x?xf32>
```

**Target (MemRef + SCF):**
```mlir
%output = memref.alloc(%d1, %d0)
scf.for %i = 0 to %d0 step 1 {
  scf.for %j = 0 to %d1 step 1 {
    %val = memref.load %input[%i, %j]
    memref.store %val, %output[%j, %i]
  }
}
```

---

# Slide 11: The DialectConversion Framework
- **Correct by Construction**: Ensures either full conversion or reports failure.
- **Components**:
  1. **TypeConverter**: Handles source to target type mapping.
  2. **ConversionPattern**: Rewrites specific ops; provides `OpAdaptor` for converted operands.
  3. **ConversionTarget**: Declares which ops/dialects are "Legal" or "Illegal".
  4. **applyPartialConversion**: The driver managing mixed-dialect IR during conversion.

---

# Slide 12: Test Program Workflow
- Test file: `test_lowering.mlir` containing 5 comprehensive tests.
- **Workflow**:
  1. **Parsing**: `mdarray-opt` reads MLIR IR.
  2. **Pass Execution**: Invoked via `--convert-mdarray-to-memref`.
  3. **Pattern Rewriting**: DialectConversion executes rewrite patterns.
  4. **Output Validation**: Ensures zero `mdarray` ops remain.
- **Special Cases Handled**: Dynamic shapes (`?x?`), type casting in slices, and multi-op dependency chains.

---

# Slide 13: Core MLIR/LLVM APIs Utilized
- **`mlir::ConversionPatternRewriter`**: Safely mutates IR (insert/delete/replace).
- **`mlir::OpAdaptor`**: Retrieves newly converted operands during rewrite.
- **`mlir::TypeConverter`**: Reconciles type boundaries via `unrealized_conversion_cast`.
- **`mlir::PassWrapper`**: Boilerplate for registering CLI pass execution.

---

# Slide 14: Final Results
- Complete progressive lowering achieved!
- Tensor allocations and memory accesses map cleanly to `memref`.
- Complex operations (`transpose`) successfully expand into memory buffers and loop nests.
- Function signatures seamlessly transition from `tensor` to `memref`.
- The output IR is purely standard MLIR dialects, ready for further lowering to LLVM IR.

---

# Slide 15: Limitations & Future Work
- **Type Restriction**: Currently hardcoded to 32-bit floats (`f32`).
- **Rank Limitations**: Transpose only supports strictly 2-D arrays. N-D permutation is not implemented.
- **Memory Management**: Emits `memref.alloc` but lacks `memref.dealloc`, which would cause memory leaks in binaries. Needs a dedicated bufferization/deallocation pass.
- **Performance**: The transpose loop nest is a naive copy, lacking optimizations like cache tiling, vectorization, or parallelization.
