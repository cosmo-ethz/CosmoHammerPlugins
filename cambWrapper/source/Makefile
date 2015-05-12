#You may need to edit the library paths for MKL for Intel
#Beware of using optimizations that lose accuracy - may give errors when running

IFLAG = -I
INCLUDE=

#Intel ifort
#these settings for ifort 11.1 and higher; may need to add explicit link directory otherwise
F90C     = ifort
FFLAGS = -O3 -openmp -fpp -vec_report0 -mkl=parallel -FR -fpic
LAPACKL = 


F90FLAGS = -DMATRIX_SINGLE $(FFLAGS) $(IFLAG)../camb $(INCLUDE)
LINKFLAGS = -L../camb -lcamb_recfast $(LAPACKL)

OBJFILES=  CambWrapperCore.o CambWrapper.o CambWrapperManager.o

default: cambWrapper

all : cambWrapper

export FFLAGS
export F90C

.f.o:
	f77 $(F90FLAGS) -c $<

%.o: %.f90
	$(F90C) $(F90FLAGS) -c $*.f90 -o $*.o


cambWrapper: camb $(OBJFILES)
	$(F90C) -o ../cambWrapperManager $(OBJFILES) $(LINKFLAGS) $(F90FLAGS)


clean: cleancambWrapper
	rm -f ../camb/*.o ../camb/*.obj ../camb/*.mod

cleancambWrapper:
	rm -f *.o *.mod *.d *.pc *.obj ../cambWrapperManager


camb:
	cd ../camb && $(MAKE) --file=Makefile_main libcamb_recfast.a
