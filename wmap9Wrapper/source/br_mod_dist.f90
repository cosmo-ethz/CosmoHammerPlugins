Module br_mod_dist
    Implicit None

    ! *********************************************************************
    ! *      br_mod -- An F90 module for computing the Blackwell-Rao      *
    ! *                estimator given signal samples from the posterior  *
    ! *                                                                   *
    ! *                 Written by Hans Kristian Eriksen                  *
    ! *                                                                   *
    ! *                Copyright 2006, all rights reserved                *
    ! *                                                                   *
    ! *                                                                   *
    ! *   NB! The code is provided as is, and *no* guarantees are given   *
    ! *       as far as either accuracy or correctness goes.              *
    ! *                                                                   *
    ! *  If used for published results, please cite these papers:         *
    ! *                                                                   *
    ! *      - Eriksen et al. 2006, ApJ, submitted, astro-ph/0606088      *
    ! *      - Chu et al. 2005, Phys. Rev. D, 71, 103002                  *
    ! *                                                                   *
    ! *********************************************************************
    ! E. Komatsu, March 5, 2009
    ! -- Changed the orders of do-loops for a better performance
    !    [thanks to Raphael Flauger]

    Integer, Parameter, Private :: i4b = Selected_int_kind(8)
    Integer, Parameter, Private :: sp = Selected_real_kind(5, 30)
    Integer, Parameter, Private :: dp = Selected_real_kind(12, 200)
    Integer, Parameter, Private :: lgt = Kind(.True.)

    Integer(i4b), Private :: lmin, lmax, numsamples, numchain
    Logical(lgt), Private :: first_eval
    Real(dp), Private :: offset
    Real(dp), Allocatable, Dimension(:, :, :), Private :: sigmas
    !---DH13: declare arrays used in subroutine compute_br_estimator.
    real(dp), private     :: subtotal
    real(dp), allocatable, dimension(:,:),private ::  sigmasum
    real(dp), allocatable, dimension(:) :: prefactor_ell
    !---DH13


Contains

    ! Initialization routines
    Subroutine initialize_br_mod(lmin_in, sigmas_in)
        Implicit None

        Integer(i4b), Intent(In) :: lmin_in
        Real(sp), Dimension(lmin_in:, 1:, 1:), Intent(In) :: sigmas_in

        Integer(i4b) :: i, j, ell

        lmin = lmin_in
        lmax = Size(sigmas_in(:, 1, 1)) + lmin - 1
        numchain = Size(sigmas_in(lmin, :, 1))
        numsamples = Size(sigmas_in(lmin, 1, :))
        first_eval = .True.

        Allocate(sigmas(lmin:lmax, numchain, numsamples))
        !---DH13: allocate arrays used in subroutine compute_br_estimator.
        allocate(sigmasum(numchain,numsamples))
        allocate(prefactor_ell(lmin:lmax))
        !---DH13
	
        sigmas = Real(sigmas_in, dp)
        ! --- original
        !    do ell = lmin, lmax
        !       do i = 1, numchain
        !          do j = 1, numsamples
        ! ---
        Do j = 1, numsamples
            Do i = 1, numchain
                Do ell = lmin, lmax
                    If (sigmas(ell, i, j) .Le. 0.0) Then
                        Print *, "Error: sigma value <= zero."
                        Print *, "sigma value is ", sigmas(ell, i, j)
                        Print *, "at(ell,chain,sample) = ", ell, i, j
                        Stop
                    End If
                End Do
            End Do
        End Do

        !---DH13: precompute arrays used in subroutine compute_br_estimator.
        do ell=lmin,lmax
            prefactor_ell(ell)=0.5d0*real(2*ell+1,dp)
        end do

	      do j=1,numsamples
	        do i=1,numchain
              sigmasum(i,j)=0.d0
              do ell=lmin,lmax
                  sigmasum(i,j)=sigmasum(i,j)+&
	                  &(0.5d0*real(2*ell+1,dp)-1.d0)*dlog(sigmas(ell,i,j))
              end do
	        end do
        end do
        !---DH13

    End Subroutine initialize_br_mod


    Subroutine clean_up_br_mod
        Implicit None

        If (Allocated(sigmas)) Deallocate(sigmas)
        !---DH13: deallocate arrays used in subroutine compute_br_estimator.
        if (allocated(sigmasum)) deallocate(sigmasum)
        if (allocated(prefactor_ell)) deallocate(prefactor_ell)
        !---DH13

    End Subroutine clean_up_br_mod



    ! Base computation routine
    Subroutine compute_br_estimator(cls, lnL)
        Implicit None

        Real(dp), Dimension(lmin:), Intent(In) :: cls
        Real(dp), Intent(Out) :: lnL

        Integer(i4b) :: i, j, l
        !---DH13: original
        !Real(dp) :: subtotal, x
        !---DH13
        
        !---DH13: declare new variables and arrays used in subroutine compute_br_estimator.
        real(dp), dimension(lmin:lmax) :: logcls,prefactor_cls
        real(dp) sum_logcls
        !---DH13


        If (first_eval) Then
            Call compute_largest_term(cls)
            first_eval = .False.
        End If

        ! Compute the Blackwell-Rao estimator
        lnL = 0.d0

        ! --- original
        !    do i = 1, numchain
        !       do j = 1, numsamples
        ! --- RF

        !---DH13: precompute arrays used in subroutine compute_br_estimator.
        sum_logcls=-offset
        do l = lmin, lmax
            logcls(l)=log(cls(l))
            prefactor_cls(l)=prefactor_ell(l)/cls(l)
            sum_logcls=sum_logcls-prefactor_ell(l)*logcls(l)
        end do
        !---DH13        

        !---DH13: original loop.
        !        Do j = 1, numsamples
        !            Do i = 1, numchain
        !                ! ---
        !                subtotal = 0.d0
        !                Do l = lmin, lmax
        !                    x = sigmas(l, i, j) / cls(l)
        !                    subtotal = subtotal + &
        !                        & 0.5d0 * Real(2*l+1, dp) * (-x+Log(x)) - Log(Real(sigmas(l, i, j), dp))
        !                End Do
        !
        !                lnL = lnL + Exp(subtotal-offset)
        !
        !            End Do
        !        End Do
        !---DH13

        !---DH13: OMP parallel reduction loop with precomputes 
        !$OMP PARALLEL DO DEFAULT(SHARED),PRIVATE(subtotal),SCHEDULE(GUIDED),REDUCTION(+:lnL)
            do j = 1, numsamples
               do i = 1, numchain
                  subtotal = sigmasum(i,j)+sum_logcls
                  do l = lmin, lmax
                        subtotal=subtotal-&
                        	&prefactor_cls(l)*sigmas(l,i,j)
                  end do
                lnL = lnL + exp(subtotal)
               end do
            end do
        !$OMP END PARALLEL DO
        !---DH13
        
        If (lnL > 1e-20) Then
            lnL = Log(lnL)
        Else
            lnL = Log(1e-30)
        End If

        ! print *, lnL

    End Subroutine compute_br_estimator



    ! Routine for reading the Gibbs sigma samples
    Subroutine read_gibbs_chain(filename, unit, lmax, numchains, numsamples, Data)
        Implicit None

        Character(Len=*), Intent(In) :: filename
        Integer(i4b), Intent(In) :: unit
        Integer(i4b), Intent(Out) :: lmax, numchains, numsamples
        Real(sp), Pointer, Dimension(:, :, :) :: Data

        Integer(i4b) :: l, status, blocksize, readwrite, numspec, i, j, k
        Integer(i4b) :: fpixel, group, numargs
        Logical(lgt) :: anyf
        Real(sp) :: nullval
        Character(Len=80) :: comment

        Integer(i4b), Dimension(4) :: naxes
        Real(sp), Pointer, Dimension(:, :, :, :) :: indata

        status = 0
        readwrite = 0
        nullval = 0.

        ! numargs = 1
        numargs = 0

        ! Open the result file
        Call ftopen(unit, Trim(filename), readwrite, blocksize, status)

        ! Read keywords
        Call ftgkyj(unit, 'LMAX', lmax, comment, status)
        Call ftgkyj(unit, 'NUMSAMP', numsamples, comment, status)
        Call ftgkyj(unit, 'NUMCHAIN', numchains, comment, status)
        Call ftgkyj(unit, 'NUMSPEC', numspec, comment, status)

        Allocate(Data(0:lmax, numchains, numsamples))
        Nullify(indata)
        Allocate(indata(0:lmax, 1:1, 1:numchains, 1:numargs+numsamples))

