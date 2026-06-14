#loop_annotation = #llvm.loop_annotation<mustProgress = true>
module attributes {dlti.dl_spec = #dlti.dl_spec<!llvm.ptr<270> = dense<32> : vector<4xi64>, !llvm.ptr<271> = dense<32> : vector<4xi64>, !llvm.ptr<272> = dense<64> : vector<4xi64>, i64 = dense<64> : vector<2xi64>, i128 = dense<128> : vector<2xi64>, f80 = dense<128> : vector<2xi64>, !llvm.ptr = dense<64> : vector<4xi64>, i1 = dense<8> : vector<2xi64>, i8 = dense<8> : vector<2xi64>, i16 = dense<16> : vector<2xi64>, i32 = dense<32> : vector<2xi64>, f16 = dense<16> : vector<2xi64>, f64 = dense<64> : vector<2xi64>, f128 = dense<128> : vector<2xi64>, "dlti.endianness" = "little", "dlti.mangling_mode" = "w", "dlti.legal_int_widths" = array<i32: 8, 16, 32, 64>, "dlti.stack_alignment" = 128 : i64>, llvm.ident = "clang version 22.1.2 (https://github.com/msys2/MINGW-packages 4f19d31560faf73257116b7c95f0b322ba83d720)", llvm.module_asm = [], llvm.target_triple = "x86_64-w64-windows-gnu"} {
  llvm.module_flags [#llvm.mlir.module_flag<warning, "Debug Info Version", 3 : i32>, #llvm.mlir.module_flag<error, "wchar_size", 2 : i32>, #llvm.mlir.module_flag<min, "PIC Level", 2 : i32>, #llvm.mlir.module_flag<max, "uwtable", 2 : i32>, #llvm.mlir.module_flag<error, "MaxTLSAlign", 65536 : i32>]
  llvm.func @test_double_transpose(%arg0: i64 {llvm.noundef}, %arg1: i64 {llvm.noundef}) -> !llvm.ptr attributes {dso_local, no_inline, no_unwind, optimize_none, passthrough = [["min-legal-vector-width", "0"], ["no-trapping-math", "true"], ["stack-protector-buffer-size", "8"], ["target-cpu", "x86-64"]], target_cpu = "x86-64", target_features = #llvm.target_features<["+cmov", "+cx8", "+fxsr", "+mmx", "+sse", "+sse2", "+x87"]>, tune_cpu = "generic", uwtable_kind = #llvm.uwtableKind<async>} {
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
    %10 = llvm.alloca %0 x !llvm.ptr {alignment = 8 : i64} : (i32) -> !llvm.ptr
    %11 = llvm.alloca %0 x i64 {alignment = 8 : i64} : (i32) -> !llvm.ptr
    %12 = llvm.alloca %0 x i64 {alignment = 8 : i64} : (i32) -> !llvm.ptr
    llvm.store %arg0, %4 {alignment = 8 : i64} : i64, !llvm.ptr
    llvm.store %arg1, %5 {alignment = 8 : i64} : i64, !llvm.ptr
    %13 = llvm.load %4 {alignment = 8 : i64} : !llvm.ptr -> i64
    %14 = llvm.load %5 {alignment = 8 : i64} : !llvm.ptr -> i64
    %15 = llvm.mul %13, %14 overflow<nsw> : i64
    %16 = llvm.mul %15, %1 : i64
    %17 = llvm.call @malloc(%16) {allocsize = array<i32: 0>} : (i64 {llvm.noundef}) -> !llvm.ptr
    llvm.store %17, %6 {alignment = 8 : i64} : !llvm.ptr, !llvm.ptr
    %18 = llvm.load %5 {alignment = 8 : i64} : !llvm.ptr -> i64
    %19 = llvm.load %4 {alignment = 8 : i64} : !llvm.ptr -> i64
    %20 = llvm.mul %18, %19 overflow<nsw> : i64
    %21 = llvm.mul %20, %1 : i64
    %22 = llvm.call @malloc(%21) {allocsize = array<i32: 0>} : (i64 {llvm.noundef}) -> !llvm.ptr
    llvm.store %22, %7 {alignment = 8 : i64} : !llvm.ptr, !llvm.ptr
    llvm.store %2, %8 {alignment = 8 : i64} : i64, !llvm.ptr
    llvm.br ^bb1
  ^bb1:  // 2 preds: ^bb0, ^bb7
    %23 = llvm.load %8 {alignment = 8 : i64} : !llvm.ptr -> i64
    %24 = llvm.load %4 {alignment = 8 : i64} : !llvm.ptr -> i64
    %25 = llvm.icmp "slt" %23, %24 : i64
    llvm.cond_br %25, ^bb2, ^bb8
  ^bb2:  // pred: ^bb1
    llvm.store %2, %9 {alignment = 8 : i64} : i64, !llvm.ptr
    llvm.br ^bb3
  ^bb3:  // 2 preds: ^bb2, ^bb5
    %26 = llvm.load %9 {alignment = 8 : i64} : !llvm.ptr -> i64
    %27 = llvm.load %5 {alignment = 8 : i64} : !llvm.ptr -> i64
    %28 = llvm.icmp "slt" %26, %27 : i64
    llvm.cond_br %28, ^bb4, ^bb6
  ^bb4:  // pred: ^bb3
    %29 = llvm.load %6 {alignment = 8 : i64} : !llvm.ptr -> !llvm.ptr
    %30 = llvm.load %8 {alignment = 8 : i64} : !llvm.ptr -> i64
    %31 = llvm.load %5 {alignment = 8 : i64} : !llvm.ptr -> i64
    %32 = llvm.mul %30, %31 overflow<nsw> : i64
    %33 = llvm.load %9 {alignment = 8 : i64} : !llvm.ptr -> i64
    %34 = llvm.add %32, %33 overflow<nsw> : i64
    %35 = llvm.getelementptr inbounds %29[%34] : (!llvm.ptr, i64) -> !llvm.ptr, f32
    %36 = llvm.load %35 {alignment = 4 : i64} : !llvm.ptr -> f32
    %37 = llvm.load %7 {alignment = 8 : i64} : !llvm.ptr -> !llvm.ptr
    %38 = llvm.load %9 {alignment = 8 : i64} : !llvm.ptr -> i64
    %39 = llvm.load %4 {alignment = 8 : i64} : !llvm.ptr -> i64
    %40 = llvm.mul %38, %39 overflow<nsw> : i64
    %41 = llvm.load %8 {alignment = 8 : i64} : !llvm.ptr -> i64
    %42 = llvm.add %40, %41 overflow<nsw> : i64
    %43 = llvm.getelementptr inbounds %37[%42] : (!llvm.ptr, i64) -> !llvm.ptr, f32
    llvm.store %36, %43 {alignment = 4 : i64} : f32, !llvm.ptr
    llvm.br ^bb5
  ^bb5:  // pred: ^bb4
    %44 = llvm.load %9 {alignment = 8 : i64} : !llvm.ptr -> i64
    %45 = llvm.add %44, %3 overflow<nsw> : i64
    llvm.store %45, %9 {alignment = 8 : i64} : i64, !llvm.ptr
    llvm.br ^bb3 {loop_annotation = #loop_annotation}
  ^bb6:  // pred: ^bb3
    llvm.br ^bb7
  ^bb7:  // pred: ^bb6
    %46 = llvm.load %8 {alignment = 8 : i64} : !llvm.ptr -> i64
    %47 = llvm.add %46, %3 overflow<nsw> : i64
    llvm.store %47, %8 {alignment = 8 : i64} : i64, !llvm.ptr
    llvm.br ^bb1 {loop_annotation = #loop_annotation}
  ^bb8:  // pred: ^bb1
    %48 = llvm.load %4 {alignment = 8 : i64} : !llvm.ptr -> i64
    %49 = llvm.load %5 {alignment = 8 : i64} : !llvm.ptr -> i64
    %50 = llvm.mul %48, %49 overflow<nsw> : i64
    %51 = llvm.mul %50, %1 : i64
    %52 = llvm.call @malloc(%51) {allocsize = array<i32: 0>} : (i64 {llvm.noundef}) -> !llvm.ptr
    llvm.store %52, %10 {alignment = 8 : i64} : !llvm.ptr, !llvm.ptr
    llvm.store %2, %11 {alignment = 8 : i64} : i64, !llvm.ptr
    llvm.br ^bb9
  ^bb9:  // 2 preds: ^bb8, ^bb15
    %53 = llvm.load %11 {alignment = 8 : i64} : !llvm.ptr -> i64
    %54 = llvm.load %5 {alignment = 8 : i64} : !llvm.ptr -> i64
    %55 = llvm.icmp "slt" %53, %54 : i64
    llvm.cond_br %55, ^bb10, ^bb16
  ^bb10:  // pred: ^bb9
    llvm.store %2, %12 {alignment = 8 : i64} : i64, !llvm.ptr
    llvm.br ^bb11
  ^bb11:  // 2 preds: ^bb10, ^bb13
    %56 = llvm.load %12 {alignment = 8 : i64} : !llvm.ptr -> i64
    %57 = llvm.load %4 {alignment = 8 : i64} : !llvm.ptr -> i64
    %58 = llvm.icmp "slt" %56, %57 : i64
    llvm.cond_br %58, ^bb12, ^bb14
  ^bb12:  // pred: ^bb11
    %59 = llvm.load %7 {alignment = 8 : i64} : !llvm.ptr -> !llvm.ptr
    %60 = llvm.load %11 {alignment = 8 : i64} : !llvm.ptr -> i64
    %61 = llvm.load %4 {alignment = 8 : i64} : !llvm.ptr -> i64
    %62 = llvm.mul %60, %61 overflow<nsw> : i64
    %63 = llvm.load %12 {alignment = 8 : i64} : !llvm.ptr -> i64
    %64 = llvm.add %62, %63 overflow<nsw> : i64
    %65 = llvm.getelementptr inbounds %59[%64] : (!llvm.ptr, i64) -> !llvm.ptr, f32
    %66 = llvm.load %65 {alignment = 4 : i64} : !llvm.ptr -> f32
    %67 = llvm.load %10 {alignment = 8 : i64} : !llvm.ptr -> !llvm.ptr
    %68 = llvm.load %12 {alignment = 8 : i64} : !llvm.ptr -> i64
    %69 = llvm.load %5 {alignment = 8 : i64} : !llvm.ptr -> i64
    %70 = llvm.mul %68, %69 overflow<nsw> : i64
    %71 = llvm.load %11 {alignment = 8 : i64} : !llvm.ptr -> i64
    %72 = llvm.add %70, %71 overflow<nsw> : i64
    %73 = llvm.getelementptr inbounds %67[%72] : (!llvm.ptr, i64) -> !llvm.ptr, f32
    llvm.store %66, %73 {alignment = 4 : i64} : f32, !llvm.ptr
    llvm.br ^bb13
  ^bb13:  // pred: ^bb12
    %74 = llvm.load %12 {alignment = 8 : i64} : !llvm.ptr -> i64
    %75 = llvm.add %74, %3 overflow<nsw> : i64
    llvm.store %75, %12 {alignment = 8 : i64} : i64, !llvm.ptr
    llvm.br ^bb11 {loop_annotation = #loop_annotation}
  ^bb14:  // pred: ^bb11
    llvm.br ^bb15
  ^bb15:  // pred: ^bb14
    %76 = llvm.load %11 {alignment = 8 : i64} : !llvm.ptr -> i64
    %77 = llvm.add %76, %3 overflow<nsw> : i64
    llvm.store %77, %11 {alignment = 8 : i64} : i64, !llvm.ptr
    llvm.br ^bb9 {loop_annotation = #loop_annotation}
  ^bb16:  // pred: ^bb9
    %78 = llvm.load %10 {alignment = 8 : i64} : !llvm.ptr -> !llvm.ptr
    llvm.return %78 : !llvm.ptr
  }
  llvm.func @malloc(i64 {llvm.noundef}) -> !llvm.ptr attributes {allocsize = array<i32: 0>, dso_local, passthrough = [["no-trapping-math", "true"], ["stack-protector-buffer-size", "8"], ["target-cpu", "x86-64"]], target_cpu = "x86-64", target_features = #llvm.target_features<["+cmov", "+cx8", "+fxsr", "+mmx", "+sse", "+sse2", "+x87"]>, tune_cpu = "generic"}
}
