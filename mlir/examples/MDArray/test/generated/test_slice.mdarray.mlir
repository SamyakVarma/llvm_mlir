// Generated from normal C LLVM IR by ll_to_mdarray.py
// Source: test_slice.ll

func.func @test_slice(%arg0: index, %arg1: index, %arg2: index, %arg3: index, %arg4: index, %arg5: index) -> tensor<?x?xf32> {
  %0 = mdarray.alloc(%arg0, %arg1) : tensor<?x?xf32>
  %1 = mdarray.slice %0[%arg2, %arg3][%arg4, %arg5]
       : tensor<?x?xf32> -> tensor<?x?xf32>
  return %1 : tensor<?x?xf32>
}

