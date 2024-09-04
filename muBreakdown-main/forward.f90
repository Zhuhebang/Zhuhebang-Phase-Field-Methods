SUBROUTINE forward(input, output)
USE globalvars
!calculates forward fourier transform (real to complex) using FFTW
REAL*8, INTENT(IN) :: input(nx,ny,nz)
COMPLEX*16, INTENT(OUT) :: output(nx21,ny,nz)

CALL dfftw_execute_dft_r2c(p_up,input,output)

!RETURN
END SUBROUTINE forward
