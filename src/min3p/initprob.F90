!*****Revision Informations Automatically Generated by VisualSVN*****!
!---------------------------------------------------------------------
!> $ID:$
!> $Revision: 879 $
!> $Author: dsu $
!> $Date: 2024-02-17 10:15:21 -0800 (Sat, 17 Feb 2024) $
!> $URL: https://min3psvn.ubc.ca/svn/min3p_thcm/branches/dsu_new_add_2024Jan/src/min3p/initprob.F90 $
!---------------------------------------------------------------------
!********************************************************************!

!c ----------------------------------------------------------------------
!c subroutine initprob
!c -------------------
!c
!c initialize variably saturated flow and/or reactive transportBF simulation or initialize equilibrium or reaction path simulation
!c
!c modified for optional density dependent flow simulation
!c
!c written by:      Uli Mayer - October, 1995
!c
!c last modified:   Tom Henderson - April 1, 2003
!c
!c                  Danyang Su - Sept. 10, 2018
!c                  Unstructured grid and HPC capabilities
!c
!c            Celine Blitz Frayret (CBF) for Frederic Gerard, December 14, 2018 
!c            allocate memory for evapo-transpiration parameters (mem_etr),
!c            build binary matrix (physical evap and transpiration),
!c            initialize plant parameters (initplant)
!c
!c definition of variables:
!c
!c I --> on input   * arbitrary  - initialized  + entries expected
!c O --> on output  * arbitrary  - unaltered    + altered
!c                                                                    I O
!c passed:   -
!c
!c common:   
!c gen.f:    logical:
!c           --------
!c           geo_chemistry      = .true.  -> local or background and  + -
!c                                           source chemistry
!c           reactive_transport = .true.  -> perform reactive         + -
!c                                           transport simulation
!c           varsat_flow        = .true.  -> perform flow simulation  + -
!c           root_uptake        = .true.  -> calculate root water
!c                                            uptake    CBF
!c
!c dens.f:   logical:
!c           --------
!c          density_dependence = .true.  -> density-dependent flow   + -
!c           flow_verification  = .true.  -> verify pressure formulation
!c                                           for constant density 
!c                                           test problem
!c           
!c local:    -
!c
!c external: inittsgs = time step control parameters (global system)
!c           initcpvs = control parameters for variably saturated flow
!c           initcpdd = control parameters for density dependent flow
!c           initcprt = control parameters for reactive transport
!c           sptldisc = read spatial discretization parameters, 
!c                      discretize solution domain and compute nodal 
!c                      volumes
!c           initopgs = output control parameters (global system)
!c           initcsys = define geochemical system 
!c           opnmbfls = open mass balance files
!c           opnmbfls_mcd = open mass balance files for MCD
!c           datstr_1 = set up data structure, generate ordering vectors 
!c                      and perform symbolic factorization for 1d-scalar 
!c                      matrix (variably saturated flow)
!c           datstr_n = set up data-structure, generate ordering vectors 
!c                      and perform symbolic factorization for nd-scalar
!c                      matrix (reactive transport)
!c           initcplc = control parameters for local chemistry
!c           initpppm = physical parameters for porous medium
!c           initppvs = physical parameters for variably saturated flow
!c           initppdd = physical parameters for density dependent flow
!c           infcvs   = compute influence coefficients (variably
!c                      saturated flow)
!c           initpprt = physical parameters (reactive transport)
!c           initicvs = initial condition (variably saturated flow)
!c           initicdd = initial condition (density dependent flow)
!c           initbcvs = boundary conditions (variably saturated flow)
!c           initbcdd = boundary conditions (density dependent flow)
!c           initsatw = compute initial saturations 
!c           initicrt = initial condition (reactive transport)
!c           initbcrt = boundary conditions (reactive transport)
!c           indextec = calculate i,j,k indices for TECPLOT
!c                      postprocessing
!c           initweed = initialize work arrays for determination 
!c                      of secondary aqueous species, which are 
!c                      obsolete for simulation
!c           inittemp = define temperature field and compute
!c                      temperature-dependent constants
!c         initplant= plant transpiration and passive/rejective 
!c            uptake for variably saturated flow ! CBF
!c           mem_rt   = allocate memory for reactive transport 
!c                      simulation
!c           mem_vs   = allocate memory for variably-saturated
!c                      flow simulation
!c           mem_dd = allocate memory for variably-saturated
!c                      density dependent flow simulation
!c           mem_hmcd = allocate memory for hybrid
!c                      multicomponent diffusion model
!c           mem_etr  = allocate memory for evapo-transpiration
!c            parameters ! CBF
!c           weed     = determine seondary aqueous species, which 
!c                      are obsolete for simulation
!c           binmattransp = assign binary values to matrix localizing
!c            control volume subjected to transpiration 
!c            (rld based) ! CBF
!c           binmatevap = assign binary values to matrix localizing
!c            control volume subjected to evaporation
!c            (h1dry based) ! CBF
!c ----------------------------------------------------------------------
 
      subroutine initprob

