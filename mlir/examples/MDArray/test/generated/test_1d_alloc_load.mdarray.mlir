// Generated from normal C LLVM IR by ll_to_mdarray.py
// Source: test_1d_alloc_load.ll

func.func @test_1d_alloc_load(%arg0: index, %arg1: index) -> f32 {
  %0 = mdarray.alloc(%arg0) : tensor<?xf32>
  %1 = mdarray.load %0[%arg1] : tensor<?xf32> -> f32
  return %1 : f32
}

