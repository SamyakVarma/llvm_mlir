// Generated from normal C LLVM IR by ll_to_mdarray.py
// Source: test_store_load.ll

func.func @test_store_load(%arg0: index, %arg1: index, %arg2: index, %arg3: index, %arg4: f32) -> f32 {
  %0 = mdarray.alloc(%arg0, %arg1) : tensor<?x?xf32>
  mdarray.store %arg4, %0[%arg2, %arg3] : tensor<?x?xf32>
  %1 = mdarray.load %0[%arg2, %arg3] : tensor<?x?xf32> -> f32
  return %1 : f32
}

