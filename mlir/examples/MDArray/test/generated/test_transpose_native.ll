; ModuleID = 'd:\hpe\llvm-project\mlir\examples\MDArray\test\src\test_transpose.c'
source_filename = "d:\\hpe\\llvm-project\\mlir\\examples\\MDArray\\test\\src\\test_transpose.c"
target datalayout = "e-m:w-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-f80:128-n8:16:32:64-S128"
target triple = "x86_64-w64-windows-gnu"

; Function Attrs: noinline nounwind optnone uwtable
define dso_local ptr @test_transpose(i64 noundef %0, i64 noundef %1) #0 {
  %3 = alloca i64, align 8
  %4 = alloca i64, align 8
  %5 = alloca ptr, align 8
  %6 = alloca ptr, align 8
  %7 = alloca i64, align 8
  %8 = alloca i64, align 8
  store i64 %0, ptr %3, align 8
  store i64 %1, ptr %4, align 8
  %9 = load i64, ptr %3, align 8
  %10 = load i64, ptr %4, align 8
  %11 = mul nsw i64 %9, %10
  %12 = mul i64 %11, 4
  %13 = call ptr @malloc(i64 noundef %12) #2
  store ptr %13, ptr %5, align 8
  %14 = load i64, ptr %4, align 8
  %15 = load i64, ptr %3, align 8
  %16 = mul nsw i64 %14, %15
  %17 = mul i64 %16, 4
  %18 = call ptr @malloc(i64 noundef %17) #2
  store ptr %18, ptr %6, align 8
  store i64 0, ptr %7, align 8
  br label %19

19:                                               ; preds = %48, %2
  %20 = load i64, ptr %7, align 8
  %21 = load i64, ptr %3, align 8
  %22 = icmp slt i64 %20, %21
  br i1 %22, label %23, label %51

23:                                               ; preds = %19
  store i64 0, ptr %8, align 8
  br label %24

24:                                               ; preds = %44, %23
  %25 = load i64, ptr %8, align 8
  %26 = load i64, ptr %4, align 8
  %27 = icmp slt i64 %25, %26
  br i1 %27, label %28, label %47

28:                                               ; preds = %24
  %29 = load ptr, ptr %5, align 8
  %30 = load i64, ptr %7, align 8
  %31 = load i64, ptr %4, align 8
  %32 = mul nsw i64 %30, %31
  %33 = load i64, ptr %8, align 8
  %34 = add nsw i64 %32, %33
  %35 = getelementptr inbounds float, ptr %29, i64 %34
  %36 = load float, ptr %35, align 4
  %37 = load ptr, ptr %6, align 8
  %38 = load i64, ptr %8, align 8
  %39 = load i64, ptr %3, align 8
  %40 = mul nsw i64 %38, %39
  %41 = load i64, ptr %7, align 8
  %42 = add nsw i64 %40, %41
  %43 = getelementptr inbounds float, ptr %37, i64 %42
  store float %36, ptr %43, align 4
  br label %44

44:                                               ; preds = %28
  %45 = load i64, ptr %8, align 8
  %46 = add nsw i64 %45, 1
  store i64 %46, ptr %8, align 8
  br label %24, !llvm.loop !8

47:                                               ; preds = %24
  br label %48

48:                                               ; preds = %47
  %49 = load i64, ptr %7, align 8
  %50 = add nsw i64 %49, 1
  store i64 %50, ptr %7, align 8
  br label %19, !llvm.loop !10

51:                                               ; preds = %19
  %52 = load ptr, ptr %6, align 8
  ret ptr %52
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
!1 = !DIFile(filename: "d:\\hpe\\llvm-project\\mlir\\examples\\MDArray\\test\\src/test_transpose.c", directory: "D:/hpe/llvm-project")
!2 = !{i32 2, !"Debug Info Version", i32 3}
!3 = !{i32 1, !"wchar_size", i32 2}
!4 = !{i32 8, !"PIC Level", i32 2}
!5 = !{i32 7, !"uwtable", i32 2}
!6 = !{i32 1, !"MaxTLSAlign", i32 65536}
!7 = !{!"clang version 22.1.2 (https://github.com/msys2/MINGW-packages 4f19d31560faf73257116b7c95f0b322ba83d720)"}
!8 = distinct !{!8, !9}
!9 = !{!"llvm.loop.mustprogress"}
!10 = distinct !{!10, !9}
