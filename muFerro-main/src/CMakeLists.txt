if(MUPRODEV)
  message(STATUS the mupro dev is true)
  cmake_path(GET CMAKE_BINARY_DIR FILENAME CurrentDir)
  set(root ${CMAKE_CURRENT_SOURCE_DIR}/../../../)
  set(mupro_DIR ${root}/library/out/build/${CurrentDir})
  set(openmupro_DIR ${root}/openmupro/out/build/${CurrentDir}/library)
  set(license_DIR
  ${root}/license/out/build/${CurrentDir}/library)
endif()

message(STATUS "mupro_DIR is " ${mupro_DIR})
message(STATUS "CMAKE_PREFIX_PATH is " ${CMAKE_PREFIX_PATH})
find_package(mupro)
find_package(MPI REQUIRED)
include(GNUInstallDirs)

add_executable(
  muFerro
  data.f90
  finalize.f90
  input.f90
  output.f90
  setup.f90
  solve.f90
  setup/elastic.f90
  setup/electric.f90
  setup/initial.f90
  setup/tdgl.f90
  setup/ferroelectric.f90
  solve.f90
  main.f90)

set_target_properties(muFerro PROPERTIES DEBUG_POSTFIX ${CMAKE_DEBUG_POSTFIX})
set_target_properties(muFerro PROPERTIES LINKER_LANGUAGE Fortran)
set_target_properties(
  muFerro
  PROPERTIES POSITION_INDEPENDENT_CODE TRUE
             OUTPUT_NAME muFerro
             Fortran_MODULE_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/include")
if(NOT EXISTS "${CMAKE_CURRENT_BINARY_DIR}/include")
  make_directory("${CMAKE_CURRENT_BINARY_DIR}/include")
endif()
# find_package(muprolib)
target_link_libraries(muFerro PUBLIC mupro::mupro)

configure_file(input.toml input.toml COPYONLY)
configure_file(material.toml material.toml COPYONLY)

set(CPACK_INSTALL_CMAKE_PROJECTS "debug;muFerro;ALL;/debug"
                                 "release;muFerro;ALL;/")

install(
  TARGETS muFerro
  EXPORT muFerroTargets
  LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
  ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
  RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
  INCLUDES
  DESTINATION ${CMAKE_INSTALL_INCLUDEDIR})

install(
  EXPORT muFerroTargets
  FILE muFerroTargets.cmake
  NAMESPACE mupro::
  DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/muFerro)
