SUBROUTINE periodic
USE globalvars
IMPLICIT NONE

INTEGER :: nx2,ny2,nz2
INTEGER :: ii,jj,kk,ti,tj,tk
REAL*8 :: dkx,dky,dkz

dkx = 2.0*pi/(DBLE(nx)*dx)
dky = 2.0*pi/(DBLE(ny)*dy)
dkz = 2.0*pi/(DBLE(nz)*dz)

nx2 = nx + 2
ny2 = ny + 2
nz2 = nz + 2

DO ii=1,nx21
 kx(ii) = DBLE(ii - 1)*dkx
 kx(nx2 - ii) = -kx(ii)
END DO

DO jj=1,ny/2 + 1 
 ky(jj) = DBLE(jj - 1)*dky
 ky(ny2 - jj) = -ky(jj)
END DO

DO kk=1,nz/2 + 1
 kz(kk) = DBLE(kk - 1)*dkz
 kz(nz2 - kk) = -kz(kk)
END DO

DO kk=1,nz + 1
 DO jj=1,ny + 1
  DO ii=1,nx + 1
   kpow2(ii,jj,kk) = kx(ii)**2 + ky(jj)**2 + kz(kk)**2
  END DO
 END DO
END DO 

RETURN
END SUBROUTINE periodic

