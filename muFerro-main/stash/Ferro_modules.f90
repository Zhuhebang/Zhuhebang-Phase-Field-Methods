module mod_Simsize
    use mupro_double_precision
    implicit none
    integer  nx,ny,nz
    integer k1,k2
    integer(kind=idp) kt
    real(kind=rdp) dx,dy,dz
    real(kind=rdp) hf,hs
    integer Rn3,Rn2,Rn1
    integer Cn3,Cn2,Cn1
    integer Hn2,Hn1
    integer lstartR
    integer trans
    integer rank,process
    integer,dimension(6) :: polarBox
    integer,dimension(6) :: elasBox
    integer,dimension(6) :: elecBox
    character(len=8) passfilename
    character(len=78) text1
    real(kind=rdp) :: memory
end module

module mod_Input
    use mupro_double_precision
    implicit none
    ! real(kind=rdp) xf
    real(kind=rdp) tem
    real(kind=rdp) noise_magn_p,noise_magn_q
    real(kind=rdp) lx,ly,lz
    real(kind=rdp) dt0,kinetic_coeff
    real(kind=rdp) dt0_q,kinetic_coeff_q
    real(kind=rdp) anglePhi,angleTheta,anglePsi
    real(kind=rdp) rotAxis1,rotAxis2,rotAxis3
    real(kind=rdp),dimension(6)::sTotappSI,sTotappAU
    real(kind=rdp),dimension(3)::eTotappSI,eTotappAU
    real(kind=rdp) mismatch_exx,mismatch_eyy,mismatch_exy
    real(kind=rdp) phitopSI,phibotSI,phibotAU,phitopAU
    real(kind=rdp) screentop,screenbot
    real(kind=rdp) etrl1SI,etrl2SI,etrl3SI
    real(kind=rdp) etrl1AU,etrl2AU,etrl3AU
    real(kind=rdp) etrlq1SI,etrlq2SI,etrlq3SI
    real(kind=rdp) etrlq1AU,etrlq2AU,etrlq3AU
    real(kind=rdp) tolerance
    logical flag_elastic,flag_flexo,flag_electric,flag_oxytilt,flag_bulk,flag_rotate,flag_elec_bulk,flag_elas_bulk
    logical output_elastic,output_electric,output_landau,output_gradient,output_driving_force,output_flexo,output_time_depend
    logical flag_inhomo_electric,flag_inhomo_elastic,flag_inhomo_rotate,flag_inhomo_landau,flag_inhomo_oxytilt
    !logical flag_inhomo_oxytilt_elastic,flag_inhomo_landau_elastic,flag_inhomo_landau_oxytilt
    logical flag_inhomo
    integer materials_count,choice_inhomo,choice_inhomo_format
    logical flag_noise_p,flag_noise_q,flag_update_landau,flag_tdgl,flag_q_tdgl,flag_AFMtip
    integer choice_rotate_format
    integer rotation_count
    logical conditionChange
    character(len=30) :: choice_material
    integer choice_elec_bc,choice_elas_bc,choice_derivative
    integer choice_force,choice_bias
    integer recursionLimit
    integer bcTP1,bcTP2,bcTP3
    integer bcTQ1,bcTQ2,bcTQ3
    integer seed_random_p,seed_random_q
    integer n_grid_film,n_grid_substrate
    integer kstep,kprnt,kstart
    logical :: lREALDIM,lSYSDIM,lSURFCHRG,LKINETICQ
    integer choice_island_shape,islandDim1,islandDim2,islandDim3
    logical flag_island
    real(kind=rdp) C_sub11,C_sub12,C_sub44
    real(kind=rdp) epsilon_sub11,epsilon_sub22,epsilon_sub33
    integer :: choice_elas_homo,choice_elec_homo
    logical :: flag_edge_compensate
    integer choice_membrane_load,membrane_load_x,membrane_load_y
    real(kind=rdp) membrane_load

    ! character(len=300),dimension(:,:),allocatable :: firstLevelList,secondLevelList
    character(len=300),dimension(:,:),allocatable :: wholeList
    character(len=300),dimension(:,:),allocatable :: wholeList_td

    real(kind=rdp) chargeD
    real(kind=rdp) eigenD1,eigenD2,eigenD3
    real(kind=rdp) eigenD4,eigenD5,eigenD6
    real(kind=rdp) boundChargeScaleD,eigenScaleD


    logical flag_nucleus_p,flag_nucleus_q
    integer choice_nucleus_shape_p,choice_nucleus_shape_q
    real(kind=rdp) :: nucleus_px,nucleus_py,nucleus_pz
    real(kind=rdp) :: nucleus_qx,nucleus_qy,nucleus_qz
    integer :: nucleus_p_posx,nucleus_p_posy,nucleus_p_posz
    integer :: nucleus_q_posx,nucleus_q_posy,nucleus_q_posz
    real(kind=rdp) :: nucleus_p_size,nucleus_q_size

    logical :: lINITIALP,lINITIALQ
    real(kind=rdp) :: initial_px,initial_py,initial_pz
    real(kind=rdp) :: initial_qx,initial_qy,initial_qz

    real(kind=rdp) :: elec_multiplier
    real(kind=rdp) :: elas_multiplier
    logical :: flag_in_plane

    logical :: printKeywords
    character(len=:),allocatable :: keywordFile
