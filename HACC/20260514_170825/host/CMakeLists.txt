cmake_minimum_required(VERSION 3.20)
include(${CMAKE_CURRENT_SOURCE_DIR}/UserConfig.cmake)
project(bambu_application LANGUAGES C CXX)

set(CMAKE_MODULE_PATH
  "$ENV{XILINX_VITIS}/vitis-server/scripts/cmake"
  ${CMAKE_MODULE_PATH}
)
find_package(Host REQUIRED)

set(VITIS_PLATFORM_PATH
  /opt/xilinx/platforms/xilinx_u55c_gen3x16_xdma_3_202210_1/xilinx_u55c_gen3x16_xdma_3_202210_1.xpfm
  CACHE STRING "Vitis Platform"
)

set(CMAKE_CXX_STANDARD 17 CACHE STRING "C++ standard")
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

add_executable(${CMAKE_PROJECT_NAME} "")
target_sources(${CMAKE_PROJECT_NAME}            PRIVATE ${USER_COMPILE_SOURCES})
target_compile_definitions(${CMAKE_PROJECT_NAME} PRIVATE __USE_XOPEN2K8 ${USER_COMPILE_DEFINITIONS})
target_compile_options(${CMAKE_PROJECT_NAME}     PRIVATE -g ${USER_COMPILE_OPTIONS})
target_include_directories(${CMAKE_PROJECT_NAME} PRIVATE ${Vitis_INCLUDE_DIRS} ${USER_INCLUDE_DIRECTORIES})
target_link_libraries(${CMAKE_PROJECT_NAME}      PRIVATE ${Vitis_LIBRARIES} -lpthread -lrt -lstdc++ ${USER_LINK_LIBRARIES})
target_link_directories(${CMAKE_PROJECT_NAME}    PRIVATE $ENV{XILINX_XRT}/lib ${USER_LINK_DIRECTORIES})
target_link_options(${CMAKE_PROJECT_NAME}        PRIVATE ${USER_LINK_OPTIONS})

if(NOT "${VITIS_PLATFORM_PATH}" STREQUAL "")
  set(NUMBER_OF_DEVICES 1)
  add_custom_command(OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/emconfig.json
    COMMAND ${Vitis_EMCONFIG_UTIL} --od . --nd ${NUMBER_OF_DEVICES} --platform ${VITIS_PLATFORM_PATH}
  )
  add_custom_target(GenerateEmulationConfig ALL
    DEPENDS ${CMAKE_CURRENT_BINARY_DIR}/emconfig.json)
endif()
