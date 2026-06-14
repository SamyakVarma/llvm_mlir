// Generated from normal C LLVM IR by ll_to_mdarray.py
// Source: test_i32_tensor.ll

func.func @test_i32_tensor(%arg0: index, %arg1: index, %arg2: index, %arg3: index, %arg4: i32) -> i32 {
  %0 = mdarray.alloc(%arg0, %arg1) : tensor<?x?xi32>
  mdarray.store %arg4, %0[%arg2, %arg3] : tensor<?x?xi32>
  %1 = mdarray.load %0[%arg2, %arg3] : tensor<?x?xi32> -> i32
  return %1 : i32
}

