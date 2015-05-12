!Core module for the computation of the cmb power spectrum using camb.
!Provides routines for the setup of a CAMBparams using a params file and
!for the computation of the cls using those parameters

!
!Author: Joel Akeret
!Created: 08.05.2012
!Modified: 14.08.2013
module CambWrapperCore
       use IniFile
        use CAMB
        use ModelParams
        use LambdaGeneral
        use Lensing
        use AMLUtils
        use Transfer
        use constants
        use Precision
        use Bispectrum
        use ModelParams
        use constants
        use CAMB

    implicit none

    integer, parameter :: input_file_len = 1024
    integer, parameter :: CL_TT_INDEX = 1
    integer, parameter :: CL_EE_INDEX = 2
    integer, parameter :: CL_TE_INDEX = 4
    integer, parameter :: CL_BB_INDEX = 3

contains

    !Gets the power specturm for the given parameters using Camb
    subroutine getCambCmbPowerSpectrum(params, cl_tt,cl_te,cl_ee,cl_bb)
        Type(CAMBparams) params
        real(dl), dimension(2:params%Max_l), intent(out) :: cl_tt,cl_te,cl_ee,cl_bb

        integer :: error = 0
        integer i
        Type(CAMBdata) Transfers

        !write(*,*) "params1 ", params


        call updateReionization(params, params%Reion%optical_depth)

        !call CAMB_GetResults(params, error)
        call CAMB_GetTransfers(params, Transfers, error)
        call CAMB_TransfersToPowers(Transfers)

        !write(*,*) "params2 ", params

        !write(*,*) "camb called. error ", error

        call convertCls(params,cl_tt,cl_te,cl_ee,cl_bb)

        call CAMB_cleanup

    end subroutine

    subroutine updateReionization(params, tau)
        Type(CAMBparams) params
        real(dl), intent(in) :: tau
        real(dl) zre

        params%Reion%use_optical_depth = .true.
        params%Reion%redshift = tau

        zre = CAMB_GetZreFromTau(params,tau)

        params%Reion%use_optical_depth = .false.
        params%Reion%redshift = zre
        params%Reion%optical_depth = 0

    end subroutine

    !Converts the given Camb power spectrum to wmap conform specturms
    subroutine convertCls(params,cl_tt,cl_te,cl_ee,cl_bb)
        Type(CAMBparams) params
        real(dl), dimension(2:params%Max_l), intent(inout) :: cl_tt,cl_te,cl_ee,cl_bb
        real(dl), parameter :: cons =  (COBE_CMBTemp*1e6)**2
        integer i

        !cl_tt(1) = 0
        !cl_te(1) = 0
        !cl_ee(1) = 0
        !cl_bb(1) = 0

        do i = 2, params%Max_l
            cl_tt(i) = cons*Cl_lensed(i,CL_TT_INDEX,1)
            cl_te(i) = cons*Cl_lensed(i,CL_TE_INDEX,1)
            cl_ee(i) = cons*Cl_lensed(i,CL_EE_INDEX,1)
            cl_bb(i) = cons*Cl_lensed(i,CL_BB_INDEX,1)
        end do
        !close(fileio_unit)

    end subroutine


    !Sets the given cosmological parameters to the Camb parameters
    subroutine convertParameters(params, values)
        Type(CAMBparams), intent(inout) ::  params
        real(dl), dimension(6), intent(in) :: values

        !write(*,*) "converting params", values
        params%h0     = values(1) !hubble
        params%omegab = values(2)/(params%H0/100)**2 !ombh2
        params%omegac = values(3)/(params%H0/100)**2 !omch2

        !P%omegav = 1- Ini_Read_Double('omk') - P%omegab-P%omegac - P%omegan
        params%omegav = 1- 0 - params%omegab - params%omegac - params%omegan


        params%InitPower%ScalarPowerAmp(1) = values(4) !scalar_amp(1)
        params%InitPower%an(1) = values(5) !scalar_spectral_index(1)

        params%Reion%optical_depth = values(6) !re_optical_depth

    end subroutine



    !Reads in the params file at the given file path and sets up the given params.
    !Finally init the wmap module
    subroutine setup(params, inputFile, installPath)
        character(LEN=input_file_len) inputFile
        character(LEN=input_file_len) installPath
        Type(CAMBparams) params
        integer i
        logical bad
        character(LEN=Ini_max_string_len) numstr
        character(LEN=Ini_max_string_len) TransferFileNames(max_transfer_redshifts), &
        MatterPowerFileNames(max_transfer_redshifts), outroot
        real(dl) output_factor, Age, nmassive

        if (inputFile == '') stop 'No parameter input file'

        write(*,*) "Using param file:", trim(inputFile)
        
        if (installPath == '') stop 'No installPath provided'

        write(*,*) "Using install path: ", trim(installPath)
        
        !set the absolute path to cambWrapper in ModelParams
        highL_unlensed_cl_template = trim(installPath) // trim(highL_unlensed_cl_template)
        
        call Ini_Open(inputFile, 1, bad, .false.)
        if (bad) stop 'Error opening parameter file'

        Ini_fail_on_not_found = .false.

        outroot = Ini_Read_String('output_root')
        if (outroot /= '') outroot = trim(outroot) // '_'

        call CAMB_SetDefParams(params)

        params%WantScalars = Ini_Read_Logical('get_scalar_cls')
        params%WantVectors = Ini_Read_Logical('get_vector_cls',.false.)
        params%WantTensors = Ini_Read_Logical('get_tensor_cls',.false.)

        params%OutputNormalization=outNone
        !if (Ini_Read_Logical('COBE_normalize',.false.))  params%OutputNormalization=outCOBE
        output_factor = Ini_Read_Double('CMB_outputscale',1._dl)

        params%WantCls= params%WantScalars .or. params%WantTensors .or. params%WantVectors

        params%WantTransfer=Ini_Read_Logical('get_transfer')

        params%NonLinear = Ini_Read_Int('do_nonlinear',NonLinear_none)

        params%DoLensing = .false.
        if (params%WantCls) then
            if (params%WantScalars  .or. params%WantVectors) then
                params%Max_l = Ini_Read_Int('l_max_scalar')
                params%Max_eta_k = Ini_Read_Double('k_eta_max_scalar',params%Max_l*2._dl)
                if (params%WantScalars) then
                    params%DoLensing = Ini_Read_Logical('do_lensing',.false.)
                    if (params%DoLensing) lensing_method = Ini_Read_Int('lensing_method',1)
                end if
                if (params%WantVectors) then
                    if (params%WantScalars .or. params%WantTensors) stop 'Must generate vector modes on their own'
                    i = Ini_Read_Int('vector_mode')
                    if (i==0) then
                        vec_sig0 = 1
                        Magnetic = 0
                    else if (i==1) then
                        Magnetic = -1
                        vec_sig0 = 0
                    else
                        stop 'vector_mode must be 0 (regular) or 1 (magnetic)'
                    end if
                end if
            end if

            if (params%WantTensors) then
                params%Max_l_tensor = Ini_Read_Int('l_max_tensor')
                params%Max_eta_k_tensor =  Ini_Read_Double('k_eta_max_tensor',Max(500._dl,params%Max_l_tensor*2._dl))
            end if
        endif


        !  Read initial parameters.

        w_lam = Ini_Read_Double('w', -1._dl)
        cs2_lam = Ini_Read_Double('cs2_lam',1._dl)

        params%h0     = Ini_Read_Double('hubble')

        if (Ini_Read_Logical('use_physical',.false.)) then

            params%omegab = Ini_Read_Double('ombh2')/(params%H0/100)**2
            params%omegac = Ini_Read_Double('omch2')/(params%H0/100)**2
            params%omegan = Ini_Read_Double('omnuh2')/(params%H0/100)**2
            params%omegav = 1- Ini_Read_Double('omk') - params%omegab-params%omegac - params%omegan

        else

            params%omegab = Ini_Read_Double('omega_baryon')
            params%omegac = Ini_Read_Double('omega_cdm')
            params%omegav = Ini_Read_Double('omega_lambda')
            params%omegan = Ini_Read_Double('omega_neutrino')

        end if

        params%tcmb   = Ini_Read_Double('temp_cmb',COBE_CMBTemp)
        params%yhe    = Ini_Read_Double('helium_fraction',0.24_dl)
        params%Num_Nu_massless  = Ini_Read_Double('massless_neutrinos')
        nmassive = Ini_Read_Double('massive_neutrinos')
        !Store fractional numbers in the massless total
        params%Num_Nu_massive   = int(nmassive+1e-6)
        params%Num_Nu_massless  = params%Num_Nu_massless + nmassive-params%Num_Nu_massive

        params%nu_mass_splittings = .true.
        params%Nu_mass_eigenstates = Ini_Read_Int('nu_mass_eigenstates',1)
        if (params%Nu_mass_eigenstates > max_nu) stop 'too many mass eigenstates'
        numstr = Ini_Read_String('nu_mass_degeneracies')
        if (numstr=='') then
            params%Nu_mass_degeneracies(1)= params%Num_nu_massive
        else
            read(numstr,*) params%Nu_mass_degeneracies(1:params%Nu_mass_eigenstates)
        end if
        numstr = Ini_read_String('nu_mass_fractions')
        if (numstr=='') then
            params%Nu_mass_fractions(1)=1
            if (params%Nu_mass_eigenstates >1) stop 'must give nu_mass_fractions for the eigenstates'
        else
            read(numstr,*) params%Nu_mass_fractions(1:params%Nu_mass_eigenstates)
        end if

        if (params%NonLinear==NonLinear_lens .and. params%DoLensing) then
            if (params%WantTransfer) &
            write (*,*) 'overriding transfer settings to get non-linear lensing'
            params%WantTransfer  = .true.
            call Transfer_SetForNonlinearLensing(params%Transfer)
            params%Transfer%high_precision=  Ini_Read_Logical('transfer_high_precision',.false.)

        else if (params%WantTransfer)  then
            params%Transfer%high_precision=  Ini_Read_Logical('transfer_high_precision',.false.)
            params%transfer%kmax          =  Ini_Read_Double('transfer_kmax')
            params%transfer%k_per_logint  =  Ini_Read_Int('transfer_k_per_logint')
            params%transfer%num_redshifts =  Ini_Read_Int('transfer_num_redshifts')

            transfer_interp_matterpower = Ini_Read_Logical('transfer_interp_matterpower ', transfer_interp_matterpower)
            transfer_power_var = Ini_read_int('transfer_power_var',transfer_power_var)
            if (params%transfer%num_redshifts > max_transfer_redshifts) stop 'Too many redshifts'
            do i=1, params%transfer%num_redshifts
                params%transfer%redshifts(i)  = Ini_Read_Double_Array('transfer_redshift',i,0._dl)
                transferFileNames(i)     = Ini_Read_String_Array('transfer_filename',i)
                MatterPowerFilenames(i)  = Ini_Read_String_Array('transfer_matterpower',i)

                if (TransferFileNames(i) == '') then
                    TransferFileNames(i) =  trim(numcat('transfer_',i))//'.dat'
                end if
                if (MatterPowerFilenames(i) == '') then
                    MatterPowerFilenames(i) =  trim(numcat('matterpower_',i))//'.dat'
                end if
                if (TransferFileNames(i)/= '') &
                TransferFileNames(i) = trim(outroot)//TransferFileNames(i)
                if (MatterPowerFilenames(i) /= '') &
                MatterPowerFilenames(i)=trim(outroot)//MatterPowerFilenames(i)
            end do


            params%transfer%kmax=params%transfer%kmax*(params%h0/100._dl)

        else
            params%transfer%high_precision = .false.
        endif

        Ini_fail_on_not_found = .false.

        call Reionization_ReadParams(params%Reion, DefIni)
        call InitialPower_ReadParams(params%InitPower, DefIni, params%WantTensors)
        call Recombination_ReadParams(params%Recomb, DefIni)
        if (Ini_HasKey('recombination')) then
            i = Ini_Read_Int('recombination',1)
            if (i/=1) stop 'recombination option deprecated'
        end if

        call Bispectrum_ReadParams(BispectrumParams, DefIni, outroot)

        if (params%WantScalars .or. params%WantTransfer) then
            params%Scalar_initial_condition = Ini_Read_Int('initial_condition',initial_adiabatic)
            if (params%Scalar_initial_condition == initial_vector) then
                params%InitialConditionVector=0
                numstr = Ini_Read_String('initial_vector',.true.)
                read (numstr,*) params%InitialConditionVector(1:initial_iso_neutrino_vel)
            end if

        end if

