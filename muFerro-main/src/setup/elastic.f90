submodule(mod_setup) mod_setup_elastic
  use mod_mupro_elastic
  ! type(type_mupro_elasticContext) :: elasticContext
contains
  module subroutine setup_elastic
    implicit none

    print *,"setup elastic"

    elasticContext%eigenstrain => eigenstrain
    elasticContext%strain => strain
    elasticContext%displacement => displacement
    elasticContext%stress => stress
    elasticContext%energy => elasticEnergy
    elasticContext%stiffness = CS
    elasticContext%BC = elastic_BC
    call elasticContext%setup()

  end subroutine setup_elastic
end submodule mod_setup_elastic
