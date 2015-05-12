!Core module for the computation of the likelihood using wmap.
!Provides routines for the computation of the wmap likelihood using the given cls

!
!Author: Joel Akeret
!Created: 08.05.2012
!Modified 12.08.2013
module WmapWrapperCore
        use wmap_likelihood_9yr
        use WMAP_OPTIONS
        use WMAP_UTIL

    implicit none

    integer, parameter :: CL_TT_INDEX = 1
    integer, parameter :: CL_EE_INDEX = 2
    integer, parameter :: CL_TE_INDEX = 4
    integer, parameter :: CL_BB_INDEX = 3
    integer, parameter :: MAX_NUM = 10

contains

    !computes the wmap likelihood using the given power spectrum
    subroutine calcWmapLikelihood(cl_tt,cl_te,cl_ee,cl_bb,lmax,likelihood)
        real(8), dimension(2:lmax), intent(in) :: cl_tt,cl_te,cl_ee,cl_bb
        real(8), intent(out) :: likelihood(MAX_NUM)
        real(8) :: like(num_WMAP)
        integer lmax
        integer n

        do n=1,MAX_NUM
            likelihood(n) = 0.d0
        end do
        like=0.d0
        call wmap_likelihood_compute(cl_tt(2:ttmax),cl_te(2:ttmax),cl_ee(2:ttmax),cl_bb(2:ttmax),like)
        if (wmap_likelihood_ok) then
!	        likelihood = sum(like(1:num_WMAP))
            do n=1,num_WMAP
                likelihood(n) = like(n)
            end do
	    else
            print *, "WMAPLnLike: Error computing WMAP likelihood."
            call wmap_likelihood_error_report
        end if
    end subroutine

    !Inits the wmap module
    subroutine setup(wmapDataDir,TT,TE,lowlTT,lowlPOL,TTmi,TTma)
    	character(LEN=1024), intent(in) :: wmapDataDir
        logical, intent(in) ::TT
        logical, intent(in) ::TE
        logical, intent(in) ::lowlTT
        logical, intent(in) ::lowlPOL
        real(8), intent(in) ::TTmi
        real(8), intent(in) ::TTma


        !---------------------------------------------------
        ! put in likelihood options
        ! see PASS2_options module for the options below
        !---------------------------------------------------

        use_TT               = TT
        use_TE               = TE
        use_lowl_TT          = lowlTT
        use_lowl_pol         = lowlPOL
        ttmin                = TTmi
        temin                = TTmi
        ttmax                = TTma
        
        write(*,*) "Using WMAP data dir:", trim(wmapDataDir)
        
        WMAP_data_dir = wmapDataDir
        
        gibbs_sigma_filename = trim(WMAP_data_dir) // gibbs_sigma_filename

        call wmap_likelihood_init

    end subroutine

end module
