// Generated from normal C LLVM IR by ll_to_mdarray.py
// Source: test_double_transpose.ll

func.func @test_double_transpose(%arg0: index, %arg1: index) -> tensor<?x?xf32> {
  %0 = mdarray.alloc(%arg0, %arg1) : tensor<?x?xf32>
  %1 = mdarray.transpose %0 : tensor<?x?xf32> -> tensor<?x?xf32>
  %2 = mdarray.transpose %1 : tensor<?x?xf32> -> tensor<?x?xf32>
  return %2 : tensor<?x?xf32>
}

