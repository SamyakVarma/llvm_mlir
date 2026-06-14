// ============================================================================
// test_lowering.mlir — MdArray dialect reference IR
//
// This file shows the expected MdArray IR for each test case. The automated
// test pipeline generates equivalent IR from C sources at run time:
//
//   test/src/*.c  →  clang  →  LLVM IR  →  ll_to_mdarray.py  →  mdarray MLIR
//
// Run the full pipeline with:  ./scripts/run.sh
// Or lower this file directly:
//   mdarray-opt --convert-mdarray-to-memref test_lowering.mlir
// ============================================================================

// ---------------------------------------------------------------------------
// TEST 1: Alloc + Load
// ---------------------------------------------------------------------------
// Allocates a 2-D dynamic tensor and loads a single element.
//
// EXPECTED LOWERING:
//   mdarray.alloc(%n, %m)      -> memref.alloc(%n, %m) : memref<?x?xf32>
//   mdarray.load %0[%i, %j]    -> memref.load %0[%i, %j] : memref<?x?xf32>

func.func @test_alloc_load(%n: index, %m: index, %i: index, %j: index) -> f32 {
  %0 = mdarray.alloc(%n, %m) : tensor<?x?xf32>
  %1 = mdarray.load %0[%i, %j] : tensor<?x?xf32> -> f32
  return %1 : f32
}

// ---------------------------------------------------------------------------
// TEST 2: Alloc + Store + Load (round-trip)
// ---------------------------------------------------------------------------
// Allocates a tensor, stores a value, then loads it back.
//
// EXPECTED LOWERING:
//   mdarray.alloc      -> memref.alloc
//   mdarray.store      -> memref.store
//   mdarray.load       -> memref.load

func.func @test_store_load(%n: index, %m: index, %i: index, %j: index, %val: f32) -> f32 {
  %0 = mdarray.alloc(%n, %m) : tensor<?x?xf32>
  mdarray.store %val, %0[%i, %j] : tensor<?x?xf32>
  %1 = mdarray.load %0[%i, %j] : tensor<?x?xf32> -> f32
  return %1 : f32
}

// ---------------------------------------------------------------------------
// TEST 3: Slice
// ---------------------------------------------------------------------------
// Allocates a tensor and extracts a sub-region.
//
// EXPECTED LOWERING:
//   mdarray.alloc      -> memref.alloc
//   mdarray.slice      -> memref.subview (+ optional memref.cast)

func.func @test_slice(%n: index, %m: index,
                      %off0: index, %off1: index,
                      %sz0: index, %sz1: index) -> tensor<?x?xf32> {
  %0 = mdarray.alloc(%n, %m) : tensor<?x?xf32>
  %1 = mdarray.slice %0[%off0, %off1][%sz0, %sz1]
       : tensor<?x?xf32> -> tensor<?x?xf32>
  return %1 : tensor<?x?xf32>
}

// ---------------------------------------------------------------------------
// TEST 4: Transpose
// ---------------------------------------------------------------------------
// Allocates a 2-D tensor and transposes it.
//
// EXPECTED LOWERING:
//   mdarray.alloc      -> memref.alloc
//   mdarray.transpose  -> memref.alloc (output) + affine.for loop nest
//                         that copies input[i][j] to output[j][i]

func.func @test_transpose(%n: index, %m: index) -> tensor<?x?xf32> {
  %0 = mdarray.alloc(%n, %m) : tensor<?x?xf32>
  %1 = mdarray.transpose %0 : tensor<?x?xf32> -> tensor<?x?xf32>
  return %1 : tensor<?x?xf32>
}

// ---------------------------------------------------------------------------
// TEST 5: Combined pipeline
// ---------------------------------------------------------------------------
// A realistic multi-op pipeline: alloc -> store -> transpose -> load.
//
// EXPECTED LOWERING:
//   All mdarray ops replaced with memref/affine equivalents.

func.func @test_combined(%n: index, %m: index,
                         %i: index, %j: index, %val: f32) -> f32 {
  // Allocate an NxM array
  %0 = mdarray.alloc(%n, %m) : tensor<?x?xf32>

  // Store a value at [i, j]
  mdarray.store %val, %0[%i, %j] : tensor<?x?xf32>

  // Transpose to get MxN array
  %1 = mdarray.transpose %0 : tensor<?x?xf32> -> tensor<?x?xf32>

  // Load from transposed array at [j, i] (which is original [i, j])
  %2 = mdarray.load %1[%j, %i] : tensor<?x?xf32> -> f32

  return %2 : f32
}

