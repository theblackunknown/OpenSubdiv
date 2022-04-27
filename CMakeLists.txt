#
#   Copyright 2013 Pixar
#
#   Licensed under the Apache License, Version 2.0 (the "Apache License")
#   with the following modification; you may not use this file except in
#   compliance with the Apache License and the following modification to it:
#   Section 6. Trademarks. is deleted and replaced with:
#
#   6. Trademarks. This License does not grant permission to use the trade
#      names, trademarks, service marks, or product names of the Licensor
#      and its affiliates, except as required to comply with Section 4(c) of
#      the License and to reproduce the content of the NOTICE file.
#
#   You may obtain a copy of the Apache License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the Apache License with the above modification is
#   distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
#   KIND, either express or implied. See the Apache License for the specific
#   language governing permissions and limitations under the Apache License.
#

cmake_minimum_required(VERSION 3.23 FATAL_ERROR)

#
# CMake Options (before `project` to support vcpkg manifest mode features).
#

include(CMakeDependentOption)

set(PTEX_LOCATION "" CACHE FILEPATH "Path to Ptex")
set(GLEW_LOCATION "" CACHE FILEPATH "Path to GLEW")
set(GLFW_LOCATION "" CACHE FILEPATH "Path to GLFW")

option(BUILD_SHARED_LIBS "Build shared libraries" ON)
option(BUILD_TESTING     "Build tests" ON) 

option(NO_LIB        "Disable the opensubdiv libs build (caveat emptor)" OFF)
option(NO_EXAMPLES   "Disable examples build" OFF)
option(NO_TUTORIALS  "Disable tutorials build" OFF)
option(NO_PTEX       "Disable PTex support" OFF)
option(NO_DOC        "Disable documentation build" OFF)
option(NO_OMP        "Disable OpenMP backend" OFF)
option(NO_TBB        "Disable TBB backend" OFF)
option(NO_CUDA       "Disable CUDA backend" OFF)
option(NO_OPENCL     "Disable OpenCL backend" OFF)
option(NO_CLEW       "Disable CLEW wrapper library" OFF)
option(NO_OPENGL     "Disable OpenGL support")
option(NO_GLEW       "Disable use of GLEW" ON)

option(OPENSUBDIV_GREGORY_EVAL_TRUE_DERIVATIVES "Enable true derivative evaluation for Gregory basis patches" OFF)

cmake_dependent_option(NO_DX           "Disable DirectX support" OFF "WIN32" ON)
cmake_dependent_option(NO_METAL        "Disable Metal support" OFF "APPLE" ON)
cmake_dependent_option(NO_TESTS        "Disable all tests" OFF "BUILD_TESTING" ON)
cmake_dependent_option(NO_GLTESTS      "Disable GL tests" OFF "BUILD_TESTING;NOT NO_OPENGL" ON)
cmake_dependent_option(NO_REGRESSION   "Disable regression tests build" OFF "BUILD_TESTING" ON)
cmake_dependent_option(NO_GLFW        "Disable components depending on GLFW" OFF "NOT NO_OPENGL;NOT ANDROID;NOT IOS" ON)
cmake_dependent_option(NO_GLFW_X11     "Disable GLFW components depending on X11" OFF "UNIX;NOT NO_GLFW" ON)
cmake_dependent_option(MSVC_STATIC_CRT "Statically link MSVC CRT" OFF "MSVC" OFF)

#
# vcpkg  features.
#

if(NOT NO_EXAMPLES)
    list(APPEND VCPKG_MANIFEST_FEATURES "examples")
    message(STATUS "[vcpkg] enabling feature: examples")
endif()
if(NOT NO_TUTORIALS)
    list(APPEND VCPKG_MANIFEST_FEATURES "tutorials")
    message(STATUS "[vcpkg] enabling feature: tutorials")
endif()
if(NOT NO_TESTS)
    list(APPEND VCPKG_MANIFEST_FEATURES "tests")
    message(STATUS "[vcpkg] enabling feature: tests")
endif()
if(NOT NO_REGRESSION)
    list(APPEND VCPKG_MANIFEST_FEATURES "tests-regression")
    message(STATUS "[vcpkg] enabling feature: tests-regression")
endif()
if(NOT NO_GLTESTS)
    list(APPEND VCPKG_MANIFEST_FEATURES "tests-opengl")
    message(STATUS "[vcpkg] enabling feature: tests-opengl")
endif()
if(NOT NO_DOC)
    list(APPEND VCPKG_MANIFEST_FEATURES "docs")
    message(STATUS "[vcpkg] enabling feature: docs")
endif()

