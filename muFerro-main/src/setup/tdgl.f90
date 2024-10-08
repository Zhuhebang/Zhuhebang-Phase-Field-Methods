submodule(mod_setup) mod_setup_tdgl
contains
  module subroutine setup_tdgl
    implicit none

    print *, "setup tdgl"

    tdglContext%kinetic_coefficient = kineticCoefficient
    tdglContext%dt = dt0
    tdglContext%G = GS
    tdglContext%rhs => tdglRHS
    tdglContext%op => polarization
    call tdglContext%setup()

  end subroutine
end submodule
