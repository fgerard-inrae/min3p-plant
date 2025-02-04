!*****Revision Informations Automatically Generated by VisualSVN*****!
!---------------------------------------------------------------------
!> $ID:$
!> $Revision: 875 $
!> $Author: dsu $
!> $Date: 2024-01-21 12:55:48 -0800 (Sun, 21 Jan 2024) $
!> $URL: https://min3psvn.ubc.ca/svn/min3p_thcm/branches/dsu_new_add_2024Jan/src/min3p/seepface.F90 $
!---------------------------------------------------------------------
!********************************************************************!

!c ----------------------------------------------------------------------
!c subroutine seepface
!c -------------------
!c
!c seepage face iteration control
!c
!c written by:      Danyang Su - Aug 04, 2016
!c
!c last modified:
!c
!c definition of variables:
!c
!c I --> on input   * arbitrary  - initialized  + entries expected
!c O --> on output  * arbitrary  - unaltered    + altered
!c                                                                    I O
!c passed:   -
!c
!c common:   
!c gen.f:    real*8:
!c           -------
!c           bcondvs(nbvs)      = boundary condition                  + +
!c                                (pressure head or flux) or
!c                                identification of seepage face
!c                                boundary type
!c           cinfvs(njavs)      = influence coefficients              + -
!c           hhead(nn)          = hydraulic head                      + +
!c           relperm(nn)        = relative permeability               + -
!c           uvsold(nn)         = solution vector (old time level)    + +
!c           uvsnew(nn)         = solution vector (new time level)    + +
!c           vsflux(ncon-1)     = interfacial fluxes                  * +
!c           zg(nn)             = spatial coordinates in z-direction  + -
!c
!c           integer*4:
!c           ---------- 
!c           iabvs(nbvs)        = pointer to boundary control volumes + -
!c                                for variably saturated flow
!c           javs(njavs)        = connectivity list                   + - 
!c           nn                 = total number of control volumes     + -
!c           nbvs               = number of specified boundary
!c                                control volumes
!c                                (variably saturated flow)
!c           nseep_first        = number of seepage face nodes        + -
!c
!c           logical:
!c           --------
!c           seep_iter          = .true.  -> continue seepage face    + +
!c                                           iteration 
!c           upstream           = .true.  -> upstream weighting       + -
!c
!c           character:
!c           ----------
!c           btypevs(nbvs)      = boundary type array                 + -
!c                                (variably saturated flow)
!c                                'first'   = Dirichlet
!c                                'second'  = Neumann
!c                                'seepage' = seepage face
!c           iups(ncon-1)       = upstream pointer array              * +
!c
!c local:    real*8:
!c           -------
!c           totvsflux          = total flux 
!c           r0                 = constant
!c           r1                 = constant
!c
!c           integer*4:
!c           ----------
!c           i1                 = counter (row entries)
!c           ibvs               = counter (boundary control volumes)
!c           icon               = pointer (connections - local)
!c           iend               = pointer (end of row)
!c           istart             = pointer (start of row)
!c           ivol               = counter (control volumes)
!c           jvol               = pointer
!c           not_matched        = number of nonconforming seepage 
!c                                face nodes
!c
!c external: fluxvs   = flux function for variably saturated flow       
!c ----------------------------------------------------------------------

      subroutine seepface

#ifdef PETSC
#include <petscversion.h>
#if (PETSC_VERSION_MAJOR >= 3 && PETSC_VERSION_MINOR >= 8)
#include <petsc/finclude/petscsys.h>
      use petscsys
#endif
#endif

      use parm
      use gen
      use phys, only : is_cell_based_relp
#ifdef OPENMP
      use omp_lib 
#endif

#ifdef USG
      use math_common
      use geometry
      use usg_mesh_data, only : num_edge_dvols,num_edge_maxcells
      use gradient_usg, only : gradient_cross_diff
      use usg_face_utility, only : usg_face_utility_cinfvs
      use mod_fluxvs_usg, only : fluxvs_usg
#endif
      implicit none
#ifdef PETSC
#if (PETSC_VERSION_MAJOR >= 3 && PETSC_VERSION_MINOR >= 6 && PETSC_VERSION_MINOR < 8)
#include <petsc/finclude/petscsys.h>
#elif (PETSC_VERSION_MAJOR >= 3 && PETSC_VERSION_MINOR < 6)
#include <finclude/petscsys.h>
#endif
#endif

      integer :: not_matched, ibvs, ivol, istart, iend, icon, i1, i2,  &
                 jvol
      real*8 :: totvsflux
      real*8, external :: fluxvs