end module


module mod_Materialconst
    use mupro_double_precision
    use mupro_fdm,only:fdm_mask
    ! use mod_materialtype
    implicit none

    type Normalizer
        real(kind=rdp) lengthNormalizer !l0
        real(kind=rdp) polarNormalizer !p0
        real(kind=rdp) pLandauNormalizer !a0
        real(kind=rdp) pGradNormalizer ! g110 = a0*l0**2
        real(kind=rdp) oxytiltNormalizer !q0
        real(kind=rdp) qLandauNormalizer !b0
        real(kind=rdp) qGradNormalizer ! v110 = b0*l0**2
        real(kind=rdp) permittivity !epsilon0

    end type


    type MaterialConst
        character(len=:),allocatable :: name
        real(kind=rdp) composition ! xf
        real(kind=rdp) temperature ! tem
        real(kind=rdp) elasticStiffness(6,6) !CS
        real(kind=rdp) elasticStiffness1D(21) !CS
        real(kind=rdp) elasticCompliance(6,6) !SS
        real(kind=rdp) elasticCompliance1D(21) !SS
        real(kind=rdp) electroStrictive(6,6) !QS
        real(kind=rdp) electroStrictive1D(21) !QS
        real(kind=rdp) polarLandau(10) !a1,a11 ...
        real(kind=rdp) oxytiltLandau(10) !b1,b11 ....
        real(kind=rdp) backgroundPermittivity(3,3) !epsilon ....
        real(kind=rdp) backgroundPermittivity1D(6) !epsilon ....
        real(kind=rdp) polarGradient(3) !g11,g12 ....
        real(kind=rdp) oxytiltGradient(3) !v11,v12 ....
        real(kind=rdp) polarOxytilt(3) !t11,t12 ...
        real(kind=rdp) rotostrictive(6,6) !LS L11,L12 ...
        real(kind=rdp) rotostrictive1D(21) !LS L11,L12 ...
        real(kind=rdp) flexoelectric(3,18) !f11,f12 ...
        real(kind=rdp) flexoelectricCap(3,18) !f11,f12 ...
        real(kind=rdp) flexoelectricCapReverse(6,9) !f11,f12 ...
        ! real(kind=rdp) flexoelectricCapRev(6,9) !f11,f12 ...
        type(Normalizer) normal

        logical :: lGRADPCON,lGRADQCON,lELASCON,lELASCOM,lDIELECON,lELESTRCON,lROTSTRCON,lFLEXOCON,lFLEXOCON2
        ! real(kind=rdp) polarNormalizer !p0
        ! real(kind=rdp) lengthNormalizer !l0
        ! real(kind=rdp) oxytiltNormalizer !q0
        ! real(kind=rdp) pLandauNormalizer !a0
        ! real(kind=rdp) qLandauNormalizer !b0
    end type


    real(kind=rdp),allocatable,dimension(:,:,:)::a1Inhomo,a11Inhomo,a12Inhomo,a111Inhomo,a112Inhomo,a123Inhomo
    real(kind=rdp),allocatable,dimension(:,:,:)::a1111Inhomo,a1112Inhomo,a1122Inhomo,a1123Inhomo
    real(kind=rdp),allocatable,dimension(:,:,:)::b1Inhomo,b11Inhomo,b12Inhomo,b111Inhomo,b112Inhomo,b123Inhomo
    real(kind=rdp),allocatable,dimension(:,:,:)::b1111Inhomo,b1112Inhomo,b1122Inhomo,b1123Inhomo
    real(kind=rdp),allocatable,dimension(:,:,:)::t11Inhomo,t12Inhomo,t44Inhomo
    real(kind=rdp),allocatable,dimension(:,:,:,:,:)::qInhomo,cInhomo,lInhomo
    real(kind=rdp),allocatable,dimension(:,:,:,:)::epsilonInhomo1D
    real(kind=rdp),allocatable,dimension(:,:,:,:,:)::epsilonInhomo
    real(kind=rdp),allocatable,dimension(:,:,:) :: composition

    real(kind=rdp)::a1Homo,a11Homo,a12Homo,a111Homo,a112Homo,a123Homo
    real(kind=rdp)::a1111Homo,a1112Homo,a1122Homo,a1123Homo
    real(kind=rdp)::b1Homo,b11Homo,b12Homo,b111Homo,b112Homo,b123Homo
    real(kind=rdp)::b1111Homo,b1112Homo,b1122Homo,b1123Homo
    real(kind=rdp)::t11Homo,t12Homo,t44Homo
    real(kind=rdp),dimension(6,6)::cHomo,qHomo,lHomo
    real(kind=rdp),dimension(3) :: tHomo
    real(kind=rdp),dimension(21)::cHomo1D,qHomo1D,lHomo1D,tHomo1D
    real(kind=rdp),dimension(6)::epsilonHomo1D
    real(kind=rdp),dimension(3,3)::epsilonHomo
    real(kind=rdp) :: polarGradientHomo11,polarGradientHomo12,polarGradientHomo44
    real(kind=rdp) :: oxytiltGradientHomo11,oxytiltGradientHomo12,oxytiltGradientHomo44
    real(kind=rdp) :: polarOxytiltHomo11,polarOxytiltHomo12,polarOxytiltHomo44
    real(kind=rdp),dimension(6,9)::capFR
    real(kind=rdp),dimension(3,18)::capF

    !real(kind=rdp) FCC(3,18),capF(3,18),capFGlob(3,18),FCCR(6,9),capFRGlob(6,9),capFR(6,9)
    !real(kind=rdp) sTensor(3,3,3,3),capFTensorGlob(3,3,3,3),capFRTensorGlob(3,3,3,3)
    !real(kind=rdp) FCCTensor(3,3,3,3),capFTensor(3,3,3,3),FCCRTensor(3,3,3,3),capFRTensor(3,3,3,3)

    logical,dimension(:,:,:),allocatable ::airMask,ferroMask,solidMask,ferroEdge
    type(fdm_mask) :: ferroMaterialMask
    integer :: airIndex


    real(kind=rdp) YoungTipSI,YoungFilmSI,YoungEffSI
    real(kind=rdp) YoungTipAU,YoungFilmAU,YoungEffAU
    real(kind=rdp) PoissonTip,PoissonFilm
    real(kind=rdp),parameter :: epsilon0=8.854e-12
    real(kind=rdp),parameter :: pi=4.0*atan(1.0)
    type(MaterialConst),allocatable,dimension(:) :: materialsGroupSI
    type(MaterialConst),allocatable,dimension(:) :: materialsGroupAU
    type(MaterialConst) :: materialSub
    type(Normalizer) :: systemNormalizer
