module mod_data
  use mod_mupro_base, only: rdp, idp, isp, type_mupro_SizeContext
  use mod_mupro_electric, only: type_mupro_electricContext
  use mod_mupro_fft, only: type_mupro_fftContext
  use mod_mupro_elastic, only: type_mupro_elasticContext
  use mod_mupro_tdgl, only: type_mupro_tdglContext
  use mod_mupro_ferroelectric, only: type_mupro_FerroelectricContext
  implicit none
  include "mpif.h"

  ! simulation size related data
  type(type_mupro_sizecontext) :: sizeContext
  integer ::  nx, ny, nz, ns, nf
  real(kind=rdp) dx, dy, dz, lx, ly, lz

  ! fft data
  type(type_mupro_fftcontext) :: fftContext
  integer Rn3, Rn2, Rn1
  integer Cn3, Cn2, Cn1
  integer Hn2, Hn1
  integer lstartR
  integer trans

  ! mpi data
  integer rank, process, ierr

  ! time step data
  integer kt
  real(kind=rdp), target :: tem

  ! denominator
  real(kind=rdp) :: a0 ! landau denominator
  real(kind=rdp) :: l0 ! length denominator
  real(kind=rdp) :: p0 ! polarization denominator
  real(kind=rdp) :: C0 ! Denominator for elastic stiffness = a0*p0^2
  real(kind=rdp) :: S0 ! Denominator for stress = a0*p0^2*l0^2
  real(kind=rdp) :: E0 ! Denominator for electric field = a0*p0
  real(kind=rdp) :: G0 ! Denominator for p gradient coeff = a0*l0**2
  real(kind=rdp) :: Q0 ! Denominator for electrostrictive coeff = 1/p0**2
  real(kind=rdp) :: phi0 ! Denominator for electrostrictive coeff = a0*p0*l0
  real(kind=rdp), parameter :: epsilon0 = 8.8541878128d-12 !
  real(kind=rdp), parameter :: pi = 4.0*atan(1.0)

  ! landau data
  real(kind=rdp) :: initialPx, initialPy, initialPz
  type(type_mupro_TDGLContext)::tdglContext
  type(type_mupro_FerroelectricContext) :: ferroelectricContext
  real(kind=rdp) :: a1, a11, a12, a111, a112, a123, a1111, a1112, a1122, a1123
  real(kind=rdp) :: totalLandauEnergy, totalGradientEnergy
  real(kind=rdp) :: GS(6, 6)
  real(kind=rdp) :: kineticCoefficient
  real(kind=rdp) :: dt0
  real(kind=rdp), allocatable, target, dimension(:, :, :, :) :: polarization
  real(kind=rdp), allocatable, target, dimension(:, :, :, :) :: landauDrivingForce
  real(kind=rdp), allocatable, target, dimension(:, :, :, :) :: gradientDrivingForce
  real(kind=rdp), allocatable, target, dimension(:, :, :, :) :: elasticDrivingForce
  real(kind=rdp), allocatable, target, dimension(:, :, :, :) :: electricDrivingForce
  real(kind=rdp), allocatable, target, dimension(:, :, :, :) :: tdglRHS
  real(kind=rdp), allocatable, target, dimension(:, :, :) :: gradientEnergy
  real(kind=rdp), allocatable, target, dimension(:, :, :) :: landauEnergy
  ! real(kind=rdp), dimension(:, :, :), pointer :: px, py, pz
  ! real(kind=rdp), dimension(:, :, :), pointer :: lan1, lan2, lan3
  ! real(kind=rdp), dimension(:, :, :), pointer ::grad1, grad2, grad3

  ! elastic data
  type(type_mupro_ElasticContext) :: elasticContext
  real(kind=rdp) :: totalElasticEnergy
  real(kind=rdp) :: CS(6, 6), QS(6, 6)
  real(kind=rdp), allocatable, target, dimension(:, :, :, :) :: stress
  real(kind=rdp), allocatable, target, dimension(:, :, :, :) :: eigenstrain
  real(kind=rdp), allocatable, target, dimension(:, :, :, :) :: strain
  real(kind=rdp), allocatable, target, dimension(:, :, :, :) :: displacement
  real(kind=rdp), allocatable, target, dimension(:, :, :) :: elasticEnergy
  real(kind=rdp), allocatable, target, dimension(:, :) :: filmStress33, filmStress23, filmStress12
  real(kind=rdp) :: filmMismatch11, filmMismatch22, filmMismatch12
  integer :: elastic_BC
  real(kind=rdp) :: bulkStrain(6), bulkStress(6)
  ! real(kind=rdp), dimension(:, :, :), pointer :: s1, s2, s3, s4, s5, s6
  ! real(kind=rdp), dimension(:, :, :), pointer :: eta1, eta2, eta3, eta4, eta5, eta6
  ! real(kind=rdp), dimension(:, :, :), pointer :: e1, e2, e3, e4, e5, e6
  ! real(kind=rdp), dimension(:, :, :), pointer :: u1, u2, u3
  ! real(kind=rdp), dimension(:, :, :), pointer :: elas1, elas2, elas3

  ! electric data
  type(type_mupro_electricContext) :: electricContext
  real(kind=rdp), dimension(3, 3) :: epsilonR ! relative permittivity
  real(kind=rdp), dimension(3) :: bulkElectricField
  real(kind=rdp) :: totalElectricEnergy
  real(kind=rdp) :: filmScreenTop, filmScreenBot
  real(kind=rdp), allocatable, target, dimension(:, :, :) :: boundCharge
  real(kind=rdp), allocatable, target, dimension(:, :, :, :) :: electricField
  real(kind=rdp), allocatable, target, dimension(:, :, :) :: electricEnergy
  real(kind=rdp), allocatable, target, dimension(:, :, :) :: electricPotential
  real(kind=rdp), allocatable, target, dimension(:, :) :: filmPotentialTop
  real(kind=rdp), allocatable, target, dimension(:, :) :: filmPotentialBot
  integer :: electric_BC
  ! real(kind=rdp), dimension(:, :, :), pointer::elec1, elec2, elec3

  character(len=8) passfilename

  integer :: noiseSeed
  integer :: flag_noise
  real(kind=rdp) :: noiseMagnitude
  integer :: kprnt, kstep, kstart

  real(kind=rdp) :: totalEnergy
end module
