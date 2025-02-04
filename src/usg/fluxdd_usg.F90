!*****Revision Informations Automatically Generated by VisualSVN*****!
!---------------------------------------------------------------------
!> $ID:$
!> $Revision: 786 $
!> $Author: dsu $
!> $Date: 2021-01-06 21:41:32 -0800 (Wed, 06 Jan 2021) $
!> $URL: https://min3psvn.ubc.ca/svn/min3p_thcm/branches/dsu_new_add_2024Jan/src/usg/fluxdd_usg.F90 $
!---------------------------------------------------------------------
!********************************************************************!

!c ----------------------------------------------------------------------
!c real*8 function fluxdd_usg
!c ----------------------
!c
!c compute water flux for density-dependent flow
!c fully saturated or variably saturated (differ 
!c only in passed variable dcoef)
!c
!c written by:      Danyang Su - Aug. 8, 2016
!c
!c definition of variables:
!c
!c I --> on input   * arbitrary  - initialized  + entries expected
!c O --> on output  * arbitrary  - unaltered    + altered
!c                                                                    I O
!c passed:   real*8:
!c           ------- 
!c           del_p              = difference in total                 * +       
!c                                pressure potential
!c           dcoef              = coefficient including density,      + -
!c                                viscosity, and relative 
!c                                permeability
!c           cinfvs             = influence coefficient               + -
!c           fluxdd             = mass flux at interface             * +
!c 
!c
!c common:   -
!c           
!c local:    -
!c
!c external: -
!c ----------------------------------------------------------------------
#ifdef USG
    module mod_fluxdd_usg

    implicit none

    contains

    !>
    !> calculate flux term
    !>
    real*8 function fluxdd_usg(delpress,ndvol,ncell,grad_mids,         &
                               flux_corr,cinfvs,cinfvs_cross,          &
                               bcellbased,nrelp,dcoef)

      use geometry
      use gen, only : b_use_cross_diffusion_flow, b_use_hls_correction

      implicit none
      
      real*8 :: delpress
      integer :: ndvol, ncell, nrelp
      real*8 :: flux_corr(ndvol,ncell)
      real*8 :: cinfvs(ndvol,ncell)
      real*8 :: dcoef(nrelp)
      logical :: bcellbased
      type(point) :: grad_mids(ndvol,ncell), cinfvs_cross(ndvol,ncell)

      !c local variable
      integer :: i, j
      real*8 :: fluxd_direct, fluxd_cross

!c  compute interfacial flux
      fluxd_direct = 0.0d0
      if (b_use_hls_correction) then
        if (bcellbased) then
          do i = 1, ncell
            do j = 1, ndvol
              fluxd_direct = fluxd_direct + cinfvs(j,i)*dcoef(i)*      &
                                   (delpress-flux_corr(j,i))
            end do
          end do
        else
          do i = 1, ncell
            do j = 1, ndvol
              fluxd_direct = fluxd_direct + cinfvs(j,i)*dcoef(1)*      &
                                   (delpress-flux_corr(j,i))
            end do
          end do
        end if
      else
        if (bcellbased) then
          do i = 1, ncell
            do j = 1, ndvol
              fluxd_direct = fluxd_direct + cinfvs(j,i)*dcoef(i)*delpress
            end do
          end do
        else
          do i = 1, ncell
            do j = 1, ndvol
              fluxd_direct = fluxd_direct + cinfvs(j,i)*dcoef(1)*delpress
            end do
          end do
        end if
      end if

      fluxd_cross = 0.0d0
      if (b_use_cross_diffusion_flow) then
        if (bcellbased) then
          do i = 1, ncell
            do j = 1, ndvol
              fluxd_cross = fluxd_cross + (cinfvs_cross(j,i).dot.grad_mids(j,i))*dcoef(i)
            end do
          end do
        else
          do i = 1, ncell
            do j = 1, ndvol
              fluxd_cross = fluxd_cross + (cinfvs_cross(j,i).dot.grad_mids(j,i))*dcoef(1)
            end do
          end do
        end if
      end if

      fluxdd_usg = fluxd_direct + fluxd_cross

    end function fluxdd_usg

    !>
    !> calculate flux term over the control volume ivol
    !> This function is used in velocity reconstruction from control volume interface to node.
    !>
    type(point) function fluxdd_cvol_usg(delpress,ndvol,ncell,grad_mids,     &
                             flux_corr,cinfvs,cinfvs_cross,cvf2node,         &
                             bcellbased,nrelp,dcoef)

      use geometry
      use gen, only : b_use_cross_diffusion_flow, b_use_hls_correction

      implicit none

      real*8 :: delpress
      integer :: ndvol, ncell, nrelp
      real*8 :: flux_corr(ndvol,ncell)
      real*8 :: cinfvs(ndvol,ncell)
      real*8 :: dcoef(nrelp)
      logical :: bcellbased
      type(point) :: grad_mids(ndvol,ncell)
      type(point) :: cinfvs_cross(ndvol,ncell)
      type(point) :: cvf2node(ndvol,ncell)

      !c local variable
      integer :: i, j
      type(point) :: vel_cvol

      vel_cvol = vector_zero

