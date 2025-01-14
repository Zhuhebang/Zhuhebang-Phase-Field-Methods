PROGRAM main
USE globalvars
USE invert
IMPLICIT NONE

INCLUDE 'fftw3.f'
!------------------------------------------------------------------------------------------------      
INTEGER :: ii,jj,kk,i,j,k,l,n
INTEGER :: kstep,nstep,np0,np1
REAL*8 :: input(nx,ny,nz)
COMPLEX*16 :: output(nx21,ny,nz)
REAL*8 :: px,py,pz,pp,ps,pm,pv
REAL*8 :: x11m, x12m, x13m, x21m, x22m, x23m, x31m, x32m, x33m
REAL*8 :: x11p, x12p, x13p, x21p, x22p, x23p, x31p, x32p, x33p
REAL*8 :: x11s, x12s, x13s, x21s, x22s, x23s, x31s, x32s, x33s
REAL*8 :: x11c, x12c, x13c, x21c, x22c, x23c, x31c, x32c, x33c
REAL*8 :: Eksm(3,3),Eksp(3,3),Ekss(3,3),Eksv(3,3),Eksc(3,3),Km(3,3),Kp(3,3),deta(3,3)
REAL*8 :: Em_break,Es_break,Ep_break,Ev_break
REAL*8 :: radius,E_ext(3),R1,R2
REAL*8 :: shell_thickness,circle(3),circles(256,4),dd
INTEGER :: ic,nn,sample,num_samples,particle_num
REAL*8 :: dt,CA,L0,f0,g11,ifbreak(nx,ny,nz),Ebreak(nx,ny,nz),temp(nx,ny,nz)
REAL*8 :: ave_D(3)

REAL*8,ALLOCATABLE :: phi(:,:,:),phi1(:,:,:),phi2(:,:,:)
REAL*8,ALLOCATABLE :: phip(:,:,:),phim(:,:,:),phis(:,:,:),phiv(:,:,:)
REAL*8,ALLOCATABLE :: phicp(:,:,:,:),phicm(:,:,:,:),phics(:,:,:,:)
REAL*8,ALLOCATABLE :: el(:,:,:,:)
REAL*8,ALLOCATABLE :: Khom(:,:),Kapha(:,:,:,:,:),Eks(:,:,:,:,:),dKdeta(:,:,:,:,:)
REAL*8,ALLOCATABLE :: eta(:,:,:),force(:,:,:)
COMPLEX*16,ALLOCATABLE :: etak(:,:,:),forcek(:,:,:)
REAL*8,ALLOCATABLE :: G_elec(:,:,:),Gc(:,:,:)
REAL*8,ALLOCATABLE :: fsepar(:,:,:),fgrad(:,:,:),felec(:,:,:)

ALLOCATE(phi(nx,ny,nz),phi1(nx,ny,nz),phi2(nx,ny,nz))
ALLOCATE(phip(nx,ny,nz),phim(nx,ny,nz),phis(nx,ny,nz),phiv(nx,ny,nz))
ALLOCATE(phicp(256,nx,ny,nz),phicm(256,nx,ny,nz),phics(256,nx,ny,nz))
ALLOCATE(el(3,nx,ny,nz))
ALLOCATE(Khom(3,3),Kapha(3,3,nx,ny,nz),Eks(3,3,nx,ny,nz),dKdeta(3,3,nx,ny,nz))
ALLOCATE(eta(nx,ny,nz),force(nx,ny,nz))
ALLOCATE(etak(nx21,ny,nz),forcek(nx21,ny,nz))
ALLOCATE(G_elec(nx,ny,nz),Gc(nx,ny,nz))
ALLOCATE(fsepar(nx,ny,nz),fgrad(nx,ny,nz),felec(nx,ny,nz))
!-----------------------------------------------------------------------------------------
OPEN(UNIT = 1,FILE = 'input.in')
READ(1,*)dt,nstep
READ(1,*)np0,np1
READ(1,*)g11
READ(1,*)E_ext(1),E_ext(2),E_ext(3)
READ(1,*)x11m,x12m,x13m
READ(1,*)x21m,x22m,x23m
READ(1,*)x31m,x32m,x33m
READ(1,*)x11p,x12p,x13p
READ(1,*)x21p,x22p,x23p
READ(1,*)x31p,x32p,x33p
READ(1,*)x11s,x12s,x13s
READ(1,*)x21s,x22s,x23s
READ(1,*)x31s,x32s,x33s
READ(1,*)x11c,x12c,x13c
READ(1,*)x21c,x22c,x23c
READ(1,*)x31c,x32c,x33c
READ(1,*)particle_num,num_samples
CLOSE(1)