if(NOT NO_PTEX)
    list(APPEND VCPKG_MANIFEST_FEATURES "ptex")
    message(STATUS "[vcpkg] enabling feature: ptex")
endif()
if(NOT NO_OMP)
    list(APPEND VCPKG_MANIFEST_FEATURES "omp")
    message(STATUS "[vcpkg] enabling feature: omp")
endif()
if(NOT NO_TBB)
    list(APPEND VCPKG_MANIFEST_FEATURES "tbb")
    message(STATUS "[vcpkg] enabling feature: tbb")
endif()
if(NOT NO_CUDA)
    list(APPEND VCPKG_MANIFEST_FEATURES "cuda")
    message(STATUS "[vcpkg] enabling feature: cuda")
endif()
if(NOT NO_OPENCL)
    list(APPEND VCPKG_MANIFEST_FEATURES "opencl")
    message(STATUS "[vcpkg] enabling feature: opencl")
endif()
if(NOT NO_OPENGL)
    list(APPEND VCPKG_MANIFEST_FEATURES "opengl")
    message(STATUS "[vcpkg] enabling feature: opengl")
endif()
if(NOT NO_METAL)
    list(APPEND VCPKG_MANIFEST_FEATURES "metal")
    message(STATUS "[vcpkg] enabling feature: metal")
endif()
if(NOT NO_DX)
    list(APPEND VCPKG_MANIFEST_FEATURES "dx")
    message(STATUS "[vcpkg] enabling feature: dx")
endif()

if(NOT NO_CLEW)
    list(APPEND VCPKG_MANIFEST_FEATURES "clew")
    message(STATUS "[vcpkg] enabling feature: clew")
endif()
if(NOT NO_GLEW)
    list(APPEND VCPKG_MANIFEST_FEATURES "glew")
    message(STATUS "[vcpkg] enabling feature: glew")
endif()
if(NOT NO_GLFW)
    list(APPEND VCPKG_MANIFEST_FEATURES "glfw")
    message(STATUS "[vcpkg] enabling feature: glfw")
endif()

if(NOT OPENSUBDIV_GREGORY_EVAL_TRUE_DERIVATIVES)
    list(APPEND VCPKG_MANIFEST_FEATURES "true-deriv-eval")
    message(STATUS "[vcpkg] enabling feature: true-deriv-eval")
endif()

#
# CMake Configuration.
#

#-------------------------------------------------------------------------------
# Obtain OpenSubdiv API version from version.h file
if(EXISTS "${CMAKE_CURRENT_LIST_DIR}/opensubdiv/version.h")
    file(STRINGS "${CMAKE_CURRENT_LIST_DIR}/opensubdiv/version.h" OpenSubdiv_VERSION REGEX "^#define OPENSUBDIV_VERSION .*$")
    string(REPLACE "#define OPENSUBDIV_VERSION " "" OpenSubdiv_VERSION ${OpenSubdiv_VERSION})

    # Evaluate 'soname' from OSD version

    # replace '_' with '.'
    string(REGEX REPLACE "(_)" "." OSD_SONAME ${OpenSubdiv_VERSION})
    # remove starting 'v' character
    string(REGEX REPLACE "^v" "" OSD_SONAME ${OSD_SONAME})
else()
    message(FATAL_ERROR "Cannot locate opensubdiv/version.h in ${OpenSubdiv_SOURCE_DIR}")
endif()

# # Evaluate 'soname' from OSD version

# # replace '_' with '.'
# string(REGEX REPLACE "(_)" "." OSD_SONAME ${OpenSubdiv_VERSION})

# # remove starting 'v' character
# string(REGEX REPLACE "^v" "" OSD_SONAME ${OSD_SONAME})

# add_definitions(
#     -DOPENSUBDIV_VERSION_STRING="${OSD_SONAME}"
# )

#-------------------------------------------------------------------------------

project(OpenSubdiv
    VERSION ${OSD_SONAME}
    DESCRIPTION "An Open-Source subdivision surface library."
    HOMEPAGE_URL "https://github.com/PixarAnimationStudios/OpenSubdiv"
)

message(STATUS "[${PROJECT_NAME}] Compiling ${PROJECT_NAME} version ${OpenSubdiv_VERSION}")
message(STATUS "[${PROJECT_NAME}] Using cmake version ${CMAKE_VERSION}")

if(PROJECT_IS_TOP_LEVEL)
    message(STATUS "[${PROJECT_NAME}] ${PROJECT_NAME} is the top level project")
else()
    message(STATUS "[${PROJECT_NAME}] ${PROJECT_NAME} is a subproject of ${CMAKE_PROJECT_NAME}")
endif()

