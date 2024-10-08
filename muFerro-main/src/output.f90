module mod_output
  use mod_input
  use mod_mupro_base
  use mod_mupro_io
  use mod_mupro_fft
  use mod_data
  use mod_mupro_log, only: mupro_print_message
  use mod_finalize
  use mod_mupro_utilities, only: mupro_sum_box
  use mod_mupro_transform, only: mupro_create_tensor_rank4_cubic_homo
  USE, INTRINSIC :: IEEE_ARITHMETIC

contains

  subroutine output_initial()
    implicit none
    print *, "output initial"
    ! pxc = px
    ! pyc = py
    ! pzc = pz
!passfilename = 'Polar';call outputxN_P(passfilename,px*systemNormalizer%polarNormalizer,py*systemNormalizer%polarNormalizer,pz*systemNormalizer%polarNormalizer,pxc*systemNormalizer%polarNormalizer,pyc*systemNormalizer%polarNormalizer,pzc*systemNormalizer%polarNormalizer)
    ! hold1 = px*systemNormalizer%polarNormalizer; hold2 = py*systemNormalizer%polarNormalizer; hold3 = pz*systemNormalizer%polarNormalizer; hold4 = pxc*systemNormalizer%polarNormalizer; hold5 = pyc*systemNormalizer%polarNormalizer; hold6 = pzc*systemNormalizer%polarNormalizer
    ! passfilename = 'Polar'; call outputxN_P(passfilename, hold1, hold2, hold3, hold4, hold5, hold6)
    passfilename = 'Polar'; call mupro_output_4D(passfilename, kt, polarization*p0)
  end subroutine

  subroutine setup_output_energy_profile
    implicit none
    logical :: lexist
        !!!!!!!!!!!!!!!!!!!!!!!!!!!!! energy_out setup !!!!!!!!!!!!!!!!!!!!!!!!!
    if (rank .eq. 0) then
      inquire (file='energy_out.dat', exist=lexist)
      if (.not. lexist) then
        open (unit=65, file='energy_out.dat')
5001    format('    ', A6, '         ', 5A18)
5002    format('    ', A6, '         ', 8A18)
5003    format('    ', A6, '         ', 7A18)

        write (65, 5001) "step", "Elastic Energy", "Electric Energy", "Landau Energy", &
          "Gradient P Energy", "Total Energy"
        ! write(66,5002) "step","avgPx", "avgPy", "avgPz", "avgP", "avgEx", "avgEy", "avgEz", "avgE"
      else
        open (unit=65, file='energy_out.dat', position='append')
      end if
    end if
  end subroutine

  subroutine printHeader
    implicit none

    character(len=40) :: information

    ! Let all processor write output to check if every one is initialized
    ! properly, printMessage is only for rank 0 so, write is called
4002 format("Total of ", i3, " cores is used")
    write (information, 4002) process
    call mupro_print_message(information, " ", "l")

    call mupro_print_message("--", "-", "c")
    call mupro_print_message("Ferroelectric main program", "*", "c")
    call mupro_print_message("using", "*", "c")
    call mupro_print_message("mu-pro package", "*", "c")
    call mupro_print_message("--", "-", "c")
  end subroutine

  subroutine output_final()
    implicit none
  end subroutine

  subroutine output_iteration
    ! use mod_All
    implicit none
    real(kind=rdp) energy_total
    real(kind=rdp), allocatable, dimension(:, :, :, :) :: u_prime1, u_prime2, u_prime3
    real(kind=rdp), allocatable, dimension(:, :, :) :: ptotal
    real(kind=rdp), dimension(6) :: phase
    real(kind=rdp) :: magnCr = 0.1, angleCr = 1, diffCr = 0.1



    if (rank .eq. 0) then
