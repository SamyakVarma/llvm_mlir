; ModuleID = 'D:/hpe/llvm-project/mlir/examples/MDArray/scripts/../test/src/test_combined.c'
source_filename = "D:/hpe/llvm-project/mlir/examples/MDArray/scripts/../test/src/test_combined.c"
target datalayout = "e-m:w-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-f80:128-n8:16:32:64-S128"
target triple = "x86_64-w64-windows-gnu"

; Function Attrs: noinline nounwind optnone uwtable
define dso_local float @test_combined(i64 noundef %0, i64 noundef %1, i64 noundef %2, i64 noundef %3, float noundef %4) #0 {
  %6 = alloca i64, align 8
  %7 = alloca i64, align 8
  %8 = alloca i64, align 8
  %9 = alloca i64, align 8
  %10 = alloca float, align 4
  %11 = alloca ptr, align 8
  %12 = alloca ptr, align 8
  %13 = alloca i64, align 8
  %14 = alloca i64, align 8
  store i64 %0, ptr %6, align 8
  store i64 %1, ptr %7, align 8
  store i64 %2, ptr %8, align 8
  store i64 %3, ptr %9, align 8
  store float %4, ptr %10, align 4
  %15 = load i64, ptr %6, align 8
  %16 = load i64, ptr %7, align 8
  %17 = mul nsw i64 %15, %16
  %18 = mul i64 %17, 4
  %19 = call ptr @malloc(i64 noundef %18) #2
  store ptr %19, ptr %11, align 8
  %20 = load float, ptr %10, align 4
  %21 = load ptr, ptr %11, align 8
  %22 = load i64, ptr %8, align 8
  %23 = load i64, ptr %7, align 8
  %24 = mul nsw i64 %22, %23
  %25 = load i64, ptr %9, align 8
  %26 = add nsw i64 %24, %25
  %27 = getelementptr inbounds float, ptr %21, i64 %26
  store float %20, ptr %27, align 4
  %28 = load i64, ptr %7, align 8
  %29 = load i64, ptr %6, align 8
  %30 = mul nsw i64 %28, %29
  %31 = mul i64 %30, 4
  %32 = call ptr @malloc(i64 noundef %31) #2
  store ptr %32, ptr %12, align 8
  store i64 0, ptr %13, align 8
  br label %33

33:                                               ; preds = %62, %5
  %34 = load i64, ptr %13, align 8
  %35 = load i64, ptr %6, align 8
  %36 = icmp slt i64 %34, %35
  br i1 %36, label %37, label %65

37:                                               ; preds = %33
  store i64 0, ptr %14, align 8
  br label %38

38:                                               ; preds = %58, %37
  %39 = load i64, ptr %14, align 8
  %40 = load i64, ptr %7, align 8
  %41 = icmp slt i64 %39, %40
  br i1 %41, label %42, label %61

42:                                               ; preds = %38
  %43 = load ptr, ptr %11, align 8
  %44 = load i64, ptr %13, align 8
  %45 = load i64, ptr %7, align 8
  %46 = mul nsw i64 %44, %45
  %47 = load i64, ptr %14, align 8
  %48 = add nsw i64 %46, %47
  %49 = getelementptr inbounds float, ptr %43, i64 %48
  %50 = load float, ptr %49, align 4
  %51 = load ptr, ptr %12, align 8
  %52 = load i64, ptr %14, align 8
  %53 = load i64, ptr %6, align 8
  %54 = mul nsw i64 %52, %53
  %55 = load i64, ptr %13, align 8
  %56 = add nsw i64 %54, %55
  %57 = getelementptr inbounds float, ptr %51, i64 %56
  store float %50, ptr %57, align 4
  br label %58

58:                                               ; preds = %42
  %59 = load i64, ptr %14, align 8
  %60 = add nsw i64 %59, 1
  store i64 %60, ptr %14, align 8
  br label %38, !llvm.loop !8

61:                                               ; preds = %38
  br label %62

62:                                               ; preds = %61
  %63 = load i64, ptr %13, align 8
  %64 = add nsw i64 %63, 1
  store i64 %64, ptr %13, align 8
  br label %33, !llvm.loop !10

65:                                               ; preds = %33
  %66 = load ptr, ptr %12, align 8
  %67 = load i64, ptr %9, align 8
  %68 = load i64, ptr %6, align 8
  %69 = mul nsw i64 %67, %68
  %70 = load i64, ptr %8, align 8
  %71 = add nsw i64 %69, %70
  %72 = getelementptr inbounds float, ptr %66, i64 %71
  %73 = load float, ptr %72, align 4
  ret float %73
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
!1 = !DIFile(filename: "D:/hpe/llvm-project/mlir/examples/MDArray/scripts/../test/src/test_combined.c", directory: "D:/hpe/llvm-project/mlir/examples/MDArray")
!2 = !{i32 2, !"Debug Info Version", i32 3}
!3 = !{i32 1, !"wchar_size", i32 2}
!4 = !{i32 8, !"PIC Level", i32 2}
!5 = !{i32 7, !"uwtable", i32 2}
!6 = !{i32 1, !"MaxTLSAlign", i32 65536}
!7 = !{!"clang version 22.1.2 (https://github.com/msys2/MINGW-packages 4f19d31560faf73257116b7c95f0b322ba83d720)"}
!8 = distinct !{!8, !9}
!9 = !{!"llvm.loop.mustprogress"}
!10 = distinct !{!10, !9}
