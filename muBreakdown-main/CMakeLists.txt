cmake_minimum_required(VERSION 3.20)

project(
  muBreakDown
  LANGUAGES C Fortran
)

set(fftw_wrapper_path "share/mkl/interfaces/fftw3xf/wrappers")
set(MKLROOT "/opt/intel/oneapi/2024.2")

file(GLOB FFTW_SRC ${MKLROOT}/${fftw_wrapper_path}/*.c)
#message(STATUS ${MKLROOT}${fftw_wrapper_path})
#message(STATUS "FFTW_SRC:${FFTW_SRC}")

file(GLOB SRC ${CMAKE_CURRENT_SOURCE_DIR}/*.f90)
#message(STATUS "SRC:${SRC}")


include_directories(${MKLROOT}/include/fftw)
#message(${LIBRARY_OUTPUT_PATH})

set(EXECUTABLE_OUTPUT_PATH ${CMAKE_CURRENT_SOURCE_DIR})
add_executable(a.out ${SRC} ${FFTW_SRC})

target_link_libraries(a.out 
                      -Wl,--start-group 
                      ${MKLROOT}/lib/libmkl_intel_lp64.a 
                      ${MKLROOT}/lib/libmkl_sequential.a 
                      ${MKLROOT}/lib/libmkl_core.a 
                      -Wl,--end-group 
                      pthread m dl
)