E_ext = E_ext*1.0E7
L0 = 1.0
f0 = g11
CA = 0.5
Em_break = 3.7E8
Es_break = 1.0E8
Ep_break = 2.0E7
Ev_break = 3.0E6

Eksm(1,1) = x11m
Eksm(1,2) = x12m
Eksm(1,3) = x13m
Eksm(2,1) = x21m
Eksm(2,2) = x22m
Eksm(2,3) = x23m
Eksm(3,1) = x31m
Eksm(3,2) = x32m
Eksm(3,3) = x33m

Eksp(1,1) = x11p
Eksp(1,2) = x12p
Eksp(1,3) = x13p
Eksp(2,1) = x21p
Eksp(2,2) = x22p
Eksp(2,3) = x23p
Eksp(3,1) = x31p
Eksp(3,2) = x32p
Eksp(3,3) = x33p

Ekss(1,1) = x11s
Ekss(1,2) = x12s
Ekss(1,3) = x13s
Ekss(2,1) = x21s
Ekss(2,2) = x22s
Ekss(2,3) = x23s
Ekss(3,1) = x31s
Ekss(3,2) = x32s
Ekss(3,3) = x33s

Eksv = 0.0

Eksc(1,1) = x11c
Eksc(1,2) = x12c
Eksc(1,3) = x13c
Eksc(2,1) = x21c
Eksc(2,2) = x22c
Eksc(2,3) = x23c
Eksc(3,1) = x31c
Eksc(3,2) = x32c
Eksc(3,3) = x33c

Eksm = Eksm*1.0E-9
Eksp = Eksp*1.0E-9
Ekss = Ekss*1.0E-9
Eksv = Eksv*1.0E-9
Eksc = Eksc*1.0E-9
!----------------------------------------------------------------------------------
!FFTW plans for forward and backward transforms
CALL dfftw_plan_dft_r2c_3d(p_up, nx, ny, nz, input, output, FFTW_MEASURE)
CALL dfftw_plan_dft_c2r_3d(p_dn, nx, ny, nz, output, input, FFTW_MEASURE) 
CALL periodic

!Define the Dirac function data
deta = 0.0
DO j=1,3
 DO i=1,3
  IF(i == j) deta(i,j) = 1.0E-9
 END DO
END DO

phip = 0.0
phim = 0.0
phis = 0.0
phiv = 0.0
!GOTO 100
!-----------------------------------------------------------------------------------

! 读取结构文件
OPEN(UNIT = 1, FILE = 'structure.in')

! 假设存在一个变量 structure_type, 用来区分文件类型
! structure_type == 1 表示第一种结构
! structure_type == 2 表示第二种结构

IF (structure_type == 1) THEN
    ! 第一种结构类型，文件中包含四个相场变量 phip, phis, phim, phiv
    DO n = 1, nx * ny * nz
        READ(1,*) i, j, k, pp, ps, pm, pv  ! 从文件读取每个相场变量
        ii = i
        jj = j
        kk = k
        phip(ii, jj, kk) = pp  ! 填料相
        phis(ii, jj, kk) = ps  ! 壳层相
        phim(ii, jj, kk) = pm  ! 基体相
        phiv(ii, jj, kk) = pv  ! 孔洞相
    END DO

ELSE IF (structure_type == 2) THEN
    ! 第二种结构类型，文件中包含四位字符串，表示相场的状态
    DO n = 1, nx * ny * nz
        READ(1,*) i, j, k, phase_code_str  ! 从文件读取四位相位代码
        ii = i
        jj = j
        kk = k

        ! 解析四位字符串中的每一位，并将其转换为相场变量
        ! 第一位对应 phip，第二位对应 phis，第三位对应 phiv，第四位对应 phim
        IF (phase_code_str(1:1) == '1') THEN
            phip(ii, jj, kk) = 1.0
        ELSE
            phip(ii, jj, kk) = 0.0
        END IF

        IF (phase_code_str(2:2) == '2') THEN
            phis(ii, jj, kk) = 1.0
        ELSE
            phis(ii, jj, kk) = 0.0
        END IF

        IF (phase_code_str(3:3) == '3') THEN
            phiv(ii, jj, kk) = 1.0
        ELSE
            phiv(ii, jj, kk) = 0.0
        END IF

        IF (phase_code_str(4:4) == '4') THEN
            phim(ii, jj, kk) = 1.0
        ELSE
            phim(ii, jj, kk) = 0.0
        END IF
    END DO