# Ignore rules that will re-run cmake (this will avoid constant
# reloading of the generated Visual Studio project).
if(PROJECT_IS_TOP_LEVEL AND CMAKE_GENERATOR MATCHES "Visual Studio")
    set(CMAKE_SUPPRESS_REGENERATION TRUE)
endif()

# Turn on folder support
set_property(GLOBAL PROPERTY USE_FOLDERS ON)

#
# CMake Libraries.
#

include(CTest)
include(GNUInstallDirs)
include(CMakePrintHelpers)
include(CMakePackageConfigHelpers)

include(cmake/osd_find_opengl_version.cmake)
include(cmake/osd_target_compile_definitions.cmake)
include(cmake/osd_target_compile_features.cmake)
include(cmake/osd_target_compile_options.cmake)
include(cmake/osd_target_include_directories.cmake)
include(cmake/osd_target_link_system_libraries.cmake)
include(cmake/osd_target_link_cpu_dependencies_libraries.cmake)
include(cmake/osd_target_link_gpu_dependencies_libraries.cmake)
include(cmake/osd_target_warning_options.cmake)

#
# CMake Packages.
#

# Specify the list of directories to search for cmake modules.
list(APPEND CMAKE_MODULE_PATH
    "${CMAKE_CURRENT_SOURCE_DIR}/cmake"
)
if(PROJECT_IS_TOP_LEVEL)
    if(NOT NO_OMP)
        find_package(OpenMP REQUIRED)
    endif()
    if(NOT NO_TBB)
        find_package(TBB 4.0 REQUIRED)
    endif()
    if(NOT NO_OPENGL)
        find_package(OpenGL REQUIRED)
    endif()

    find_package(OpenGLES)

    if(NOT NO_OPENCL)
        if(NOT NO_CLEW)
            find_package(CLEW)
        endif()
        if (NOT CLEW_FOUND)
            find_package(OpenCL 1.1 REQUIRED)
        else()
            set(OpenCL_FOUND TRUE)
        endif()
    endif()

    if(NOT NO_CUDA)
        enable_language(CUDA)
        find_package(CUDAToolkit 4.0 REQUIRED)
    endif()

    if(NOT NO_GLFW)
        find_package(glfw3 REQUIRED)
    endif()

    if(NOT NO_PTEX)
       find_package(PTex 2.0 REQUIRED)
    endif()

    if(NOT NO_METAL)
        enable_language(OBJCXX)
        find_library(METAL_LIBRARY Metal)
        find_library(FOUNDATION_LIBRARY Foundation)
    endif()

    if (NOT NO_GLEW)
        find_package(GLEW REQUIRED)
    endif()

    if (NOT NO_DX)
        find_package(DXSDK REQUIRED)
    endif()

    if (NOT NO_DOC)
        find_package(Doxygen 1.8.4 REQUIRED)
        find_package(Docutils 0.9 REQUIRED)
    endif()
else()
    # TODO
endif()

#
# Setup post-packages.
#

set(OSD_GPU FALSE)

if( METAL_FOUND AND NOT NO_METAL)
    set(OSD_GPU TRUE)
elseif( OPENGL_FOUND AND NOT NO_OPENGL)
    set(OSD_GPU TRUE)
elseif( OPENGLES_FOUND)
    set(OSD_GPU TRUE)
elseif( OPENCL_FOUND AND NOT NO_OPENCL )
    set(OSD_GPU TRUE)
elseif( CUDA_FOUND AND NOT NO_CUDA )
    set(OSD_GPU TRUE)
elseif( DXSDK_FOUND AND NOT NO_DX )
    set(OSD_GPU TRUE)
endif()

# Warn about missing dependencies that will cause parts of OpenSubdiv to be
# disabled.

if(NOT OPENMP_FOUND AND NOT NO_OMP)
    message(WARNING
        "OpenMP was not found : support for OMP parallel compute kernels "
        "will be disabled in Osd.  If your compiler supports OpenMP "
        "directives, please refer to the FindOpenMP.cmake shared module "
        "in your cmake installation.")
endif()

if(NOT TBB_FOUND AND NOT NO_TBB)
    message(WARNING
        "TBB was not found : support for TBB parallel compute kernels "
        "will be disabled in Osd.  If your compiler supports TBB "
        "directives, please refer to the FindTBB.cmake shared module "
        "in your cmake installation.")
endif()

