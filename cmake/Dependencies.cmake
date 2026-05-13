# ------------------------------------------------------------------
# CMake modules
# ------------------------------------------------------------------
list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_LIST_DIR}")
list(APPEND CMAKE_PREFIX_PATH "${CMAKE_SOURCE_DIR}/deps")
list(APPEND CMAKE_PREFIX_PATH "${CMAKE_SOURCE_DIR}/deps/vulkansdk/x86_64")

include(configure_build_type)
include(CompileSlang)
# ------------------------------------------------------------------
# Dependency discovery
# ------------------------------------------------------------------
find_package(gflags REQUIRED)
find_package(glog REQUIRED)
find_package(GTest REQUIRED)

# ------------------------------------------------------------------
# Enable CUDA ONLY if the user asked for OptiX/CUDA build
# ------------------------------------------------------------------
if (RAYJOIN_BUILD_OPTIX)
  enable_language(CUDA)

  # CUDAToolkit is required only for OptiX/CUDA mode.
  find_package(CUDAToolkit REQUIRED)
  find_package(OptiX REQUIRED)
  message(STATUS "OptixDir: ${OptiX_INSTALL_DIR}")

  include(nvcuda_compile_module)
endif ()

# Vulkan dependencies are only required if Vulkan backend is enabled.
if(RAYJOIN_BUILD_VULKAN)
  find_package(Vulkan REQUIRED)
  find_package(VulkanMemoryAllocator REQUIRED)
endif ()
