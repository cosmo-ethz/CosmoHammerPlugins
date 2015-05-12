!Programm which computes the power spectrum for a set of cosmological parameters.
!The params.ini file is hardcoded since this program is only for demonstration and testig purpose
!
!Author: Joel Akeret
!Created: 08.05.2012
!Modified: 14.08.2013
program CambWrapperManager
    use ModelParams
    use CambWrapper

    implicit none
    character(LEN=input_file_len) inputFile
    character(LEN=input_file_len) path 

    integer i
    real(dl), dimension(2:4000) :: cl_tt,cl_te,cl_ee,cl_bb
    real(dl), dimension(6) :: values
    integer :: ttmax = 1200

    values(1) = 67.11243
    values(2) = 0.0226
    values(3) = 0.122
    values(4) = 2.453253156176061E-009
    values(5) = 0.91
    values(6) = 0.09


    inputFile = "cambWrapper/camb/params.ini"
    path = "camb/"
    call setupParams(inputFile, path, ttmax)

	write(*,*) "Computing cmb power spectrum for", values
    call computeCmbPowerSpectrum(values, cl_tt(2:ttmax), cl_te(2:ttmax), cl_ee(2:ttmax), cl_bb(2:ttmax))
	write(*,*) "Done. Writing results to file"
	
    open(unit=fileio_unit,file="wrapper_lensedcls.dat",form='formatted',status='replace')
    do i = 2, ttmax
        write(fileio_unit,'(1I6,4E15.5)')i, cl_tt(i), cl_ee(i), cl_bb(i), cl_te(i)
    end do

end program