if(OPENGL_FOUND AND NOT NO_OPENGL)
    osd_find_opengl_version(OpenGL_VERSION)
    # note : (GLSL transform feedback kernels require GL 4.2)
    if(OpenGL_VERSION VERSION_LESS 4.2)
        message(WARNING
            "OpenGL 4.2 was not found : support for GLSL transform feedback kernels "
            "will be disabled in Osd.  If you have an OpenGL SDK installed "
            "(version 4.2 or above), please refer to the FindOpenGL.cmake "
            "shared module in your cmake installation.")
    # note : (GLSL compute shader kernels require GL 4.3)
    elseif(OpenGL_VERSION VERSION_LESS 4.3)
        message(WARNING
            "OpenGL 4.3 was not found : support for GLSL compute shader kernels "
            "will be disabled in Osd.  If you have an OpenGL SDK installed "
            "(version 4.3 or above), please refer to the FindOpenGL.cmake "
            "shared module in your cmake installation.")
    endif()
endif()

# if(OPENCL_FOUND AND CLEW_FOUND)
#     set(OPENCL_INCLUDE_DIRS ${CLEW_INCLUDE_DIR})
#     set(OPENCL_LIBRARIES ${CLEW_LIBRARY} ${CMAKE_DL_LIBS})
# endif()

if(OPENCL_FOUND AND NOT NO_CLEW)
    message(WARNING
        "OpenCL was found, but CLEW was not. "
        "Building with OpenCL support enabled, but the built binary "
        "will not be portable to systems without OpenCL installed.")
endif()

if(OPENCL_FOUND AND NOT NO_OPENCL)
    message(WARNING
        "OpenCL was not found : support for OpenCL parallel compute kernels "
        "will be disabled in Osd.  If you have the OpenCL SDK installed, "
        "please refer to the FindOpenCL.cmake in ${PROJECT_SOURCE_DIR}/cmake.")
endif()

if(NOT PTEX_FOUND AND NOT NO_PTEX)
    message(WARNING
        "Ptex was not found : the OpenSubdiv Ptex example will not be "
        "available.  If you do have Ptex installed and see this message, "
        "please add your Ptex path to FindPTex.cmake in "
        "${PROJECT_SOURCE_DIR}/cmake or set it through the PTEX_LOCATION "
        "cmake command line argument or environment variable.")
endif()

if(NOT DXSDK_FOUND AND NOT NO_DX)
    message(WARNING
        "DirectX11 SDK was not found. "
        "If you do have DXSDK installed and see this message, "
        "please add your sdk path to FindDirectX.cmake in "
        "${PROJECT_SOURCE_DIR}/cmake or set it through the "
        "DXSDK_LOCATION cmake command line argument or "
        "environment variable.")
endif()

# if(OPENCL_FOUND)
#     if (DXSDK_FOUND AND NOT NO_DX)
#         if (OPENCL_CL_D3D11_H_FOUND)
#             set(OPENCL_D3D11_INTEROP_FOUND "YES")
#         endif()
#         if (OPENCL_CL_D3D11_EXT_H_FOUND)
#             set(OPENCL_D3D11_INTEROP_FOUND "YES")
#         endif()
#     endif()
# endif()

# if(GLEW_FOUND AND GLEW_INCLUDE_DIR)
#     osd_detect_gl_version(${GLEW_INCLUDE_DIR}/GL/glew.h)
#     set(OPENGL_LOADER_INCLUDE_DIRS
#         ${GLEW_INCLUDE_DIR}
#         ${PROJECT_SOURCE_DIR}/glLoader)
#     set(OPENGL_LOADER_LIBRARIES
#         ${GLEW_LIBRARY}
#         ${OPENGL_gl_LIBRARY}
#         ${CMAKE_DL_LIBS})
# elseif(OPENGL_FOUND)
#     osd_detect_gl_version(${PROJECT_SOURCE_DIR}/glLoader/glApi.h)
#     set(OPENGL_LOADER_INCLUDE_DIRS
#         ${OPENGL_INCLUDE_DIR}
#         ${PROJECT_SOURCE_DIR}/glLoader)
#     set(OPENGL_LOADER_LIBRARIES
#         ${OPENGL_gl_LIBRARY}
#         ${CMAKE_DL_LIBS})
# endif()

# # Specify the default install path
# if (NOT DEFINED CMAKE_INSTALL_PREFIX)
#     SET( CMAKE_INSTALL_PREFIX "${PROJECT_BINARY_DIR}/" )
# endif()

# if (NOT DEFINED CMAKE_INCDIR_BASE)
#     set( CMAKE_INCDIR_BASE include/opensubdiv )
# endif()

# if (NOT DEFINED CMAKE_BINDIR_BASE)
#     set( CMAKE_BINDIR_BASE bin )
# endif()

# if (NOT DEFINED CMAKE_LIBDIR_BASE)
#     set( CMAKE_LIBDIR_BASE lib )
# endif()

# if (NOT DEFINED CMAKE_FRAMEWORKDIR_BASE)
#     set( CMAKE_FRAMEWORKDIR_BASE Frameworks )
# endif()

