program ferroelectric
  use mod_mupro_base
  use mod_data
  use mod_input
  use mod_setup
  use mod_output
  use mod_solve
  use mod_finalize
  implicit none
  character(len=40) :: information

  real(kind=rdp), dimension(3) :: d(3)
  integer i, j, n, moduleInt
  logical lexist

  call input_read ! read input variables

  call setup_base ! setup simulation size, mpi, and fft
  call setup_allocate
  call setup_solver
  call setup_output

  call output_initial

  print *,"main loop begins"
  main: do kt = kstart + 1, kstep + kstart + 1
    call get_electric_driving_force
    call get_elastic_driving_force
    call get_landau_driving_force
    call evolve_polarization
    call output_iteration
  end do main
  print *,"main loop ends"

  call output_final
  call system_finalize
end program
