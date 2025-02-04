!*****Revision Informations Automatically Generated by VisualSVN*****!
!---------------------------------------------------------------------
!> $ID:$
!> $Revision: 869 $
!> $Author: dsu $
!> $Date: 2023-08-18 09:44:21 -0700 (Fri, 18 Aug 2023) $
!> $URL: https://min3psvn.ubc.ca/svn/min3p_thcm/branches/dsu_new_add_2024Jan/src/solver/solver_linear.F90 $
!---------------------------------------------------------------------
!********************************************************************!

!>
!> module solver_linear
!>
!> This module includes functions for pseudo inversion or generalized
!> inverse of a matrix.
!>
!> written by:      Danyang Su
!>
!> last modified:   Danyang Su - Nov. 24, 2017
!>

module solver_linear

  implicit none

  contains

  !>
  !> test of pseudo inverse, or generalized inverse of a matrix
  !>
  subroutine solver_linear_ginv_test
    !********  example 1 ************!
    !A(3x3) =
    ! 1     0     2!
    !-1     5     0!
    ! 0     3    -9!
    !inv(A) =
    !0.8824   -0.1176    0.1961!
    !0.1765    0.1765    0.0392!
    !0.0588    0.0588   -0.0980!

    !********  example 2 ************!
    !A(3x2)
    !2     1!
    !5     2!
    !2     1!
    !pinv(A) =
    !-1.0000       1.0000     -1.0000!
    ! 2.5000      -2.0000      2.5000!

    !********  example 3 ************!
    !
    !A(8x6) =
    !0.7094    0.9597    0.8909    0.8143    0.3517    0.3804!
    !0.7547    0.3404    0.9593    0.2435    0.8308    0.5678!
    !0.2760    0.5853    0.5472    0.9293    0.5853    0.0759!
    !0.6797    0.2238    0.1386    0.3500    0.5497    0.0540!
    !0.6551    0.7513    0.1493    0.1966    0.9172    0.5308!
    !0.1626    0.2551    0.2575    0.2511    0.2858    0.7792!
    !0.1190    0.5060    0.8407    0.6160    0.7572    0.9340!
    !0.4984    0.6991    0.2543    0.4733    0.7537    0.1299!
    !
    !pinv(A)=
    ! 0.4949    0.2223   -0.3707    1.2584   -0.0952    0.6267   -0.7872   -0.4369!
    ! 0.8052   -0.4100   -0.3839   -1.3647    0.8406   -0.5344   -0.0896    0.6394!
    ! 0.3086    0.9746   -0.0689   -0.8068   -0.4031   -0.8388    0.2680   -0.0368!
    !-0.0843   -0.7176    0.9242    1.1828   -0.6763    0.8122    0.0776   -0.3129!
    !-1.0973    0.3675    0.4143   -0.0844    0.3314   -0.6292    0.4545    0.5522!
    ! 0.0710   -0.3303   -0.3785    0.3494    0.1156    1.2128    0.2414   -0.4732!
    implicit none

    integer :: i, nr, nc

    !example 1
    !real*8 :: a(3,3), u(3,3), aflag(3), atemp(3)
    !nr = 3
    !nc = 3
    !a = reshape((/1,-1,0,0,5,3,2,0,-9/),(/3,3/))

    !example 2
    !real*8 :: a(3,2), u(2,2), aflag(2), atemp(2)
    !nr = 3
    !nc = 2
    !a = reshape((/2,5,2,1,2,1/),(/3,2/))

    !example 3
    !real*8 :: a(8,6), utemp(6,6), aflag(6), atemp(6)
    !nr = 8
    !nc = 6
    !a = reshape((/0.7094,0.7547,0.2760,0.6797,0.6551,0.1626,0.1190,0.4984,         &
    !            & 0.9597,0.3404,0.5853,0.2238,0.7513,0.2551,0.5060,0.6991,         &
    !            & 0.8909,0.9593,0.5472,0.1386,0.1493,0.2575,0.8407,0.2543,         &
    !            & 0.8143,0.2435,0.9293,0.3500,0.1966,0.2511,0.6160,0.4733,         &
    !            & 0.3517,0.8308,0.5853,0.5497,0.9172,0.2858,0.7572,0.7537,         &
    !            & 0.3804,0.5678,0.0759,0.0540,0.5308,0.7792,0.9340,0.1299/),(/8,6/))

    !call solver_linear_ginv(nr,nc,a,aflag,atemp,utemp)
    !write(*,*) "pseudo inverse of a is"
    !do i = 1, nc
    !  write(*,*) a(:,i)
    !end do

    !example 4
    real*8 :: a(23,23), utemp(23,23), aflag(23), atemp(23)
    integer, dimension (1:2) :: order2 = (/ 2, 1 /)
    nr = 23
    nc = 23
    a = reshape((/1.305467E-07, 0.000000E+00, 0.000000E+00, 0.000000E+00, 0.000000E+00, &
                  0.000000E+00, 0.000000E+00, 0.000000E+00, 0.000000E+00, 0.000000E+00, &
                  0.000000E+00, 0.000000E+00, 0.000000E+00, 0.000000E+00, 1.016547E-13, &
                  0.000000E+00, 0.000000E+00, 0.000000E+00, 0.000000E+00, 0.000000E+00, &
                  2.694736E-09, 0.000000E+00, 0.000000E+00, 0.000000E+00, 2.050322E-09, &
                  0.000000E+00, 0.000000E+00, 0.000000E+00, 0.000000E+00, 0.000000E+00, &
                  0.000000E+00, 0.000000E+00, 0.000000E+00, 0.000000E+00, 0.000000E+00, &
                  0.000000E+00, 0.000000E+00, 0.000000E+00, 0.000000E+00, 0.000000E+00, &
                  0.000000E+00, 0.000000E+00, 0.000000E+00, 1.379541E-12, 0.000000E+00, &
                  0.000000E+00, 0.000000E+00, 0.000000E+00, 8.934084E-09, 0.000000E+00, &
                  0.000000E+00, 0.000000E+00, 0.000000E+00, 0.000000E+00, 1.657779E-15, &
                  4.270067E-17, 1.629010E-17, 4.779319E-16, 0.000000E+00, 0.000000E+00, &
                  0.000000E+00, 0.000000E+00, 0.000000E+00, 0.000000E+00, 0.000000E+00, &
                  1.132761E-23, 0.000000E+00, 0.000000E+00, 0.000000E+00, 0.000000E+00, &
                  0.000000E+00, 0.000000E+00, 2.279732E-09, 0.000000E+00, 0.000000E+00, &
                  0.000000E+00, 0.000000E+00, 0.000000E+00, 0.000000E+00, 0.000000E+00, &
                  0.000000E+00, 0.000000E+00, 0.000000E+00, 0.000000E+00, 0.000000E+00, &
                  0.000000E+00, 0.000000E+00, 0.000000E+00, 0.000000E+00, 0.000000E+00, &
                  0.000000E+00, 0.000000E+00, 0.000000E+00, 0.000000E+00, 0.000000E+00, &
                  0.000000E+00, 5.985118E-08, 0.000000E+00, 0.000000E+00, 0.000000E+00, &
                  0.000000E+00, 0.000000E+00, 0.000000E+00, 0.000000E+00, 0.000000E+00, &
                  0.000000E+00, 0.000000E+00, 0.000000E+00, 0.000000E+00, 0.000000E+00, &
                  0.000000E+00, 0.000000E+00, 2.602621E-11, 0.000000E+00, 0.000000E+00, &
                  0.000000E+00, 0.000000E+00, 0.000000E+00, 0.000000E+00, 0.000000E+00, &
                  1.000000E+00, 0.000000E+00, 0.000000E+00, 0.000000E+00, 0.000000E+00, &
                  0.000000E+00, 0.000000E+00, 0.000000E+00, 0.000000E+00, 0.000000E+00, &
                  0.000000E+00, 0.000000E+00, 0.000000E+00, 0.000000E+00, 0.000000E+00, &
                  0.000000E+00, 0.000000E+00, 0.000000E+00, 0.000000E+00, 0.000000E+00, &
                  0.000000E+00, 0.000000E+00, 0.000000E+00, 0.000000E+00, 1.000000E+00, &
                  0.000000E+00, 0.000000E+00, 0.000000E+00, 0.000000E+00, 0.000000E+00, &
                  0.000000E+00, 0.000000E+00, 0.000000E+00, 0.000000E+00, 0.000000E+00, &
                  0.000000E+00, 0.000000E+00, 0.000000E+00, 0.000000E+00, 0.000000E+00, &
                  0.000000E+00, 0.000000E+00, 0.000000E+00, 0.000000E+00, 0.000000E+00, &
                  0.000000E+00, 0.000000E+00, 0.000000E+00, 1.000000E+00, 0.000000E+00, &
                  0.000000E+00, 0.000000E+00, 0.000000E+00, 0.000000E+00, 0.000000E+00, &
                  0.000000E+00, 0.000000E+00, 0.000000E+00, 0.000000E+00, 0.000000E+00, &
                  0.000000E+00, 0.000000E+00, 0.000000E+00, 0.000000E+00, 0.000000E+00, &
                  0.000000E+00, 1.657779E-15, 0.000000E+00, 0.000000E+00, 0.000000E+00, &
                  0.000000E+00, 0.000000E+00, 1.295398E-10, 0.000000E+00, 0.000000E+00, &
                  0.000000E+00, 0.000000E+00, 0.000000E+00, 0.000000E+00, 0.000000E+00, &
                  0.000000E+00, 0.000000E+00, 0.000000E+00, 0.000000E+00, 3.081994E-12, &
                  0.000000E+00, 0.000000E+00, 0.000000E+00, 0.000000E+00, 4.270067E-17, &
                  0.000000E+00, 0.000000E+00, 0.000000E+00, 0.000000E+00, 0.000000E+00, &
                  0.000000E+00, 2.624666E-13, 0.000000E+00, 0.000000E+00, 0.000000E+00, &
                  0.000000E+00, 0.000000E+00, 0.000000E+00, 0.000000E+00, 0.000000E+00, &
                  0.000000E+00, 0.000000E+00, 1.229113E-14, 0.000000E+00, 0.000000E+00, &
                  0.000000E+00, 0.000000E+00, 1.629010E-17, 0.000000E+00, 0.000000E+00, &
                  0.000000E+00, 0.000000E+00, 0.000000E+00, 0.000000E+00, 0.000000E+00, &
                  3.441291E-12, 0.000000E+00, 0.000000E+00, 0.000000E+00, 0.000000E+00, &
                  0.000000E+00, 0.000000E+00, 0.000000E+00, 0.000000E+00, 0.000000E+00, &
                  3.501083E-14, 0.000000E+00, 0.000000E+00, 0.000000E+00, 0.000000E+00, &
                  4.779319E-16, 0.000000E+00, 0.000000E+00, 0.000000E+00, 0.000000E+00, &
                  0.000000E+00, 0.000000E+00, 0.000000E+00, 0.000000E+00, 5.738976E-13, &
                  0.000000E+00, 0.000000E+00, 0.000000E+00, 0.000000E+00, 0.000000E+00, &
                  0.000000E+00, 0.000000E+00, 0.000000E+00, 1.734065E-14, 0.000000E+00, &
                  0.000000E+00, 0.000000E+00, 0.000000E+00, 0.000000E+00, 0.000000E+00, &
                  0.000000E+00, 0.000000E+00, 0.000000E+00, 0.000000E+00, 0.000000E+00, &
                  0.000000E+00, 0.000000E+00, 0.000000E+00, 5.860990E-09, 0.000000E+00, &
                  0.000000E+00, 0.000000E+00, 0.000000E+00, 0.000000E+00, 0.000000E+00, &
                  0.000000E+00, 0.000000E+00, 0.000000E+00, 0.000000E+00, 0.000000E+00, &
                  0.000000E+00, 0.000000E+00, 0.000000E+00, 0.000000E+00, 0.000000E+00, &
                  0.000000E+00, 0.000000E+00, 0.000000E+00, 0.000000E+00, 0.000000E+00, &
                  0.000000E+00, 0.000000E+00, 2.41743E-144, 0.000000E+00, 0.000000E+00, &
                  0.000000E+00, 0.000000E+00, 0.000000E+00, 0.000000E+00, 0.000000E+00, &
                  0.000000E+00, 0.000000E+00, 1.016547E-13, 0.000000E+00, 0.000000E+00, &
                  0.000000E+00, 0.000000E+00, 0.000000E+00, 0.000000E+00, 0.000000E+00, &
                  0.000000E+00, 0.000000E+00, 0.000000E+00, 0.000000E+00, 0.000000E+00, &
                  0.000000E+00, 2.100857E-12, 0.000000E+00, 0.000000E+00, 0.000000E+00, &
                  0.000000E+00, 0.000000E+00, 0.000000E+00, 0.000000E+00, 0.000000E+00, &
                  0.000000E+00, 0.000000E+00, 0.000000E+00, 0.000000E+00, 0.000000E+00, &
                  0.000000E+00, 0.000000E+00, 0.000000E+00, 0.000000E+00, 0.000000E+00, &
                  0.000000E+00, 0.000000E+00, 0.000000E+00, 0.000000E+00, 0.000000E+00, &
                  1.579384E-08, 0.000000E+00, 0.000000E+00, 0.000000E+00, 0.000000E+00, &
                  2.695271E-10, 0.000000E+00, 0.000000E+00, 0.000000E+00, 0.000000E+00, &
                  0.000000E+00, 0.000000E+00, 0.000000E+00, 0.000000E+00, 0.000000E+00, &
                  0.000000E+00, 0.000000E+00, 0.000000E+00, 0.000000E+00, 0.000000E+00, &
                  0.000000E+00, 0.000000E+00, 0.000000E+00, 0.000000E+00, 4.581117E-09, &
                  0.000000E+00, 0.000000E+00, 0.000000E+00, 2.466929E-12, 0.000000E+00, &
                  0.000000E+00, 0.000000E+00, 0.000000E+00, 0.000000E+00, 0.000000E+00, &
                  0.000000E+00, 0.000000E+00, 0.000000E+00, 0.000000E+00, 0.000000E+00, &
                  0.000000E+00, 0.000000E+00, 0.000000E+00, 0.000000E+00, 0.000000E+00, &
                  0.000000E+00, 0.000000E+00, 0.000000E+00, 2.438798E-08, 0.000000E+00, &
                  0.000000E+00, 0.000000E+00, 0.000000E+00, 0.000000E+00, 0.000000E+00, &
                  0.000000E+00, 0.000000E+00, 0.000000E+00, 0.000000E+00, 0.000000E+00, &
                  0.000000E+00, 0.000000E+00, 0.000000E+00, 0.000000E+00, 0.000000E+00, &
                  0.000000E+00, 0.000000E+00, 0.000000E+00, 0.000000E+00, 0.000000E+00, &
                  0.000000E+00, 0.000000E+00, 2.438798E-08, 0.000000E+00, 0.000000E+00, &
                  0.000000E+00, 0.000000E+00, 0.000000E+00, 0.000000E+00, 1.132761E-23, &
                  0.000000E+00, 0.000000E+00, 0.000000E+00, 0.000000E+00, 0.000000E+00, &
                  0.000000E+00, 0.000000E+00, 0.000000E+00, 0.000000E+00, 0.000000E+00, &
                  0.000000E+00, 0.000000E+00, 0.000000E+00, 0.000000E+00, 0.000000E+00, &
                  0.000000E+00, 1.513218E-12, 6.276980E-20, 0.000000E+00, 0.000000E+00, &
                  2.694736E-09, 1.379541E-12, 0.000000E+00, 0.000000E+00, 2.602621E-11, &
                  0.000000E+00, 0.000000E+00, 0.000000E+00, 3.081993E-12, 1.229113E-14, &
                  3.501083E-14, 1.734065E-14, 0.000000E+00, 0.000000E+00, 0.000000E+00, &
                  2.695271E-10, 2.466929E-12, 0.000000E+00, 0.000000E+00, 6.276980E-20, &
                  1.160742E-07, 0.000000E+00, 0.000000E+00, 0.000000E+00, 0.000000E+00, &
                  0.000000E+00, 0.000000E+00, 0.000000E+00, 0.000000E+00, 0.000000E+00, &
                  0.000000E+00, 0.000000E+00, 0.000000E+00, 0.000000E+00, 0.000000E+00, &
                  0.000000E+00, 0.000000E+00, 0.000000E+00, 0.000000E+00, 0.000000E+00, &
                  0.000000E+00, 0.000000E+00, 0.000000E+00, 0.000000E+00, 0.000000E+00, &
                  0.000000E+00, 0.000000E+00, 0.000000E+00, 0.000000E+00, 0.000000E+00, &
                  0.000000E+00, 0.000000E+00, 0.000000E+00, 0.000000E+00, 0.000000E+00, &
                  0.000000E+00, 0.000000E+00, 0.000000E+00, 0.000000E+00, 0.000000E+00, &
                  0.000000E+00, 0.000000E+00, 0.000000E+00, 0.000000E+00, 0.000000E+00, &
                  0.000000E+00, 0.000000E+00, 0.000000E+00, 0.000000E+00/), (/nr,nc/),  &
                  order = order2)

    call solver_linear_ginv(nr,nc,a,aflag,atemp,utemp)
    write(*,*) "pseudo inverse of a is"
    do i = 1, nc
      write(*,*) a(:,i)
    end do
    

    write(*,*) "force stop after usg_mesh_data_pseudo_inverse"
    stop

  end subroutine solver_linear_ginv_test

  !>
  !> pseudo inverse, or generalized inverse of a matrix
  !>
  subroutine solver_linear_ginv(nr,nc,ain,aflag,atemp,utemp)

    implicit none
    integer, intent(in) :: nr, nc
    real*8, dimension(:,:), intent(inout) :: ain
    real*8, dimension(:,:), intent(out) :: utemp
    real*8, dimension(:), intent(out) :: aflag, atemp

    call ginv(ain,utemp,aflag,atemp,nr,nc)


  end subroutine solver_linear_ginv

  !>
  !> compute the generalized inverse of a matrix
  !> taken from http://ftp.cac.psu.edu/pub/ger/fortran/hdk/ginv.f90
  !> https://github.com/fercook/ForMPS/blob/master/CACM66InverseCalculator.f90
  !>
  subroutine GINV (A,U,AFLAG,ATEMP,NR,NC)

