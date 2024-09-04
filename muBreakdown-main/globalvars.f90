MODULE globalvars
IMPLICIT NONE

INTEGER, PARAMETER :: nx = 256, ny = 256, nz = 1, n3 = nx*ny*nz
INTEGER, PARAMETER :: ndim = 2    ! Dimensions
REAL*8, PARAMETER :: dx = 1.0, dy = 1.0, dz = 1.0
REAL*8, PARAMETER :: pi = ACOS(-1.0)
INTEGER, PARAMETER :: nx21 = nx/2 + 1
REAL*8, PARAMETER :: sizescale = 1.0/FLOAT(n3)
REAL*8,PARAMETER :: epson0 = 8.854E-12
REAL*8,PARAMETER :: miu0 = 4.0*pi*1.0E-7  !(H/m)
COMPLEX*16,PARAMETER :: imag = (0,1)
INTEGER (KIND = 8) p_up, p_dn
REAL*8 :: kx(nx + 1),ky(ny + 1),kz(nz + 1)
REAL*8 :: kpow2(nx + 1,ny + 1,nz + 1)


END MODULE globalvars
