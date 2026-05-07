# ------------------------------------------------------------------
# CMake modules
# ------------------------------------------------------------------
set(DEP_SETUP_CMAKE_DIR "${CMAKE_CURRENT_LIST_DIR}")
list(APPEND CMAKE_MODULE_PATH "${DEP_SETUP_CMAKE_DIR}")
include(configure_build_type)
include(CompileSlang)

# ------------------------------------------------------------------
# Build options
#
# User controls backend selection explicitly; no automatic GPU detection.
# ------------------------------------------------------------------
if (DEFINED RAYJOIN_BUILD_OPTIX AND NOT DEFINED BUILD_OPTIX_BACKEND)
  set(BUILD_OPTIX_BACKEND "${RAYJOIN_BUILD_OPTIX}" CACHE BOOL
          "Build OptiX/CUDA backend" FORCE)
endif ()

if (DEFINED RAYJOIN_BUILD_VULKAN AND NOT DEFINED BUILD_VULKAN_BACKEND)
  set(BUILD_VULKAN_BACKEND "${RAYJOIN_BUILD_VULKAN}" CACHE BOOL
          "Build Vulkan backend" FORCE)
endif ()

option(BUILD_OPTIX_BACKEND "Build OptiX/CUDA backend" ON)
option(BUILD_VULKAN_BACKEND "Build Vulkan backend" ON)

message(STATUS "BUILD_OPTIX_BACKEND  = ${BUILD_OPTIX_BACKEND}")
message(STATUS "BUILD_VULKAN_BACKEND = ${BUILD_VULKAN_BACKEND}")

# ------------------------------------------------------------------
# Enable CUDA ONLY if the user asked for OptiX/CUDA build
# ------------------------------------------------------------------
if (BUILD_OPTIX_BACKEND)
  include(CheckLanguage)
  check_language(CUDA)

  if (NOT CMAKE_CUDA_COMPILER)
    message(FATAL_ERROR
            "BUILD_OPTIX_BACKEND=ON but no CUDA compiler was found. "
            "Either install CUDA or configure with -DBUILD_OPTIX_BACKEND=OFF")
  endif ()

  enable_language(CUDA)

  # OptiX/CUDA-related modules are only needed in this mode.
  include(FindOptiX)
  include(nvcuda_compile_module)

  # CUDAToolkit is required only for OptiX/CUDA mode.
  find_package(CUDAToolkit REQUIRED)

  if (NOT WIN32)
    set(CUDA_PROPAGATE_HOST_FLAGS ON CACHE STRING
            "Propagate C/CXX_FLAGS and friends to the host compiler via -Xcompile")
  endif ()
endif ()

# ------------------------------------------------------------------
# Dependency discovery
# ------------------------------------------------------------------
list(APPEND CMAKE_PREFIX_PATH "${CMAKE_SOURCE_DIR}/deps")
list(APPEND CMAKE_PREFIX_PATH "${CMAKE_SOURCE_DIR}/deps/vulkansdk/x86_64")

find_package(gflags REQUIRED)
find_package(glog REQUIRED)
find_package(GTest REQUIRED)

# Vulkan dependencies are only required if Vulkan backend is enabled.
if (BUILD_VULKAN_BACKEND)
  find_package(Vulkan REQUIRED)
  find_package(VulkanMemoryAllocator REQUIRED)
endif ()
