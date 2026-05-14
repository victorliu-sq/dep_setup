# dep_setup

`dep_setup` provides vendored dependency paths and small CMake helper modules for projects in this repository.

Start every project with the shared dependency path setup:

```cmake
# ------------------------------------------------------------------
# Shared dependency setup
# ------------------------------------------------------------------
set(DEP_SETUP_DIR "${CMAKE_CURRENT_SOURCE_DIR}/dep_setup")
include("${DEP_SETUP_DIR}/cmake/dep_paths.cmake")
```

After that, use `find_package(...)` and `include(...)` only for the dependencies and helpers the project needs.

## General Dependencies

Use normal CMake package discovery:

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

Optional helper scripts:

```cmake
include(configure_build_type)
include("${DEP_SETUP_DIR}/cmake/scripts/build_output_dir.cmake")
```

## CUDA And OptiX

Enable CUDA and find the CUDA/OptiX packages:

```cmake
enable_language(CUDA)
find_package(CUDAToolkit REQUIRED)
find_package(OptiX REQUIRED)
message(STATUS "OptixDir: ${OptiX_INSTALL_DIR}")
```

For OptiX shader compilation helpers:

```cmake
include(optix_compile_shaders)
```

This defines:

```cmake
OPTIX_COMPILE_SHADERS(<output_dir> <generated_files_var>)
```

If you only need low-level CUDA module compilation, include:

```cmake
include(nvcuda_compile_module)
```

## Vulkan

Use Vulkan packages directly after `dep_paths.cmake`:

```cmake
find_package(Vulkan REQUIRED)
find_package(VulkanMemoryAllocator REQUIRED)
```

If the project uses Slang shader helpers:

```cmake
include(CompileSlang)
```