!!$    print *, "Allocated arrays"

        ! Read the binned power spectrum array
        group = 1
        fpixel = 1
        Call ftgpve(unit, group, fpixel, Size(indata), nullval, indata, anyf, status)

!!$    print *, "Read data"

        Call ftclos(unit, status)

!!$    print *, "Closed file"

        ! --- original
        !    do i = 0, lmax
        !       do j = 1, numchains
        !          do k = numargs+1, numargs+numsamples
        ! --- RF
        Do k = numargs + 1, numargs + numsamples
            Do j = 1, numchains
                Do i = 0, lmax
                    ! ---
                    Data(i, j, k) = indata(i, 1, j, k)
                    ! data(:,:,:) = indata(0:lmax,1:1,1:numchains,numargs+1:numargs+numsamples)
                End Do
            End Do
        End Do

!!$    print *, "Deallocating data"

        Deallocate(indata)

!!$    print *, "Leaving subroutine"

    End Subroutine read_gibbs_chain



    ! Utility routine for initializing the offset to be subtracted from each term
    ! to avoid overflow errors. Only called with the first power spectrum
    Subroutine compute_largest_term(cls)
        Implicit None

        Real(dp), Dimension(lmin:), Intent(In) :: cls

        Integer(i4b) :: i, j, l
        Real(dp) :: subtotal, x

        ! Compute the Blackwell-Rao estimator
        offset = - 1.6375e30

        ! --- original
        !    do i = 1, numchain
        !       do j = 1, numsamples
        ! --- RF

        Do j = 1, numsamples
            Do i = 1, numchain
                ! ---
                subtotal = 0.d0
                Do l = lmin, lmax
                    x = sigmas(l, i, j) / cls(l)
                    subtotal = subtotal + &
                        & 0.5d0 * Real(2*l+1, dp) * (-x+Log(x)) - Log(Real(sigmas(l, i, j), dp))
                End Do

                offset = Max(offset, subtotal)

            End Do
        End Do

        If (offset <-1.637e30) Then
            Print *, "Error: offset in br_mod_dist not being computed properly"
            Print *, "lmin = ", lmin
            Print *, "lmax = ", lmax
            Print *, "numchain = ", numchain
            Print *, "numsamples = ", numsamples
            Print *, "offset = ", offset
            Print *, "cls = ", cls(lmin:lmax)
            Print *, "sigmas(lmin:lmax, 10, 10) = ", sigmas(lmin:lmax, 10, 10)
            Stop
        End If

    End Subroutine compute_largest_term


End Module br_mod_dist