# if (NOT DEFINED CMAKE_PLUGINDIR_BASE)
#     set( CMAKE_PLUGINDIR_BASE plugin )
# endif()

# if (NOT DEFINED CMAKE_DOCDIR_BASE)
#     set( CMAKE_DOCDIR_BASE share/doc/opensubdiv )
# else()
#     if (IS_ABSOLUTE ${CMAKE_DOCDIR_BASE})
#         set( CMAKE_DOCDIR_BASE "${CMAKE_DOCDIR_BASE}" )
#     else()
#         set( CMAKE_DOCDIR_BASE "${CMAKE_INSTALL_PREFIX}/${CMAKE_DOCDIR_BASE}" )
#     endif()
# endif()

# # Allow install path to be overridden for cross-compile builds
# if(LIBRARY_OUTPUT_PATH_ROOT)
#     SET( CMAKE_INSTALL_PREFIX "${LIBRARY_OUTPUT_PATH_ROOT}/" )
# endif()

# if (MAIN_PROJECT)
#     # Set the directory where the executables will be stored.
#     set(EXECUTABLE_OUTPUT_PATH
#         "${PROJECT_BINARY_DIR}/bin"
#         CACHE PATH
#         "Directory where executables will be stored"
#     )

#     # Set the directory where the libraries will be stored.
#     set(LIBRARY_OUTPUT_PATH
#         "${PROJECT_BINARY_DIR}/lib"
#         CACHE PATH
#         "Directory where all libraries will be stored"
#     )
# endif()

# # Specify the list of directories to search for cmake modules.
# set(CMAKE_MODULE_PATH
#     "${CMAKE_CURRENT_SOURCE_DIR}/cmake"
# )

# #-------------------------------------------------------------------------------
# # OpenSubdiv trips bugs in some older gcc versions
# if (CMAKE_COMPILER_IS_GNUCC)
#     if (CMAKE_CXX_COMPILER_VERSION VERSION_LESS 4.8)
#         message(WARNING "g++ 4.8 or newer recommended")
#     endif()
# endif()

# # Detect Clang (until a cmake version provides built-in variables)
# if(${CMAKE_CXX_COMPILER_ID} MATCHES "Clang")
#     set(CMAKE_COMPILER_IS_CLANGCC 1)
# elseif(${CMAKE_CXX_COMPILER_ID} MATCHES "Intel")
#     set(CMAKE_COMPILER_IS_ICC 1)
# endif()


# if (NOT CMAKE_COMPILER_IS_ICC)
#     # Currently icc has a bug that asserts when linking rpaths containing long
#     # sequences of ':' that this command causes. The consequence is that examples
#     # built and installed using icc will not have an rpath pointing to the built
#     # OSD library which they depend on and will have to set LD_LIBRARY_PATH instead.
#     list(APPEND CMAKE_INSTALL_RPATH "${CMAKE_INSTALL_PREFIX}/lib")
# endif()

# if(PROJECT_IS_TOP_LEVEL)
#     # add the automatically determined parts of the RPATH
#     # which point to directories outside the build tree to the install RPATH
#     SET(CMAKE_INSTALL_RPATH_USE_LINK_PATH TRUE)
# endif()

# # ensure that ARC is shown as enabled in the Xcode UI
# if(CMAKE_GENERATOR STREQUAL "Xcode")
#     set (CMAKE_XCODE_ATTRIBUTE_CLANG_ENABLE_OBJC_ARC "YES")
# endif()

# #
# # CMake Options (before `project` to support vcpkg manifest mode features).
# #

# # Ignore rules that will re-run cmake (this will avoid constant
# # reloading of the generated Visual Studio project).
# if(PROJECT_IS_TOP_LEVEL AND CMAKE_GENERATOR MATCHES "Visual Studio")
#     set(CMAKE_SUPPRESS_REGENERATION TRUE)
# endif()

# option(PTEX_LOCATION "Path to Ptex" "")
# option(GLEW_LOCATION "Path to GLEW" "")
# option(GLFW_LOCATION "Path to GLFW" "")