// ---------------------------------------------------------------------------
// TEST 6: 1-D tensor (rank-1 alloc and load)
// ---------------------------------------------------------------------------
// Exercises ops on a rank-1 tensor (only 1 index required).
//
// EXPECTED LOWERING:
//   mdarray.alloc(%n)  -> memref.alloc(%n) : memref<?xf32>
//   mdarray.load %0[%i] -> memref.load %0[%i] : memref<?xf32>

func.func @test_1d_alloc_load(%n: index, %i: index) -> f32 {
  %0 = mdarray.alloc(%n) : tensor<?xf32>
  %1 = mdarray.load %0[%i] : tensor<?xf32> -> f32
  return %1 : f32
}

// ---------------------------------------------------------------------------
// TEST 7: Integer element type (i32)
// ---------------------------------------------------------------------------
// Ensures the type converter handles non-f32 element types correctly.
//
// EXPECTED LOWERING:
//   mdarray.alloc      -> memref.alloc  : memref<?x?xi32>
//   mdarray.store      -> memref.store  (i32 value)
//   mdarray.load       -> memref.load   (i32 result)

func.func @test_i32_tensor(%n: index, %m: index,
                           %i: index, %j: index, %val: i32) -> i32 {
  %0 = mdarray.alloc(%n, %m) : tensor<?x?xi32>
  mdarray.store %val, %0[%i, %j] : tensor<?x?xi32>
  %1 = mdarray.load %0[%i, %j] : tensor<?x?xi32> -> i32
  return %1 : i32
}

// ---------------------------------------------------------------------------
// TEST 8: Slice then load from the sub-array
// ---------------------------------------------------------------------------
// Chains slice and load: allocate -> extract sub-region -> load from it.
//
// EXPECTED LOWERING:
//   mdarray.alloc  -> memref.alloc
//   mdarray.slice  -> memref.subview (+ optional memref.cast)
//   mdarray.load   -> memref.load on the subview result

func.func @test_slice_then_load(%n: index, %m: index,
                                %off0: index, %off1: index,
                                %sz0: index, %sz1: index,
                                %i: index, %j: index) -> f32 {
  %0 = mdarray.alloc(%n, %m) : tensor<?x?xf32>
  %1 = mdarray.slice %0[%off0, %off1][%sz0, %sz1]
       : tensor<?x?xf32> -> tensor<?x?xf32>
  %2 = mdarray.load %1[%i, %j] : tensor<?x?xf32> -> f32
  return %2 : f32
}

// ---------------------------------------------------------------------------
// TEST 9: Double transpose
// ---------------------------------------------------------------------------
// Transposes a 2-D array twice. Each transpose lowers to its own scf.for nest.
// Net effect: second result has the same logical layout as the original.
//
// EXPECTED LOWERING:
//   First  transpose -> memref.alloc(MxN) + scf.for nest (out[j][i] = in[i][j])
//   Second transpose -> memref.alloc(NxM) + scf.for nest (out[i][j] = tmp[j][i])

func.func @test_double_transpose(%n: index, %m: index) -> tensor<?x?xf32> {
  %0 = mdarray.alloc(%n, %m) : tensor<?x?xf32>
  %1 = mdarray.transpose %0 : tensor<?x?xf32> -> tensor<?x?xf32>
  %2 = mdarray.transpose %1 : tensor<?x?xf32> -> tensor<?x?xf32>
  return %2 : tensor<?x?xf32>
}

// ---------------------------------------------------------------------------
// TEST 10: Multiple stores, then load
// ---------------------------------------------------------------------------
// Stores two values at different indices, then reads one back.
// Each store lowers independently to its own memref.store.
//
// EXPECTED LOWERING:
//   mdarray.alloc  -> memref.alloc
//   mdarray.store (x2) -> memref.store (x2) at different indices
//   mdarray.load   -> memref.load

func.func @test_multiple_stores(%n: index, %m: index,
                                %i0: index, %j0: index, %v0: f32,
                                %i1: index, %j1: index, %v1: f32) -> f32 {
  %0 = mdarray.alloc(%n, %m) : tensor<?x?xf32>
  mdarray.store %v0, %0[%i0, %j0] : tensor<?x?xf32>
  mdarray.store %v1, %0[%i1, %j1] : tensor<?x?xf32>
  %1 = mdarray.load %0[%i0, %j0] : tensor<?x?xf32> -> f32
  return %1 : f32
}
