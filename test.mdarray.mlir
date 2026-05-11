module {
  func.func @test(%n: index, %m: index, %i: index, %j: index) -> f32 {
    %0 = mdarray.alloc(%n, %m) : tensor<?x?xf32>
    %1 = mdarray.load %0[%i, %j] : tensor<?x?xf32> -> f32
    return %1 : f32
  }
}