! A Simple Algorithm for Computing the Generalized Inverse of a Matrix
!  by B. Rust, W. R. Burrus and C. Schneeberger
!  CACM 9(5):381-387 (May, 1966)
!
! This routine calculstes the Generalized Inverse of input matrix, A,
! and stores the transpose of it in matrix, A.
! NR -> Number of rows of matrix,  A
! NC -> Number of columns of matrix,  A
! U  -> a bookkeeping matrix.
! AFLAG and ATEMP are temporary working vectors
!
! Notes: If the columns of A are independent, then the Generalized
!        Inverse of A is the Least Squares Inverse of A. That is,
!        GINV can be used to compute Least Squares Regression
!        Coefficients.
!
!        If the matrix A is square with independent columns, then
!        the Generalized Inverse of A is the Inverse of A.
!
!
  implicit none

  real*8, dimension(:,:), intent(inout) :: A
  real*8, dimension(:,:), intent(out) :: U
  real*8, dimension(:), intent(out) :: AFLAG, ATEMP
  real*8 :: FAC, TOL, DOT1, DOT2
  integer, intent(in) :: NR,NC
  integer  :: I,J,K,L,JM1

      DO  I = 1,NC
        DO J = 1,NC
          U(I,J) = 0.0
        END DO
        U(I,I) = 1.0
      END DO
      FAC = DOT(NR,A,1,1)
      FAC= 1.0d0/SQRT(FAC)
      DO I = 1,NR
        A(I,1) = A(I,1) * FAC
      END DO
      DO I = 1,NC
        U (I,1) = U(I,1)*FAC
      END DO
      AFLAG(1) = 1.0