#ifdef PETSC
#include <petscversion.h>
#if (PETSC_VERSION_MAJOR >= 3 && PETSC_VERSION_MINOR >= 8)
#include <petsc/finclude/petscsys.h>
      use petscsys
#endif
#endif

      use parm
      use gen
      use dens
      use chem 
      use phys 
      use bbls
      use mip_bubble, only : mip_mt_enable, mip_ctrl_params,           &
                             mip_initial_cond, mip_boundary_vols
      use mip_output, only : mip_output_params
      
      use module_binary_mpiio, only : binary_subarray_initialize
      use biol

#ifdef OPENMP
      use omp_lib 
#endif
     
#ifdef PETSC
      use solver_snes_common, only : rtol_flow, abstol_flow,           &
                 maxits_flow, rtol_react, abstol_react, maxits_react,  &
                 pc_factor_shift_flow, pc_factor_shift_react
      use solver_dd, only : solver_dd_DMDACreate_react
      use petsc_mpi_common, only : petsc_mpi_finalize, petsc_mpi_barrier
#endif

#ifdef LIS
      use solver_lis_common, only : lis_default_flow,                  &
                                    lis_options_flow,                  &
                                    lis_abstol_flow,                   &
                                    lis_maxit_flow,                    &
                                    lis_default_react,                 &
                                    lis_options_react,                 &
                                    lis_abstol_react,                  &
                                    lis_maxit_react
#endif
    
#ifdef USG
      use usg_mesh_data, only : usg_mesh_data_mem_vs,                  &
                                usg_mesh_data_mem_rt
#endif
      implicit none
#ifdef PETSC
#if (PETSC_VERSION_MAJOR >= 3 && PETSC_VERSION_MINOR >= 6 && PETSC_VERSION_MINOR < 8)
#include <petsc/finclude/petscsys.h>
#elif (PETSC_VERSION_MAJOR >= 3 && PETSC_VERSION_MINOR < 6)
#include <finclude/petscsys.h>
#endif
#endif

      integer :: ivol, ibrt, izn, ierr
      
      real*8 :: actw, dummy

#ifdef PETSC
      real(kind=8) :: rsum_vprop_gbl
      logical :: seepage_face_gbl
      PetscErrorCode :: ierrcode
#endif

!cdsu
!c Small round-off error in OpenMP reduction operation (:sum) causes 
!c significant difference in the final results. The code looks very sensitive
!c to the value of rsum_vprop
      real(kind=16) :: rsum_vprop_quad
      
      integer :: rwork_max_size

      character(72) :: strbuffer

      external inittsgs,initcpvs,initcpdd,initcprt,sptldisc,           &
               initopgs,initcsys,opnmbfls,datstr_1,datstr_n,initcplc,  &
               initpppm,initppvs,initppdd,infcvs,initpprt,initicvs,    &
               initicdd,initbcvs,initbcdd,initsatw, initicrt,initbcrt, &
               initppsn,initiice,initbcice,indextec,inittemp,initweed, &
               mem_rt,mem_vs,mem_dd,weed,mem_hmcd,tcorr
     
      real*8, parameter :: rkelvin=273.15d0,r0=0.0d0,r1=1.0d0

!c  read spatial discretization parameters, discretize solution domain
!c  and compute nodal volumes
!c  Parallelized, OpenMP, MPI, DSU

      if (varsat_flow.or.reactive_transport) then
        call sptldisc
      end if
    