end module

module mod_polarization
    use mupro_double_precision
    implicit none
    real(kind=rdp),allocatable :: pxc(:,:,:),pyc(:,:,:),pzc(:,:,:)
    real(kind=rdp),allocatable :: hold1(:,:,:),hold2(:,:,:),hold3(:,:,:)
    real(kind=rdp),allocatable :: hold4(:,:,:),hold5(:,:,:),hold6(:,:,:)
    real(kind=rdp),allocatable :: px(:,:,:),py(:,:,:),pz(:,:,:),domain(:,:,:)
    real(kind=rdp),allocatable :: landau_energy(:,:,:)
    real(kind=rdp),dimension(:,:,:),pointer :: lan1,lan2,lan3
    real(kind=rdp),allocatable,dimension(:,:,:,:),target :: land
    real(kind=rdp),allocatable,dimension(:,:,:)::grad1,grad2,grad3
    real(kind=rdp),allocatable,dimension(:,:,:,:)::grad1d,grad2d,grad3d
    real(kind=rdp),allocatable,dimension(:,:,:)::grad_energy
    real(kind=rdp) energy_land,energy_grad
end module

module mod_oxytilt
    use mupro_double_precision
    implicit none
    real(kind=rdp),allocatable :: oxytilt_energy(:,:,:)
    real(kind=rdp),allocatable :: qx(:,:,:),qy(:,:,:),qz(:,:,:)
    real(kind=rdp),allocatable :: qxc(:,:,:),qyc(:,:,:),qzc(:,:,:)
    real(kind=rdp),dimension(:,:,:),pointer :: lanq1,lanq2,lanq3
    real(kind=rdp),allocatable,dimension(:,:,:,:),target :: landq
    real(kind=rdp),allocatable,dimension(:,:,:)::gradq1,gradq2,gradq3
    real(kind=rdp),allocatable,dimension(:,:,:,:)::grad1dq,grad2dq,grad3dq
    real(kind=rdp),allocatable,dimension(:,:,:)::gradq_energy
    real(kind=rdp) energy_oxytilt,energy_gradq
