SUBROUTINE iniconf(x0,y0,z0,r0,phi0)
USE globalvars
IMPLICIT NONE

INTEGER :: x0,y0,z0
REAL*8 :: r0,phi0(nx,ny,nz),rr(nx,ny,nz)
INTEGER :: ii,jj,kk

IF(ndim == 2) THEN
!PRINT*,'Two dimensionsional simulation'
DO ii=1,nx
 DO jj=1,ny
  DO kk=1,nz
   rr(ii,jj,kk) = SQRT(DBLE(ii - x0)**2 + DBLE(jj - y0)**2)
   phi0(ii,jj,kk) = 1.0 - (0.5*TANH(4.0*(rr(ii,jj,kk) - r0)) + 0.5)£¡Ë«ÇúÕýÇÐº¯Êý
  ENDDO
 ENDDO
ENDDO
!Generate initial configuration (3D sphere)
ELSEIF (ndim == 3) THEN        
PRINT*,'Three dimensionsional simulation'
DO ii=1,nx
 DO jj=1,ny
  DO kk=1,nz
  ENDDO
 ENDDO
ENDDO
ENDIF

END SUBROUTINE iniconf
