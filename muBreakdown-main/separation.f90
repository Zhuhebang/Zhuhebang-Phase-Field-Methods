SUBROUTINE separation(eta,f0,fsepar)
USE globalvars
IMPLICIT NONE

INTEGER :: ii,jj,kk
REAL*8 :: f0,eta(nx,ny,nz),fsepar(nx,ny,nz)

fsepar = 0.0
DO kk=1,nz
 DO jj=1,ny
  DO ii=1,nx
   fsepar(ii,jj,kk) = 2.0*f0*eta(ii,jj,kk)*(1.0 - eta(ii,jj,kk))*(1.0 - 2.0*eta(ii,jj,kk))
  END DO
 END DO
END DO
 
END SUBROUTINE separation