!c  define geochemical system
      if (geo_chemistry) then
        call initcsys
      end if

!c  Parallelized, OpenMP, DSU
      if (varsat_flow) then
        call mem_vs
      end if
      
!c  Parallelized, OpenMP, DSU
      if (heat_transport .or. temp_field) then
        call mem_heat
      else
        b_water_freezing = .false.
        b_water_freezing_cond = .false.
        b_water_freezing_curve = .false.
        b_water_freezing_ratemin = .false.
      end if
      

!c  allocate memory for reactive transport simulation
!c  Parallelized, OpenMP, DSU
      if (reactive_transport) then
        call mem_rt
      end if

!c  allocate memory for density-dependent flow simulation (new)
!c  Parallelized, OpenMP, DSU
      if (density_dependence) then
        call mem_dd
      end if

!c  define temperature field and compute temperature-dependent 
!c  constants

      if (geo_chemistry) then
        call inittemp
      end if
  
!c  assign indices for tecplot output
      if(discretization_type == 0) then
        call indextec
      end if

!c  time step control parameters for reactive transport and/or
!c  variably saturated flow 

      if ((varsat_flow.and.transient_flow).or.reactive_transport) then
        call inittsgs
      end if

!c  control parameters for local chemistry

      if (geo_chemistry) then
        call initcplc
      end if

!c  control parameters for variably saturated 
!c  and density dependent flow

      if (varsat_flow)then
        if (density_dependence) then
          
          call initcpdd
        
          if (heat_transport) then
            call initcpenergybal
            if (variably_saturated.and.evaporation) then             
              call initcpevaporation
!c  Parallelized, OpenMP, DSU
              call mem_evap              
            end if
          end if 
        
        else 
          call initcpvs
        end if

        !c DSU: do not allocate when root_uptake is not used
        !c Only allocate the necesary variables, move this part upward.
        !if (.not.root_uptake) then    ! CBF
        !  call mem_etr                ! CBF
        !endif                        ! CBF

      end if
     
!cprovi---------------------------------------------------------------------
!cprovi it was added by Sergio Andr�s Bea Jofr?
!cprovi Aqueous Phase with Pitzer equations are created only if
!cprovi ispitzer=true 
!cprovi---------------------------------------------------------------------
      if (ispitzer) then 
        call initpitzer  
      end if 
!cprovi---------------------------------------------------------------------
!cprovi---------------------------------------------------------------------
!cprovi---------------------------------------------------------------------
      
!c  control parameters for reactive transport

      if (reactive_transport) then
        call initcprt
      end if
      
!c  initialize ice loading/unloading simulation
      if (compute_ice_sheet_loading) then
        call initcpice
      end if

!c  control parameters for reactive transport

      if (gas_bubbles) then
        call initcpgb
      end if

!cdsu-----------------------------------------------------------------
!cdsu  Initialize macroscopic invasion percolation (IP) bubble flow model
!cdsu-----------------------------------------------------------------
      if (mip_mt_enable) then
        !c initialize IP model, some hardwired variables
#ifndef GPL 
        if (rank == 0) then
          write(*,*) 'Error: GPL licensed library is required for MIP model'
          write(ilog,*) 'Error: GPL licensed library is required for MIP model'
        end if
        goto 999
#endif
        call mip_ctrl_params
      end if

!c  output control parameters for reactive transport and/or
!c  variably saturated flow and/or batch reaction

      call initopgs

!c  set up data structure, generate ordering vectors and perform 
!c  symbolic factorization for 1d - Jacobian matrix
!c  (variably saturated flow and reactive transport)
!c  Partially parallelized, OpenMP, DSU
      if (varsat_flow.or.reactive_transport) then
        call datstr_1
      end if

!c  set up data-structure, generate ordering vectors and perform
!c  symbolic factorization for reactive transport problem
!c  Partially parallelized, OpenMP, DSU
      if (reactive_transport) then
        call datstr_n
#ifdef PETSC
        call solver_dd_DMDACreate_react
#endif
      end if


!c  open mass balance files
!c  write mass balance files only by the master process (thread)
      if(b_enable_output) then

          call opnmbfls

          if(flux_out)then               !MCD
            call opnmbfls_mcd
          end if
      end if

