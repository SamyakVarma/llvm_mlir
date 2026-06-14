// Generated from normal C LLVM IR by ll_to_mdarray.py
// Source: test_multiple_stores.ll

func.func @test_multiple_stores(%arg0: index, %arg1: index, %arg2: index, %arg3: index, %arg4: f32, %arg5: index, %arg6: index, %arg7: f32) -> f32 {
  %0 = mdarray.alloc(%arg0, %arg1) : tensor<?x?xf32>
  mdarray.store %arg4, %0[%arg2, %arg3] : tensor<?x?xf32>
  mdarray.store %arg7, %0[%arg5, %arg6] : tensor<?x?xf32>
  %1 = mdarray.load %0[%arg2, %arg3] : tensor<?x?xf32> -> f32
  return %1 : f32
}