# option(NO_LIB "Disable the opensubdiv libs build (caveat emptor)" OFF)
# option(NO_EXAMPLES "Disable examples build" OFF)
# option(NO_TUTORIALS "Disable tutorials build" OFF)
# option(NO_REGRESSION "Disable regression tests build" OFF)
# option(NO_PTEX "Disable PTex support" OFF)
# option(NO_DOC "Disable documentation build" OFF)
# option(NO_OMP "Disable OpenMP backend" OFF)
# option(NO_TBB "Disable TBB backend" OFF)
# option(NO_CUDA "Disable CUDA backend" OFF)
# option(NO_OPENCL "Disable OpenCL backend" OFF)
# option(NO_CLEW "Disable CLEW wrapper library" OFF)
# option(NO_OPENGL "Disable OpenGL support")
# option(NO_METAL "Disable Metal support" OFF)
# option(NO_DX "Disable DirectX support")
# option(NO_TESTS "Disable all tests")
# option(NO_GLTESTS "Disable GL tests")
# option(NO_GLEW "Disable use of GLEW" ON)
# option(NO_GLFW "Disable components depending on GLFW" OFF)
# option(NO_GLFW_X11 "Disable GLFW components depending on X11" OFF)

# option(OPENSUBDIV_GREGORY_EVAL_TRUE_DERIVATIVES "Enable true derivative evaluation for Gregory basis patches" OFF)

# option(BUILD_SHARED_LIBS "Build shared libraries" ON)

# # Save the current value of BUILD_SHARED_LIBS and restore it after
# # processing Find* modules, since some of the Find* modules invoked
# # below may wind up stomping over this value.
# set(build_shared_libs "${BUILD_SHARED_LIBS}")

# set(OSD_GPU FALSE)

# # Check for dependencies
# if(NOT NO_OMP)
#     find_package(OpenMP)
# endif()
# if(NOT NO_TBB)
#     find_package(TBB 4.0)
# endif()
# if (NOT NO_OPENGL)
#     find_package(OpenGL)
# endif()
# find_package(OpenGLES)
# if(NOT NO_OPENCL)
#     if(NOT NO_CLEW)
#         find_package(CLEW)
#     endif()
#     if (NOT CLEW_FOUND)
#         find_package(OpenCL 1.1)
#     else()
#         set(OPENCL_FOUND TRUE)
#     endif()
# endif()
# if(NOT NO_CUDA)
#     find_package(CUDA 4.0)
# endif()
# if(NOT NO_GLFW AND NOT NO_OPENGL AND NOT ANDROID AND NOT IOS)
#     find_package(GLFW 3.0.0)
# endif()
# if(NOT NO_PTEX)
#    find_package(PTex 2.0)
#    find_package(ZLIB 1.2)
# endif()
# if(APPLE AND NOT NO_METAL)
#     find_package(Metal)
# endif()
# if (OPENGL_FOUND AND NOT IOS)
#     add_definitions(
#         -DOPENSUBDIV_HAS_OPENGL
#     )
#     if (NOT NO_GLEW)
#         if (APPLE)
#             find_package(GLEW)
#         else()
#             find_package(GLEW REQUIRED)
#         endif()
#     endif()
#     if(GLEW_FOUND)
#         add_definitions( -DOSD_USES_GLEW )
#     else()
#         add_definitions( -DOSD_USES_INTERNAL_GLAPILOADER )
#     endif()
# endif()

# if (WIN32 AND NOT NO_DX)
#    find_package(DXSDK)
# endif()

# if (NOT NO_DOC)
#     find_package(Doxygen 1.8.4)
#     find_package(Docutils 0.9)
# else()
#     set(DOXYGEN_EXECUTABLE )
# endif()

# set(BUILD_SHARED_LIBS "${build_shared_libs}")

# Warn about missing dependencies that will cause parts of OpenSubdiv to be
# disabled.  Also, add preprocessor defines that can be used in the source
# code to determine if a specific dependency is present or not.


# if(CUDA_FOUND)
#     add_definitions(
#         -DOPENSUBDIV_HAS_CUDA
#         -DCUDA_ENABLE_DEPRECATED=0
#     )
#     set(OSD_GPU TRUE)

#     if (UNIX)
#         list( APPEND CUDA_NVCC_FLAGS -Xcompiler -fPIC )
#         if (NOT DEFINED OSD_CUDA_NVCC_FLAGS)
#             if (CUDA_VERSION_MAJOR LESS 6)
#                 set( OSD_CUDA_NVCC_FLAGS --gpu-architecture compute_11 )
#             else()
#                 set( OSD_CUDA_NVCC_FLAGS --gpu-architecture compute_20 )
#             endif()
#         endif()
#     endif()

#     if (DEFINED OSD_CUDA_NVCC_FLAGS)
#         list( APPEND CUDA_NVCC_FLAGS ${OSD_CUDA_NVCC_FLAGS})
#     endif()

# else()
#     if (NOT NO_CUDA)
#         message(WARNING
#             "CUDA was not found : support for CUDA parallel compute kernels "
#             "will be disabled in Osd.  If you have the CUDA SDK installed, please "
#             "refer to the FindCUDA.cmake shared module in your cmake installation.")
#     endif()
# endif()