end module

module mod_Elastic
    use mupro_double_precision
    implicit none
    real(kind=rdp) energy_elast
    real(kind=rdp) CS(6,6),SS(6,6),QS(6,6),LS(6,6),CU(6,6)
    real(kind=rdp) C_in(21),Q_in(21),L_in(21)
    real(kind=rdp),dimension(:,:,:),pointer :: s1,s2,s3,s4,s5,s6
    real(kind=rdp),dimension(:,:,:),pointer :: eta1,eta2,eta3,eta4,eta5,eta6
    real(kind=rdp),dimension(:,:,:),pointer :: e1,e2,e3,e4,e5,e6
    real(kind=rdp),dimension(:,:,:),pointer :: u1,u2,u3
    real(kind=rdp),pointer :: elas1(:,:,:),elas2(:,:,:),elas3(:,:,:)
    real(kind=rdp),pointer :: elastq1(:,:,:),elastq2(:,:,:),elastq3(:,:,:)
    real(kind=rdp),allocatable :: s3appAU(:,:),s4appAU(:,:),s5appAU(:,:)
    real(kind=rdp),allocatable :: deflectionAU(:,:),theta1AU(:,:),theta2AU(:,:)
    real(kind=rdp),allocatable,target :: s(:,:,:,:)
    real(kind=rdp),allocatable,target :: eta(:,:,:,:)
    real(kind=rdp),allocatable,target :: e(:,:,:,:)
    real(kind=rdp),allocatable,target :: u(:,:,:,:)
    real(kind=rdp),allocatable,target :: elast(:,:,:,:)
    real(kind=rdp),allocatable,target :: elastq(:,:,:,:)
    real(kind=rdp),allocatable :: cGlob(:,:,:,:,:)
    real(kind=rdp),allocatable,dimension(:,:,:) :: elast_energy,additionalEigen
    real(kind=rdp),dimension(:,:,:,:,:),allocatable :: cglob_in ! remember to allocate this array
