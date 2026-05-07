# dep_setup

Shared dependency setup for CMake projects.

## Add to Your Project

Add this repository as a Git submodule in the root of the project that will use
the dependencies:

```bash
git submodule add https://github.com/victorliu-sq/dep_setup.git dep_setup
git submodule update --init --recursive
```

This creates a `dep_setup/` directory inside your project.

## Install Dependencies

After adding and initializing the submodule, run the installer from the root of
your project:

```bash
bash dep_setup/install_all.sh
```

The installer downloads and prepares the dependencies expected by
`dep_setup/cmake/Dependencies.cmake`.

## Use from CMake

In your top-level `CMakeLists.txt`, include the dependency configuration:

```cmake
include(dep_setup/cmake/Dependencies.cmake)
```

Put this before targets that depend on the packages configured by
`Dependencies.cmake`.

Example:

```cmake
cmake_minimum_required(VERSION 3.20)
project(MyProject LANGUAGES C CXX)

include(dep_setup/cmake/Dependencies.cmake)

add_executable(my_app main.cpp)
target_link_libraries(my_app PRIVATE glog::glog gflags GTest::gtest)
```

## Initialize After Cloning

If someone clones your project after `dep_setup` has been added as a submodule,
they should initialize submodules before configuring the build:

```bash
git submodule update --init --recursive
```

## Update dep_setup Later

When this repository has new changes and you want to update the submodule in
your project, run this from the root of your project:

```bash
git submodule update --remote --merge dep_setup
```

Then commit the updated submodule pointer in your project:

```bash
git add dep_setup
git commit -m "Update dep_setup submodule"
```

## Build Options

`Dependencies.cmake` exposes backend options that can be set when configuring
your project:

```bash
cmake -S . -B build -DBUILD_OPTIX_BACKEND=ON -DBUILD_VULKAN_BACKEND=ON
```

Disable a backend if your system does not have the required SDK or compiler:

```bash
cmake -S . -B build -DBUILD_OPTIX_BACKEND=OFF
cmake -S . -B build -DBUILD_VULKAN_BACKEND=OFF
```
