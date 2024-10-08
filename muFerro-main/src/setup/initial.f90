submodule(mod_setup) mod_setup_initial
contains
  module subroutine setup_initial
    implicit none
    logical :: lexist

    print *,"setup initial"


    polarization(1, :, :, :) = initialPx
    polarization(2, :, :, :) = initialPy
    polarization(3, :, :, :) = initialPz

    passfilename = 'Polar'
    inquire (file=(trim(passfilename)//".in"), exist=lexist)

    if (lexist) call mupro_input_4D(passfilename, polarization)

    if (flag_noise.eq.1) then
      call random_seed(size=noiseSeed)
      call random_number(polarization)
      polarization = 2*(polarization - 0.5)*noiseMagnitude
    end if

    call MPI_Barrier(MPI_COMM_WORLD, ierr)

  end subroutine

end submodule
