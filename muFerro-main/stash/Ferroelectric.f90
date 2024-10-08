program main
  ! use mod_All
  ! use mod_main_interfaces
  ! use ifport
  use mod_input
  use mod_setup
  use mod_output
  use mod_solve
  implicit none
  character(len=40) :: information

  real(kind=rdp), dimension(3) :: d(3)
  integer i, j, n, moduleInt
  logical lexist

  character(len=:), allocatable::moduleName, versionNumber
  real(kind=rdp) :: p0

  call MPI_INIT(ierr)
  call MPI_comm_size(MPI_COMM_WORLD, process, ierr)
  call MPI_comm_rank(MPI_comm_world, rank, ierr)

  call printHeader

    !!!!!!!!!!!!!!!!! General setup !!!!!!!!!!!!!!!!!!!
  ! Read from the input.in free format file
    !!!!!!!!!!!!!!!!!!!!!!!11
  call read_input
  call read_materials

  ! call normalize
  call normalize_materials

  call print_materials
  call mupro_setup

  call setup_allocate

  call solve_allocate
  call MPI_Barrier(MPI_COMM_WORLD, ierr)

  ! Read related parameters from the input.in file
  ! Read materials from the pot.in files
  ! normalization is no longer needed, things are normalized right after
  ! read in from pot.in file
  ! call normalizeConstants
  call setup_rotation
  call setupMaterials

  call setupTDVariables

    !!!!!!!!!!!!!!!!!!!!!!!!! AFM tip setup !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
  call setup_afm

  !      passfilename="AirMask"
  !      incR=airMask
  !      print *,"airmask ",airMask(1,1,1),incR(1,1,1)
  !      call outputxN_P(passfileName,incR)
    !!!!!!!!!!!!!!!!!! Landau setup !!!!!!!!!!!!!!!!!!!!!!!!!!!!

  call setup_landau
  call setup_oxytilt

  call setup_elastic

    !!!!!!!!!!!!!!!!!!!!!!!!! AFM tip setup !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

  !    if (flag_AFMtip.eq..True.) then
  !        if(choice_force.ne.0) call setup_force_tip_shape(forces(1),tippos(1,:),friction(1,:))
  !        if(choice_bias.ne.0) call setup_bias_tip_shape(biases(1),tippos(1,:),forces(1))
  !    endif

  !        if (flag_rotate) then
  !
  !            if(flag_inhomo.eq..true.) then
  !                call setup_polyRotation
  !            else
  !                call setup_singleRotation
  !            endif
  !
  !        end if
  call printMessage("General setup finished", "*", "c")

    !!!!!!!!!!!!!!!!!!!!!!!! Polarization setup !!!!!!!!!!!!!!!!!!!!!!!!!!
  call printMessage("Initial polarization setup started", "-", "c")
  pxc = initial_px
  pyc = initial_py
  pzc = initial_pz
  passfilename = 'Polar'
  call setup_op(passfilename, px, py, pz, pxc, pyc, pzc, flag_noise_p, noise_magn_p, seed_random_p, lINITIALP)
  if (flag_nucleus_p) then
    call printMessage("Adding some polarization nucleus", " ", "l")
        call setup_nucleus(flag_nucleus_p,choice_nucleus_shape_p,px,py,pz,pxc,pyc,pzc,nucleus_px,nucleus_py,nucleus_pz,nucleus_p_posx,nucleus_p_posy,nucleus_p_posz,nucleus_p_size)
  end if
  px = px/systemNormalizer%polarNormalizer; py = py/systemNormalizer%polarNormalizer; pz = pz/systemNormalizer%polarNormalizer
  pxc = pxc/systemNormalizer%polarNormalizer; pyc = pyc/systemNormalizer%polarNormalizer; pzc = pzc/systemNormalizer%polarNormalizer
  call printMessage("Initial polarization setup finished", "*", "c")

    !!!!!!!!!!!!!!!!!! Oxygen Octahedral Tilt setup !!!!!!!!!!!!!!!!!!!!!!
  if (flag_oxytilt) then
    qxc = initial_qx
    qyc = initial_qy
    qzc = initial_qz
    call printMessage("Initial oxygen octahedral rotation setup started", "*", "c")
    passfilename = 'OctaTilt'
    call setup_op(passfilename, qx, qy, qz, qxc, qyc, qzc, flag_noise_q, noise_magn_q, seed_random_q, lINITIALQ)
    call printMessage("Initial oxygen octahedral rotation setup finished", "*", "c")
    if (flag_nucleus_q) then
      call printMessage("Adding some polarization nucleus", " ", "l")
            call setup_nucleus(flag_nucleus_q,choice_nucleus_shape_q,qx,qy,qz,qxc,qyc,qzc,nucleus_qx,nucleus_qy,nucleus_qz,nucleus_q_posx,nucleus_q_posy,nucleus_q_posz,nucleus_q_size)
    end if
    qx = qx/systemNormalizer%oxytiltNormalizer; qy = qy/systemNormalizer%oxytiltNormalizer; qz = qz/systemNormalizer%oxytiltNormalizer
    qxc = qxc/systemNormalizer%oxytiltNormalizer; qyc = qyc/systemNormalizer%oxytiltNormalizer; qzc = qzc/systemNormalizer%oxytiltNormalizer
  end if

    !!!!!!!!!!!!!!!!!!!!!!!! General msolve setup !!!!!!!!!!!!!!!!!!!!!!!!!
  call setup_msolve_general

    !!!!!!!!!!!!!!!!!!!!!!!!!!! P solver setup !!!!!!!!!!!!!!!!!!!!!!!!!!!!
  if (flag_tdgl) then
    !print *,"polargradient",polarGradientHomo11,polarGradientHomo12,polarGradientHomo44
    g_P(1) = oxytiltGradientHomo11
    g_P(2) = oxytiltGradientHomo12
    g_P(16) = oxytiltGradientHomo44
    tdglContext%g_in = g_P
    tdglContext%ga = kinetic_coeff_q
    call TDGL_lapack_setup(tdglContext)!polarGradientHomo11, polarGradientHomo12, polarGradientHomo44, kinetic_coeff)
  else
    d = polarGradientHomo44; d(1) = polarGradientHomo11
    msolveContext1%bcT = bcTP1
    msolveContext1%d = d
    msolveContext1%outArray = p1_sys
    call setup_mpi_msolve(msolveContext1)!bcTP1, d, p1_sys)
    d = polarGradientHomo44; d(2) = polarGradientHomo11

    msolveContext2%bcT = bcTP2
    msolveContext2%d = d
    msolveContext2%outArray = p2_sys
    call setup_mpi_msolve(msolveContext2)!bcTP2, d, p2_sys)
    d = polarGradientHomo44; d(3) = polarGradientHomo11

    msolveContext3%bcT = bcTP3
    msolveContext3%d = d
    msolveContext3%outArray = p3_sys
    call setup_mpi_msolve(msolveContext3)!bcTP3, d, p3_sys)
  end if

  if (flag_rotate) then
    if (flag_inhomo_rotate) then
      call printMessage("Inhomogeneous rotation", "-", "c")
      call tensor_rotate_variable(px, py, pz, pxc, pyc, pzc, 'r')
    else
      call printMessage("Homogeneous rotation", "-", "c")
      call tensor_rotate_fixed(px, py, pz, pxc, pyc, pzc, 'r')
    end if
  else
    pxc = px
    pyc = py
    pzc = pz
  end if
  call setZero(px, polarBox, .true., ferroMask)
  call setZero(py, polarBox, .true., ferroMask)
  call setZero(pz, polarBox, .true., ferromask)
  call setZero(pxc, polarBox, .true., ferromask)
  call setZero(pyc, polarBox, .true., ferromask)
  call setZero(pzc, polarBox, .true., ferromask)
  !passfilename = 'Polar';call outputxN_P(passfilename,px*systemNormalizer%polarNormalizer,py*systemNormalizer%polarNormalizer,pz*systemNormalizer%polarNormalizer,pxc*systemNormalizer%polarNormalizer,pyc*systemNormalizer%polarNormalizer,pzc*systemNormalizer%polarNormalizer)
  hold1 = px*systemNormalizer%polarNormalizer; hold2 = py*systemNormalizer%polarNormalizer; hold3 = pz*systemNormalizer%polarNormalizer; hold4 = pxc*systemNormalizer%polarNormalizer; hold5 = pyc*systemNormalizer%polarNormalizer; hold6 = pzc*systemNormalizer%polarNormalizer
  passfilename = 'Polar'; call outputxN_P(passfilename, hold1, hold2, hold3, hold4, hold5, hold6)

    !!!!!!!!!!!!!!!!!!!!! OOT landau solver setup !!!!!!!!!!!!!!!!!!!!!!!!!!
  if (flag_oxytilt) then
    g_OT(1) = oxytiltGradientHomo11
    g_OT(2) = oxytiltGradientHomo12
    g_OT(16) = oxytiltGradientHomo44
    tdglOTContext%g_in = g_OT
    tdglOTContext%ga = kinetic_coeff_q
    call TDGL_OT_lapack_setup(tdglOTContext)!oxytiltGradientHomo11, oxytiltGradientHomo12, oxytiltGradientHomo44, kinetic_coeff_q)
    if (flag_rotate) then
      if (flag_inhomo_rotate) then
        call tensor_rotate_variable(qx, qy, qz, qxc, qyc, qzc, 'r')
      else
        call tensor_rotate_fixed(qx, qy, qz, qxc, qyc, qzc, 'r')
      end if
    else
      qxc = qx
      qyc = qy
      qzc = qz
    end if
    call setZero(qx, polarBox, .true., ferromask)
    call setZero(qy, polarBox, .true., ferromask)
    call setZero(qz, polarBox, .true., ferromask)
    call setZero(qxc, polarBox, .true., ferromask)
    call setZero(qyc, polarBox, .true., ferromask)
    call setZero(qzc, polarBox, .true., ferromask)

    hold1 = qx*systemNormalizer%oxytiltNormalizer
    hold2 = qy*systemNormalizer%oxytiltNormalizer
    hold3 = qz*systemNormalizer%oxytiltNormalizer
    hold4 = qxc*systemNormalizer%oxytiltNormalizer
    hold5 = qyc*systemNormalizer%oxytiltNormalizer
    hold6 = qzc*systemNormalizer%oxytiltNormalizer

    passfilename = 'OctaTilt'; call outputxN_P(passfilename, hold1, hold2, hold3, hold4, hold5, hold6)
  end if

    !!!!!!!!!!!!!!!!!!!!!!!!!!!!! energy_out setup !!!!!!!!!!!!!!!!!!!!!!!!!
  if (rank .eq. 0) then
    inquire (file='energy_out.dat', exist=lexist)
    if (.not. lexist) then
      open (unit=65, file='energy_out.dat')
