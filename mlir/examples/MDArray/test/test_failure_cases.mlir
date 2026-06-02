// ============================================================================
// test_failure_cases.mlir — MdArray dialect verifier failure tests
//
// Each function below contains a deliberate violation of an op's verifier.
// Running this file WITHOUT --verify-diagnostics causes the verifier to
// reject the module and print error messages. With --verify-diagnostics the
// tool checks that the expected-error annotations match the actual errors.
//
// Run with:
//   mdarray-opt --verify-diagnostics test/test_failure_cases.mlir
//
// All five functions must produce errors; the tool exits 0 only when every
// expected-error annotation is matched.
// ============================================================================

// ---------------------------------------------------------------------------
// FAILURE F1: AllocOp — wrong number of dynamic sizes
// ---------------------------------------------------------------------------
// tensor<?x?xf32> has 2 dynamic dims, but only 1 index is supplied.
// Expected error: "expected 2 dynamic size(s) ... but got 1"

func.func @bad_alloc_wrong_dyn_count(%n: index) -> tensor<?x?xf32> {
  // expected-error @+1 {{'mdarray.alloc' op expected 2 dynamic size(s) for result type 'tensor<?x?xf32>', but got 1}}
  %0 = mdarray.alloc(%n) : tensor<?x?xf32>
  return %0 : tensor<?x?xf32>
}

// ---------------------------------------------------------------------------
// FAILURE F2: LoadOp — wrong number of index operands
// ---------------------------------------------------------------------------
// tensor<?x?xf32> has rank 2, but only 1 index is provided.
// Expected error: "expected 2 index operand(s) ... but got 1"

func.func @bad_load_wrong_index_count(%n: index, %m: index, %i: index) -> f32 {
  %0 = mdarray.alloc(%n, %m) : tensor<?x?xf32>
  // expected-error @+1 {{'mdarray.load' op expected 2 index operand(s) for tensor of rank 2, but got 1}}
  %1 = mdarray.load %0[%i] : tensor<?x?xf32> -> f32
  return %1 : f32
}

// ---------------------------------------------------------------------------
// FAILURE F3: StoreOp — wrong number of index operands
// ---------------------------------------------------------------------------
// tensor<?x?xf32> has rank 2, but 3 indices are provided.
// Expected error: "expected 2 index operand(s) ... but got 3"

func.func @bad_store_wrong_index_count(
    %n: index, %m: index, %i: index, %j: index, %k: index, %val: f32) {
  %0 = mdarray.alloc(%n, %m) : tensor<?x?xf32>
  // expected-error @+1 {{'mdarray.store' op expected 2 index operand(s) for tensor of rank 2, but got 3}}
  mdarray.store %val, %0[%i, %j, %k] : tensor<?x?xf32>
  return
}

// ---------------------------------------------------------------------------
// FAILURE F4: SliceOp — wrong number of offsets
// ---------------------------------------------------------------------------
// Source is rank 2 but only 1 offset is provided (sizes are correct).
// Expected error: "expected 2 offset(s) ... but got 1"

func.func @bad_slice_wrong_offset_count(
    %n: index, %m: index, %off: index, %sz0: index, %sz1: index)
    -> tensor<?x?xf32> {
  %0 = mdarray.alloc(%n, %m) : tensor<?x?xf32>
  // expected-error @+1 {{'mdarray.slice' op expected 2 offset(s) for source tensor of rank 2, but got 1}}
  %1 = mdarray.slice %0[%off][%sz0, %sz1] : tensor<?x?xf32> -> tensor<?x?xf32>
  return %1 : tensor<?x?xf32>
}

// ---------------------------------------------------------------------------
// FAILURE F5: TransposeOp — input tensor is not 2-D
// ---------------------------------------------------------------------------
// transpose requires exactly a 2-D input. This passes a 1-D tensor.
// Expected error: "expected 2-D input tensor, but got rank 1"

func.func @bad_transpose_wrong_rank(%n: index) -> tensor<?xf32> {
  %0 = mdarray.alloc(%n) : tensor<?xf32>
  // expected-error @+1 {{'mdarray.transpose' op expected 2-D input tensor, but got rank 1}}
  %1 = mdarray.transpose %0 : tensor<?xf32> -> tensor<?xf32>
  return %1 : tensor<?xf32>
}

