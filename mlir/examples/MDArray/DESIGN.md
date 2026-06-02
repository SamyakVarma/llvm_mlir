# MdArray Dialect — Design Document

## 1. Problem Statement

ML framework frontends (PyTorch, TensorFlow) need to express tensor operations
at a high abstraction level before lowering to hardware-specific code. MLIR's
dialect system allows creating domain-specific IRs that can be progressively
lowered. This project defines a minimal such dialect — `mdarray` — that covers
the five most fundamental tensor operations: allocation, element access (load/store),
slicing, and transposition.

---

## 2. Design Approach

### 2.1 Dialect as a Thin High-Level Layer

The `mdarray` dialect is intentionally thin. It does not define new types — it
reuses MLIR's built-in `tensor<>` types. This means:

- No custom type definitions required (unlike the Toy tutorial which defines a
  custom ToyArrayType).
- Interoperability with other dialects that also use `tensor<>` is free.
- The type converter is simple: `tensor<?x?xf32>` → `memref<?x?xf32>`.

**Trade-off**: Using generic `tensor<>` means the dialect cannot enforce
MdArray-specific invariants at the type level (e.g., "only 2-D tensors allowed
for transpose"). Instead, invariants are enforced via per-op verifiers.

### 2.2 Dynamic Shapes Only

All five ops operate on dynamically-shaped tensors (`tensor<?x?xf32>`) rather
than statically-shaped ones. This makes the dialect general — it works for any
runtime-determined sizes — at the cost of:

- Slightly more complex lowering (need `memref.dim` to query sizes at runtime).
- Potential missed optimizations that static shapes would enable.

**Alternative considered**: Accept both static and dynamic shapes by having ops
take optional size attributes. Rejected for simplicity — the assignment focuses
on the lowering mechanism, not shape inference.

### 2.3 One-Step Lowering Pass

All five ops are lowered in a single pass (`--convert-mdarray-to-memref`). The
pass is declared illegal for the entire `MdArray` dialect and applies all five
conversion patterns simultaneously.

**Alternative considered**: Multi-step lowering:
1. First pass: `mdarray` → `linalg` + `tensor`
2. Second pass: `linalg` + `tensor` → `memref` + `scf`

This would mirror real ML compiler pipelines more closely (e.g., TensorFlow's
lowering chain). Rejected because the assignment asks for lowering *to* memref
dialect specifically, and adding an intermediate linalg step would increase
complexity without demonstrating new concepts.

### 2.4 Transpose as Explicit Loop Nest

`mdarray.transpose` is lowered to an explicit `scf.for` loop nest that copies
elements with swapped indices. This is the simplest correct implementation.

**Alternatives considered**:

| Approach | Pros | Cons |
|----------|------|------|
| `memref.transpose` (linalg_ext) | Zero-copy; O(1) | More complex type handling, strided layout |
| `linalg.generic` with permutation map | Standard; optimizable | Requires linalg dialect dependency |
| Explicit `scf.for` (chosen) | Simple; no extra deps | O(N×M) time/memory |

The explicit loop approach was chosen for clarity — it directly demonstrates
how MLIR loop dialects compose with memory operations.

### 2.5 Slice via `memref.subview`

`mdarray.slice` maps naturally to `memref.subview`, which supports dynamic
offsets and sizes with unit strides. The only complication is that `subview`
may produce a strided layout type; a `memref.cast` is inserted when needed.

**Alternative**: Lower to a copy into a fresh allocation (like transpose).
Rejected because `subview` gives a zero-copy view, which is the semantically
correct model for slicing.

---

## 3. Op Design Decisions

### AllocOp
- Takes `Variadic<Index>` for dynamic sizes (one per `?` dimension).
- Verifier checks count matches the number of `?` dims in the result type.
- No alignment attribute — simplification; real allocators need this.

### LoadOp / StoreOp
- Use `TypesMatchWith` trait to statically enforce value type == element type.
- Verifier additionally checks index count == tensor rank.

### SliceOp
- Uses `AttrSizedOperandSegments` because it has two variadic operand groups
  (offsets and sizes). Without this attribute, MLIR cannot unambiguously parse
  which indices belong to which group.

### TransposeOp
- Restricted to exactly 2-D tensors (verifier enforces this).
- **Alternative**: Support N-D transpose with a permutation map attribute.
  Rejected — adds attribute parsing complexity without adding pedagogical value.

---

## 4. Verification Strategy

Every op has a custom C++ verifier (`hasVerifier = 1` in TableGen + implementation
in `MdArrayOps.cpp`). This is preferred over relying solely on TableGen type
constraints because:

- Rank mismatches (e.g., wrong number of indices) cannot be expressed by
  TableGen type constraints alone.
- Custom error messages are clearer for debugging malformed IR.

---

## 5. What Was Not Implemented

| Feature | Reason |
|---------|--------|
| N-D transpose with permutation map | Out of scope |
| Static shape support | Out of scope |
| Strided slices (step > 1) | Out of scope |
| Deallocation op | Out of scope (no ownership model) |
| Type inference / shape inference | Out of scope |
| Python bindings | Out of scope |
