submodule(mod_setup) mod_setup_ferroelectric
contains
  module subroutine setup_ferroelectric
    implicit none
    print *, "setup ferroelectric"

    ferroelectricContext%a1 = a1
    ferroelectricContext%a2 = a1
    ferroelectricContext%a3 = a1
    ferroelectricContext%a11 = a11
    ferroelectricContext%a22 = a11
    ferroelectricContext%a33 = a11
    ferroelectricContext%a12 = a12
    ferroelectricContext%a23 = a12
    ferroelectricContext%a13 = a12
    ferroelectricContext%a111 = a111
    ferroelectricContext%a112 = a112
    ferroelectricContext%a123 = a123
    ferroelectricContext%a1111 = a1111
    ferroelectricContext%a1112 = a1112
    ferroelectricContext%a1122 = a1122
    ferroelectricContext%a1123 = a1123
    ferroelectricContext%electrostrictive = QS
    ferroelectricContext%stiffness = CS
    ferroelectricContext%op => polarization
    ferroelectricContext%strain => strain
    ferroelectricContext%eigenstrain => eigenstrain
    ferroelectricContext%elec => electricField
    ferroelectricContext%lan => landauDrivingForce
    ferroelectricContext%grad => gradientDrivingForce
    ferroelectricContext%elast => elasticDrivingForce
    ferroelectricContext%landau_energy => landauEnergy
    ferroelectricContext%grad_energy => gradientEnergy
    ferroelectricContext%boundCharge => boundCharge
    ferroelectricContext%G = GS
    call ferroelectricContext%setup()

  end subroutine
end submodule