# if(PTEX_FOUND)
#     add_definitions(
#         -DOPENSUBDIV_HAS_PTEX
#         -DPTEX_STATIC
#     )
# else()
#     if(NOT NO_PTEX)
#         message(WARNING
#             "Ptex was not found : the OpenSubdiv Ptex example will not be "
#             "available.  If you do have Ptex installed and see this message, "
#             "please add your Ptex path to FindPTex.cmake in "
#             "${PROJECT_SOURCE_DIR}/cmake or set it through the PTEX_LOCATION "
#             "cmake command line argument or environment variable.")
#     endif()
# endif()

# if( OPENSUBDIV_GREGORY_EVAL_TRUE_DERIVATIVES )
#     add_definitions(-DOPENSUBDIV_GREGORY_EVAL_TRUE_DERIVATIVES)
# endif()

# Link examples & regressions against Osd
if( BUILD_SHARED_LIBS )
    if( OSD_GPU )
        set( OSD_LINK_TARGET osd_dynamic_gpu osd_dynamic_cpu )
    else()
        set( OSD_LINK_TARGET osd_dynamic_cpu )
    endif()
else()
    if( OSD_GPU )
        set( OSD_LINK_TARGET osd_static_gpu osd_static_cpu )
    else()
        set( OSD_LINK_TARGET osd_static_cpu )
    endif()
endif()

if (WIN32)
    # if ("${GLEW_LIBRARY}" MATCHES "glew32s(d|)")
    #     # Link against the static version of GLEW
    #     add_definitions(
    #         -DGLEW_STATIC
    #     )
    # endif()

    # if (DXSDK_FOUND AND NOT NO_DX)
    #     add_definitions(
    #         -DOPENSUBDIV_HAS_DX11SDK
    #     )
    #     set(OSD_GPU TRUE)
    # elseif(NOT NO_DX)
    #     message(WARNING
    #         "DirectX11 SDK was not found. "
    #         "If you do have DXSDK installed and see this message, "
    #         "please add your sdk path to FindDirectX.cmake in "
    #         "${PROJECT_SOURCE_DIR}/cmake or set it through the "
    #         "DXSDK_LOCATION cmake command line argument or "
    #         "environment variable."
    #     )
    # endif()

    # Link examples & regressions statically against Osd for
    # Windows until all the kinks can be worked out.
    if( OSD_GPU )
        set( OSD_LINK_TARGET osd_static_cpu osd_static_gpu )
    else()
        set( OSD_LINK_TARGET osd_static_cpu )
    endif()

endif()


#-------------------------------------------------------------------------------
# General-use macros

# Macro for processing public headers into the build area for doxygen processing

add_custom_target( public_headers )

macro(osd_add_doxy_headers headers)
    if (NOT NO_DOC AND DOXYGEN_FOUND)
        file(RELATIVE_PATH path "${OpenSubdiv_SOURCE_DIR}" "${CMAKE_CURRENT_SOURCE_DIR}" )

        string(REPLACE  "/" "_" targetpath ${path})

        foreach (header ${headers})

            set(infile "${CMAKE_CURRENT_SOURCE_DIR}/${header}")
            set(outfile "${OpenSubdiv_BINARY_DIR}/public_headers/${path}/${header}")
            set(targetname "${targetpath}_${header}")

            add_custom_command(
                OUTPUT
                    "${outfile}"
                COMMAND
                    ${CMAKE_COMMAND}
                ARGS
                    -E copy ${infile} ${outfile}
                DEPENDS
                    ${infile}
            )

            add_custom_target(${targetname} DEPENDS "${outfile}")


            list(APPEND headerfiles ${targetname} )
        endforeach()

        add_dependencies( public_headers DEPENDS ${headerfiles} )
    endif()
endmacro()

# Kernel Stringification
# We want to use preprocessor include directives to include GLSL and OpenCL
# kernel source files in cpp files, but since the sources contain newline
# characters we would need raw string literals from C++11 to do this directly.
# To avoid depending on C++11 we instead use a small tool called "line_quote"
# to generate source files that are suitable for direct inclusion.
function(osd_stringify src_files varname)

    set(inc_files "")

    foreach(src_file ${src_files})

    string(REGEX REPLACE ".*[.](.*)" "\\1" extension "${src_file}")

        string(REGEX REPLACE "(.*)[.].*" "\\1.gen.h" inc_file "${src_file}")
        list(APPEND inc_files "${CMAKE_CURRENT_BINARY_DIR}/${inc_file}")

        add_custom_command(
            OUTPUT
                "${CMAKE_CURRENT_BINARY_DIR}/${inc_file}"
            COMMAND
                stringify "${CMAKE_CURRENT_SOURCE_DIR}/${src_file}" "${CMAKE_CURRENT_BINARY_DIR}/${inc_file}"
            DEPENDS
                stringify "${CMAKE_CURRENT_SOURCE_DIR}/${src_file}"
        )

    endforeach()
    set(${varname} ${inc_files} PARENT_SCOPE)