// ---------------------------------------------------------------------------
// FAILURE F6: SliceOp — wrong number of sizes
// ---------------------------------------------------------------------------
// Source is rank 2 but only 1 size is provided (offsets are correct).
// Expected error: "expected 2 size(s) ... but got 1"

func.func @bad_slice_wrong_size_count(
    %n: index, %m: index, %off0: index, %off1: index, %sz: index)
    -> tensor<?x?xf32> {
  %0 = mdarray.alloc(%n, %m) : tensor<?x?xf32>
  // expected-error @+1 {{'mdarray.slice' op expected 2 size(s) for source tensor of rank 2, but got 1}}
  %1 = mdarray.slice %0[%off0, %off1][%sz] : tensor<?x?xf32> -> tensor<?x?xf32>
  return %1 : tensor<?x?xf32>
}

// ---------------------------------------------------------------------------
// FAILURE F7: SliceOp — result element type mismatches source
// ---------------------------------------------------------------------------
// Source is tensor<?x?xf32> but result is declared as tensor<?x?xf64>.
// Expected error: "result element type 'f64' must match source element type 'f32'"

func.func @bad_slice_element_type_mismatch(
    %n: index, %m: index,
    %off0: index, %off1: index,
    %sz0: index, %sz1: index)
    -> tensor<?x?xf64> {
  %0 = mdarray.alloc(%n, %m) : tensor<?x?xf32>
  // expected-error @+1 {{'mdarray.slice' op result element type 'f64' must match source element type 'f32'}}
  %1 = mdarray.slice %0[%off0, %off1][%sz0, %sz1]
       : tensor<?x?xf32> -> tensor<?x?xf64>
  return %1 : tensor<?x?xf64>
}

// ---------------------------------------------------------------------------
// FAILURE F8: TransposeOp — 3-D input (rank 3, not 2)
// ---------------------------------------------------------------------------
// transpose requires rank-2 input. A 3-D tensor must be rejected.
// Expected error: "expected 2-D input tensor, but got rank 3"

func.func @bad_transpose_3d(%n: index, %m: index, %k: index) -> tensor<?x?x?xf32> {
  %0 = mdarray.alloc(%n, %m, %k) : tensor<?x?x?xf32>
  // expected-error @+1 {{'mdarray.transpose' op expected 2-D input tensor, but got rank 3}}
  %1 = mdarray.transpose %0 : tensor<?x?x?xf32> -> tensor<?x?x?xf32>
  return %1 : tensor<?x?x?xf32>
}

// ---------------------------------------------------------------------------
// FAILURE F9: AllocOp — static tensor with dynamic sizes provided
// ---------------------------------------------------------------------------
// tensor<4x4xf32> has 0 dynamic dimensions; providing 2 dynamic sizes is wrong.
// Expected error: "expected 0 dynamic size(s) ... but got 2"

func.func @bad_alloc_static_tensor_with_dyn_sizes(%n: index, %m: index)
    -> tensor<4x4xf32> {
  // expected-error @+1 {{'mdarray.alloc' op expected 0 dynamic size(s) for result type 'tensor<4x4xf32>', but got 2}}
  %0 = mdarray.alloc(%n, %m) : tensor<4x4xf32>
  return %0 : tensor<4x4xf32>
}

// ---------------------------------------------------------------------------
// FAILURE F10: SliceOp — result rank mismatches source rank
// ---------------------------------------------------------------------------
// Source is rank 2 but result is declared rank 1; ranks must match.
// Expected error: "result rank 1 must match source rank 2"

func.func @bad_slice_result_rank_mismatch(
    %n: index, %m: index,
    %off0: index, %off1: index,
    %sz0: index, %sz1: index)
    -> tensor<?xf32> {
  %0 = mdarray.alloc(%n, %m) : tensor<?x?xf32>
  // expected-error @+1 {{'mdarray.slice' op result rank 1 must match source rank 2}}
  %1 = mdarray.slice %0[%off0, %off1][%sz0, %sz1]
       : tensor<?x?xf32> -> tensor<?xf32>
  return %1 : tensor<?xf32>
}