!        if (params%WantScalars) then
!            ScalarFileName = trim(outroot)//Ini_Read_String('scalar_output_file')
!            LensedFileName =  trim(outroot) //Ini_Read_String('lensed_output_file')
!            LensPotentialFileName =  Ini_Read_String('lens_potential_output_file')
!            if (LensPotentialFileName/='') LensPotentialFileName = concat(outroot,LensPotentialFileName)
!        end if
!        if (params%WantTensors) then
!            TensorFileName =  trim(outroot) //Ini_Read_String('tensor_output_file')
!            if (params%WantScalars)  then
!                TotalFileName =  trim(outroot) //Ini_Read_String('total_output_file')
!                LensedTotFileName = Ini_Read_String('lensed_total_output_file')
!                if (LensedTotFileName/='') LensedTotFileName= trim(outroot) //trim(LensedTotFileName)
!            end if
!        end if
!        if (params%WantVectors) then
!            VectorFileName =  trim(outroot) //Ini_Read_String('vector_output_file')
!        end if


        Ini_fail_on_not_found = .false.

        !optional parameters controlling the computation

        params%AccuratePolarization = Ini_Read_Logical('accurate_polarization',.true.)
        params%AccurateReionization = Ini_Read_Logical('accurate_reionization',.false.)
        params%AccurateBB = Ini_Read_Logical('accurate_BB',.false.)

        !Mess here to fix typo with backwards compatibility
        if (Ini_HasKey('do_late_rad_trunction')) then
            DoLateRadTruncation = Ini_Read_Logical('do_late_rad_trunction',.true.)
            if (Ini_HasKey('do_late_rad_truncation')) stop 'check do_late_rad_xxxx'
        else
            DoLateRadTruncation = Ini_Read_Logical('do_late_rad_truncation',.true.)
        end if
        DoTensorNeutrinos = Ini_Read_Logical('do_tensor_neutrinos',DoTensorNeutrinos )
        FeedbackLevel = Ini_Read_Int('feedback_level',FeedbackLevel)

        params%MassiveNuMethod  = Ini_Read_Int('massive_nu_approx',Nu_best)

        ThreadNum      = Ini_Read_Int('number_of_threads',ThreadNum)
        AccuracyBoost  = Ini_Read_Double('accuracy_boost',AccuracyBoost)
        lAccuracyBoost = Ini_Read_Real('l_accuracy_boost',lAccuracyBoost)
        HighAccuracyDefault = Ini_Read_Logical('high_accuracy_default',HighAccuracyDefault)

        if (HighAccuracyDefault) then
            params%Max_eta_k=max(min(params%max_l,3000)*2.5_dl,params%Max_eta_k)
        end if
        DoTensorNeutrinos = DoTensorNeutrinos .or. HighAccuracyDefault
        if (do_bispectrum) then
            lSampleBoost   = 50
        else
            lSampleBoost   = Ini_Read_Double('l_sample_boost',lSampleBoost)
        end if