end module

module mod_Electric
    use mupro_double_precision
    implicit none
    real(kind=rdp),allocatable,target :: chargeT(:,:,:),chargeF(:,:,:)
    real(kind=rdp),allocatable,dimension(:,:,:) :: charge1,charge2,charge3,chargeB,additionalCharge
    real(kind=rdp),allocatable,dimension(:,:,:,:)::epsilon
    real(kind=rdp),allocatable,target :: phi(:,:,:)
    real(kind=rdp),allocatable,target :: elect(:,:,:,:)
    real(kind=rdp),allocatable :: phi0_bot(:,:),phi0_top(:,:)
    logical,allocatable,dimension(:,:) :: film_pillar
    real(kind=rdp),pointer,dimension(:,:,:)::elec1,elec2,elec3
    real(kind=rdp),allocatable :: elect_energy(:,:,:)
    real(kind=rdp) :: epsilonAll(6),epsilon_sub(6)
    real(kind=rdp) energy_elect
end module

module mod_rotation
    use mupro_double_precision
    implicit none
    type rotation
        real(kind=rdp),dimension(3) ::  eularAngle
        real(kind=rdp),dimension(3,3) ::  rotationMatrix
    end type
    real(kind=rdp),allocatable,dimension(:,:,:,:,:) :: polyTR
    real(kind=rdp),allocatable,dimension(:,:) :: singleTR
    type(rotation),allocatable,dimension(:) :: rotationGroup
end module

module mod_flexo
    use mupro_double_precision
    implicit none
    real(kind=rdp),allocatable,dimension(:,:,:,:),target :: flexo
    real(kind=rdp),dimension(:,:,:),pointer::flexo1,flexo2,flexo3
end module

module mod_AFMtip
    use mupro_double_precision
    implicit none
    real(kind=rdp),allocatable,dimension(:) :: biasesSI,forcesSI
    real(kind=rdp),allocatable,dimension(:) :: biasesAU,forcesAU
    real(kind=rdp),allocatable,dimension(:,:) :: tippos,friction
    real(kind=rdp),allocatable,dimension(:,:) :: bias_shape,force_shape
    real(kind=rdp) tipRadSI,tipGammaSI
    real(kind=rdp) tipRadAU,tipGammaAU
    real(kind=rdp) tipRadSmoothSI
    real(kind=rdp) tipRadSmoothAU
    integer(kind=idp),allocatable,dimension(:) :: ktip
    integer(kind=idp) ntipstep
end module

module mod_defect
    use mupro_double_precision
    implicit none

    real(kind=rdp) defectX,defectY,defectZ
    real(kind=rdp) defectLx,defectLy,defectLz
    real(kind=rdp) defectThickness
    real(kind=rdp),dimension(:,:,:),allocatable :: defect,chargeDefect
    real(kind=rdp),dimension(:,:,:),allocatable :: boundChargeScale,eigenScale
    real(kind=rdp),dimension(:,:,:,:),allocatable :: eigenDefect

    integer choice_defect,defect_count
    logical flag_defect

end module

