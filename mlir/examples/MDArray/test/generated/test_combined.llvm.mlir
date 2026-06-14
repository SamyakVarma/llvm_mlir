#loop_annotation = #llvm.loop_annotation<mustProgress = true>
module attributes {dlti.dl_spec = #dlti.dl_spec<!llvm.ptr<270> = dense<32> : vector<4xi64>, !llvm.ptr<271> = dense<32> : vector<4xi64>, !llvm.ptr<272> = dense<64> : vector<4xi64>, i64 = dense<64> : vector<2xi64>, i128 = dense<128> : vector<2xi64>, f80 = dense<128> : vector<2xi64>, !llvm.ptr = dense<64> : vector<4xi64>, i1 = dense<8> : vector<2xi64>, i8 = dense<8> : vector<2xi64>, i16 = dense<16> : vector<2xi64>, i32 = dense<32> : vector<2xi64>, f16 = dense<16> : vector<2xi64>, f64 = dense<64> : vector<2xi64>, f128 = dense<128> : vector<2xi64>, "dlti.endianness" = "little", "dlti.mangling_mode" = "w", "dlti.legal_int_widths" = array<i32: 8, 16, 32, 64>, "dlti.stack_alignment" = 128 : i64>, llvm.ident = "clang version 22.1.2 (https://github.com/msys2/MINGW-packages 4f19d31560faf73257116b7c95f0b322ba83d720)", llvm.module_asm = [], llvm.target_triple = "x86_64-w64-windows-gnu"} {
  llvm.module_flags [#llvm.mlir.module_flag<warning, "Debug Info Version", 3 : i32>, #llvm.mlir.module_flag<error, "wchar_size", 2 : i32>, #llvm.mlir.module_flag<min, "PIC Level", 2 : i32>, #llvm.mlir.module_flag<max, "uwtable", 2 : i32>, #llvm.mlir.module_flag<error, "MaxTLSAlign", 65536 : i32>]
  llvm.func @test_combined(%arg0: i64 {llvm.noundef}, %arg1: i64 {llvm.noundef}, %arg2: i64 {llvm.noundef}, %arg3: i64 {llvm.noundef}, %arg4: f32 {llvm.noundef}) -> f32 attributes {dso_local, no_inline, no_unwind, optimize_none, passthrough = [["min-legal-vector-width", "0"], ["no-trapping-math", "true"], ["stack-protector-buffer-size", "8"], ["target-cpu", "x86-64"]], target_cpu = "x86-64", target_features = #llvm.target_features<["+cmov", "+cx8", "+fxsr", "+mmx", "+sse", "+sse2", "+x87"]>, tune_cpu = "generic", uwtable_kind = #llvm.uwtableKind<async>} {
    %0 = llvm.mlir.constant(1 : i32) : i32
    %1 = llvm.mlir.constant(4 : i64) : i64
    %2 = llvm.mlir.constant(0 : i64) : i64
    %3 = llvm.mlir.constant(1 : i64) : i64
    %4 = llvm.alloca %0 x i64 {alignment = 8 : i64} : (i32) -> !llvm.ptr
    %5 = llvm.alloca %0 x i64 {alignment = 8 : i64} : (i32) -> !llvm.ptr
    %6 = llvm.alloca %0 x i64 {alignment = 8 : i64} : (i32) -> !llvm.ptr
    %7 = llvm.alloca %0 x i64 {alignment = 8 : i64} : (i32) -> !llvm.ptr
    %8 = llvm.alloca %0 x f32 {alignment = 4 : i64} : (i32) -> !llvm.ptr
    %9 = llvm.alloca %0 x !llvm.ptr {alignment = 8 : i64} : (i32) -> !llvm.ptr
    %10 = llvm.alloca %0 x !llvm.ptr {alignment = 8 : i64} : (i32) -> !llvm.ptr
    %11 = llvm.alloca %0 x i64 {alignment = 8 : i64} : (i32) -> !llvm.ptr
    %12 = llvm.alloca %0 x i64 {alignment = 8 : i64} : (i32) -> !llvm.ptr
    llvm.store %arg0, %4 {alignment = 8 : i64} : i64, !llvm.ptr
    llvm.store %arg1, %5 {alignment = 8 : i64} : i64, !llvm.ptr
    llvm.store %arg2, %6 {alignment = 8 : i64} : i64, !llvm.ptr
    llvm.store %arg3, %7 {alignment = 8 : i64} : i64, !llvm.ptr
    llvm.store %arg4, %8 {alignment = 4 : i64} : f32, !llvm.ptr
    %13 = llvm.load %4 {alignment = 8 : i64} : !llvm.ptr -> i64
    %14 = llvm.load %5 {alignment = 8 : i64} : !llvm.ptr -> i64
    %15 = llvm.mul %13, %14 overflow<nsw> : i64
    %16 = llvm.mul %15, %1 : i64
    %17 = llvm.call @malloc(%16) {allocsize = array<i32: 0>} : (i64 {llvm.noundef}) -> !llvm.ptr
    llvm.store %17, %9 {alignment = 8 : i64} : !llvm.ptr, !llvm.ptr
    %18 = llvm.load %8 {alignment = 4 : i64} : !llvm.ptr -> f32
    %19 = llvm.load %9 {alignment = 8 : i64} : !llvm.ptr -> !llvm.ptr
    %20 = llvm.load %6 {alignment = 8 : i64} : !llvm.ptr -> i64
    %21 = llvm.load %5 {alignment = 8 : i64} : !llvm.ptr -> i64
    %22 = llvm.mul %20, %21 overflow<nsw> : i64
    %23 = llvm.load %7 {alignment = 8 : i64} : !llvm.ptr -> i64
    %24 = llvm.add %22, %23 overflow<nsw> : i64
    %25 = llvm.getelementptr inbounds %19[%24] : (!llvm.ptr, i64) -> !llvm.ptr, f32
    llvm.store %18, %25 {alignment = 4 : i64} : f32, !llvm.ptr
    %26 = llvm.load %5 {alignment = 8 : i64} : !llvm.ptr -> i64
    %27 = llvm.load %4 {alignment = 8 : i64} : !llvm.ptr -> i64
    %28 = llvm.mul %26, %27 overflow<nsw> : i64
    %29 = llvm.mul %28, %1 : i64
    %30 = llvm.call @malloc(%29) {allocsize = array<i32: 0>} : (i64 {llvm.noundef}) -> !llvm.ptr
    llvm.store %30, %10 {alignment = 8 : i64} : !llvm.ptr, !llvm.ptr
    llvm.store %2, %11 {alignment = 8 : i64} : i64, !llvm.ptr
    llvm.br ^bb1
  ^bb1:  // 2 preds: ^bb0, ^bb7
    %31 = llvm.load %11 {alignment = 8 : i64} : !llvm.ptr -> i64
    %32 = llvm.load %4 {alignment = 8 : i64} : !llvm.ptr -> i64
    %33 = llvm.icmp "slt" %31, %32 : i64
    llvm.cond_br %33, ^bb2, ^bb8
  ^bb2:  // pred: ^bb1
    llvm.store %2, %12 {alignment = 8 : i64} : i64, !llvm.ptr
    llvm.br ^bb3
  ^bb3:  // 2 preds: ^bb2, ^bb5
    %34 = llvm.load %12 {alignment = 8 : i64} : !llvm.ptr -> i64
    %35 = llvm.load %5 {alignment = 8 : i64} : !llvm.ptr -> i64
    %36 = llvm.icmp "slt" %34, %35 : i64
    llvm.cond_br %36, ^bb4, ^bb6
  ^bb4:  // pred: ^bb3
    %37 = llvm.load %9 {alignment = 8 : i64} : !llvm.ptr -> !llvm.ptr
    %38 = llvm.load %11 {alignment = 8 : i64} : !llvm.ptr -> i64
    %39 = llvm.load %5 {alignment = 8 : i64} : !llvm.ptr -> i64
    %40 = llvm.mul %38, %39 overflow<nsw> : i64
    %41 = llvm.load %12 {alignment = 8 : i64} : !llvm.ptr -> i64
    %42 = llvm.add %40, %41 overflow<nsw> : i64
    %43 = llvm.getelementptr inbounds %37[%42] : (!llvm.ptr, i64) -> !llvm.ptr, f32
    %44 = llvm.load %43 {alignment = 4 : i64} : !llvm.ptr -> f32
    %45 = llvm.load %10 {alignment = 8 : i64} : !llvm.ptr -> !llvm.ptr
    %46 = llvm.load %12 {alignment = 8 : i64} : !llvm.ptr -> i64
    %47 = llvm.load %4 {alignment = 8 : i64} : !llvm.ptr -> i64
    %48 = llvm.mul %46, %47 overflow<nsw> : i64
    %49 = llvm.load %11 {alignment = 8 : i64} : !llvm.ptr -> i64
    %50 = llvm.add %48, %49 overflow<nsw> : i64
    %51 = llvm.getelementptr inbounds %45[%50] : (!llvm.ptr, i64) -> !llvm.ptr, f32
    llvm.store %44, %51 {alignment = 4 : i64} : f32, !llvm.ptr
    llvm.br ^bb5
  ^bb5:  // pred: ^bb4
    %52 = llvm.load %12 {alignment = 8 : i64} : !llvm.ptr -> i64
    %53 = llvm.add %52, %3 overflow<nsw> : i64
    llvm.store %53, %12 {alignment = 8 : i64} : i64, !llvm.ptr
    llvm.br ^bb3 {loop_annotation = #loop_annotation}
  ^bb6:  // pred: ^bb3
    llvm.br ^bb7
  ^bb7:  // pred: ^bb6
    %54 = llvm.load %11 {alignment = 8 : i64} : !llvm.ptr -> i64
    %55 = llvm.add %54, %3 overflow<nsw> : i64
    llvm.store %55, %11 {alignment = 8 : i64} : i64, !llvm.ptr
    llvm.br ^bb1 {loop_annotation = #loop_annotation}
  ^bb8:  // pred: ^bb1
    %56 = llvm.load %10 {alignment = 8 : i64} : !llvm.ptr -> !llvm.ptr
    %57 = llvm.load %7 {alignment = 8 : i64} : !llvm.ptr -> i64
    %58 = llvm.load %4 {alignment = 8 : i64} : !llvm.ptr -> i64
    %59 = llvm.mul %57, %58 overflow<nsw> : i64
    %60 = llvm.load %6 {alignment = 8 : i64} : !llvm.ptr -> i64
    %61 = llvm.add %59, %60 overflow<nsw> : i64
    %62 = llvm.getelementptr inbounds %56[%61] : (!llvm.ptr, i64) -> !llvm.ptr, f32
    %63 = llvm.load %62 {alignment = 4 : i64} : !llvm.ptr -> f32
    llvm.return %63 : f32
  }
  llvm.func @malloc(i64 {llvm.noundef}) -> !llvm.ptr attributes {allocsize = array<i32: 0>, dso_local, passthrough = [["no-trapping-math", "true"], ["stack-protector-buffer-size", "8"], ["target-cpu", "x86-64"]], target_cpu = "x86-64", target_features = #llvm.target_features<["+cmov", "+cx8", "+fxsr", "+mmx", "+sse", "+sse2", "+x87"]>, tune_cpu = "generic"}
}
