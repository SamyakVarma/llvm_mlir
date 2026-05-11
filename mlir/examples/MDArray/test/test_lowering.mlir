// ============================================================================
// test_lowering.mlir — MdArray dialect test
//
// This file demonstrates the multi-stage lowering from MdArray dialect
// to the MemRef dialect. Run with:
//
//   mdarray-opt --convert-mdarray-to-memref test_lowering.mlir
//
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
