!Provides an interface for f2py for the computation of the WMAP likelihood

!
!Author: Joel Akeret
!Created: 08.02.2013
!Modified 12.08.2013
module WmapWrapper
    use WmapWrapperCore
    implicit none

    logical :: initialized = .false.

contains

    !Computes the wmap likelihood using the given power spectrum
    subroutine computeWmapLikelihood(cl_tt,cl_te,cl_ee,cl_bb,lmax,likelihood)
        real(8), dimension(2:lmax), intent(in) :: cl_tt,cl_te,cl_ee,cl_bb
        real(8), intent(out) :: likelihood(10)
        integer lmax

        if (.not. initialized) then
           stop "Likelihood can only be computed after the setup routine has been called"
        end if

        call calcWmapLikelihood(cl_tt,cl_te,cl_ee,cl_bb,lmax,likelihood)

    end subroutine

    !Sets up the params in the module using the parameter file in the given location
    !inputFile: the relative path to the file to use
    subroutine setupParams(wmapDataDir,TT,TE,lowlTT,lowlPOL,TTmi,TTma)
        logical, intent(in) ::TT
        logical, intent(in) ::TE
        logical, intent(in) ::lowlTT
        logical, intent(in) ::lowlPOL
        real(8), intent(in) ::TTmi
        real(8), intent(in) ::TTma
		character(LEN=1024), intent(in) :: wmapDataDir
        write(*,*) "Start setup of wmap"
        call setup(wmapDataDir,TT,TE,lowlTT,lowlPOL,TTmi,TTma)

        initialized = .true.

        write(*,*) "Setup done"

    end subroutine


end module
