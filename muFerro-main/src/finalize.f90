module mod_finalize
  use mod_data
  use mod_mupro_base, only: mupro_mpi_exit
contains
  subroutine system_finalize()
    implicit none
    if (rank .eq. 0) close (65)
    call mupro_mpi_exit(0)
  end subroutine
end module
