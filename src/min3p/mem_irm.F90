!*****Revision Informations Automatically Generated by VisualSVN*****!
!---------------------------------------------------------------------
!> $ID:$
!> $Revision: 875 $
!> $Author: dsu $
!> $Date: 2024-01-21 12:55:48 -0800 (Sun, 21 Jan 2024) $
!> $URL: https://min3psvn.ubc.ca/svn/min3p_thcm/branches/dsu_new_add_2024Jan/src/min3p/mem_irm.F90 $
!---------------------------------------------------------------------
!********************************************************************!

!c -----------------------------------------------------------------------
!c subroutine mem_irm
!c -----------------
!c
!c allocate memory for intermittent reeaction related arrays
!c
!c written by:      Danyang Su - Sept 30, 2023
!c
!c last modified:   -
!c
!c definition of variables:
!c
!c I --> on input   * arbitrary  - initialized  + entries expected
!c O --> on output  * arbitrary  - unaltered    + altered
!c                                                                    I O
!c passed:   -
!c
!c common:
!c gen.f:    integer:
!c           --------
!c           ilog               = unit number, logbook file           + -
!c
!c chem.f:   real*8:
!c           -------
!c
!c external: checkerr  = check for error during memory allocation
!c ----------------------------------------------------------------------
  
      subroutine mem_irm

      use gen
      use chem
      
      implicit none
      
      integer :: ierr
 
      external checkerr

!c  main variables - intermittent reaction    

      allocate(iairm(niz_irm+1), stat = ierr)
      iairm = 1
      call checkerr(ierr,'iairm',ilog)
      call memory_monitor(sizeof(iairm),'iairm',.true.)

      allocate(jairm(niz_irm*nm), stat = ierr)
      jairm = 0
      call checkerr(ierr,'jairm',ilog)
      call memory_monitor(sizeof(jairm),'jairm',.true.)


      allocate(iairt(niz_irm+1), stat = ierr)
      iairt = 1
      call checkerr(ierr,'iairt',ilog)
      call memory_monitor(sizeof(iairt),'iairt',.true.)

      allocate(irt(niz_irm*1000), stat = ierr)
      irt = 0.0d0
      call checkerr(ierr,'irt',ilog)
      call memory_monitor(sizeof(irt),'irt',.true.)


      allocate(iairc(niz_irm+1), stat = ierr)
      iairc = 1
      call checkerr(ierr,'iairc',ilog)
      call memory_monitor(sizeof(iairc),'iairc',.true.)

      allocate(irc(niz_irm*nm*1000), stat = ierr)
      irc = 1.0d0
      call checkerr(ierr,'irc',ilog)
      call memory_monitor(sizeof(irc),'irc',.true.)

      allocate(imizn2jairm(nm,niz_irm), stat = ierr)
      imizn2jairm = 0
      call checkerr(ierr,'imizn2jairm',ilog)
      call memory_monitor(sizeof(imizn2jairm),'imizn2jairm',.true.)        

      allocate(imizn2irc(nm,niz_irm), stat = ierr)
      imizn2irc = 1.0d0
      call checkerr(ierr,'imizn2irc',ilog)
      call memory_monitor(sizeof(imizn2irc),'imizn2irc',.true.) 

      return
      end