endfunction()

# Macro wrapper for adding a non-cuda dependent executable
macro(osd_add_executable target folder)

    add_executable(${target} ${ARGN})

    set_target_properties(${target} PROPERTIES FOLDER ${folder})

    if(CMAKE_COMPILER_IS_ICC)
        target_link_libraries(${target} ${ICC_LIBRARIES})
    endif()

    if(APPLE)
        set_property (TARGET ${target} APPEND_STRING PROPERTY
              COMPILE_FLAGS " -fobjc-arc ")
    endif()
endmacro()


# Macro for adding a cuda executable if cuda is found and a regular
# executable otherwise.
macro(osd_add_possibly_cuda_executable target folder)
    if(CUDA_FOUND)
        cuda_add_executable(${target} ${ARGN})
    else()
        add_executable(${target} ${ARGN})
    endif()

    set_target_properties(${target} PROPERTIES FOLDER ${folder})

    if(CMAKE_COMPILER_IS_ICC)
        target_link_libraries(${target} ${ICC_LIBRARIES})
    endif()

    if(APPLE)
        set_property (TARGET ${target} APPEND_STRING PROPERTY
              COMPILE_FLAGS " -fobjc-arc ")
    endif()
endmacro()


# Macro for adding a cuda library if cuda is found and a regular
# library otherwise.
macro(osd_add_possibly_cuda_library target folder)
    if(CUDA_FOUND)
        cuda_add_library(${target} ${ARGN})
    else()
        add_library(${target} ${ARGN})
    endif()
    set_target_properties(${target} PROPERTIES FOLDER ${folder})

    if(APPLE)
        set_property (TARGET ${target} APPEND_STRING PROPERTY
              COMPILE_FLAGS " -fobjc-arc ")
    endif()
endmacro()


# Macro for adding a (potentially cuda) GLFW executable.
macro(osd_add_glfw_executable target folder)

    osd_add_possibly_cuda_executable(${target} ${folder} ${ARGN})

    if(APPLE)
        set_property (TARGET ${target} APPEND_STRING PROPERTY
              COMPILE_FLAGS " -fobjc-arc ")
    endif()

endmacro()

#-------------------------------------------------------------------------------
# Build targets


# # if you want to build examples against installed OpenSubdiv header files,
# # use OPENSUBDIV_INCLUDE_DIR.

# # example: if you have already installed opensubdiv libs in this cmake setup,
# # set (OPENSUBDIV_INCLUDE_DIR ${CMAKE_INSTALL_PREFIX}/${CMAKE_INSTALL_INCLUDEDIR})

# if (NOT OPENSUBDIV_INCLUDE_DIR)
#     set(OPENSUBDIV_INCLUDE_DIR "${PROJECT_SOURCE_DIR}")
# endif()

# if (NOT NO_TESTS)
#     enable_testing()
# endif()

if (NOT NO_OPENGL)
    add_subdirectory(glLoader)
endif()

add_subdirectory(opensubdiv)

if (NOT ANDROID AND NOT NO_REGRESSION) # XXXdyu
    add_subdirectory(regression)
endif()

if (NOT NO_EXAMPLES)
    add_subdirectory(examples)
endif()

if (NOT NO_TUTORIALS)
    add_subdirectory(tutorials)
endif()

if (NOT NO_DOC)
    add_subdirectory(documentation)
endif()

#
# CMake Config.
#

configure_package_config_file(
    opensubdiv-config.cmake.in
    ${CMAKE_CURRENT_BINARY_DIR}/opensubdiv-config.cmake
    INSTALL_DESTINATION ${CMAKE_INSTALL_DATADIR}/${PROJECT_NAME}
)
write_basic_package_version_file(
    ${CMAKE_CURRENT_BINARY_DIR}/opensubdiv-config-version.cmake
    VERSION ${OpenSubdiv_VERSION}
    COMPATIBILITY SameMajorVersion
)

install(EXPORT opensubdiv-targets
    NAMESPACE OpenSubdiv::
    DESTINATION ${CMAKE_INSTALL_DATADIR}/${PROJECT_NAME})

install(FILES
    ${CMAKE_CURRENT_BINARY_DIR}/opensubdiv-config.cmake
    ${CMAKE_CURRENT_BINARY_DIR}/opensubdiv-config-version.cmake
    DESTINATION ${CMAKE_INSTALL_DATADIR}/${PROJECT_NAME}
)
