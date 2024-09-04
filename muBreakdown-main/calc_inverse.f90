MODULE invert

IMPLICIT NONE

CONTAINS

SUBROUTINE calcinv(a,ainv)
REAL*8, INTENT(IN) :: a(3,3)
REAL*8, INTENT(OUT) :: ainv(3,3)
REAL*8 :: det
INTEGER :: i,j

DO i = 1,3
 DO j = 1,3
 ainv(i,j) = 0.
 END DO
END DO

det =   a(1,1)*(a(2,2)*a(3,3) - a(2,3)*a(3,2))  &
      - a(1,2)*(a(2,1)*a(3,3) - a(2,3)*a(3,1))  &
      + a(1,3)*(a(2,1)*a(3,2) - a(2,2)*a(3,1))

IF (ABS(det) > 1.E-06) THEN
ainv(1,1) = (a(2,2)*a(3,3) - a(3,2)*a(2,3))/det
ainv(1,2) = (a(3,2)*a(1,3) - a(1,2)*a(3,3))/det
ainv(1,3) = (a(2,3)*a(1,2) - a(1,3)*a(2,2))/det
ainv(2,1) = (a(2,3)*a(3,1) - a(3,3)*a(2,1))/det
ainv(2,2) = (a(1,1)*a(3,3) - a(3,1)*a(1,3))/det
ainv(2,3) = (a(1,3)*a(2,1) - a(2,3)*a(1,1))/det
ainv(3,1) = (a(2,1)*a(3,2) - a(3,1)*a(2,2))/det
ainv(3,2) = (a(1,2)*a(3,1) - a(3,2)*a(1,1))/det
ainv(3,3) = (a(1,1)*a(2,2) - a(2,1)*a(1,2))/det
END IF
END SUBROUTINE calcinv

END MODULE invert