!
! Dependent column tolerance, TOL
!
!     N = 27
!     TOL = (10.0 * 0.5**N)**2
      TOL=10.0*EPSILON(FAC)
      DO J = 2,NC
        DOT1 = DOT(NR,A,J,J)
        JM1=J-1
         DO L=1,2
          DO K=1,JM1
            ATEMP(K) = DOT(NR,A,J,K)
         END DO
         DO K=1,JM1
            DO I = 1,NR
              A(I,J) = A(I,J)-ATEMP(K)*A(I,K)*AFLAG(K)
            END DO
            DO I = 1,NC
              U(I,J) = U(I,J)-ATEMP(K)*U(I,K)
            END DO
         END DO
         END DO
        DOT2 = DOT(NR,A,J,J)
        IF((DOT2/DOT1) <= TOL) THEN
          DO I=1,JM1
            ATEMP (I)=0.0
            DO  K=1,I
             ATEMP(I) = ATEMP(I) + U(K,I)*U(K,J)
            END DO
          END DO
          DO I = 1,NR
            A( I,J)=0.0
            DO K=I,JM1
              A(I,J) = A(I,J) - A (I,K)*ATEMP(K)*AFLAG(K)
            END DO
          END DO
          AFLAG(J) = 0.0
          FAC = DOT(NC,U,J,J)
          FAC= 1.0d0/SQRT(FAC)
        ELSE
          AFLAG(J) = 1.0
          FAC=1.0d0/SQRT(DOT2)
        ENDIF
        DO I = 1,NR
          A(I,J) = A(I,J)*FAC
        END DO
        DO I = 1,NC
          U(I,J) = U(I,J)*FAC
        END DO
      END DO
      DO J=1,NC
        DO I=1,NR
        FAC = 0.0
        DO K = J,NC
          FAC=FAC+A(I,K)*U(J,K)
        END DO
          A(I,J) = FAC
        END DO
      END DO
      RETURN
  end subroutine GINV


  !>
  !> dot product
  !>
  FUNCTION DOT (NR,A,JC,KC) result (PROD)

    implicit none
!  Computes the inner product of columns JC and KC
!  of matrix, A.

! type (QUAD), Dimension(:,:) :: A
! type (QUAD) :: DOT
    real*8, dimension(:,:), intent(in) :: A
    real*8 :: PROD
    integer :: I
    integer, intent(in) :: NR,JC,KC
    PROD=0.0
    DO I = 1,NR
      PROD = PROD + A(I,JC)*A(I,KC)
    END DO
    RETURN
  end function DOT

end module solver_linear
