SUBROUTINE backward(output, input)
USE globalvars
!calculates backward fourier transform (complex to real) using FFTW
COMPLEX*16, INTENT(IN) :: output(nx21,ny,nz)
REAL*8, INTENT(OUT)   :: input(nx,ny,nz)
COMPLEX*16 :: tempk(nx21,ny,nz)
INTEGER :: i,j,k

tempk = 0.
DO k=1,nz
  DO j=1,ny
    DO i=1,nx21
      tempk(i,j,k) = output(i,j,k)
    END DO
  END DO
END DO

CALL dfftw_execute_dft_c2r(p_dn,tempk,input)

DO k=1,nz
  DO j=1,ny
    DO i=1,nx
      input(i,j,k) = sizescale*input(i,j,k)
    END DO
  END DO
END DO

!RETURN
END SUBROUTINE backward