#ifdef USG
      integer :: icell, idvol, kvol, ncell, ndvol, nrelp
      real*8 :: relps_loc(num_edge_maxcells)
      real*8 :: grad_weights(num_crossdifficv_max)
      real*8 :: flux_hls_corr(num_edge_dvols,num_edge_maxcells)
      type(point) :: grad_locs(num_crossdifficv_max),                  &
                     grad_flow_mids(num_edge_dvols,num_edge_maxcells)
      type(grad_hls_term) :: grad_flow_hls_loc(num_edge_dvols)
      real*8 :: cinfvs_usg_loc(num_edge_dvols,num_edge_maxcells)
      type(point) :: cinfvs_usg_cross_loc(num_edge_dvols,num_edge_maxcells)
#endif

#ifdef PETSC 
      integer :: not_matched_gbl, nseep_first_gbl
      PetscErrorCode :: ierrcode
#endif      

      real*8, parameter :: r0 = 0.0d0, r1 = 1.0d0, r2 = 2.0d0, r3 = 3.0d0

!c  reassign seepage face boundary condition
 
      not_matched = 0
      nseep_first = 0
#ifdef OPENMP
    !$omp parallel                                                    &
    !$omp if (nbvs > numofloops_thred_seepface_1)                     &
    !$omp num_threads(numofthreads_global)                            &
    !$omp default(shared)                                             &
    !$omp private (                                                   &
#ifdef USG
    !$omp icell, idvol, kvol, ncell, ndvol, nrelp, relps_loc,         &
    !$omp grad_locs, grad_weights,                                    &
    !$omp grad_flow_mids, flux_hls_corr, grad_flow_hls_loc,          &
    !$omp cinfvs_usg_loc, cinfvs_usg_cross_loc,                       &
#endif
    !$omp i1, ibvs, icon, iend, istart, ivol, jvol,                   &
    !$omp iups, totvsflux, vsflux, i2)                                &
    !$omp reduction(+:not_matched, nseep_first)
#endif

#ifdef OPENMP
#ifdef SCHEDULE_DYNAMIC
    !$omp do schedule(dynamic)
#elif SCHEDULE_STATIC
    !$omp do schedule(static)
#elif SCHEDULE_GUIDED
    !$omp do schedule(guided) 
#else
    !$omp do schedule(auto)
#endif
#endif 
      do ibvs = 1,nbvs             !loop over boundary control volumes

        if (compute_ice_sheet_loading) then
          if (.not. b_iabvs_ice(ibvs)) then
            cycle
          end if
        end if

!c  check only on seepage face boundary

        if (btypevs(ibvs).eq.'seepage' .or. &
            btypevs(ibvs).eq.'seepage-second') then  
          
          ivol = iabvs(ibvs)         !pointer to control volume
          if (ivol < 0) then
            cycle  
          end if
          
!#ifdef PETSC
!          if(node_idx_lg2l(ivol) < 0) then
!              cycle
!          end if
!#endif

!c  check, if seepage face too low and reassign if p>0

          if ((seepage_bits(ibvs).ge.2).and.(uvsnew(ivol).gt.r0)) then  
            !bcondvs(ibvs) = -r1
            seepage_bits(ibvs) = 1
            uvsnew(ivol) = r0
            uvsold(ivol) = r0
            hhead(ivol) = r0 + zg(ivol)
            not_matched = not_matched+1
            nseep_first = nseep_first+1    !sum up seepage face nodes
            
!#ifdef DEBUG
!            if(ivol == 14) then
!                write(idbg,*) "-->seepface hhead(ivol)", hhead(ivol)
!            end if
!#endif

!c  check, if seepage face too high and reassign if necessary,
!c  this is done by doing a mass balance on all seepage face 
!c  control volume with p=0, the zero pressure boundary condition
!c  is correct, if the change in mass is negative, i.e. outflow
!c  occurs over the boundary, if the change in mass is positive
!c  a zero flux boundary has to be assigned 
 
          elseif (seepage_bits(ibvs).eq.1) then

!c  calculate total flux

            istart = iavs(ivol)       !pointer - start of row 
            iend = iavs(ivol+1)-1     !pointer - end of row
            icon = 0                  !counter (connections)
            totvsflux = r0            !initialize total influx

            do i1=istart,iend         !loop over connections

              jvol = javs(i1)         !column pointer

#ifdef USG
              if (discretization_type > 0) then
                ncell = janumcell(i1)
              end if
#endif
        
              if (jvol.ne.ivol) then
                icon = icon+1         !counter (connections)
