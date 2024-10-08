submodule(mod_setup) mod_setup_electric
  use mod_data
  use mod_mupro_electric
contains

  module subroutine setup_electric
    implicit none

    print *, "setup electric"

    electricContext%filmPotentialTop => filmPotentialTop
    electricContext%filmPotentialBot => filmPotentialBot
    electricContext%potential => electricPotential
    electricContext%elec => electricField
    electricContext%energy => electricEnergy
    electricContext%chargeRHS => boundCharge
    electricContext%polarization => polarization
    electricContext%epsilon = epsilonR
    electricContext%flag_bulk = .true.
    call electricContext%setup()

  end subroutine
end submodule mod_setup_electric
