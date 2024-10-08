module mod_input
  use mod_data
  use tomlf, only: toml_table, get_value, toml_array
  use mod_mupro_base, only: mupro_toml_get_value_evaluate
  implicit none

  character(len=:), allocatable :: systemFile
  type(toml_table), allocatable :: systemTable

  character(len=:), allocatable :: materialFile
  type(toml_table), allocatable :: materialTable

contains

  subroutine input_read
    use mod_mupro_base, only: mupro_toml_read_file
    implicit none

    systemFile = "input.toml"
    call mupro_toml_read_file(systemFile, systemTable)
    call get_value(systemTable, "material", materialFile)
    call mupro_toml_read_file(materialFile, materialTable)

    call input_read_system
    call input_read_material

    call input_normalize ! normalize the input variables, from now on everything is in reduced unit

  end subroutine

  subroutine input_read_system
    use mod_mupro_base, only: mupro_toml_read_file, mupro_add_variable, mupro_add_constant, mupro_evaluate
    use tomlf, only: toml_table, get_value, toml_array, len
    implicit none
    type(toml_table), pointer :: system
    type(toml_table), pointer :: output
    type(toml_table), pointer :: child
    type(toml_array), pointer :: narray, darray
    type(toml_table), pointer :: normalizer

    integer(kind=4) :: test
    integer, allocatable, dimension(:) :: nn
    real(kind=rdp), allocatable, dimension(:) :: dd, pp
    real(kind=rdp) :: g11, g12, g44
    print *, "read system input"
    ! system table
    call get_value(systemTable, "system", system)
    call get_value(system, "simulation_grid", narray)
    ! print *, "len", len(narray), nn, size(nn)
    if (associated(narray)) then
      call get_value(narray, nn)
      if (size(nn) == 3) then
        nx = nn(1)
        ny = nn(2)
        nz = nn(3)
      else
        print *, "The size of simulation_grid is not 3"
      end if
    end if

    call get_value(system, "film_grid", nf)
    call get_value(system, "substrate_grid", ns)

    call get_value(system, "length_per_grid", darray)
    if (associated(darray)) then
      call get_value(darray, dd)
      if (size(dd) == 3) then
        dx = dd(1)
        dy = dd(2)
        dz = dd(3)
      else
        print *, "The size of length_per_grid is not 3"
      end if
    end if
    lx = nx*dx
    ly = ny*dy
    lz = nz*dz

    call get_value(system, "temperature", tem)
    call mupro_add_variable("TEM", tem)
    call get_value(system, "timestep_start", kstart)
    call get_value(system, "timestep_total", kstep)
    call get_value(system, "elastic_BC", elastic_BC)
    call get_value(system, "dt", dt0)
    call get_value(system, "noise", flag_noise)
    call get_value(system, "noise_magnitude", noiseMagnitude)
    call get_value(system, "noise_seed", noiseSeed)
    noiseSeed = noiseSeed + rank
    call get_value(system, "initial_polarization", darray)
    if (associated(darray)) then
      call get_value(darray, pp)
      if (size(pp) == 3) then
        initialPx = pp(1)
        initialPy = pp(2)
        initialPz = pp(3)
      else
        print *, "The size of initial_polarization is not 3"
      end if
    end if
    call get_value(system, "G11", g11)
    call get_value(system, "G12", g12)
    call get_value(system, "G44", g44)
    GS = 0
    GS(1, 1) = g11; GS(2, 2) = g11; GS(3, 3) = g11
    GS(1, 2) = g12; GS(1, 3) = g12; GS(2, 1) = g12
    GS(2, 3) = g12; GS(3, 1) = g12; GS(3, 2) = g12
    GS(4, 4) = g44; GS(5, 5) = g44; GS(6, 6) = g44

    call get_value(systemTable, "normalizer", normalizer)
    call get_value(normalizer, "p0", p0)
    call get_value(normalizer, "l0", l0, 1.d-9)

    ! output table
    call get_value(systemTable, "output", output)
    call get_value(output, "interval", kprnt)

    kineticCoefficient = 1

    call get_value(system, "permittivity", darray)
    if (associated(darray)) then
      call get_value(darray, pp)
      if (size(pp) == 3) then
        epsilonR(1, 1) = pp(1)
        epsilonR(2, 2) = pp(2)
        epsilonR(3, 3) = pp(3)
      else
        print *, "The size of permittivity is not 3"
      end if
    end if

  end subroutine

  subroutine input_read_material
    use mod_mupro_electric, only: mupro_electric_read_permittivity
    use mod_mupro_elastic, only: mupro_elastic_read_stiffness
    use mod_mupro_ferroelectric, only: mupro_ferroelectric_read_electrostrictive
    use tomlf, only: toml_table, get_value, toml_array, len

    implicit none
    real(kind=rdp) :: tem_hold
    ! type(toml_array), pointer ::  darray

    type(toml_table), pointer :: ferroelectric
    type(toml_table), pointer :: child, landau
    ! real(kind=rdp), allocatable, dimension(:) :: pp

    print *, "read material input"

    ! call mupro_electric_read_permittivity(materialTable, "permittivity", epsilonR)

    call mupro_elastic_read_stiffness(materialTable, "stiffness", CS)
    call mupro_ferroelectric_read_electrostrictive(materialTable, "electrostrictive", QS)

    call get_value(materialTable, "landau", landau)
    if (associated(landau)) then
      call mupro_toml_get_value_evaluate(landau, "a1", a1)
      ! call mupro_toml_get_value_evaluate(landau, "a11", a11)
      ! call mupro_toml_get_value_evaluate(landau, "a12", a12)
      ! call mupro_toml_get_value_evaluate(landau, "a111", a111)
      ! call mupro_toml_get_value_evaluate(landau, "a112", a112)
      ! call mupro_toml_get_value_evaluate(landau, "a123", a123)
      ! call get_value(landau, "a1", a1)
      call get_value(landau, "a11", a11)
      call get_value(landau, "a12", a12)
      call get_value(landau, "a111", a111)
      call get_value(landau, "a112", a112)
      call get_value(landau, "a123", a123)
      call get_value(landau, "a1111", a1111, 0.d0)
      call get_value(landau, "a1112", a1112, 0.d0)
      call get_value(landau, "a1122", a1122, 0.d0)
      call get_value(landau, "a1123", a1123, 0.d0)
    end if

    ! use the 273k a1 as a0, no particular reason
    tem_hold = tem
    tem = 273
    call mupro_toml_get_value_evaluate(landau, "a1", a0)
    a0 = abs(a0)
    tem = tem_hold

  end subroutine

  ! Normalization is purely for numerical purposes, to avoid too small or large value
  ! To make things easier, we normalize everything to unitless
  ! a0, l0, and p0 are the three base denominator
  ! all other units are normalized using combination of these three values
  subroutine input_normalize
    implicit none
    ! Denominator for elastic stiffness = a0*p0^2
    ! Denominator for stress = 1e9*a0*p0^2*l0^2
    ! Denominator for electrostrictive coeff = 1/p0**2
    ! Denominator for p gradient coeff = a0*l0**2
    ! Denominator for landau coeff is a0
    ! Denominator for polarization is p0
    ! Denominator for permittivity = 1/(a0*epsilon0)
    ! Denominator for electric potential = a0*p0*l0
    ! Denominator for electric field = a0*p0
    print *, "normalize input parametes"

    C0 = a0*p0**2
    S0 = a0*p0**2*l0**2
    Q0 = 1/p0**2
    g0 = a0*l0**2
    E0 = a0*p0
    phi0 = a0*p0*l0

    a1 = a1/a0
    a11 = a11*p0**2/a0
    a12 = a12*p0**2/a0
    a111 = a111*p0**4/a0
    a112 = a112*p0**4/a0
    a123 = a123*p0**4/a0
    a1111 = a1111*p0**6/a0
    a1112 = a1112*p0**6/a0
    a1122 = a1122*p0**6/a0
    a1123 = a1123*p0**6/a0

    bulkElectricField = bulkElectricField/E0

    QS = QS/Q0
    epsilonR = epsilonR*a0*epsilon0
    CS = CS/C0
    ! GS = GS/g0 GS is already normalized value

    initialPx = initialPx/p0
    initialPy = initialPy/p0
    initialPz = initialPz/p0

    noiseMagnitude = noiseMagnitude/p0

  end subroutine

  subroutine input_set_default
    implicit none
    tem = 298.0

    ! System dimension
    nx = 10; ny = 10; nz = 10; nf = 0; ns = 0
    dx = 1.d-9; dy = 1.d-9; dz = 1.d-9
    lx = nx*dx; ly = ny*dy; lz = nz*dz

    ! System time
    kstart = 0; kprnt = 200; kstep = 1000
    dt0 = 0.01
    kineticCoefficient = 1.

    ! Landau polarization
    flag_noise = 0; noiseMagnitude = 0.1; noiseSeed = 10
    ! etrl1SI = 0; etrl2SI = 0; etrl3SI = 0

    ! Gradient polarization
    ! Set in readPotential.f90

    ! Elastic
    ! flag_elastic = .true.
    elastic_bc = 2
    filmMismatch11 = 0.; filmMismatch22 = 0.; filmMismatch12 = 0.
    ! sTotappSI = 0.
    bulkStrain = 0.
    bulkStress = 0.

    ! Electric
    ! flag_electric = .true.
    electric_BC = 2
    filmScreenTop = 1.; filmScreenBot = 1.
    filmPotentialTop = 0.; filmPotentialBot = 0.
    bulkElectricField = 0.

    ! Output
    ! output_elastic = .false.
    ! output_electric = .false.
    ! output_landau = .false.
    ! output_gradient = .false.
    ! output_flexo = .false.
    ! output_driving_force = .false.

    initialPx = 0.d0
    initialPy = 0.d0
    initialPz = 0.d0

  end subroutine
end module
