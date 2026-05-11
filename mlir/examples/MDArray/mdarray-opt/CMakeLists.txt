set(LIBS
    MLIRArithDialect
    MLIRSCFDialect
    MLIRMemRefDialect
    MLIROptLib
    MLIRRegisterAllDialects
    MLIRRegisterAllPasses
    MLIRMdArray
  )
add_llvm_executable(mdarray-opt mdarray-opt.cpp)

llvm_update_compile_flags(mdarray-opt)
target_link_libraries(mdarray-opt PRIVATE ${LIBS})

mlir_check_all_link_libraries(mdarray-opt)
