F90 = gfortran
XLIB = -L/usr/lib64 -lfftw3 -lfftw3_threads -lfftw3l -lfftw3l_threads -lfftw3f -lfftw3f_threads -lm
FOPT = -O3
OBJS = globalvars.o iniconf.o periodic.o forward.o backward.o\
       calc_inverse.o create_random_seed.o separation.o\
       gradient.o electric.o main.o

%.o: %.f90
	$(F90) $(FOPT) -c $<
a.out: $(OBJS) 
	$(F90) $(FOPT) -o $@ $(OBJS) $(XLIB)
clean:  
	-\rm *.o *.mod *.out 
