cmake_minimum_required(VERSION 3.10)
project(read_bm_krnl_host CXX)
set(CMAKE_CXX_STANDARD 17)

if(NOT DEFINED ENV{XILINX_XRT})
  message(FATAL_ERROR "Set XILINX_XRT before cmake, e.g. export XILINX_XRT=/opt/xilinx/xrt_2024.2")
endif()
set(XRT_ROOT $ENV{XILINX_XRT})

add_executable(bm_host bm_host.cpp)
target_include_directories(bm_host PRIVATE ${XRT_ROOT}/include)
target_link_directories(bm_host PRIVATE ${XRT_ROOT}/lib)
target_link_libraries(bm_host PRIVATE xrt_coreutil pthread)
install(TARGETS bm_host DESTINATION ${CMAKE_INSTALL_PREFIX})
