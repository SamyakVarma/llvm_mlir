; ModuleID = 'D:/hpe/llvm-project/mlir/examples/MDArray/scripts/../test/src/test_double_transpose.c'
source_filename = "D:/hpe/llvm-project/mlir/examples/MDArray/scripts/../test/src/test_double_transpose.c"
target datalayout = "e-m:w-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-f80:128-n8:16:32:64-S128"
target triple = "x86_64-w64-windows-gnu"

; Function Attrs: noinline nounwind optnone uwtable
define dso_local ptr @test_double_transpose(i64 noundef %0, i64 noundef %1) #0 {
  %3 = alloca i64, align 8
  %4 = alloca i64, align 8
  %5 = alloca ptr, align 8
  %6 = alloca ptr, align 8
  %7 = alloca i64, align 8
  %8 = alloca i64, align 8
  %9 = alloca ptr, align 8
  %10 = alloca i64, align 8
  %11 = alloca i64, align 8
  store i64 %0, ptr %3, align 8
  store i64 %1, ptr %4, align 8
  %12 = load i64, ptr %3, align 8
  %13 = load i64, ptr %4, align 8
  %14 = mul nsw i64 %12, %13
  %15 = mul i64 %14, 4
  %16 = call ptr @malloc(i64 noundef %15) #2
  store ptr %16, ptr %5, align 8
  %17 = load i64, ptr %4, align 8
  %18 = load i64, ptr %3, align 8
  %19 = mul nsw i64 %17, %18
  %20 = mul i64 %19, 4
  %21 = call ptr @malloc(i64 noundef %20) #2
  store ptr %21, ptr %6, align 8
  store i64 0, ptr %7, align 8
  br label %22

22:                                               ; preds = %51, %2
  %23 = load i64, ptr %7, align 8
  %24 = load i64, ptr %3, align 8
  %25 = icmp slt i64 %23, %24
  br i1 %25, label %26, label %54

26:                                               ; preds = %22
  store i64 0, ptr %8, align 8
  br label %27

27:                                               ; preds = %47, %26
  %28 = load i64, ptr %8, align 8
  %29 = load i64, ptr %4, align 8
  %30 = icmp slt i64 %28, %29
  br i1 %30, label %31, label %50

31:                                               ; preds = %27
  %32 = load ptr, ptr %5, align 8
  %33 = load i64, ptr %7, align 8
  %34 = load i64, ptr %4, align 8
  %35 = mul nsw i64 %33, %34
  %36 = load i64, ptr %8, align 8
  %37 = add nsw i64 %35, %36
  %38 = getelementptr inbounds float, ptr %32, i64 %37
  %39 = load float, ptr %38, align 4
  %40 = load ptr, ptr %6, align 8
  %41 = load i64, ptr %8, align 8
  %42 = load i64, ptr %3, align 8
  %43 = mul nsw i64 %41, %42
  %44 = load i64, ptr %7, align 8
  %45 = add nsw i64 %43, %44
  %46 = getelementptr inbounds float, ptr %40, i64 %45
  store float %39, ptr %46, align 4
  br label %47

47:                                               ; preds = %31
  %48 = load i64, ptr %8, align 8
  %49 = add nsw i64 %48, 1
  store i64 %49, ptr %8, align 8
  br label %27, !llvm.loop !8

50:                                               ; preds = %27
  br label %51

51:                                               ; preds = %50
  %52 = load i64, ptr %7, align 8
  %53 = add nsw i64 %52, 1
  store i64 %53, ptr %7, align 8
  br label %22, !llvm.loop !10

54:                                               ; preds = %22
  %55 = load i64, ptr %3, align 8
  %56 = load i64, ptr %4, align 8
  %57 = mul nsw i64 %55, %56
  %58 = mul i64 %57, 4
  %59 = call ptr @malloc(i64 noundef %58) #2
  store ptr %59, ptr %9, align 8
  store i64 0, ptr %10, align 8
  br label %60

60:                                               ; preds = %89, %54
  %61 = load i64, ptr %10, align 8
  %62 = load i64, ptr %4, align 8
  %63 = icmp slt i64 %61, %62
  br i1 %63, label %64, label %92

64:                                               ; preds = %60
  store i64 0, ptr %11, align 8
  br label %65

65:                                               ; preds = %85, %64
  %66 = load i64, ptr %11, align 8
  %67 = load i64, ptr %3, align 8
  %68 = icmp slt i64 %66, %67
  br i1 %68, label %69, label %88

69:                                               ; preds = %65
  %70 = load ptr, ptr %6, align 8
  %71 = load i64, ptr %10, align 8
  %72 = load i64, ptr %3, align 8
  %73 = mul nsw i64 %71, %72
  %74 = load i64, ptr %11, align 8
  %75 = add nsw i64 %73, %74
  %76 = getelementptr inbounds float, ptr %70, i64 %75
  %77 = load float, ptr %76, align 4
  %78 = load ptr, ptr %9, align 8
  %79 = load i64, ptr %11, align 8
  %80 = load i64, ptr %4, align 8
  %81 = mul nsw i64 %79, %80
  %82 = load i64, ptr %10, align 8
  %83 = add nsw i64 %81, %82
  %84 = getelementptr inbounds float, ptr %78, i64 %83
  store float %77, ptr %84, align 4
  br label %85

85:                                               ; preds = %69
  %86 = load i64, ptr %11, align 8
  %87 = add nsw i64 %86, 1
  store i64 %87, ptr %11, align 8
  br label %65, !llvm.loop !11

88:                                               ; preds = %65
  br label %89

89:                                               ; preds = %88
  %90 = load i64, ptr %10, align 8
  %91 = add nsw i64 %90, 1
  store i64 %91, ptr %10, align 8
  br label %60, !llvm.loop !12

92:                                               ; preds = %60
  %93 = load ptr, ptr %9, align 8
  ret ptr %93
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
!1 = !DIFile(filename: "D:/hpe/llvm-project/mlir/examples/MDArray/scripts/../test/src/test_double_transpose.c", directory: "D:/hpe/llvm-project/mlir/examples/MDArray")
!2 = !{i32 2, !"Debug Info Version", i32 3}
!3 = !{i32 1, !"wchar_size", i32 2}
!4 = !{i32 8, !"PIC Level", i32 2}
!5 = !{i32 7, !"uwtable", i32 2}
!6 = !{i32 1, !"MaxTLSAlign", i32 65536}
!7 = !{!"clang version 22.1.2 (https://github.com/msys2/MINGW-packages 4f19d31560faf73257116b7c95f0b322ba83d720)"}
!8 = distinct !{!8, !9}
!9 = !{!"llvm.loop.mustprogress"}
!10 = distinct !{!10, !9}
!11 = distinct !{!11, !9}
!12 = distinct !{!12, !9}