5001  format('    ', A6, '         ', 6A18)
5002  format('    ', A6, '         ', 13A18)
5003  format('    ', A6, '         ', 7A18)
      if (flag_oxytilt) then
        write (65, 5003) "step", "Elastic Energy", "Electric Energy", "Landau Energy", &
          "OT+Coup Energy", "Grad P Energy", "GradOT Energy", "Total Energy"
      else
        write (65, 5002) "step", "Elastic Energy", "Electric Energy", "Landau Energy", &
          "Gradient P Energy", "Total Energy", "avgPx", "avgPy", "avgPz", "avgP", "avgEx", "avgEy", "avgEz", "avgE"
      end if
    else
      open (unit=65, file='energy_out.dat', position='append')
    end if
  end if
  call printTimeDependentHeader("phasFrac.dat", "kt", "C", "T", "M", "O", "R", "Null")

  call setzero_all


  call printMessageRank0("Starting main loop", "*", "c")
  main: do kt = kstart + 1, kstep + kstart + 1

  if (mod(kt - kstart, int(10, idp)) .eq. 0 .and. rank .eq. 0) then
    write (information, "(A,I30)") ' kt = ', kt
    call printMessageRank0(information, " ", "l")
  end if

    call updateTDVariables
    call solve_elastic
    call solve_electric
    call evolve_polarization
    ! call evolve_oxytilt ! future
  end do main

  call printMessageRank0("Main loop finished", "*", "c")
  call printMessageRank0("-", "-", "c")

  call system_finalize()

  call mupro_mpi_exit()

end program

subroutine system_finalize()
  implicit none

  if (rank .eq. 0) close (65)
end subroutine
