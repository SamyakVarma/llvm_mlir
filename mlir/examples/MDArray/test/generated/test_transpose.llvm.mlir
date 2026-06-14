#loop_annotation = #llvm.loop_annotation<mustProgress = true>
module attributes {dlti.dl_spec = #dlti.dl_spec<!llvm.ptr<270> = dense<32> : vector<4xi64>, !llvm.ptr<271> = dense<32> : vector<4xi64>, !llvm.ptr<272> = dense<64> : vector<4xi64>, i64 = dense<64> : vector<2xi64>, i128 = dense<128> : vector<2xi64>, f80 = dense<128> : vector<2xi64>, !llvm.ptr = dense<64> : vector<4xi64>, i1 = dense<8> : vector<2xi64>, i8 = dense<8> : vector<2xi64>, i16 = dense<16> : vector<2xi64>, i32 = dense<32> : vector<2xi64>, f16 = dense<16> : vector<2xi64>, f64 = dense<64> : vector<2xi64>, f128 = dense<128> : vector<2xi64>, "dlti.endianness" = "little", "dlti.mangling_mode" = "w", "dlti.legal_int_widths" = array<i32: 8, 16, 32, 64>, "dlti.stack_alignment" = 128 : i64>, llvm.ident = "clang version 22.1.2 (https://github.com/msys2/MINGW-packages 4f19d31560faf73257116b7c95f0b322ba83d720)", llvm.module_asm = [], llvm.target_triple = "x86_64-w64-windows-gnu"} {
  llvm.module_flags [#llvm.mlir.module_flag<warning, "Debug Info Version", 3 : i32>, #llvm.mlir.module_flag<error, "wchar_size", 2 : i32>, #llvm.mlir.module_flag<min, "PIC Level", 2 : i32>, #llvm.mlir.module_flag<max, "uwtable", 2 : i32>, #llvm.mlir.module_flag<error, "MaxTLSAlign", 65536 : i32>]
  llvm.func @test_transpose(%arg0: i64 {llvm.noundef}, %arg1: i64 {llvm.noundef}) -> !llvm.ptr attributes {dso_local, no_inline, no_unwind, optimize_none, passthrough = [["min-legal-vector-width", "0"], ["no-trapping-math", "true"], ["stack-protector-buffer-size", "8"], ["target-cpu", "x86-64"]], target_cpu = "x86-64", target_features = #llvm.target_features<["+cmov", "+cx8", "+fxsr", "+mmx", "+sse", "+sse2", "+x87"]>, tune_cpu = "generic", uwtable_kind = #llvm.uwtableKind<async>} {
    %0 = llvm.mlir.constant(1 : i32) : i32
    %1 = llvm.mlir.constant(4 : i64) : i64
    %2 = llvm.mlir.constant(0 : i64) : i64
    %3 = llvm.mlir.constant(1 : i64) : i64
    %4 = llvm.alloca %0 x i64 {alignment = 8 : i64} : (i32) -> !llvm.ptr
    %5 = llvm.alloca %0 x i64 {alignment = 8 : i64} : (i32) -> !llvm.ptr
    %6 = llvm.alloca %0 x !llvm.ptr {alignment = 8 : i64} : (i32) -> !llvm.ptr
    %7 = llvm.alloca %0 x !llvm.ptr {alignment = 8 : i64} : (i32) -> !llvm.ptr
    %8 = llvm.alloca %0 x i64 {alignment = 8 : i64} : (i32) -> !llvm.ptr
    %9 = llvm.alloca %0 x i64 {alignment = 8 : i64} : (i32) -> !llvm.ptr
    llvm.store %arg0, %4 {alignment = 8 : i64} : i64, !llvm.ptr
    llvm.store %arg1, %5 {alignment = 8 : i64} : i64, !llvm.ptr
    %10 = llvm.load %4 {alignment = 8 : i64} : !llvm.ptr -> i64
    %11 = llvm.load %5 {alignment = 8 : i64} : !llvm.ptr -> i64
    %12 = llvm.mul %10, %11 overflow<nsw> : i64
    %13 = llvm.mul %12, %1 : i64
    %14 = llvm.call @malloc(%13) {allocsize = array<i32: 0>} : (i64 {llvm.noundef}) -> !llvm.ptr
    llvm.store %14, %6 {alignment = 8 : i64} : !llvm.ptr, !llvm.ptr
    %15 = llvm.load %5 {alignment = 8 : i64} : !llvm.ptr -> i64
    %16 = llvm.load %4 {alignment = 8 : i64} : !llvm.ptr -> i64
    %17 = llvm.mul %15, %16 overflow<nsw> : i64
    %18 = llvm.mul %17, %1 : i64
    %19 = llvm.call @malloc(%18) {allocsize = array<i32: 0>} : (i64 {llvm.noundef}) -> !llvm.ptr
    llvm.store %19, %7 {alignment = 8 : i64} : !llvm.ptr, !llvm.ptr
    llvm.store %2, %8 {alignment = 8 : i64} : i64, !llvm.ptr
    llvm.br ^bb1
  ^bb1:  // 2 preds: ^bb0, ^bb7
    %20 = llvm.load %8 {alignment = 8 : i64} : !llvm.ptr -> i64
    %21 = llvm.load %4 {alignment = 8 : i64} : !llvm.ptr -> i64
    %22 = llvm.icmp "slt" %20, %21 : i64
    llvm.cond_br %22, ^bb2, ^bb8
  ^bb2:  // pred: ^bb1
    llvm.store %2, %9 {alignment = 8 : i64} : i64, !llvm.ptr
    llvm.br ^bb3
  ^bb3:  // 2 preds: ^bb2, ^bb5
    %23 = llvm.load %9 {alignment = 8 : i64} : !llvm.ptr -> i64
    %24 = llvm.load %5 {alignment = 8 : i64} : !llvm.ptr -> i64
    %25 = llvm.icmp "slt" %23, %24 : i64
    llvm.cond_br %25, ^bb4, ^bb6
  ^bb4:  // pred: ^bb3
    %26 = llvm.load %6 {alignment = 8 : i64} : !llvm.ptr -> !llvm.ptr
    %27 = llvm.load %8 {alignment = 8 : i64} : !llvm.ptr -> i64
    %28 = llvm.load %5 {alignment = 8 : i64} : !llvm.ptr -> i64
    %29 = llvm.mul %27, %28 overflow<nsw> : i64
    %30 = llvm.load %9 {alignment = 8 : i64} : !llvm.ptr -> i64
    %31 = llvm.add %29, %30 overflow<nsw> : i64
    %32 = llvm.getelementptr inbounds %26[%31] : (!llvm.ptr, i64) -> !llvm.ptr, f32
    %33 = llvm.load %32 {alignment = 4 : i64} : !llvm.ptr -> f32
    %34 = llvm.load %7 {alignment = 8 : i64} : !llvm.ptr -> !llvm.ptr
    %35 = llvm.load %9 {alignment = 8 : i64} : !llvm.ptr -> i64
    %36 = llvm.load %4 {alignment = 8 : i64} : !llvm.ptr -> i64
    %37 = llvm.mul %35, %36 overflow<nsw> : i64
    %38 = llvm.load %8 {alignment = 8 : i64} : !llvm.ptr -> i64
    %39 = llvm.add %37, %38 overflow<nsw> : i64
    %40 = llvm.getelementptr inbounds %34[%39] : (!llvm.ptr, i64) -> !llvm.ptr, f32
    llvm.store %33, %40 {alignment = 4 : i64} : f32, !llvm.ptr
    llvm.br ^bb5
  ^bb5:  // pred: ^bb4
    %41 = llvm.load %9 {alignment = 8 : i64} : !llvm.ptr -> i64
    %42 = llvm.add %41, %3 overflow<nsw> : i64
    llvm.store %42, %9 {alignment = 8 : i64} : i64, !llvm.ptr
    llvm.br ^bb3 {loop_annotation = #loop_annotation}
  ^bb6:  // pred: ^bb3
    llvm.br ^bb7
  ^bb7:  // pred: ^bb6
    %43 = llvm.load %8 {alignment = 8 : i64} : !llvm.ptr -> i64
    %44 = llvm.add %43, %3 overflow<nsw> : i64
    llvm.store %44, %8 {alignment = 8 : i64} : i64, !llvm.ptr
    llvm.br ^bb1 {loop_annotation = #loop_annotation}
  ^bb8:  // pred: ^bb1
    %45 = llvm.load %7 {alignment = 8 : i64} : !llvm.ptr -> !llvm.ptr
    llvm.return %45 : !llvm.ptr
  }
  llvm.func @malloc(i64 {llvm.noundef}) -> !llvm.ptr attributes {allocsize = array<i32: 0>, dso_local, passthrough = [["no-trapping-math", "true"], ["stack-protector-buffer-size", "8"], ["target-cpu", "x86-64"]], target_cpu = "x86-64", target_features = #llvm.target_features<["+cmov", "+cx8", "+fxsr", "+mmx", "+sse", "+sse2", "+x87"]>, tune_cpu = "generic"}
}
