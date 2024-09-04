SUBROUTINE create_random(circle)
INTEGER :: clock,i,n
INTEGER, DIMENSION(:), ALLOCATABLE :: seed
REAL*8 :: circle(4)

CALL RANDOM_SEED(size = n)

ALLOCATE(seed(n))

CALL SYSTEM_CLOCK(count = clock)
   
seed = clock + 100*(/(i-1, i=1, 4)/)

CALL RANDOM_SEED(put = seed)

CALL RANDOM_NUMBER(circle)
          
DEALLOCATE(seed)

END SUBROUTINE