ENDIF

CLOSE(1)


!-----------------------------------------------------------------------------------
!DO 2000 sample = 1,num_samples
!IF(np0 == 1) THEN !read from a given structure
! OPEN(UNIT = 1, FILE = 'given_structure.dat')
!  DO n=1,nx*ny*nz
!   READ(1,*)i,j,k,pp,ps,pm,pv
!   ii = i
!   jj = j
!   kk = k
!   phip(ii,jj,kk) = pp
!   phis(ii,jj,kk) = ps
!   phim(ii,jj,kk) = pm
!   phiv(ii,jj,kk) = pv
!  END DO
! CLOSE(1)
!ELSE
!!Start to create a sample with random microstructure
! phicp = 0.0
! phicm = 0.0
! phics = 0.0
!
! shell_thickness = 0.0 !shell thickness
! ic = 1
!GOTO 111
!CALL create_random(circle)
!circle(1) = circle(1)*(nx - 24) + 12  !coordinate of x
!circle(2) = circle(2)*(ny - 24) + 12  !coordinate of y
 !circle(3) = (circle(3) + 1.0)*16.0         !random Radius
!circle(3) = 8.0         !random Radius
 !Save the first circle to circles
!circle(1) = DBLE(nx/2)  
!circle(2) = DBLE(ny/2)
!circle(3) = 4
!R1 = circle(3)
!R2 = circle(3) + shell_thickness
!circles(ic,1) = circle(1)
!circles(ic,2) = circle(2)
!circles(ic,3) = R1 
!circles(ic,4) = R2
!CALL iniconf(INT(circle(1)),INT(circle(2)),nz,R1,phi1) 
!CALL iniconf(INT(circle(1)),INT(circle(2)),nz,R2,phi2)
!phim = 1.0 - phi2
!phis = phi2 - phi1
!phip = phi1
!phicm(ic,:,:,:) = phim(:,:,:)
!phics(ic,:,:,:) = phis(:,:,:)
!phicp(ic,:,:,:) = phip(:,:,:)
!
!11 IF(ic >= particle_num) GOTO 112
! CALL create_random(circle)
! PRINT*,circle 
! circle(1) = circle(1)*(nx - 20) + 10  !coordinate of x
! circle(2) = circle(2)*(ny - 20) + 10  !coordinate of y
! !circle(3) = (circle(3) + 1.0)*16.0         !random Radius
! circle(3) = 8.0         !random Radius
! R1 = circle(3)
! R2 = circle(3) + shell_thickness
! DO i=1,ic !Determine if the created circle is wanted
!  dd = SQRT( (circle(1) - circles(i,1))**2 + (circle(2) - circles(i,2))**2 )
!  IF(dd <= (circles(i,4)+R2+14)) THEN
!   PRINT*,'Give up the unwanted and recreate'
!   GOTO 111
!  ENDIF
! END DO
! ic = ic + 1
! !Save the wanted circle to circles
! circles(ic,1) = circle(1)
! circles(ic,2) = circle(2)
! circles(ic,3) = R1
! circles(ic,4) = R2
! CALL iniconf(INT(circle(1)),INT(circle(2)),nz,R1,phi1)
! CALL iniconf(INT(circle(1)),INT(circle(2)),nz,R2,phi2)
! phim = 1.0 - phi2
! phis = phi2 - phi1
! phip = phi1
! phicm(ic,:,:,:) = phim(:,:,:)
! phics(ic,:,:,:) = phis(:,:,:)
! phicp(ic,:,:,:) = phip(:,:,:)
!!PRINT*,'ic= ',ic
!GOTO 111
!
!12 phi = 0.0
!phip = 0.0
!phim = 0.0
!phis = 0.0
!phiv = 0.0
!DO nn=1,particle_num
! IF(MOD(nn,200) == 0) THEN   
!  phiv(:,:,:) = phiv(:,:,:) + phicp(nn,:,:,:)
! ELSE
!  phip(:,:,:) = phip(:,:,:) + phicp(nn,:,:,:)
!  phis(:,:,:) = phis(:,:,:) + phics(nn,:,:,:)
! ENDIF
!END DO
!phim(:,:,:) = 1.0 - phip(:,:,:) - phis(:,:,:) - phiv(:,:,:)
!NDIF
!!End of creating a sample with random microstructure
!
!OPEN(UNIT = 2, FILE = 'structure.dat')
! DO kk=1,nz
!  DO jj=1,ny
!   DO ii=1,nx
!    WRITE(2,2002)ii,jj,kk,phip(ii,jj,kk),phis(ii,jj,kk),phim(ii,jj,kk),phiv(ii,jj,kk)
!   END DO
!  END DO
! END DO
!------------------------------------------------------------------------------------------------------
 phi(:,:,:) = phi(:,:,:) + 4.0*phim(:,:,:) + 8.0*phis(:,:,:) + 12.0*phip(:,:,:) + 16.0*phiv(:,:,:)