!cprovi--------------------------------------------------------------
!cprovi Open file corresponding to energy balance
!cprovi--------------------------------------------------------------
      if(rank == 0) then
        if (heat_transport.and.energy_balance) then
          call opnenergybal
        end if
      end if

!c  physical parameters for ice sheet basal      
      if (compute_ice_sheet_loading) then
        if (ice_sheet_type == 1) then
#ifdef USG
          call initppsn
#endif
        end if
      end if  

!c  physical parameters for porous medium
!c  Partially parallelized, OpenMP, DSU
      call initpppm
 
      if (varsat_flow) then
        if (density_dependence) then

!c  physical parameters for density dependent variably saturated flow
!c  Partially parallelized, OpenMP, DSU        
          call initppdd

!c  influence coefficients for density dependent variably saturated flow
        else   ! not density dependent flow

!c  physical parameters for variably saturated flow
!c  Partially parallelized, OpenMP, DSU
          call initppvs

!c  influence coefficients for variably saturated flow

        end if  !density dependence
        
!c  release memory for the variables that will not be used anymore
        if (allocated(cell_idx_g2lg)) then
          call memory_monitor(-sizeof(cell_idx_g2lg),'cell_idx_g2lg',.true.)
          deallocate(cell_idx_g2lg, stat = ierr)
          call checkerr(ierr,'cell_idx_g2lg',ilog)
        end if

!cprovi---------------------------------------------------------------        
!cprovi Read physical parameters for energy balance
!cprovi--------------------------------------------------------------- 
!c  Partially parallelized, OpenMP, DSU
        if (heat_transport) then
           call initppenergybal
        end if   

!cprovi-------------------------------------------------------------------
!cprovi Read initial conditions (temperature) for energy balance 
!cprovi calculations. It is performed previously to density calculations.
!cprovi-------------------------------------------------------------------
!c  Partially parallelized, OpenMP, DSU
        if (density_dependence.and.heat_transport) then
          call initicenergybal
        end if

#ifdef USG
        if(discretization_type > 0) then
          call usg_mesh_data_mem_vs
        end if
#endif

!cprovi-------------------------------------------------------------------
!cprovi Update the tkel vector and the temperature dependent variables
!cprovi-------------------------------------------------------------------  
!cdsu   The calling of tcorr is confused to me. In the sequential running, 
!cdsu   the variables (dhad, dhbd, ..., ratecaq) are updated by last volume.
!cdsu   Why call tcorr for every volume.
!cdsu   comment out by DSU       
!cdsu   Add the following variables to private if tcorr is called every time
!cdsu   in the parallel loop: dhad, dhbd, eqx, eqg, eqm, rated, eqmx, eqr, 
!cdsu   eqsb_ion, eqsb_surf, eqaq, ratecaq
!cdsu
!cdsu   if (temp_field.or.heat_transport) then
!cdsu   when temp_field is true,the temperature has already been assigned
!cdsu   in inittemp function that is called earlier.
!cdsu   DSU, 2016-04-13
       if (.not.temp_field.and.heat_transport) then
#ifdef OPENMP
   !$omp parallel                                                    &
   !$omp if (nngl > numofloops_thred_initprob_1)                     &
   !$omp num_threads(numofthreads_global)                            &
   !$omp default(shared)                                             &
   !$omp private(ivol)
   !$omp do schedule(static)
#endif   
        do ivol=1,nngl
          tkel(ivol) = tempnew(ivol) + rkelvin
        end do
#ifdef OPENMP
   !$omp end do
   !$omp end parallel
#endif 
       else if (b_water_freezing .and. .not.geo_chemistry) then
         !c set system temperature tkel to default temperature
         !c when freezing/thawing model is used without geochemistry
         tkel = tempks
       end if
       
!c  Compute influence coefficients for flow equation 
!c  Parallelized, OpenMP, DSU
        if(discretization_type == 0) then
          call infcvs
#ifdef USG
        else
          call infcvs_usg
#endif
        end if

!c  physical parameters for reactive transport

        if (reactive_transport) then
          call mem_hmcd
          call initpprt
        end if

