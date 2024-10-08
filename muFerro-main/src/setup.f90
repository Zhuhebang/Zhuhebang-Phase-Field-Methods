
module mod_setup
  use mod_mupro_base
  use mod_mupro_io
  use mod_mupro_fft
  use mod_mupro_elastic
  use mod_mupro_ferroelectric
  use mod_mupro_tdgl
  use mod_data
  use mod_output

  implicit none

  interface
    module subroutine setup_ferroelectric
    end subroutine
    module subroutine setup_elastic
    end subroutine
    module subroutine setup_electric
    end subroutine
    module subroutine setup_initial
    end subroutine
    module subroutine setup_polarization
    end subroutine
    module subroutine setup_tdgl
    end subroutine
  end interface

contains

  subroutine setup_allocate
    implicit none
    print *,"setup allocate"

    ! elastic allocation
    allocate (stress(6, Rn3, Rn2, Rn1)); stress = 0.d0
    allocate (strain(6, Rn3, Rn2, Rn1)); strain = 0.d0
    allocate (eigenstrain(6, Rn3, Rn2, Rn1)); eigenstrain = 0.d0
    allocate (displacement(3, Rn3, Rn2, Rn1)); displacement = 0.d0
    allocate (elasticEnergy(Rn3, Rn2, Rn1)); elasticEnergy = 0.d0
    allocate (filmStress33(Rn2, Rn1)); filmStress33 = 0.0
    allocate (filmStress23(Rn2, Rn1)); filmStress23 = 0.0
    allocate (filmStress12(Rn2, Rn1)); filmStress12 = 0.0

    ! electric allocation
    allocate (filmPotentialTop(Rn2, Rn1)); filmPotentialTop = 0.d0
    allocate (filmPotentialBot(Rn2, Rn1)); filmPotentialBot = 0.d0
    allocate (electricEnergy(Rn3, Rn2, Rn1)); electricEnergy = 0.d0
    allocate (boundCharge(Rn3, Rn2, Rn1)); boundCharge = 0.d0
    allocate (electricPotential(Rn3, Rn2, Rn1)); electricPotential = 0.d0
    allocate (electricField(3, Rn3, Rn2, Rn1)); electricField = 0.d0

    ! ferroelectric allocation
    allocate (gradientEnergy(Rn3, Rn2, Rn1))
    allocate (polarization(3, Rn3, Rn2, Rn1))
    allocate (landauEnergy(Rn3, Rn2, Rn1))
    allocate (landauDrivingForce(3, Rn3, Rn2, Rn1))
    allocate (elasticDrivingForce(3, Rn3, Rn2, Rn1))
    allocate (gradientDrivingForce(3, Rn3, Rn2, Rn1))

    ! TDGL allocation
    allocate (tdglRHS(3, Rn3, Rn2, Rn1))

  end subroutine

  subroutine setup_solver()
    print *,"setup solver"

    call setup_elastic ! setup elastic solver
    call setup_electric ! setup poisson solver
    call setup_ferroelectric ! setup ferroelectric
    call setup_tdgl ! setup the TDGL solver
    call setup_initial ! setup the initial order parameter distribution
  end subroutine

  subroutine setup_output()
    print *,"setup output"
    call setup_output_energy_profile
  end subroutine

  subroutine setup_base
    implicit none
    ! System general setup
    ! integer, dimension(3) :: R(3), C(3), HN(2), lstart(3)

    print *,"setup basic"
    call mupro_mpi_setup(rank,process)

    sizeContext%nx = nx
    sizeContext%ny = ny
    sizeContext%nz = nz
    sizeContext%nf = nf
    sizeContext%ns = ns
    sizeContext%dx = dx
    sizeContext%dy = dy
    sizeContext%dz = dz
    call mupro_size_setup(sizeContext)

    call mupro_fft_setup(fftContext)
    lstartR = fftContext%lstart
    Rn1 = fftContext%Rn1
    Rn2 = fftContext%Rn2
    Rn3 = fftContext%Rn3
    Cn1 = fftContext%Cn1
    Cn2 = fftContext%Cn2
    Cn3 = fftContext%Cn3
    Hn1 = fftContext%Hn1
    Hn2 = fftContext%Hn2
  end subroutine

end module