module mod_main_interfaces
    use mupro_double_precision
    implicit none
    interface
        subroutine setup_op(inputName,opx,opy,opz,opxc,opyc,opzc,noiseFlag,noiseMag,noiseSeed,initialFlag)
            use mupro_double_precision
            implicit none
            logical,intent(in) :: noiseFlag,initialFlag
            integer,intent(in),optional :: noiseSeed
            character(len=8),intent(in) :: inputName
            real(kind=rdp),intent(in) :: noiseMag
            real(kind=rdp),dimension(:,:,:),intent(out) :: opx,opy,opz,opxc,opyc,opzc
        end subroutine

        subroutine setup_nucleus(flag_nucleus,choice_nucleus,opx,opy,opz,opxc,opyc,opzc,nucleus_x,nucleus_y,nucleus_z,pos_x,pos_y,pos_z,nuc_size)
            use mupro_double_precision
            implicit none
            logical,intent(in) :: flag_nucleus
            integer,intent(in) :: choice_nucleus,pos_x,pos_y,pos_z
            real(kind=rdp),intent(in) :: nucleus_X,nucleus_Y,nucleus_Z,nuc_size
            real(kind=rdp),dimension(:,:,:),intent(inout) :: opx,opy,opz,opxc,opyc,opzc
        end subroutine

        subroutine printMaterial(outputFile,material)
            use mod_materialConst,only: MaterialConst,Normalizer
            implicit none
            character(len=:),allocatable,intent(in) :: outputFile
            character(len=80) :: stringHold
            type(MaterialConst),intent(in) :: material
        end subroutine

        subroutine readOneMaterial(material,materialName,potFileName,inputFileName,comp,temp)
            use mod_materialConst,only: MaterialConst,Normalizer
            use fson
            use double_precision
            implicit none
            type(MaterialConst),intent(inout) :: material
            ! character(len=*),intent(in) ::  potFileName,inputFileName,materialName
            character(len=:),allocatable,intent(in) ::  potFileName,inputFileName,materialName
            real(kind=rdp),optional,intent(in) :: comp,temp
          end subroutine

          subroutine normalizeMaterial(materialAU,materialSI,sysNormalizer)
            use mod_materialConst,only: MaterialConst,Normalizer
            implicit none
            type(MaterialConst),intent(inout) :: materialSI
            type(MaterialConst),intent(out) :: materialAU
            type(Normalizer),intent(in) :: sysNormalizer
          end subroutine
    end interface
end module

! module mod_All
!     use mod_interfaces
!     ! use mod_main_interfaces
!     use mod_Simsize
!     use mod_Input
!     use mod_MaterialConst
!     use mod_Elastic
!     use mod_Electric
!     use mod_oxytilt
!     use mod_polarization
!     use mod_flexo
!     use mod_rotation
!     use mod_AFMtip
!     use double_precision
!     use freeformat
!     use electric
!     use mod_defect
!     use print
!     use symmetry
!     USE, INTRINSIC :: IEEE_ARITHMETIC
!     interface
!         subroutine printMaterial(outputFile,material)
!             use mod_materialConst,only: MaterialConst,Normalizer
!             implicit none
!             character(len=:),allocatable,intent(in) :: outputFile
!             character(len=80) :: stringHold
!             type(MaterialConst),intent(in) :: material
!         end subroutine

!         subroutine readOneMaterial(material,materialName,potFileName,inputFileName,comp,temp)
!             use mod_materialConst,only: MaterialConst,Normalizer
!             use fson
!             use double_precision
!             implicit none
!             type(MaterialConst),intent(inout) :: material
!             ! character(len=*),intent(in) ::  potFileName,inputFileName,materialName
!             character(len=:),allocatable,intent(in) ::  potFileName,inputFileName,materialName
!             real(kind=rdp),optional,intent(in) :: comp,temp
!           end subroutine

!           subroutine normalizeMaterial(materialAU,materialSI,sysNormalizer)
!             use mod_materialConst,only: MaterialConst,Normalizer
!             implicit none
!             type(MaterialConst),intent(inout) :: materialSI
!             type(MaterialConst),intent(out) :: materialAU
!             type(Normalizer),intent(in) :: sysNormalizer
!           end subroutine



!     end interface

! end module