#ifdef USG
        if(discretization_type > 0) then
          call usg_mesh_data_mem_rt
        end if
#endif

!c  initialize initial condition for ice sheet loading/unloading
        if (compute_ice_sheet_loading) then
          if (ice_sheet_type == 1) then
#ifdef USG
            call initiice
            call initbcice
#endif
          end if
        end if
 
!c  initial condition for variably saturated flow
!c  not density dependent
!c  Partially parallelized, OpenMP, DSU
        if ((varsat_flow).and.(.not.density_dependence)) then
          
          culabsbalvs = r0
        
          call initicvs

!c  boundary conditions for variably saturated flow
 
          call initbcvs

!c  initial saturations 
!c  Parallelized, OpenMP, DSU 
          call initsatw
   
        end if
    
      
!cprovi-------------------------------------------------------------------
!cprovi-------------------------------------------------------------------
!cprovi-------------------------------------------------------------------
        if (reactive_transport) then

!c  initialize work arrays for determination of secondary aqueous
!c  species, which are obsolete for simulation

          call initweed

!c  initial condition for reactive transport 
!c  Partially parallelized, OpenMP, DSU

          call initicrt

!c  boundary conditions for reactive transport 
!c  Partially parallelized, OpenMP, DSU
          call initbcrt

!c  determine seondary aqueous species, which are obsolete 
!c  for simulation
          if (b_enable_output) then
            call weed
          end if

        end if

!c CBF plant transpiration and passive/rejective solute uptake
        if (varsat_flow) then
          call mem_etr

          if (root_uptake) then
#ifdef ARCHISIMPLE
            call initplant
!c CBF build binary matrix for transpiration
            call binmattransp
#endif
          end if

!c CBF build binary matrix for physical evaporation
!c DSU variables in this function are never used, comment
          !call binmatevap     ! CBF
        end if

