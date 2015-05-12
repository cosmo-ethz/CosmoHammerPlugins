!Provides an interface for the computation of the power spectrum using CAMB
!
!Author: Joel Akeret
!Created: 08.05.2012
!Modified: 14.08.2013
module CambWrapper
    use CambWrapperCore
    implicit none

    Type(CAMBparams) params
    logical :: initialized = .false.

    double precision, allocatable,dimension(:,:) :: matter_power_kh
    real,             allocatable,dimension(:,:,:) :: matter_power


contains

    !Computes the cmb power spectrum for the given cosmological parameters
    subroutine computeCmbPowerSpectrum(values, cl_tt,cl_te,cl_ee,cl_bb)
        real(8), dimension(6), intent(in) :: values
        real(8), dimension(2:params%Max_l), intent(out) :: cl_tt,cl_te,cl_ee,cl_bb

        !write(*,*) "input values", values

        if (.not. initialized) then
           stop "Likelihood can only be computed after the setup routine has been called"
        end if

        call convertParameters(params, values)

        call getCambCmbPowerSpectrum(params, cl_tt, cl_te, cl_ee, cl_bb)

    end subroutine

!    subroutine computeCambMatterPowerSpectrum(values,maxk,dlogk,nred,redshifts)
!        real(8), dimension(6), intent(in) :: values
!        !real, intent(in) :: paramVec(31)
!        integer, intent(in) :: nred
!        double precision, intent(in), dimension(nred) :: redshifts
!        real, intent(in) ::  maxk, dlogk
!
!        if (.not. initialized) then
!           stop "Likelihood can only be computed after the setup routine has been called"
!        end if
!
!        call convertParameters(params, values)
!
!        call getCambMatterPowerSpectrum(params, maxk,dlogk,nred,redshifts, matter_power, matter_power_kh)
!
!    end subroutine

    subroutine computeCambMatterPowerSpectrum(values, maxk,dlogk,nred,redshifts)
        use camb
        implicit none
        !real, intent(in) :: paramVec(31)
        real(8), dimension(6), intent(in) :: values
        integer, intent(in) :: nred
        integer :: lmax
        double precision, intent(in), dimension(nred) :: redshifts
        !type(CAMBparams) :: P
        integer :: nr, i
        real, intent(in) ::  maxk, dlogk
        real, parameter :: minkh = 1.0e-4
        integer in,itf, points, points_check

        !real, dimension(:,:,:), intent(in) :: matter_power
        !double precision, dimension(:,:), intent(in) :: matter_power_kh
        double precision, dimension(:), allocatable :: matter_power_sigma8

        nr = size(redshifts)
        call CAMB_SetDefParams(params)

        if (.not. initialized) then
           stop "Likelihood can only be computed after the setup routine has been called"
        end if

        call convertParameters(params, values)

        params%Reion%use_optical_depth = .false.


        !call makeParameters(paramVec,P)
        params%WantTransfer = .true.
        lmax=2000
        params%max_l=lmax
        params%Max_l_tensor=lmax
        params%Max_eta_k=2*lmax
        params%Max_eta_k_tensor=2*lmax
        params%transfer%num_redshifts = nr

        params%transfer%kmax = maxk * (params%h0/100._dl)
        params%transfer%k_per_logint = dlogk

        do i=1,nr
            params%transfer%redshifts(i)=redshifts(i)
        enddo
        call CAMB_GetResults(params)

        itf=1
        points = log(MT%TransferData(Transfer_kh,MT%num_q_trans,itf)/minkh)/dlogk+1

        call freematterpower()

        allocate(matter_power(points,CP%InitPower%nn,nr))
        allocate(matter_power_kh(points,nr))
        allocate(matter_power_sigma8(nr))
        matter_power_sigma8 = MT%sigma_8(:,1)

        do itf=1, CP%Transfer%num_redshifts
            points_check = log(MT%TransferData(Transfer_kh,MT%num_q_trans,itf)/minkh)/dlogk+1
             if (points_check .ne. points)  stop 'Problem with pycamb assumption on k with z'
             do in = 1, CP%InitPower%nn
              call Transfer_GetMatterPower(MT,matter_power(:,in,itf), itf, in, minkh,dlogk, points)
!              if (CP%OutputNormalization == outCOBE) then
!                 if (allocated(COBE_scales)) then
!                  outpower(:,in) = outpower(:,in)*COBE_scales(in)
!                 else
!                  if (FeedbackLevel>0) write (*,*) 'Cannot COBE normalize - no Cls generated'
!                 end if
!             end if
             end do
             do i=1,points
              matter_power_kh(i,itf)=minkh*exp((i-1)*dlogk)
             end do
        enddo !End redshifts loop
        if (allocated(matter_power_sigma8))    deallocate(matter_power_sigma8)
    end subroutine

    subroutine freematterpower()
        if (allocated(matter_power))    deallocate(matter_power)
        if (allocated(matter_power_kh)) deallocate(matter_power_kh)
        !if (allocated(matter_power_sigma8))    deallocate(matter_power_sigma8)
    end subroutine freematterpower

    !Sets up the params in the module using the parameter file in the given location
    !inputFile: the relative path to the file to use
    subroutine setupParams(inputFile, installPath, lmax)
        character(LEN=1024), intent(in) :: inputFile
        character(LEN=1024), intent(in) :: installPath
        integer, intent(out) :: lmax

        write(*,*) "Start setup of parameters"
        call setup(params, inputFile, installPath)
        lmax = params%Max_l

        initialized = .true.

        write(*,*) "Setup done"

    end subroutine


end module