!        if (outroot /= '') then
!            call Ini_SaveReadValues(trim(outroot) //'params.ini',1)
!        end if

        call Ini_Close


        if (.not. CAMB_ValidateParams(params)) stop 'Stopped due to parameter error'

        write (*,*) "calling camb for init"
        call CAMB_GetResults(params)
        write (*,*) "camb done."

		!Using same parameter config like in CosmoMC
        params%Num_Nu_Massive = 3
        params%Num_Nu_Massless = 0.046
        params%InitPower%nn = 1
        params%AccuratePolarization = 4/=1
        params%Reion%use_optical_depth = .false.
        params%Reion%fraction = -1

        params%OnlyTransfers = .true.
        params%nu_mass_splittings = .false.

        params%Nu_mass_degeneracies(1) = -3.415682162516931E-002
        params%Nu_mass_degeneracies(2) = 0
        params%Nu_mass_degeneracies(3) = -3.415680029429802E-002
        params%Nu_mass_degeneracies(4) = 0
        params%Nu_mass_degeneracies(5) = 0
        params%Nu_mass_fractions(1) = 0
        params%Nu_mass_fractions(2) = 0
        params%Nu_mass_fractions(3) = 0
        params%Nu_mass_fractions(4) = 0
        params%Nu_mass_fractions(5) = 0

        !params%InitPower%an(1) = 1
        !params%InitPower%ScalarPowerAmp(1) = 1

        params%Transfer%kmax = 0.8

        params%InitialConditionVector(initial_adiabatic) = -1

        params%flat = .false.

        params%ReionHist%tau_start = 0
        params%ReionHist%tau_complete = 0
        params%ReionHist%akthom = 0
        params%ReionHist%fHe = 0
        params%ReionHist%WindowVarMid = 0
        params%ReionHist%WindowVarDelta = 0

        params%r = 1
        params%tau0 = 0
        params%chi0 = 0


    end subroutine

end module