!c density dependent flow

        if (density_dependence) then
          !cprovi--------------------------------------------------------------------------
          !cprovi Compute densities (also viscosity) as a function of water composition
          !cprovi and temperature
          !cprovi--------------------------------------------------------------------------
          !cprovi  Parallelized, OpenMP, DSU
          if (.not. tran_steady_drho_0) then
            if (.not.flow_verification) then
              if (heat_transport) then
                 call ddtds_energybal(.true.)
              else
                 call ddtds
              end if
            end if
          end if
          !cprovi--------------------------------------------------------------------------
          !cprovi Read initial conditions for flow
          !cprovi--------------------------------------------------------------------------
          !cprovi  Paritially parallelized, OpenMP, DSU
          call initicdd

          !cprovi--------------------------------------------------------------------------
          !cprovi Read boundary conditions for flow
          !cprovi--------------------------------------------------------------------------
          call initbcdd

          !cprovi--------------------------------------------------------------------------
          !cprovi If ice sheet loading is computed, the previous boudary condictions
          !cprovi are stored
          !cprovi--------------------------------------------------------------------------
          if (compute_ice_sheet_loading) then
            allocate (bcondrt_a0(nc,nbrt), stat = ierr)
            call checkerr(ierr,'bcondrt_a0',ilog)
            call memory_monitor(sizeof(bcondrt_a0),'bcondrt_a0',.true.)
            do ibrt = 1,nbrt
              bcondrt_a0(1:nc,ibrt)= bcondrt_a(1:nc,ibrt)
            end do
          end if

          !cprovi--------------------------------------------------------------------------
          !cprovi Compute the first pore water saturation as a function of initial
          !cprovi pressure distribution
          !cprovi--------------------------------------------------------------------------
          !cprovi  Parallelized, OpenMP, DSU
          call initsatw

          if (heat_transport) then

            if (evaporation) then
              !cprovi--------------------------------------------------------------------------
              !cprovi Compute the saturated vapour density
              !cprovi (see Saito et al. (2006) and RETRASO user's manual)
              !cprovi--------------------------------------------------------------------------
#ifdef OPENMP
    !$omp parallel                                                    &
    !$omp if (nngl > numofloops_thred_initprob_2)                     &
    !$omp num_threads(numofthreads_global)                            &
    !$omp default(shared)                                             &
    !$omp private(ivol, izn, actw, dummy)                  
    !$omp do schedule(static)
#endif
              do ivol=1,nngl
                izn = mpropvs(ivol)
                if (reactive_transport) then
                  actw=gamma(nc,ivol)
                else
                  actw=r1
                end if

                if (soilhydrfunc_field) then
                  call vapor_prop (densvnew(ivol),dummy,ddensvdpa(ivol),&
                                   ddensvdt(ivol),latvapnew(ivol),      &
                                   tempnew(ivol),aentry_vol(ivol),      &
                                   uvsnew(ivol),actw,                   &
                                   density(ivol),ivol)
                else
                  call vapor_prop (densvnew(ivol),dummy,ddensvdpa(ivol),&
                                   ddensvdt(ivol),latvapnew(ivol),      &
                                   tempnew(ivol),aentry(izn),           &
                                   uvsnew(ivol),actw,                   &
                                   density(ivol),ivol)
                end if

                densvold(ivol)=densvnew(ivol)
                latvapold(ivol)=latvapnew(ivol)

                call surf_tens_prop (dummy,dsurftensdt(ivol),         &
                                     tempnew(ivol))
              end do
#ifdef OPENMP
    !$omp end do
    !$omp end parallel
#endif 
            end if
!cprovi---------------------------------------------------------------
!cprovi Init boundary conditions for heat transport
!cprovi---------------------------------------------------------------
!cprovi  Paritially parallelized, OpenMP, DSU 

            call initbcenergybal

!cprovi---------------------------------------------------------------
!cprovi Compute influence coefficients for energy balance
!cprovi--------------------------------------------------------------- 
!cprovi  Parallelized, OpenMP, DSU 
            if(discretization_type == 0) then
              call infheat_c (nvxgl,nvygl,nvzgl,iavs,javs,isymvs,       &
                              cinfheat_c,dimcv,heatcondw,               &
                              heatconds,heatcondg,heatcondi,tempnew,    &
                              pornew,sanew,uvsnew,zg,idbg,ilog,njavs,   &
                              nngl,half_cells,cinfrad,radial_coord,     &
                              heatcond_model,nheatcond)
#ifdef USG
            else
              call infheat_c_usg
#endif
            end if

          end if               
!cprovi---------------------------------------------------------------        
!cprovi---------------------------------------------------------------        
!cprovi---------------------------------------------------------------     
        end if

!cdsu-----------------------------------------------------------------
!cdsu  Update first value of rsum_vprop to avoid NaN/Infinite output 
!cdsu  in the initial condition
!cdsu-----------------------------------------------------------------
!c
!c Small round-off error in OpenMP reduction operation (:sum) causes 
!c significant difference in the final results. The code looks very sensitive
!c to the value of rsum_vprop
!c
!      rsum_vprop = r0
!      if (root_uptake) then
!#ifdef OPENMP
!    !$omp parallel                                                    &
!    !$omp if (nngl > numofloops_thred_global)                         &
!    !$omp num_threads(numofthreads_global)                            &
!    !$omp default(shared)                                             &
!    !$omp private(ivol)                                               &
!    !$omp reduction(+:rsum_vprop)
!    !$omp do schedule(static)
!#endif
!        do ivol = 1, nngl
!#ifdef PETSC
!          if(node_idx_lg2l(ivol) < 0) then
!            cycle
!          end if
!#endif
!          rsum_vprop = rsum_vprop+rld(ivol)*sanew(ivol)*cvol(ivol)
!        end do
!#ifdef OPENMP
!    !$omp end do
!    !$omp end parallel
!#endif

      rsum_vprop_quad = real(r0,kind=16)
      if (root_uptake) then
#ifdef OPENMP
    !$omp parallel                                                    &
    !$omp if (nngl > numofloops_thred_global)                         &
    !$omp num_threads(numofthreads_global)                            &
    !$omp default(shared)                                             &
    !$omp private(ivol)                                               &
    !$omp reduction(+:rsum_vprop_quad)
    !$omp do schedule(static)
#endif
        do ivol = 1, nngl
#ifdef PETSC
          if(node_idx_lg2l(ivol) < 0) then
            cycle
          end if
#endif
          rsum_vprop_quad = rsum_vprop_quad + real(rld(ivol)*sanew(ivol)*cvol(ivol),kind=16)
        end do
#ifdef OPENMP
    !$omp end do
    !$omp end parallel
#endif

!#ifdef PETSC
!!cdsu MPI_REAL16 works just fine when use Intel Fortran and Intel MPI,
!!cdsu However, it does not return right value when use OpenMPI or MPICH.
!!cdsu For example, OpenMPI 1.6 or MPICH 3.3.

!        call MPI_Allreduce(rsum_vprop_quad,rsum_vprop_gbl,1,MPI_REAL16,&
!                           MPI_SUM,Petsc_Comm_World,ierrcode)
!        CHKERRQ(ierrcode)
!        rsum_vprop_quad = rsum_vprop_gbl
!#endif
!        rsum_vprop = real(rsum_vprop_quad,kind=8)

!!cdsu alternative code

        rsum_vprop = real(rsum_vprop_quad,kind=8)

#ifdef PETSC
!!cdsu MPI_REAL16 works just fine when use Intel Fortran and Intel MPI,
!!cdsu However, it does not return right value when use OpenMPI or MPICH.
!!cdsu For example, OpenMPI 1.6 or MPICH 3.3.
        call MPI_Allreduce(rsum_vprop,rsum_vprop_gbl,1,MPI_REAL8,&
                           MPI_SUM,Petsc_Comm_World,ierrcode)
        CHKERRQ(ierrcode)
        rsum_vprop = rsum_vprop_gbl
#endif

      end if

!cdsu-----------------------------------------------------------------
!cdsu  Initialize macroscopic invasion percolation (IP) bubble flow model
!cdsu  assign initial condition and boundary condition to MIP_MT odel
!cdsu-----------------------------------------------------------------

        if (mip_mt_enable) then
          !c assign boundary volumes with MIP bubble source
          call mip_boundary_vols
          
          !c assign initial condition
          call mip_initial_cond

          !c output parameters
          if (.not.restart_sim) then
            call mip_output_params
          end if
        end if  

!c  release memory for the variables that will not be used anymore
        if (allocated(node_idx_g2lg)) then
          if (.not. restart_sim .and. .not.root_uptake) then
            call memory_monitor(-sizeof(node_idx_g2lg),'node_idx_g2lg',.true.)
            deallocate(node_idx_g2lg, stat = ierr)
            call checkerr(ierr,'node_idx_g2lg',ilog)
          end if
        end if

      end if
      
!cprovi---------------------------------------------------------------
!cprovi Init maximum size of rwork_max for flow and reactive transport
!cprovi---------------------------------------------------------------    

      if (i_solver_type_react == 0 .or. i_solver_type_flow == 0) then
          
          n_rwork_max = 0
          n_iwork_max = 0

          if(varsat_flow .or. steady_flow .or. fully_saturated) then
            n_rwork_max = 8*nngl
            n_iwork_max = nngl
          end if
      
          if (density_dependence.and.heat_transport) then
            n_rwork_max = max(n_rwork_max, 16*nngl)
            n_iwork_max = max(n_iwork_max, 2*nngl)
          end if
      
          if (reactive_transport) then
            n_rwork_max = max(n_rwork_max, 8*nngl*n)
            n_iwork_max = max(n_iwork_max, nngl*n)
          end if
      
          if (n_rwork_max > 0) then
            allocate(rwork_max(n_rwork_max), stat = ierr)
            rwork_max=0.0 
            call checkerr(ierr,'rwork_max',ilog)
            call memory_monitor(sizeof(rwork_max),'rwork_max',.true.)
          end if
      
          if (n_iwork_max > 0) then
            allocate(iwork_max(n_iwork_max), stat = ierr)
            iwork_max=0 
            call checkerr(ierr,'iwork_max',ilog)
            call memory_monitor(sizeof(iwork_max),'iwork_max',.true.)
          end if
          
      end if
      
#ifdef PETSC
      if(b_min3p_input_param_first) then
        if (i_solver_type_flow == 2) then
          if(heat_transport .and. decoupled_type_vs_heat <= 1) then
              if(level_glob >= 1) then
                pc_factor_shift_flow = "nonzero"
              end if
              rtol_flow = deltol_glob
              abstol_flow = restol_glob
              maxits_flow = msolvit_glob
          else
              if(level_vs >= 1) then
                pc_factor_shift_flow = "nonzero"
              end if
              rtol_flow = deltol_vs
              abstol_flow = restol_vs
              maxits_flow = msolvit_vs
          end if
        end if

        if (i_solver_type_react == 2) then
          if (level_rt >= 1) then
            pc_factor_shift_react = "nonzero"
          end if
          rtol_react = deltol_rt
          abstol_react = restol_rt
          maxits_react = msolvit_rt
        end if
      else
        if (i_solver_type_flow == 2) then
          if(heat_transport .and. decoupled_type_vs_heat <= 1) then
            deltol_glob = rtol_flow
            restol_glob = abstol_flow
            msolvit_glob = maxits_flow
          else
            deltol_vs = rtol_flow
            restol_vs = abstol_flow
            msolvit_vs = maxits_flow
          end if
        end if

        if (i_solver_type_react == 2) then
          deltol_rt = rtol_react
          restol_rt = abstol_react
          msolvit_rt = maxits_react
        end if

      end if
#endif

#ifdef LIS
      if(b_min3p_input_param_first) then
        if (i_solver_type_flow == 3) then
          lis_default_flow = .false.

          if(heat_transport .and. decoupled_type_vs_heat <= 1) then
            lis_abstol_flow = restol_glob
            lis_maxit_flow = msolvit_glob
            write(strbuffer,*) level_glob
          else
            lis_abstol_flow = restol_vs
            lis_maxit_flow = msolvit_vs
            write(strbuffer,*) level_vs
          end if
            
          lis_options_flow = trim(lis_options_flow)//      &
                             " -p ilu -ilu_fill "//        &
                             trim(strbuffer)  
                                          
          write(strbuffer,*) lis_abstol_flow               
          lis_options_flow = trim(lis_options_flow)//      &
                             " -tol "//trim(strbuffer) 
                                 
          write(strbuffer,*) lis_maxit_flow               
          lis_options_flow = trim(lis_options_flow)//      &
                             " -maxiter "//trim(strbuffer)
        end if
            
        if (i_solver_type_react == 3) then
          lis_default_react = .false.
          lis_abstol_react = restol_rt
          lis_maxit_react = msolvit_rt
          write(strbuffer,*) level_rt
          
          lis_options_react = trim(lis_options_react)//    &
                             " -p ilu -ilu_fill "//        &
                             trim(strbuffer)  
                                          
          write(strbuffer,*) lis_abstol_react               
          lis_options_react = trim(lis_options_react)//    &
                             " -tol "//trim(strbuffer) 
                                 
          write(strbuffer,*) lis_maxit_react               
          lis_options_react = trim(lis_options_react)//    &
                             " -maxiter "//trim(strbuffer)
        end if
      else
        if (i_solver_type_flow == 3) then
          if(heat_transport .and. decoupled_type_vs_heat <= 1) then
            deltol_glob = lis_abstol_flow
            restol_glob = lis_abstol_flow
            msolvit_glob = lis_maxit_flow
          else
            deltol_vs = lis_abstol_flow
            restol_vs = lis_abstol_flow
            msolvit_vs = lis_maxit_flow
          end if
        end if

        if (i_solver_type_react == 3) then
          deltol_rt = lis_abstol_react
          restol_rt = lis_abstol_react
          msolvit_rt = lis_maxit_react
        end if
      end if
#endif
    
        ! Do necessary synchronization here
#ifdef PETSC       
      call MPI_Allreduce(seepage_face, seepage_face_gbl,1,             &
                    MPI_LOGICAL,MPI_LOR,Petsc_Comm_World,ierrcode)
      CHKERRQ(ierrcode)
      seepage_face = seepage_face_gbl
#endif 

      !> Initialize mpi subarray output
      if (b_output_binary .and. b_output_mpiio_single .and. .not. b_output_multizone) then
        call binary_subarray_initialize
      end if

!c  close database backup file
      if (rank == 0) then
        if (.not. use_dbs_bk) then
          close(idbs_bk)
        end if
      end if

      return

999   continue

#ifdef PETSC
      call petsc_mpi_finalize
#endif
      stop

      end

