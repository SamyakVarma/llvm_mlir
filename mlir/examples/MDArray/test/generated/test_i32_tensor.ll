; ModuleID = 'D:/hpe/llvm-project/mlir/examples/MDArray/scripts/../test/src/test_i32_tensor.c'
source_filename = "D:/hpe/llvm-project/mlir/examples/MDArray/scripts/../test/src/test_i32_tensor.c"
target datalayout = "e-m:w-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-f80:128-n8:16:32:64-S128"
target triple = "x86_64-w64-windows-gnu"

; Function Attrs: noinline nounwind optnone uwtable
define dso_local i32 @test_i32_tensor(i64 noundef %0, i64 noundef %1, i64 noundef %2, i64 noundef %3, i32 noundef %4) #0 {
  %6 = alloca i64, align 8
  %7 = alloca i64, align 8
  %8 = alloca i64, align 8
  %9 = alloca i64, align 8
  %10 = alloca i32, align 4
  %11 = alloca ptr, align 8
  store i64 %0, ptr %6, align 8
  store i64 %1, ptr %7, align 8
  store i64 %2, ptr %8, align 8
  store i64 %3, ptr %9, align 8
  store i32 %4, ptr %10, align 4
  %12 = load i64, ptr %6, align 8
  %13 = load i64, ptr %7, align 8
  %14 = mul nsw i64 %12, %13
  %15 = mul i64 %14, 4
  %16 = call ptr @malloc(i64 noundef %15) #2
  store ptr %16, ptr %11, align 8
  %17 = load i32, ptr %10, align 4
  %18 = load ptr, ptr %11, align 8
  %19 = load i64, ptr %8, align 8
  %20 = load i64, ptr %7, align 8
  %21 = mul nsw i64 %19, %20
  %22 = load i64, ptr %9, align 8
  %23 = add nsw i64 %21, %22
  %24 = getelementptr inbounds i32, ptr %18, i64 %23
  store i32 %17, ptr %24, align 4
  %25 = load ptr, ptr %11, align 8
  %26 = load i64, ptr %8, align 8
  %27 = load i64, ptr %7, align 8
  %28 = mul nsw i64 %26, %27
  %29 = load i64, ptr %9, align 8
  %30 = add nsw i64 %28, %29
  %31 = getelementptr inbounds i32, ptr %25, i64 %30
  %32 = load i32, ptr %31, align 4
  ret i32 %32
}

; Function Attrs: allocsize(0)
declare dso_local ptr @malloc(i64 noundef) #1

attributes #0 = { noinline nounwind optnone uwtable "min-legal-vector-width"="0" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cmov,+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #1 = { allocsize(0) "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cmov,+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #2 = { allocsize(0) }

!llvm.dbg.cu = !{!0}
!llvm.module.flags = !{!2, !3, !4, !5, !6}
!llvm.ident = !{!7}

!0 = distinct !DICompileUnit(language: DW_LANG_C11, file: !1, producer: "clang version 22.1.2 (https://github.com/msys2/MINGW-packages 4f19d31560faf73257116b7c95f0b322ba83d720)", isOptimized: false, runtimeVersion: 0, emissionKind: NoDebug, splitDebugInlining: false, nameTableKind: None)
!1 = !DIFile(filename: "D:/hpe/llvm-project/mlir/examples/MDArray/scripts/../test/src/test_i32_tensor.c", directory: "D:/hpe/llvm-project/mlir/examples/MDArray")
!2 = !{i32 2, !"Debug Info Version", i32 3}
!3 = !{i32 1, !"wchar_size", i32 2}
!4 = !{i32 8, !"PIC Level", i32 2}
!5 = !{i32 7, !"uwtable", i32 2}
!6 = !{i32 1, !"MaxTLSAlign", i32 65536}
!7 = !{!"clang version 22.1.2 (https://github.com/msys2/MINGW-packages 4f19d31560faf73257116b7c95f0b322ba83d720)"}
