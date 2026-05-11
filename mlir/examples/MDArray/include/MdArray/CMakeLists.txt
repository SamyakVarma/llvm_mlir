add_mlir_dialect(MdArrayOps mdarray)
add_mlir_doc(MdArrayDialect MdArrayDialect MdArray/ -gen-dialect-doc)
add_mlir_doc(MdArrayOps MdArrayOps MdArray/ -gen-op-doc)

set(LLVM_TARGET_DEFINITIONS MdArrayPasses.td)
mlir_tablegen(MdArrayPasses.h.inc --gen-pass-decls)
add_public_tablegen_target(MLIRMdArrayPassesIncGen)