!c  compute interfacial flux
      if (b_use_hls_correction) then
        if (bcellbased) then
          do i = 1, ncell
            do j = 1, ndvol
              vel_cvol = vel_cvol + cvf2node(j,i)*(cinfvs(j,i)*dcoef(i)*     &
                                   (delpress-flux_corr(j,i)))
            end do
          end do
        else
          do i = 1, ncell
            do j = 1, ndvol
              vel_cvol = vel_cvol + cvf2node(j,i)*(cinfvs(j,i)*dcoef(1)*     &
                                   (delpress-flux_corr(j,i)))
            end do
          end do
        end if
      else
        if (bcellbased) then
          do i = 1, ncell
            do j = 1, ndvol
              vel_cvol = vel_cvol + cvf2node(j,i)*(cinfvs(j,i)*dcoef(i)*delpress)
            end do
          end do
        else
          do i = 1, ncell
            do j = 1, ndvol
              vel_cvol = vel_cvol + cvf2node(j,i)*(cinfvs(j,i)*dcoef(1)*delpress)
            end do
          end do
        end if
      end if

      if (b_use_cross_diffusion_flow) then
        if (bcellbased) then
          do i = 1, ncell
            do j = 1, ndvol
              vel_cvol = vel_cvol + cvf2node(j,i)*((cinfvs_cross(j,i).dot.grad_mids(j,i))*dcoef(i))
            end do
          end do
        else
          do i = 1, ncell
            do j = 1, ndvol
              vel_cvol = vel_cvol + cvf2node(j,i)*((cinfvs_cross(j,i).dot.grad_mids(j,i))*dcoef(1))
            end do
          end do
        end if
      end if

      fluxdd_cvol_usg = vel_cvol

    end function fluxdd_cvol_usg

    !>
    !> calculate velocity term
    !>
    type(point) function fluxdd_vel_usg_tend(dcoef, cond_mid, grad_mid)

      use geometry

      implicit none

      real*8 :: dcoef
      type(point) :: grad_mid, cond_mid

      !c local variable

!c  compute interfacial velocity
      fluxdd_vel_usg_tend = (cond_mid.times.grad_mid)*dcoef

    end function fluxdd_vel_usg_tend

    !>
    !> calculate velocity term
    !>
    type(point) function fluxdd_vel_usg_tenf(dcoef, conf_mid, grad_mid)

      use geometry

      implicit none

      real*8 :: dcoef
      type(tensor) :: conf_mid
      type(point) :: grad_mid

      !c local variable

!c  compute interfacial velocity
      fluxdd_vel_usg_tenf = (conf_mid.cross.grad_mid)*dcoef

    end function fluxdd_vel_usg_tenf

    end module mod_fluxdd_usg
#endif
