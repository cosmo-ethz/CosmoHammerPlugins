!Programm which computes the likelihood for a set of cls.
!The parameters are hardcoded since this program is only for demonstration and testig purpose
!
!Author: Joel Akeret
!Created: 08.05.2012
!Modified 12.08.2013
program WmapWrapperManager
    use WmapWrapperCore

    implicit none
    character(LEN=1024) inputFile
    real(8) :: likelihood
    real(8), dimension(2:1200) :: cl_tt,cl_te,cl_ee,cl_bb
    integer                     :: l,i

    character(LEN=1024) :: wmapDataDir = './likelihood_v3/data/'
    call setup(wmapDataDir)

    inputFile = "test/lensedcls.dat"

    write(*,*)"Reading in Cls from: ",trim(inputFile)

    open(unit=13,file=inputFile,action='read',status='old')

    do l=2,ttmax
       read(13,*)i,cl_tt(l),cl_ee(l),cl_bb(l),cl_te(l)
    enddo

    close(13)

    call calcWmapLikelihood(cl_tt, cl_te, cl_ee, cl_bb, ttmax, likelihood)

    write(*,*) "Likelihood: ", likelihood


end program
