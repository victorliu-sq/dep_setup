# Generate a custom build rule to translate *.cu files to *.ptx or *.optixir files.
# NVCUDA_COMPILE_MODULE(
#   SOURCES file1.cu file2.cu
#   DEPENDENCIES header1.h header2.h
#   TARGET_PATH <path where output files should be stored>
#   EXTENSION ".ptx" | ".optixir"
#   GENERATED_FILES program_modules
#   NVCC_OPTIONS -arch=sm_50
# )

# Generates *.ptx or *.optixir files for the given source files.
# The program_modules argument will receive the list of generated files.
# DAR Using this because I do not want filenames like "cuda_compile_ptx_generated_raygeneration.cu.ptx" but just "raygeneration.ptx".

FUNCTION(NVCUDA_COMPILE_MODULE)
    if (NOT CMAKE_SIZEOF_VOID_P EQUAL 8)
        message(FATAL_ERROR "ERROR: Only 64-bit programs supported.")
    endif ()

    set(options "")
    set(oneValueArgs TARGET_PATH PREFIX GENERATED_FILES EXTENSION)
    set(multiValueArgs NVCC_OPTIONS SOURCES DEPENDENCIES)

    CMAKE_PARSE_ARGUMENTS(NVCUDA_COMPILE_MODULE "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

    if (NOT WIN32) # Do not create a folder with the name ${ConfigurationName} under Windows.
        # Under Linux make sure the target directory exists.
        FILE(MAKE_DIRECTORY ${NVCUDA_COMPILE_MODULE_TARGET_PATH})
    endif ()

    # Custom build rule to generate either *.ptx or *.optixir files from *.cu files.
    FOREACH (input ${NVCUDA_COMPILE_MODULE_SOURCES})
        get_filename_component(input_we "${input}" NAME_WE)
        get_filename_component(ABS_PATH "${input}" ABSOLUTE)
        string(REPLACE "${CMAKE_CURRENT_SOURCE_DIR}/" "" REL_PATH "${ABS_PATH}")

        # Generate the output *.ptx or *.optixir files directly into the executable's selected target directory.
        set(output "${NVCUDA_COMPILE_MODULE_TARGET_PATH}/${NVCUDA_COMPILE_MODULE_PREFIX}${input_we}${NVCUDA_COMPILE_MODULE_EXTENSION}")
        # message("output = ${output}")

        LIST(APPEND OUTPUT_FILES "${output}")

        # This prints the standalone NVCC command line for each CUDA file.
        # CUDAToolkit_NVCC_EXECUTABLE has been set with FindCUDAToolkit.cmake in CMake 3.17 and newer.
        # message("${CUDAToolkit_NVCC_EXECUTABLE} " "${NVCUDA_COMPILE_MODULE_NVCC_OPTIONS} " "${input} " "-o " "${output}")

        add_custom_command(
                OUTPUT "${output}"
                DEPENDS "${input}" ${NVCUDA_COMPILE_MODULE_DEPENDENCIES}
                COMMAND ${CMAKE_CUDA_COMPILER}
                "$<$<CONFIG:Debug>:-O0;-g;-lineinfo>"
                "$<$<CONFIG:Release>:-DNDEBUG;-O3>"
                "$<$<CONFIG:RelWithDebInfo>:-DNDEBUG;-dopt=on;-g;-O2;-lineinfo>"
                ${NVCUDA_COMPILE_MODULE_NVCC_OPTIONS} "${input}" "-o" "${output}"
                COMMAND_EXPAND_LISTS
                WORKING_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}"
        )
    ENDFOREACH ()
    set(${NVCUDA_COMPILE_MODULE_GENERATED_FILES} ${OUTPUT_FILES} PARENT_SCOPE)
ENDFUNCTION()

set(ENABLED_ARCHS "75")

FUNCTION(RTSPATIAL_COMPILE_SHADERS CALLBACK_INCLUDE_DIR CALLBACK_HEADER OUTPUT_DIR GENERATED_FILES)
    set(FLOAT_TYPES "float;double")

    set(OPTIX_MODULE_EXTENSION ".ptx")
    set(OPTIX_PROGRAM_TARGET "--ptx")

    file(GLOB SHADERS "${PROJECT_SOURCE_DIR}/src/shaders/*.cu")

    foreach (FLOAT_TYPE IN LISTS FLOAT_TYPES)
        message("-- Defining shaders (FLOAT_TYPE: ${FLOAT_TYPE}, CALLBACK_INCLUDE_DIR: ${CALLBACK_INCLUDE_DIR}, CALLBACK_HEADER: ${CALLBACK_HEADER})")
        NVCUDA_COMPILE_MODULE(
                SOURCES ${SHADERS}
                DEPENDENCIES ${SHADERS_HEADERS}
                TARGET_PATH "${OUTPUT_DIR}"
                PREFIX "${FLOAT_TYPE}_"
                EXTENSION "${OPTIX_MODULE_EXTENSION}"
                GENERATED_FILES PROGRAM_MODULES
                NVCC_OPTIONS "${OPTIX_PROGRAM_TARGET}"
                "--gpu-architecture=compute_${ENABLED_ARCHS}"
                "--relocatable-device-code=true"
                "--expt-relaxed-constexpr"
                "-Wno-deprecated-gpu-targets"
                "-I${OptiX_INCLUDE}"
                "-I${PROJECT_SOURCE_DIR}/include"
                "-I${CALLBACK_INCLUDE_DIR}"
                "-DFLOAT_TYPE=${FLOAT_TYPE}"
                -include "${CALLBACK_HEADER}"
        )
        list(APPEND ALL_GENERATED_FILES ${PROGRAM_MODULES})
    endforeach ()
    set(${GENERATED_FILES} ${ALL_GENERATED_FILES} PARENT_SCOPE)
ENDFUNCTION()
