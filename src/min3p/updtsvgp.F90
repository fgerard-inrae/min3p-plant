!*****Revision Informations Automatically Generated by VisualSVN*****!
!---------------------------------------------------------------------
!> $ID:$
!> $Revision: 533 $
!> $Author: dsu $
!> $Date: 2017-10-16 11:50:08 -0700 (Mon, 16 Oct 2017) $
!> $URL: https://min3psvn.ubc.ca/svn/min3p_thcm/branches/dsu_new_add_2024Jan/src/min3p/updtsvgp.F90 $
!---------------------------------------------------------------------
!********************************************************************!

!c ----------------------------------------------------------------------
!c subroutine updtsvgp
!c -------------------
!c
!c update secondary variables in gaseous phase
!c - gas concentrations
!c - total gaseous component concentrations
!c
!c written by:      Uli Mayer - September 27, 96
!c
!c last modified:   Uli Mayer - November 28, 96 
!c
!c definition of variables:
!c I --> on input   * arbitrary  - initialized  + entries expected
!c O --> on output  * arbitrary  - unaltered    + altered
!c                                                                    I O
!c passed:   real*8:
!c           -------
!c           c(nc)              = concentrations of free species      + -
!c                                - new time level [moles/l water]
!c           gammac(nc)         = activity coefficients for free      + -
!c                                species
!c           g(ng)              = gas concentrations [moles/l air]    * +
!c           tempkel            = temperature [deg K]                 + -
!c           totcg(nc-1)        = total gaseous component             * +
!c                                concentrations [moles/l air]
!c common:
!c chem.f:   integer*4:
!c           ----------
!c           ng                 = number of gases                     + -
!c
!c local:    integer*4:
!c           ----------
!c           ig                 = counter (gases)
!c
!c external: gasconc   = compute gas concentrations based on free
!c                       species concentrations
!c           totconcg  = compute total gaseous component
!c                       concentrations based on gas concentrations
!c ----------------------------------------------------------------------
 
      subroutine updtsvgp (c,gammac,g,totcg,tempkel,tid)
 
      use parm
      use chem
 
      implicit none
      
      real*8 :: c, gammac, g, totcg, tempkel
      integer :: tid

      dimension c(*),gammac(*),g(*),totcg(*)
 
      external totconcg, gasconc
      
      integer :: ig      

!c  compute gas concentrations

      do ig = 1,ng
        call gasconc(c,gammac,g(ig),ig,tempkel,tid)
      end do

!c  compute total gaseous component concentrations

      call totconcg(g,totcg)

      return
      end
