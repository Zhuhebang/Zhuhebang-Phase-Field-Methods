SUBROUTINE gradient(eta,g11,fgrad)
USE globalvars
IMPLICIT NONE

INTEGER :: ii,jj,kk
REAL*8 :: g11,eta(nx,ny,nz),fgrad(nx,ny,nz)

COMPLEX*16,ALLOCATABLE :: etak(:,:,:),fgradk(:,:,:)

ALLOCATE(etak(nx21,ny,nz),fgradk(nx21,ny,nz))
 
 
CALL forward(eta,etak)

fgradk = 0.0 
DO kk=1,nz
 DO jj=1,ny
  DO ii=1,nx21
   fgradk(ii,jj,kk) = g11*kpow2(ii,jj,kk)*etak(ii,jj,kk) 
  END DO
 END DO
END DO 
 
CALL backward(fgradk,fgrad) 

DEALLOCATE(etak,fgradk)

END SUBROUTINE gradient 