!100 DO kk=1,nz
!  DO jj=1,ny
!   DO ii=1,nx
!    IF((ABS(ii-nx/2) <= 8).AND.(ABS(jj-ny/2) <= 8)) THEN
!     phip(ii,jj,kk) = 1.0
!    ELSE
!     phim(ii,jj,kk) = 1.0
!    ENDIF
!   END DO
!  END DO
! END DO 
 phi(1,1,1) = 0.0
 OPEN(UNIT = 2, FILE = 'shape.dat')
  DO ii=1,nx
   DO jj=1,ny
    WRITE(2,*)ii,jj,phi(ii,jj,nz)
   END DO
   WRITE(2,*)
  END DO
 CLOSE(2)
 
 DO kk=1,nz
  DO jj=1,ny
   DO ii=1,nx
    DO l=1,3
     DO k=1,3
      Eks(k,l,ii,jj,kk) = Eksm(k,l)*phim(ii,jj,kk) + Ekss(k,l)*phis(ii,jj,kk) + &
                          Eksp(k,l)*phip(ii,jj,kk) + Eksv(k,l)*phiv(ii,jj,kk)
     END DO
    END DO
    Gc(ii,jj,kk) = 0.5*epson0*((Eksm(1,1)+deta(1,1))*Em_break**2*phim(ii,jj,kk) + &
                               (Ekss(1,1)+deta(1,1))*Es_break**2*phis(ii,jj,kk) + &
                               10*(Eksp(1,1)+deta(1,1))*Ep_break**2*phip(ii,jj,kk) + &
                               (Eksv(1,1)+deta(1,1))*Ev_break**2*phiv(ii,jj,kk))
!   Ebreak(ii,jj,kk) = Em_break*phim(ii,jj,kk) + Es_break*phis(ii,jj,kk) + Ep_break*phip(ii,jj,kk) + Ev_break*phiv(ii,jj,kk)
!   Ebreak(ii,jj,kk) = Em_break
   END DO
  END DO
 END DO
 
 Km = Eksm + deta
 Kp = Eksp + deta
 
 eta = 0.0
 DO kk=1,nz
  DO jj=1,ny
   DO ii=1,nx
    IF((ABS(ii - nx/2) <= 6).AND.(ABS(jj - ny/2) < 1)) eta(ii,jj,kk) = 1.0
  END DO
 END DO
 
 IF(np1.EQ.1) THEN   !read eta from restart.dat
  OPEN(UNIT = 11, FILE = 'restart.dat')
   DO n=1,nx*ny*nz
    READ(11,*)i,j,k,px
    ii = i
    jj = j
    kk = k
    eta(ii,jj,kk) = px
   END DO
  CLOSE(11)
 ENDIF
 
 DO kk=1,nz
  DO jj=1,ny
   DO ii=1,nx
    DO l=1,3
     DO k=1,3
      Kapha(k,l,ii,jj,kk) = (eta(ii,jj,kk)**3*(10.0 - 15.0*eta(ii,jj,kk) + 6.0*eta(ii,jj,kk)**2))* &
                             (Eksc(k,l) - Eks(k,l,ii,jj,kk)) + (Eks(k,l,ii,jj,kk) + deta(k,l))
      dKdeta(k,l,ii,jj,kk) = 30.0*eta(ii,jj,kk)**2*(eta(ii,jj,kk) - 1.0)**2*(Eksc(k,l) - Eks(k,l,ii,jj,kk))
     END DO
    END DO
   END DO
  END DO
 END DO

 DO jj=1,ny
  DO ii=1,nx
   WRITE(12,*)ii,jj,Kapha(1,1,ii,jj,1),dKdeta(1,1,ii,jj,1)
    WRITE(14,*)ii,jj,Gc(ii,jj,1)
  END DO
  WRITE(12,*)
   WRITE(14,*)
 END DO