5004  format('kt: ', i6, ' energy: ', 5e18.10)
5005  format('kt: ', i6, ' energy: ', 7e18.10)

      totalEnergy = totalElectricEnergy + totalElasticEnergy + totalLandauEnergy + totalGradientEnergy
      write (65, 5004) kt, totalElasticEnergy, totalElectricEnergy, totalLandauEnergy, totalGradientEnergy, totalEnergy
    end if
    call MPI_Bcast(totalEnergy, 1, MPI_REAL8, 0, MPI_COMM_WORLD, ierr)
    call MPI_Barrier(MPI_COMM_WORLD, ierr)
    ! Polarization
    if (mod(kt - kstart, int(kprnt, idp)) == 0) then
      ! pxc = px; pyc = py; pzc = pz
      ! end if
      ! hold1 = px*p0; hold2 = py*p0; hold3 = pz*p0; hold4 = pxc*p0; hold5 = pyc*p0; hold6 = pzc*p0
      ! passfilename = 'Polar'; call outputxN_P(passfilename, hold1, hold2, hold3, hold4, hold5, hold6)
      !passfilename='Polar'; call outputxN_P(passfilename,px*p0,py*p0,pz*p0,pxc*p0,pyc*p0,pzc*p0)
      passfilename = 'Polar'; call mupro_output_4D(passfilename, kt, polarization)

    end if

    ! Gradient energy for polarization
    ! if ((mod(kt - kstart, int(kprnt, idp)) .eq. 1 .or. kprnt .eq. 1)) then
    !   call GET_GradientP;
    !   ! call phaseFraction(phase,pxc,pyc,pzc,magnCr,angleCr,diffCr)

    !   passfilename = 'Grade_En'; call mupro_output_3D(passfilename, kt, gradientEnergy)
    !   passfilename = 'Grad_For'; call mupro_output_4D(passfilename, kt, gradientDrivingForce)
    ! else
    !grad_energy =0.d0
    !energy_grad =0.d0
    !gradq_energy = 0.d0
    !energy_gradq = 0.d0

    ! end if

    ! Elastic terms
    if ((mod(kt - kstart, int(kprnt, idp)) .eq. 1 .or. kprnt .eq. 1)) then
      passfilename = 'Eigen_Str'; call mupro_output_4D(passfilename, kt, eigenstrain)
      passfilename = 'Strain'; call mupro_output_4D(passfilename, kt, strain)
      ! hold1 = e1 - eta1; hold2 = e2 - eta2; hold3 = e3 - eta3; hold4 = e4 - eta4; hold5 = e5 - eta5; hold6 = e6 - eta6
      !passfilename='Elast_Str'; call outputxN_P(passfilename,e1-eta1,e2-eta2,e3-eta3,e4-eta4,e5-eta5,e6-eta6)
      passfilename = 'Elast_Str'; call mupro_output_4D(passfilename, kt, strain - eigenstrain)
      !print *,"stress",s1(1,1,1),a0,p0**2
      ! hold1 = s1*a0*p0**2; hold2 = s2*a0*p0**2; hold3 = s3*a0*p0**2; hold4 = s4*a0*p0**2; hold5 = s5*a0*p0**2; hold6 = s6*a0*p0**2
      !passfilename='Stress'; call outputxN_P(passfilename,s1*a0*p0**2,s2*a0*p0**2,s3*a0*p0**2,s4*a0*p0**2,s5*a0*p0**2,s6*a0*p0**2)
      passfilename = 'Stress'; call mupro_output_4D(passfilename, kt, stress*S0)
      !print *,"stress",sum(hold1),sum(hold2),sum(hold3),sum(hold4),sum(hold5),sum(hold6)
      passfilename = 'Displace'; call mupro_output_4D(passfilename, kt, displacement)
      passfilename = 'Elast_En'; call mupro_output_3D(passfilename, kt, elasticEnergy)
      passfilename = 'Elas_For'; call mupro_output_4D(passfilename, kt, elasticDrivingForce)
    end if

    ! Electric terms
    if ((mod(kt - kstart, int(kprnt, idp)) .eq. 1 .or. kprnt .eq. 1)) then

      passfilename = 'Elect_En'; call mupro_output_3D(passfilename, kt, electricEnergy)
      passfilename = 'Elefield'; call mupro_output_4D(passfilename, kt, electricField*a0*p0)
      ! print *,"a0,p0,l0",a0,p0,l0,phi(nz/2,ny/2,nx/2)
      ! print *,"phi out",size(phi,1),size(phi,2),size(phi,3)
      passfilename = 'Elec_Phi'; call mupro_output_3D(passfilename, kt, electricPotential*phi0)
      passfilename = 'Elec_For'; call mupro_output_4D(passfilename, kt, electricDrivingForce)
      passfilename = 'Charges'; call mupro_output_3D(passfilename, kt, boundCharge*p0*1.d3)
      ! Output charge density in C/cm^3
    end if

    ! Landau energy terms
    if ((mod(kt - kstart, int(kprnt, idp)) .eq. 1 .or. kprnt .eq. 1)) then
      passfilename = 'LandP_En'; call mupro_output_3D(passfilename, kt, landauEnergy)
      passfilename = 'LandPFor'; call mupro_output_4D(passfilename, kt, landauDrivingForce)
    end if

    ! Driving forces for polarization
!           if (output_driving_force.and.(mod(kt-kstart,kprnt).eq.1.or.kprnt.eq.1)) then
!                   passfilename='Gen_ForX'; call outputxN_P(passfilename,elas1,elec1,flexo1,lan1,grad1,elas1+elec1+lan1+grad1)
!                   passfilename='Gen_ForY'; call outputxN_P(passfilename,elas2,elec2,flexo2,lan2,grad2,elas2+elec2+lan2+grad2)
!                   passfilename='Gen_ForZ'; call outputxN_P(passfilename,elas3,elec3,flexo3,lan3,grad3,elas3+elec3+lan3+grad3)
!           endif

    if (IEEE_IS_NAN(energy_total)) then
      call mupro_print_message("NAN detected, STOPPING!", "*", "c")
      call system_finalize
    end if

  end subroutine

end module
