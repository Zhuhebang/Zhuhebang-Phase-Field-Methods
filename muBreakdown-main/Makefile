fftw_wrapper_path := share/mkl/interfaces/fftw3xf/wrappers

IFC = ifx
ICC = icx

XLIB =  -L${MKLROOT}/lib -lmkl_intel_ilp64 -lmkl_intel_thread -lmkl_core -liomp5 -lpthread -lm -ldl

FOPT = -O3
OBJS = globalvars.o iniconf.o periodic.o forward.o backward.o\
       calc_inverse.o create_random_seed.o separation.o\
       gradient.o electric.o main.o

FFTW_SRC = $(notdir $(wildcard ${MKLROOT}/$(fftw_wrapper_path)/*.c))
FFTW_OBJS := $(FFTW_SRC:.c=.o)
MKLLIB = -Wl,--start-group ${MKLROOT}/lib/libmkl_intel_lp64.a ${MKLROOT}/lib/libmkl_sequential.a ${MKLROOT}/lib/libmkl_core.a -Wl,--end-group -lpthread -lm -ldl
MKLINC = -I"${MKLROOT}/include/fftw"

%.o: ${MKLROOT}/$(fftw_wrapper_path)/%.c
	$(ICC) $(FOPT) $(MKLINC) -c $< -o $@

%.o: %.f90
	$(IFC) $(FOPT) $(MKLINC) -c $< -o $@

a.out: $(OBJS) $(FFTW_OBJS)
	$(IFC) $(FOPT) -o $@ $(FFTW_OBJS) $(OBJS) $(MKLLIB)
clean:  
	-\rm *.o *.mod *.out 
