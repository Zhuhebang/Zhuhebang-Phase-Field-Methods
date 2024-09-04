SUBROUTINE electric(Kapha,Khom,dKdeta,E_ext,eta,felec,el,G_elec)
USE globalvars
USE invert
IMPLICIT NONE

INTEGER :: ii,jj,kk,i,j,k,l,n
INTEGER :: iter,nstep
REAL*8 :: Kapha(3,3,nx,ny,nz),Khom(3,3),dKdeta(3,3,nx,ny,nz),E_ext(3)
REAL*8 :: G_elec(nx,ny,nz),felec(nx,ny,nz),el(3,nx,ny,nz),eta(nx,ny,nz)
REAL*8 :: omega, invomega, nk(3)

REAL*8,ALLOCATABLE :: DKE(:,:,:,:)
COMPLEX*16,ALLOCATABLE :: DKEk(:,:,:,:)
REAL*8,ALLOCATABLE :: p(:,:,:,:)
COMPLEX*16,ALLOCATABLE :: pk(:,:,:,:)
COMPLEX*16,ALLOCATABLE :: elk(:,:,:,:)
REAL*8,ALLOCATABLE :: pot(:,:,:)
COMPLEX*16,ALLOCATABLE :: potk(:,:,:)
REAL*8,ALLOCATABLE :: DeltaK(:,:,:,:,:)

ALLOCATE(DKE(3,nx,ny,nz))
ALLOCATE(DKEk(3,nx21,ny,nz))
ALLOCATE(p(3,nx,ny,nz))
ALLOCATE(pk(3,nx21,ny,nz))
ALLOCATE(elk(3,nx21,ny,nz))
ALLOCATE(pot(nx,ny,nz))
ALLOCATE(potk(nx21,ny,nz))
ALLOCATE(DeltaK(3,3,nx,ny,nz))

nstep = 20
DO kk=1,nz
 DO jj=1,ny
  DO ii=1,nx
   DO l=1,3
    DO k=1,3
     DeltaK(k,l,ii,jj,kk) = Kapha(k,l,ii,jj,kk) - Khom(k,l)
    END DO
   END DO
  END DO
 END DO
END DO
 
pk = 0.0
potk = 0.0
elk = 0.0
!Begin the iterations
DO 1000 iter=1,nstep
  
!Calculate the electric field from potential
 DO kk=1,nz
  DO jj=1,ny
   DO ii=1,nx21
    nk = 0.0
    nk(1) = kx(ii)
    nk(2) = ky(jj)
    nk(3) = kz(kk)
    
    DO j=1,3
     elk(j,ii,jj,kk) = -imag*nk(j)*potk(ii,jj,kk)
    END DO
 
   END DO
  END DO
 END DO
 
 CALL backward(elk(1,:,:,:),el(1,:,:,:))
 CALL backward(elk(2,:,:,:),el(2,:,:,:))
 CALL backward(elk(3,:,:,:),el(3,:,:,:))
 
!Calculate DelataK x el
 DKE = 0.0
 DO kk=1,nz
  DO jj=1,ny
   DO ii=1,nx
 
    DO j=1,3
     DO i=1,3
      DKE(j,ii,jj,kk) = DKE(j,ii,jj,kk) + DeltaK(i,j,ii,jj,kk)*(el(i,ii,jj,kk) + E_ext(i))
     END DO
    END DO
 
   END DO
  END DO
 END DO 
 
 CALL forward(DKE(1,:,:,:),DKEk(1,:,:,:))
 CALL forward(DKE(2,:,:,:),DKEk(2,:,:,:))
 CALL forward(DKE(3,:,:,:),DKEk(3,:,:,:))
 
!Iterative equation
 potk = 0.0
 DO kk=1,nz
  DO jj=1,ny
   DO ii=1,nx21
    omega = 0.0
    invomega = 0.0
    nk = 0.0
 
    nk(1) = kx(ii)
    nk(2) = ky(jj)
    nk(3) = kz(kk)
 
    DO l=1,3
     DO k=1,3
      invomega = invomega + Khom(k,l)*nk(k)*nk(l)
     END DO
    END DO
   
    IF(ABS(invomega).GE.1.0E-8) THEN
     omega = 1.0/invomega
    ELSE
     omega = 1.0
    ENDIF
 
    DO i=1,3
     potk(ii,jj,kk) = potk(ii,jj,kk) - imag*omega*nk(i)*(DKEk(i,ii,jj,kk) + pk(i,ii,jj,kk)/epson0)
    END DO
    
    DO j=1,3
     elk(j,ii,jj,kk) = -imag*nk(j)*potk(ii,jj,kk)
    END DO 
 
   END DO
  END DO
 END DO 
 
!PRINT*,'kt=',iter, 'efield = ',el(1,nx/2,ny/2,nz)
1000 CONTINUE
CALL backward(potk,pot) 
CALL backward(elk(1,:,:,:),el(1,:,:,:)) 
CALL backward(elk(2,:,:,:),el(2,:,:,:)) 
CALL backward(elk(3,:,:,:),el(3,:,:,:)) 
 
 
DO kk=1,nz
 DO jj=1,ny
  DO ii=1,nx
   DO j=1,3
    el(j,ii,jj,kk) = (el(j,ii,jj,kk) + E_ext(j))*(1.0 - eta(ii,jj,kk)**3*(10.0 - 15.0*eta(ii,jj,kk) + 6.0*eta(ii,jj,kk)**2))
   END DO
  END DO
 END DO
END DO
 
felec = 0.0
G_elec = 0.0
DO kk=1,nz
 DO jj=1,ny
  DO ii=1,nx
   DO j=1,3
    DO i=1,3
     felec(ii,jj,kk) = felec(ii,jj,kk) - 0.5*epson0*dKdeta(i,j,ii,jj,kk)*el(i,ii,jj,kk)*el(j,ii,jj,kk)
     G_elec(ii,jj,kk) = G_elec(ii,jj,kk) + 0.5*epson0*Kapha(i,j,ii,jj,kk)*el(i,ii,jj,kk)*el(j,ii,jj,kk)
    END DO
   END DO
  END DO
 END DO
END DO

DEALLOCATE(DKE)
DEALLOCATE(DKEk)
DEALLOCATE(p)
DEALLOCATE(pk)
DEALLOCATE(elk)
DEALLOCATE(pot)
DEALLOCATE(potk)
DEALLOCATE(DeltaK)

END SUBROUTINE electric
