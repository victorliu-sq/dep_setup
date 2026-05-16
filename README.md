# Build Support

`dep_setup` provides vendored dependency paths and small CMake helper modules for projects in this repository.

In the top-level benchmark `CMakeLists.txt`, define the shared build support directory and prepend its CMake module, helper script, and package prefix paths:
```cmake
# ------------------------------------------------------------------
# JIAIXN: Shared dependency setup
# ------------------------------------------------------------------
set(BUILD_SUPPORT_DIR "${CMAKE_CURRENT_SOURCE_DIR}/dep_setup")

list(PREPEND CMAKE_MODULE_PATH
    "${BUILD_SUPPORT_DIR}/cmake/modules"
    "${BUILD_SUPPORT_DIR}/cmake/scripts"
)

list(PREPEND CMAKE_PREFIX_PATH
    "${BUILD_SUPPORT_DIR}/deps"
    "${BUILD_SUPPORT_DIR}/deps/vulkansdk/x86_64"
)
# ------------------------------------------------------------------
```

In each application `CMakeLists.txt`, reuse the benchmark-provided `BUILD_SUPPORT_DIR` when it is already available. If the application is configured on its own, fall back to the application-local `dep_setup` path:

```cmake
# ------------------------------------------------------------------
# JIAXIN: Shared dependency setup
# ------------------------------------------------------------------
if(DEFINED BUILD_SUPPORT_DIR AND NOT "${BUILD_SUPPORT_DIR}" STREQUAL "")
  message(STATUS "BUILD_SUPPORT_DIR is already set to ${BUILD_SUPPORT_DIR}")
  message(STATUS "BUILD_SUPPORT_DIR is available at ${BUILD_SUPPORT_DIR}")
else ()
  set(BUILD_SUPPORT_DIR "${PROJECT_SOURCE_DIR}/dep_setup")
  message(STATUS "BUILD_SUPPORT_DIR was not set; defaulting to ${BUILD_SUPPORT_DIR}")
endif ()

list(PREPEND CMAKE_MODULE_PATH
    "${BUILD_SUPPORT_DIR}/cmake/modules"
    "${BUILD_SUPPORT_DIR}/cmake/scripts"
)

list(PREPEND CMAKE_PREFIX_PATH
    "${BUILD_SUPPORT_DIR}/deps"
    "${BUILD_SUPPORT_DIR}/deps/vulkansdk/x86_64"
)
# ------------------------------------------------------------------
```
When an application is added through the top-level benchmark project, `BUILD_SUPPORT_DIR` points to the shared repository dependency setup. When an application is configured independently, it uses its own `dep_setup` location.

After that, use `find_package(...)` and `include(...)` only for the dependencies and helpers the project needs.

## General Dependencies

Use normal CMake package discovery after the build support paths have been prepended:

```cmake
find_package(gflags REQUIRED)
find_package(glog REQUIRED)
find_package(GTest REQUIRED)
find_package(rmm REQUIRED)
find_package(nlohmann_json REQUIRED)
find_package(Boost 1.85.0 CONFIG REQUIRED)
find_package(ZLIB REQUIRED)
find_package(HdrHistogram REQUIRED)
```

Include helper scripts only when the project needs them:

```cmake
include(configure_build_type)
include(build_output_dir)
```

## CUDA And OptiX

For projects that build CUDA or OptiX targets, enable CUDA and find the CUDA/OptiX packages:

```cmake
enable_language(CUDA)

find_package(CUDAToolkit REQUIRED)
find_package(OptiX REQUIRED)
message(STATUS "OptixDir: ${OptiX_INSTALL_DIR}")
```

For projects that compile OptiX shaders, include the shader compilation helper:

```cmake
include(optix_compile_shaders)
```

This defines:

```cmake
OPTIX_COMPILE_SHADERS(<output_dir> <generated_files_var>)
`````

For projects that only need low-level CUDA module compilation, include:

```cmake
include(nvcuda_compile_module)
```

## Vulkan

Use Vulkan packages directly after the build support paths have been prepended:

```cmake
find_package(Vulkan REQUIRED)
find_package(VulkanMemoryAllocator REQUIRED)
```

For projects that use Slang shader helpers, include:

```cmake
include(CompileSlang)
```