! PRINT*,'Kapha = ',Kapha(1,1,nx/2,ny/2,1)
 
 !Initilize homogenous dielectric constants
 IF(Kp(1,1) >= Km(1,1)) Khom = Kp
 IF(Km(1,1) >= Kp(1,1)) Khom = Km
!Khom(:,:) = Kapha(:,:,nx/2,ny/2,nz)
 Khom = (Eksc + deta)*1.0

 OPEN(UNIT = 7, FILE = 'E-D.dat')
 DO 1000 kstep = 1,nstep

  E_ext(1) = 1.0E8 + DBLE(kstep*dt*1.0E6) 

  CALL separation(eta,f0,fsepar)
  CALL gradient(eta,g11,fgrad)
  CALL electric(Kapha,Khom,dKdeta,E_ext,eta,felec,el,G_elec)

  ave_D = 0
  DO kk=1,nz
   DO jj=1,ny
    DO ii=1,nx
     DO j=1,3
      DO i=1,3
       ave_D(j) = ave_D(j) + epson0*Kapha(i,j,ii,jj,kk)*E_ext(i)
      END DO
     END DO
    END DO
   END DO
  END DO
  IF(MOD(kstep,10) == 0) WRITE(7,*)E_ext(1),ave_D(1)
!  DO jj=1,ny
!   DO ii=1,nx
!    WRITE(13,*)ii,jj,G_elec(ii,jj,1)
!   END DO
!   WRITE(13,*)
!  END DO
!  CLOSE(13)
 
! force = fsepar + fgrad - 1.0*felec
  force = fsepar + fgrad + 1.0*felec
! DO kk=1,nz
!  DO jj=1,ny
!   DO ii=1,nx
!    WRITE(15,*),ii,jj,kk,force(ii,jj,kk)
!   END DO
!   WRITE(15,*)
!  END DO
! END DO
! CLOSE(15)
 
! PRINT*,'fsepar = ',fsepar(nx/2,ny/2,nz),'fgrad = ',fgrad(nx/2,ny/2,nz),'felec = ',felec(nx/2,ny/2,nz)
  
  DO kk=1,nz
   DO jj=1,ny
    DO ii=1,nx
     IF(G_elec(ii,jj,kk) < Gc(ii,jj,kk)) THEN
!    IF(MAX1(ABS(el(1,ii,jj,kk)),ABS(el(2,ii,jj,kk)),ABS(el(3,ii,jj,kk))) < Ebreak(ii,jj,kk)) THEN
      force(ii,jj,kk) = 0.0
      ifbreak(ii,jj,kk) = 0.0
     ELSE
      force(ii,jj,kk) = L0*force(ii,jj,kk)
      ifbreak(ii,jj,kk) = 1.0
     ENDIF
!     WRITE(16,*),ii,jj,kk,force(ii,jj,kk)
!     WRITE(17,*),ii,jj,kk,G_elec(ii,jj,kk),felec(ii,jj,kk)
    END DO
!    WRITE(16,*)
!    WRITE(17,*)
   END DO
  END DO
!  CLOSE(16)
!  CLOSE(17)
 
  CALL forward(force,forcek)

  CALL forward(eta,etak)
  DO kk=1,nz
   DO jj=1,ny
    DO ii=1,nx21
     etak(ii,jj,kk) = etak(ii,jj,kk) - dt*forcek(ii,jj,kk)/(1.0 + 0.5*g11*kpow2(ii,jj,kk)*dt)