!c  consistent with upstream weighting 

                if (upstream) then
                  iups(icon) = 'i'                         !h_i >= h_j
                  if (hhead(jvol).gt.hhead(ivol)) then     !h_j > h_i
                    iups(icon) = 'j'
                  end if
                end if

                if (b_use_fixed_flow_vel) then
              
                  if (b_use_zero_flow_vel) then
                    vsflux(icon) = r0
                  else
                    !c TBD
                  end if
                
                else
#ifdef USG
!c  flux calculations
                  if (discretization_type > 0) then
!c calculate gradient at the middle of edge and along the control volume face,
!c this part can be further improved for better representation for a boundary volume
                    grad_flow_mids = vector_zero
                    flux_hls_corr = r0

                    if (b_use_cross_diffusion_flow) then
                      call gradient_cross_diff(i1,ivol,jvol,hhead,           &
                                    grad_locs,grad_flow_mids,                &
                                    grad_weights,flux_hls_corr,              &
                                    grad_flow_hls_loc)
                    end if

!cdsu calculate influence coefficient for variable saturated flow
                    call usg_face_utility_cinfvs(ivol,jvol,i1,cinfvs_usg_loc,&
                                                 cinfvs_usg_cross_loc)

                    relps_loc = 0.0d0
                    if (is_cell_based_relp) then
                      nrelp = ncell
                      do icell = 1, ncell
                        i2 = jacell(icell,i1)
                        if (i2 >0) then
                          relps_loc(icell) = relperm(i2)
                        end if
                      end do
                    else
                      nrelp = 2
                      relps_loc(1:2) = (/relperm(ivol),relperm(jvol)/)
                    end if

                    vsflux(icon) = -fluxvs_usg(upstream,hhead(ivol),           &
                                    hhead(jvol),num_edge_dvols,ncell,          &
                                    grad_flow_mids(1:num_edge_dvols,1:ncell),  &
                                    flux_hls_corr(1:num_edge_dvols,1:ncell),   &
                                    is_cell_based_relp,nrelp,                  &
                                    relps_loc(1:nrelp),iups(icon),             &
                                    cinfvs_usg_loc(1:num_edge_dvols,1:ncell),  &
                                    cinfvs_usg_cross_loc(1:num_edge_dvols,1:ncell))
                  else
#endif
                    vsflux(icon) = - fluxvs(upstream,hhead(ivol),        &
                                            hhead(jvol),relperm(ivol),   &
                                            relperm(jvol),iups(icon),    &
                                            cinfvs_a(i1))
#ifdef USG
                  end if
#endif
                end if

                totvsflux = totvsflux + vsflux(icon)

              end if                  !(ivol.eq.jvol)
            end do                    !loop over connections

            if (btypevs(ibvs).eq.'seepage') then
              if (totvsflux.gt.r0) then
                !bcondvs(ibvs) = r1             !set to zero flux
                seepage_bits(ibvs) = 2
                not_matched = not_matched+1
              else    
                nseep_first = nseep_first + 1  !sum up seepage face nodes
              end if
            else if (btypevs(ibvs).eq.'seepage-second') then
              if (totvsflux.gt.bcondvs(ibvs)) then
                !bcondvs(ibvs) = r1             !set to zero flux
                !c set bit position 2 to pause influx to avoid seepage fluctuation
                seepage_bits(ibvs) = 5
                not_matched = not_matched+1
              else    
                nseep_first = nseep_first + 1  !sum up seepage face nodes
              end if
            end if

          else if (ibits(seepage_bits(ibvs),2,1).eq.1) then
            nseep_first = nseep_first + 1      !sum up seepage face nodes
          end if                   !(p>0/p=0)
        end if                     !(seepage)
      end do                       !loop over boundary control volumes
#ifdef OPENMP
    !$omp end do
    !$omp end parallel
#endif     

#ifdef PETSC
      call MPI_Allreduce(not_matched, not_matched_gbl,1,               &
                MPI_INTEGER4,MPI_SUM, Petsc_Comm_World,ierrcode)
      CHKERRQ(ierrcode)
      not_matched = not_matched_gbl

      call MPI_Allreduce(nseep_first, nseep_first_gbl,1,               &
                MPI_INTEGER4,MPI_SUM, Petsc_Comm_World,ierrcode)
      CHKERRQ(ierrcode)
      nseep_first = nseep_first_gbl
          
#endif

!c  check for convergence of seepage face iteration

      if (not_matched.eq.0) then
        seep_iter = .false.
      end if
 
      return
      end 
