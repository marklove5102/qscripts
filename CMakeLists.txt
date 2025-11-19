cmake_minimum_required(VERSION 3.27)
project(qscripts)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Include IDA SDK bootstrap
include($ENV{IDASDK}/ida-cmake/bootstrap.cmake)
find_package(idasdk REQUIRED)

# Add idacpp library with fallback
# First, try to use idacpp from IDASDK
set(IDACPP_SDK_PATH "$ENV{IDASDK}/include/idacpp")
set(IDACPP_LOCAL_PATH "${CMAKE_CURRENT_BINARY_DIR}/idacpp")

if(EXISTS "${IDACPP_SDK_PATH}/CMakeLists.txt")
    message(STATUS "Using idacpp from IDASDK: ${IDACPP_SDK_PATH}")
    add_subdirectory(${IDACPP_SDK_PATH} ${CMAKE_CURRENT_BINARY_DIR}/idacpp)
else()
    message(STATUS "idacpp not found in IDASDK, fetching to build directory...")

    # Use FetchContent to download idacpp into build directory
    include(FetchContent)
    FetchContent_Declare(
        idacpp
        GIT_REPOSITORY https://github.com/allthingsida/idacpp.git
        GIT_TAG main
        SOURCE_DIR ${IDACPP_LOCAL_PATH}
    )
    FetchContent_MakeAvailable(idacpp)
endif()

# Convert paths to native format
set(SAMPLE_IDB "${IDA_CMAKE_DIR}/samples/wizmo32.exe.i64")
file(TO_NATIVE_PATH "${SAMPLE_IDB}" SAMPLE_IDB)

# Disabled sources
list(APPEND DISABLED_SOURCES utils_impl.cpp)
set_source_files_properties(${DISABLED_SOURCES} PROPERTIES LANGUAGE "")

# Add plugin
ida_add_plugin(qscripts
    SOURCES
        qscripts.cpp
        ida.h
        script.hpp
        ${DISABLED_SOURCES}
    DEBUG_ARGS
        "${SAMPLE_IDB}"
)

target_link_libraries(qscripts PRIVATE idacpp::idacpp)
