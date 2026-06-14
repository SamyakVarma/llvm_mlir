// Generated from normal C LLVM IR by ll_to_mdarray.py
// Source: test_slice_then_load.ll

func.func @test_slice_then_load(%arg0: index, %arg1: index, %arg2: index, %arg3: index, %arg4: index, %arg5: index, %arg6: index, %arg7: index) -> f32 {
  %0 = mdarray.alloc(%arg0, %arg1) : tensor<?x?xf32>
  %1 = mdarray.slice %0[%arg2, %arg3][%arg4, %arg5]
       : tensor<?x?xf32> -> tensor<?x?xf32>
  %2 = mdarray.load %1[%arg6, %arg7] : tensor<?x?xf32> -> f32
  return %2 : f32
}