!    etak(ii,jj,kk) = etak(ii,jj,kk) - dt*forcek(ii,jj,kk)
    END DO
   END DO
  END DO
  CALL backward(etak,eta)
! DO kk=1,nz
!  DO jj=1,ny
!   DO ii=1,nx
!    IF((ABS(ii - nx/2) <= 8).AND.(ABS(jj - ny/2) <= 2)) eta(ii,jj,kk) = 1.0
!   END DO
!  END DO
! END DO

  DO kk=1,nz
   DO jj=1,ny
    DO ii=1,nx
     DO l=1,3
      DO k=1,3
       Kapha(k,l,ii,jj,kk) = (eta(ii,jj,kk)**3*(10.0 - 15.0*eta(ii,jj,kk) + 6.0*eta(ii,jj,kk)**2))* &
                             (Eksc(k,l) - Eks(k,l,ii,jj,kk)) + (Eks(k,l,ii,jj,kk) + deta(k,l))
       dKdeta(k,l,ii,jj,kk) = 30.0*eta(ii,jj,kk)**2*(eta(ii,jj,kk) - 1.0)**2*(Eksc(k,l) - Eks(k,l,ii,jj,kk))
      END DO
     END DO
    END DO
   END DO
  END DO
  PRINT*,'kstep = ',kstep,'E1 = ',E_ext(1), 'E2 = ',E_ext(2),'eta = ',eta(40+nx/2,ny/2,nz)
  IF((MOD(kstep,100) == 0).OR.(kstep == 1)) THEN
   DO ii=1,nx
    DO jj=1,ny
     IF(eta(ii,jj,1) < 0.5) temp(ii,jj,1) = 0.0 
     IF(eta(ii,jj,1) >= 0.5) temp(ii,jj,1) = 1.0 
     IF((ABS(ii - nx/2) <= 6).AND.(ABS(jj - ny/2) < 1)) temp(ii,jj,kk) = 1.0
     WRITE(kstep,2008)ii,jj,(1.0 - temp(ii,jj,1))*phi(ii,jj,1),el(1,ii,jj,1)
     WRITE(16,*),ii,jj,force(ii,jj,1),ifbreak(ii,jj,1)
     WRITE(17,*),ii,jj,G_elec(ii,jj,1),felec(ii,jj,1),el(1,ii,jj,1)
    END DO
    WRITE(kstep,*)
    WRITE(16,*)
    WRITE(17,*)
   END DO
   CLOSE(kstep)
   CLOSE(16)
   CLOSE(17)
  END IF

 1000 CONTINUE
 ! WRITE(7)

!2000 CONTINUE
 
OPEN(UNIT = 6, FILE = 'field.dat')
OPEN(UNIT = 7, FILE = 'eta.dat')
OPEN(UNIT = 8, FILE = 'morphology.dat')
 DO kk=1,nz
  DO ii=1,nx
   DO jj=1,ny 
    WRITE(6,2006)ii,jj,kk,el(1,ii,jj,kk),el(2,ii,jj,kk),el(3,ii,jj,kk)
    WRITE(7,2007)ii,jj,kk,eta(ii,jj,kk)
    WRITE(8,2007)ii,jj,kk,(1.0 - eta(ii,jj,kk))*phi(ii,jj,kk)
   END DO
   WRITE(6,*)
   WRITE(7,*)
   WRITE(8,*)
  END DO
 END DO
CLOSE(6)
CLOSE(7)

2002  FORMAT(3(1x,i4),4(1x,e12.4))
2006  FORMAT(3(1x,i4),3(1x,e12.4))
2007  FORMAT(3(1x,i4),(1x,e12.4))
2008  FORMAT(2(1x,i4),2(1x,e12.4))

DEALLOCATE(phi,phi1,phi2)
DEALLOCATE(phip,phim,phis,phiv)
DEALLOCATE(phicp,phicm,phics)
DEALLOCATE(el)
DEALLOCATE(Khom,Kapha,Eks,dKdeta)
DEALLOCATE(eta,force)
DEALLOCATE(etak,forcek)
DEALLOCATE(G_elec,Gc)
DEALLOCATE(fsepar,fgrad,felec)

END PROGRAM main
