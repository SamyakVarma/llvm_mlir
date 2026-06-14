module attributes {dlti.dl_spec = #dlti.dl_spec<!llvm.ptr<270> = dense<32> : vector<4xi64>, !llvm.ptr<271> = dense<32> : vector<4xi64>, !llvm.ptr<272> = dense<64> : vector<4xi64>, i64 = dense<64> : vector<2xi64>, i128 = dense<128> : vector<2xi64>, f80 = dense<128> : vector<2xi64>, !llvm.ptr = dense<64> : vector<4xi64>, i1 = dense<8> : vector<2xi64>, i8 = dense<8> : vector<2xi64>, i16 = dense<16> : vector<2xi64>, i32 = dense<32> : vector<2xi64>, f16 = dense<16> : vector<2xi64>, f64 = dense<64> : vector<2xi64>, f128 = dense<128> : vector<2xi64>, "dlti.endianness" = "little", "dlti.mangling_mode" = "w", "dlti.legal_int_widths" = array<i32: 8, 16, 32, 64>, "dlti.stack_alignment" = 128 : i64>, llvm.ident = "clang version 22.1.2 (https://github.com/msys2/MINGW-packages 4f19d31560faf73257116b7c95f0b322ba83d720)", llvm.module_asm = [], llvm.target_triple = "x86_64-w64-windows-gnu"} {
  llvm.module_flags [#llvm.mlir.module_flag<warning, "Debug Info Version", 3 : i32>, #llvm.mlir.module_flag<error, "wchar_size", 2 : i32>, #llvm.mlir.module_flag<min, "PIC Level", 2 : i32>, #llvm.mlir.module_flag<max, "uwtable", 2 : i32>, #llvm.mlir.module_flag<error, "MaxTLSAlign", 65536 : i32>]
  llvm.func @test_multiple_stores(%arg0: i64 {llvm.noundef}, %arg1: i64 {llvm.noundef}, %arg2: i64 {llvm.noundef}, %arg3: i64 {llvm.noundef}, %arg4: f32 {llvm.noundef}, %arg5: i64 {llvm.noundef}, %arg6: i64 {llvm.noundef}, %arg7: f32 {llvm.noundef}) -> f32 attributes {dso_local, no_inline, no_unwind, optimize_none, passthrough = [["min-legal-vector-width", "0"], ["no-trapping-math", "true"], ["stack-protector-buffer-size", "8"], ["target-cpu", "x86-64"]], target_cpu = "x86-64", target_features = #llvm.target_features<["+cmov", "+cx8", "+fxsr", "+mmx", "+sse", "+sse2", "+x87"]>, tune_cpu = "generic", uwtable_kind = #llvm.uwtableKind<async>} {
    %0 = llvm.mlir.constant(1 : i32) : i32
    %1 = llvm.mlir.constant(4 : i64) : i64
    %2 = llvm.alloca %0 x i64 {alignment = 8 : i64} : (i32) -> !llvm.ptr
    %3 = llvm.alloca %0 x i64 {alignment = 8 : i64} : (i32) -> !llvm.ptr
    %4 = llvm.alloca %0 x i64 {alignment = 8 : i64} : (i32) -> !llvm.ptr
    %5 = llvm.alloca %0 x i64 {alignment = 8 : i64} : (i32) -> !llvm.ptr
    %6 = llvm.alloca %0 x f32 {alignment = 4 : i64} : (i32) -> !llvm.ptr
    %7 = llvm.alloca %0 x i64 {alignment = 8 : i64} : (i32) -> !llvm.ptr
    %8 = llvm.alloca %0 x i64 {alignment = 8 : i64} : (i32) -> !llvm.ptr
    %9 = llvm.alloca %0 x f32 {alignment = 4 : i64} : (i32) -> !llvm.ptr
    %10 = llvm.alloca %0 x !llvm.ptr {alignment = 8 : i64} : (i32) -> !llvm.ptr
    llvm.store %arg0, %2 {alignment = 8 : i64} : i64, !llvm.ptr
    llvm.store %arg1, %3 {alignment = 8 : i64} : i64, !llvm.ptr
    llvm.store %arg2, %4 {alignment = 8 : i64} : i64, !llvm.ptr
    llvm.store %arg3, %5 {alignment = 8 : i64} : i64, !llvm.ptr
    llvm.store %arg4, %6 {alignment = 4 : i64} : f32, !llvm.ptr
    llvm.store %arg5, %7 {alignment = 8 : i64} : i64, !llvm.ptr
    llvm.store %arg6, %8 {alignment = 8 : i64} : i64, !llvm.ptr
    llvm.store %arg7, %9 {alignment = 4 : i64} : f32, !llvm.ptr
    %11 = llvm.load %2 {alignment = 8 : i64} : !llvm.ptr -> i64
    %12 = llvm.load %3 {alignment = 8 : i64} : !llvm.ptr -> i64
    %13 = llvm.mul %11, %12 overflow<nsw> : i64
    %14 = llvm.mul %13, %1 : i64
    %15 = llvm.call @malloc(%14) {allocsize = array<i32: 0>} : (i64 {llvm.noundef}) -> !llvm.ptr
    llvm.store %15, %10 {alignment = 8 : i64} : !llvm.ptr, !llvm.ptr
    %16 = llvm.load %6 {alignment = 4 : i64} : !llvm.ptr -> f32
    %17 = llvm.load %10 {alignment = 8 : i64} : !llvm.ptr -> !llvm.ptr
    %18 = llvm.load %4 {alignment = 8 : i64} : !llvm.ptr -> i64
    %19 = llvm.load %3 {alignment = 8 : i64} : !llvm.ptr -> i64
    %20 = llvm.mul %18, %19 overflow<nsw> : i64
    %21 = llvm.load %5 {alignment = 8 : i64} : !llvm.ptr -> i64
    %22 = llvm.add %20, %21 overflow<nsw> : i64
    %23 = llvm.getelementptr inbounds %17[%22] : (!llvm.ptr, i64) -> !llvm.ptr, f32
    llvm.store %16, %23 {alignment = 4 : i64} : f32, !llvm.ptr
    %24 = llvm.load %9 {alignment = 4 : i64} : !llvm.ptr -> f32
    %25 = llvm.load %10 {alignment = 8 : i64} : !llvm.ptr -> !llvm.ptr
    %26 = llvm.load %7 {alignment = 8 : i64} : !llvm.ptr -> i64
    %27 = llvm.load %3 {alignment = 8 : i64} : !llvm.ptr -> i64
    %28 = llvm.mul %26, %27 overflow<nsw> : i64
    %29 = llvm.load %8 {alignment = 8 : i64} : !llvm.ptr -> i64
    %30 = llvm.add %28, %29 overflow<nsw> : i64
    %31 = llvm.getelementptr inbounds %25[%30] : (!llvm.ptr, i64) -> !llvm.ptr, f32
    llvm.store %24, %31 {alignment = 4 : i64} : f32, !llvm.ptr
    %32 = llvm.load %10 {alignment = 8 : i64} : !llvm.ptr -> !llvm.ptr
    %33 = llvm.load %4 {alignment = 8 : i64} : !llvm.ptr -> i64
    %34 = llvm.load %3 {alignment = 8 : i64} : !llvm.ptr -> i64
    %35 = llvm.mul %33, %34 overflow<nsw> : i64
    %36 = llvm.load %5 {alignment = 8 : i64} : !llvm.ptr -> i64
    %37 = llvm.add %35, %36 overflow<nsw> : i64
    %38 = llvm.getelementptr inbounds %32[%37] : (!llvm.ptr, i64) -> !llvm.ptr, f32
    %39 = llvm.load %38 {alignment = 4 : i64} : !llvm.ptr -> f32
    llvm.return %39 : f32
  }
  llvm.func @malloc(i64 {llvm.noundef}) -> !llvm.ptr attributes {allocsize = array<i32: 0>, dso_local, passthrough = [["no-trapping-math", "true"], ["stack-protector-buffer-size", "8"], ["target-cpu", "x86-64"]], target_cpu = "x86-64", target_features = #llvm.target_features<["+cmov", "+cx8", "+fxsr", "+mmx", "+sse", "+sse2", "+x87"]>, tune_cpu = "generic"}
}
