#You may need to edit the library paths for MKL for Intel
#Beware of using optimizations that lose accuracy - may give errors when running

WMAP = ../likelihood_v4p1

cfitsio = /usr/lib/cfitsio

IFLAG = -I
INCLUDE=

#Intel ifort
#these settings are for ifort 11.1 and higher; 
F90C     = ifort
FFLAGS = -O3 -W0 -WB -openmp -fpp -vec_report0 -mkl=parallel
LAPACKL = 


F90FLAGS = -DMATRIX_SINGLE $(FFLAGS) $(INCLUDE)
LINKFLAGS = -L$(LAPACKL)

OBJFILES=  WmapWrapperCore.o WmapWrapperManager.o WmapWrapper.o


F90FLAGS += $(IFLAG)$(cfitsio)/include $(IFLAG)$(WMAP)
LINKFLAGS +=  $(cfitsio)/lib -L$(WMAP) -lwmap7 -lcfitsio

default: wmapWrapper

all : wmapWrapper

export FFLAGS
export F90C

.f.o:
	f77 $(F90FLAGS) -c $<

%.o: %.f90
	$(F90C) $(F90FLAGS) -c $*.f90 -o $*.o


wmapWrapper: wmap $(OBJFILES)
	$(F90C) -o ../wmapWrapperManager $(OBJFILES) $(LINKFLAGS) $(F90FLAGS)


clean: cleanwmapWrapper
	rm -f 

cleanwmapWrapper:
	rm -f *.o *.mod *.d *.pc *.obj ../wmapWrapperManager

wmap:
	cd $(WMAP) && $(MAKE) libwmap7.a