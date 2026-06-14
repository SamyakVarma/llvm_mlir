; ModuleID = 'D:/hpe/llvm-project/mlir/examples/MDArray/scripts/../test/src/test_multiple_stores.c'
source_filename = "D:/hpe/llvm-project/mlir/examples/MDArray/scripts/../test/src/test_multiple_stores.c"
target datalayout = "e-m:w-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-f80:128-n8:16:32:64-S128"
target triple = "x86_64-w64-windows-gnu"

; Function Attrs: noinline nounwind optnone uwtable
define dso_local float @test_multiple_stores(i64 noundef %0, i64 noundef %1, i64 noundef %2, i64 noundef %3, float noundef %4, i64 noundef %5, i64 noundef %6, float noundef %7) #0 {
  %9 = alloca i64, align 8
  %10 = alloca i64, align 8
  %11 = alloca i64, align 8
  %12 = alloca i64, align 8
  %13 = alloca float, align 4
  %14 = alloca i64, align 8
  %15 = alloca i64, align 8
  %16 = alloca float, align 4
  %17 = alloca ptr, align 8
  store i64 %0, ptr %9, align 8
  store i64 %1, ptr %10, align 8
  store i64 %2, ptr %11, align 8
  store i64 %3, ptr %12, align 8
  store float %4, ptr %13, align 4
  store i64 %5, ptr %14, align 8
  store i64 %6, ptr %15, align 8
  store float %7, ptr %16, align 4
  %18 = load i64, ptr %9, align 8
  %19 = load i64, ptr %10, align 8
  %20 = mul nsw i64 %18, %19
  %21 = mul i64 %20, 4
  %22 = call ptr @malloc(i64 noundef %21) #2
  store ptr %22, ptr %17, align 8
  %23 = load float, ptr %13, align 4
  %24 = load ptr, ptr %17, align 8
  %25 = load i64, ptr %11, align 8
  %26 = load i64, ptr %10, align 8
  %27 = mul nsw i64 %25, %26
  %28 = load i64, ptr %12, align 8
  %29 = add nsw i64 %27, %28
  %30 = getelementptr inbounds float, ptr %24, i64 %29
  store float %23, ptr %30, align 4
  %31 = load float, ptr %16, align 4
  %32 = load ptr, ptr %17, align 8
  %33 = load i64, ptr %14, align 8
  %34 = load i64, ptr %10, align 8
  %35 = mul nsw i64 %33, %34
  %36 = load i64, ptr %15, align 8
  %37 = add nsw i64 %35, %36
  %38 = getelementptr inbounds float, ptr %32, i64 %37
  store float %31, ptr %38, align 4
  %39 = load ptr, ptr %17, align 8
  %40 = load i64, ptr %11, align 8
  %41 = load i64, ptr %10, align 8
  %42 = mul nsw i64 %40, %41
  %43 = load i64, ptr %12, align 8
  %44 = add nsw i64 %42, %43
  %45 = getelementptr inbounds float, ptr %39, i64 %44
  %46 = load float, ptr %45, align 4
  ret float %46
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
!1 = !DIFile(filename: "D:/hpe/llvm-project/mlir/examples/MDArray/scripts/../test/src/test_multiple_stores.c", directory: "D:/hpe/llvm-project/mlir/examples/MDArray")
!2 = !{i32 2, !"Debug Info Version", i32 3}
!3 = !{i32 1, !"wchar_size", i32 2}
!4 = !{i32 8, !"PIC Level", i32 2}
!5 = !{i32 7, !"uwtable", i32 2}
!6 = !{i32 1, !"MaxTLSAlign", i32 65536}
!7 = !{!"clang version 22.1.2 (https://github.com/msys2/MINGW-packages 4f19d31560faf73257116b7c95f0b322ba83d720)"}
