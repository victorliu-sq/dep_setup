# PROJECT_BINARY_DIR is the build directory for the current project()
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY "${PROJECT_BINARY_DIR}/lib") # output directory of static libraries
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY "${PROJECT_BINARY_DIR}/bin") # output directory of shared libraries
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY "${PROJECT_BINARY_DIR}/bin") # output directory of executables

if (WIN32 AND "${CMAKE_GENERATOR}" MATCHES "^(Visual Studio).*")
  # Base folder for generated PTX / OptiX artifacts.
  set(MODULE_TARGET_DIR "${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/$(ConfigurationName)")
  # Enable multi-processor build in Visual Studio.
  set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} /MP")
else ()
  set(MODULE_TARGET_DIR "${CMAKE_RUNTIME_OUTPUT_DIRECTORY}")
endif ()
