add_mlir_dialect_library(MLIRMdArray
        MdArrayDialect.cpp
        MdArrayOps.cpp
        MdArrayPasses.cpp

        ADDITIONAL_HEADER_DIRS
        ${PROJECT_SOURCE_DIR}/include/MdArray

        DEPENDS
        MLIRMdArrayOpsIncGen
        MLIRMdArrayPassesIncGen

        LINK_LIBS PUBLIC
        MLIRIR
        MLIRMemRefDialect
        MLIRSCFDialect
        MLIRArithDialect
        MLIRFuncDialect
        MLIRTransformUtils
        MLIRPass
        )
