module mod_solve
  use mod_input
  use mod_setup
  use mod_mupro_base
  use mod_mupro_msolve
  use mod_mupro_ferroelectric
  use mod_mupro_electric
  use mod_output
  use mod_mupro_utilities, only: mupro_sum_box

  implicit none
  real(kind=rdp), allocatable, dimension(:, :, :), target :: incR
  real(kind=rdp), allocatable, dimension(:, :, :, :) :: u_prime1, u_prime2, u_prime3
  real(kind=rdp), allocatable, dimension(:, :, :, :) :: incRin, pout, qout
contains

  subroutine get_electric_driving_force
    implicit none
    integer :: i

    call ferroelectricContext%get_polarization_bound_charge()!, px, py, pz, choice_derivative, ferroMask)

    electricContext%bulkElectricField = bulkElectricField

    call electricContext%solve()
    call mupro_sum_box(totalElectricEnergy, electricEnergy)
  end subroutine get_electric_driving_force

  subroutine get_elastic_driving_force
    implicit none
    integer :: i

    call ferroelectricContext%get_eigenstrain() ! this will get the eigenstrain
    call elasticContext%solve()
    call mupro_sum_box(totalElasticEnergy, elasticEnergy)
    call ferroelectricContext%get_elastic_driving_force()!px, py, pz)

  end subroutine get_elastic_driving_force

  subroutine get_landau_driving_force
    implicit none
    call ferroelectricContext%get_landau_driving_force()
    call ferroelectricContext%get_gradient_energy()
    call ferroelectricContext%get_gradient_driving_force()

    call mupro_sum_box(totalLandauEnergy, landauEnergy)
    call mupro_sum_box(totalGradientEnergy, gradientEnergy)

  end subroutine

  subroutine evolve_polarization
    implicit none

    tdglRHS = -landauDrivingForce - elasticDrivingForce - electricField
    call tdglContext%solve() ! this will update the op value in tdglContext

  end subroutine evolve_polarization
end module
