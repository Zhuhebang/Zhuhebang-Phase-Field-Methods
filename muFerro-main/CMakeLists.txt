cmake_minimum_required(VERSION 3.20)
list(APPEND CMAKE_MODULE_PATH ${CMAKE_CURRENT_SOURCE_DIR}/cmake)
message(STATUS "muFerro CMAKE_MODULE_PATH " ${CMAKE_MODULE_PATH})
project(
  muFerro
  DESCRIPTION "The Mu-PRO ferroelectric module"
  LANGUAGES Fortran C CXX)

set(PROJECT_VERSION
    "${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}.${PROJECT_VERSION_PATCH}"
)
include(Version)
include(CPackConfig)
include(GNUInstallDirs)
include(CTest)
add_subdirectory(src)

install(FILES "LICENSE" DESTINATION "${CMAKE_INSTALL_DATADIR}/licenses/muFerro")
install(DIRECTORY potentials DESTINATION "${CMAKE_INSTALL_DATADIR}")
install(DIRECTORY examples DESTINATION "${CMAKE_INSTALL_DATADIR}")
install(DIRECTORY schema DESTINATION "${CMAKE_INSTALL_DATADIR}")
