!*****Revision Informations Automatically Generated by VisualSVN*****!
!---------------------------------------------------------------------
!> $ID:$
!> $Revision: 786 $
!> $Author: dsu $
!> $Date: 2021-01-06 21:41:32 -0800 (Wed, 06 Jan 2021) $
!> $URL: https://min3psvn.ubc.ca/svn/min3p_thcm/branches/dsu_new_add_2024Jan/src/min3p/mem_hmcd.F90 $
!---------------------------------------------------------------------
!********************************************************************!

!c -----------------------------------------------------------------------
!c subroutine mem_hmcd
!c ----------------- 
!c M. Xie (April 2014)
!c
!c ----------------------------------------------------------------------
  
      subroutine mem_hmcd
       
      use parm
      use gen, only : f_epor_ps, f_etau_ps, f_epor_ss, f_etau_ss,      &
                      mem_cur, mem_max, memory_monitor
      use chem, only : nc, nx
      use phys, only : nzn
      
      implicit none

      external checkerr
      INTEGER*4 ierr,ilog
      
      
 
!cprovi-----------------------------------------------------------
!cprovi Allocate variables corresponding to evaporation processes 
!cprovi----------------------------------------------------------- 

     
      allocate (f_epor_ps(nc,nzn), stat = ierr)
      f_epor_ps=1.0d0
      call checkerr(ierr,'f_epor_ps',ilog)
      call memory_monitor(sizeof(f_epor_ps),'f_epor_ps',.true.)

      allocate (f_etau_ps(nc,nzn), stat = ierr)
      f_etau_ps=1.0d0
      call checkerr(ierr,'f_etau_ps',ilog)
      call memory_monitor(sizeof(f_etau_ps),'f_etau_ps',.true.)

      allocate (f_epor_ss(nx,nzn), stat = ierr)
      f_epor_ss=1.0d0
      call checkerr(ierr,'f_epor_ss',ilog) 
      call memory_monitor(sizeof(f_epor_ss),'f_epor_ss',.true.)
      
      allocate (f_etau_ss(nx,nzn), stat = ierr)
      f_etau_ss=1.0d0
      call checkerr(ierr,'f_etau_ss',ilog)
      call memory_monitor(sizeof(f_etau_ss),'f_etau_ss',.true.)

      return
      end
