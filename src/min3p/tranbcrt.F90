!*****Revision Informations Automatically Generated by VisualSVN*****!
!---------------------------------------------------------------------
!> $ID:$
!> $Revision: 875 $
!> $Author: dsu $
!> $Date: 2024-01-21 12:55:48 -0800 (Sun, 21 Jan 2024) $
!> $URL: https://min3psvn.ubc.ca/svn/min3p_thcm/branches/dsu_new_add_2024Jan/src/min3p/tranbcrt.F90 $
!---------------------------------------------------------------------
!********************************************************************!

!c ----------------------------------------------------------------------
!c subroutine tranbcrt  
!c ------------------- 
!c
!c update boundary conditions (reactive transport)
!c
!c written by:      Uli Mayer - October 19, 98
!c
!c last modified:   Tom Henderson - February 11, 2003
!c                  Sergi Molins - May 2, 2006 
!c                  added 'pn2', 'pch4', pco2', 'pco2x', 'par' 
!c                  Danyang Su    - February 18, 2015
!c
!c definition of variables:
!c
!c I --> on input   * arbitrary  - initialized  + entries expected
!c O --> on output  * arbitrary  - unaltered    + altered
!c                                                                    I O
!c passed:   logical:
!c           -------
!c common:
!c parm.inc: -
!c
!c gen.f:    real*8:
!c           -------
!c           bcondrt_a(nc,nbrt) = concentrations in boundary control  * +
!c                                volumes (aqueous phase)
!c                                first type b.c. -> free species 
!c                                                   concentrations
!c                                third type b.c. -> total aqueous
!c                                                   component
!c                                                   concentrations
!c           bcondrt_g(nc,nbrt) = concentrations in boundary control  * +
!c                                volumes (gaseous phase)
!c                                third type b.c. -> total gaseous
!c                                                   component
!c                                                   concentrations
!c           cnew(nc,nn)        = concentrations of free species      + -
!c                                - new time level [moles/l water]
!c           gbrt(ng,nbrt)      = gas concentrations in boundary      * +
!c                                control volumes
!c           time_io            = current solution time (I/O units)   + -
!c
!c           integer*4:
!c           ----------
!c           iabrt(nbzrt+1)     = pointer array - boundary conditions * +
!c                                (reactive transport)
!c           icnv               = unit number, data conversion and    + -
!c                                             temporary storage
!c           idat               = unit number, run specific input     + -
!c                                             file
!c           idbg               = unit number, debugging information  + -
!c           igen               = unit number, generic output file    + -
!c           ilog               = unit number, log book               + -
!c           itmp               = unit number, temporary storage      + -
!c           itsrc              = pointer to current target read      + -
!c                                time for boundary conditions        
!c                                (reactive transport)
!c           jabrt(nbrt)        = pointer array - boundary conditions * +
!c                                (reactive transport)
!c           l_prfx             = length of prefix of I/O files       + -
!c           l_zone_name        = length of zone name                 * +
!c           nbzrt              = number of boundary zones
!c                                (reactive transport)
!c
!c           logical:
!c           --------
!c           redox_equil_rt     = .true.  -> equilibrium redox        + -
!c                                           reactions
!c           tec_header         = .true.  -> write header for tecplot + -
!c                                           postprocessing to output
!c                                           files
!c                                .false. -> skip headers
!c
!c           character:
!c           ----------
!c           btypert(nn)        = type of boundary control volumes    * +
!c                                'first'  = Dirichlet
!c                                           (specified
!c                                            concentration)
!c                                'second' = Neumann
!c                                           (specified dispersive flux, 
!c                                            free mass outflux for aqueous
!c                                            phase, free exit)
!c                                'third'  = Cauchy
!c                                           (specified dispersive and advective flux, 
!c                                            for aqueous phase)
!c                                'third-evap'
!c                                         = Cauchy
!c                                           (specified advective
!c                                            mass influx for
!c                                            aqueous phase, for outflux,
!c                                            use closed boundary for transport,
!c                                            like evaporation)
!c                                'mixed'  = mixed
!c                                           (specified advective
!c                                            mass influx and
!c                                            free diffusive mass
!c                                            influx for aqueous
!c                                            phase and free
!c                                            diffusive mass influx
!c                                            for gaseous phase
!c                            'mixed-evap' = mixed-evap
!c                                           (specified advective
!c                                            mass influx and
!c                                            free diffusive mass
!c                                            influx for aqueous
!c                                            phase and gaseous phase,
!c                                            for outflux, use closed boundary
!c                                            for transport for aqueous phase,
!c                                            like evaporation)
!c           prefix             = prefix name for all I/O files       + -
!c           section_header     = section header                      * +
!c           time_unit          = time unit for output -> 'years'     + -
!c                                                        'days'
!c                                                        'hours'
!c                                                        'seconds'
!c           zone_name          = name of zone                        * +
!c           
!c
!c chem.f:   real*8:
!c           -------
!c           actv(nc)           = activities of free species          * +
!c                                - new time level
!c           ccnew(nc)          = concentrations of free species      + +
!c                                - new time level [moles/l water]
!c           ccold(nc)          = concentrations of free species      + +
!c                                - old time level [moles/l water]
!c           cgc(ng)            = gas concentrations                  * +
!c                                - new time level [moles/l air]
!c           cxc(nx)            = concentrations of secondary         * +
!c                                aqueous species
!c                                - new time level [moles/l water]
!c           delt_lc(nthreads)  = time step for local chemistry       * +
!c                                computations
!c           gamma_l(nc+nx)     = activity coefficients for aqueous   * *
!c                                species
!c           gfwc(nc)           = gram formula weight of components   + -
!c           phguess            = guess for pH                        * +
!c           tempk              = temperature [deg K]                 + -
!c           totcn(n,nthreads)  = total aqueous component             * +
!c                                concentrations
!c                                - new time level [moles/l water]
!c           totco(n,nthreads)  = total aqueous component             * +
!c                                concentrations
!c                                - old time level [moles/l water]
!c           totgn(n,nthreads)  = total gaseous component             * +
!c                                concentrations
!c                                - new time level [moles/l air]
!c
!c           integer*4:
!c           ----------
!c           l_namec(nc)        = length of component names           + -
!c           nbio               = number of biomass components        + -
!c           nc                 = number of components including h2o  + -
!c           ncorder(nc)        = ordering array for components       + -
!c                                ncorder(old order) = new order
!c           ng                 = number of gases                     + -
!c           nr                 = number of redox couples             + -
!c
!c           logical:
!c           --------
!c           reactive_minerals  = .true.  -> consider mineral         * +
!c                                           dissolution-
!c                                           precipitation reactions
!c           redox_equil_lc     = .true.  -> equilibrium reactions    + -
!c                                           for redox couples
!c
!c           character:
!c           ----------
!c           component_type(nc) = 'aqueous' = aqueous component       * +
!c                                'surface' = surface site
!c                                'biomass' = biomass
!c           ctype(nc-1)        = 'charge' = correct total aqueous    * +
!c                                           component concentration
!c                                           for specified component 
!c                                           to satisfy charge balance
!c                                'fixed'  = compute total aqueous
!c                                           component concentrations
!c                                           based on fixed activities
!c                                           of components as species
!c                                           in solution
!c                                'free'   = compute concentrations
!c                                           of components as species
!c                                           in solution based on 
!c                                           specified total aqueous
!c                                           component concentrations
!c                                'ph'    =  pH specified for 'h+1'
!c           input_units        = 'mol/l'                             + -
!c                                'mmol/l'
!c                                'mg/l'
!c                                'g/l'
!c           namec(nc)          = component names                     + -
!c
!c local:    real*8:
!c           -------
!c           porc               = porosity for local chemistry
!c                                calculations
!c           r1                 = constant
!c           r1000              = constant
!c           sgc                = gaseous phase saturation for local
!c                                chemistry calculations
!c           sac                = aqueous phase saturation for local
!c                                chemistry saturations
!c
!c           integer*4:
!c           ----------
!c           ibrt               = counter (boundary control volumes)
!c           ibrt_start         = start of current boundary zone
!c           ibrt_stop          = end of current boundary zone
!c           ibz                = counter (boundary zones)
!c           ic                 = counter (components)
!c           icount             = counter
!c           ig                 = counter (gases)
!c           itemp              = pointer
!c           ivol               = counter (control volumes)
!c           l_string           = length of text string
!c
!c           logical:
!c           --------
!c           found              = logical variable to exit search
!c           found_subsection   = .true.  -> subsection header was
!c                                           found in input file
!c
!c           character:
!c           ----------
!c           subsection         = name of subsection in input file
!c
!c external: comptotc  = compress concentration vector, if number
!c                       of unknowns is reduced due to redox
!c                       equilibrium reactions
!c           findstrg  = find text string in file
!c           findzone  = find zone in input section
!c           gcreact   = geochemical reactions for batch system
!c           guess     = guess for concentrations of
!c                       free species
!c           icbcrt    = assign initial or boundary condition
!c                       to global system (reactive transport)
!c           minmaxwd  = determine minimum total aqueous component
!c                       concentrations and maximum secondary aqueous
!c                       species concentration in solution domain
!c           outputlc  = write results of local chemistry
!c                       computations to generic output file
!c           readtime  = read section in input file for 
!c                       updating boundary conditions
!c           readzone  = read zone in section of input file and 
!c                       write to temporary file
!c           rtrvpprm  = retrieve physical parameters
!c           setsize   = define number of primary unknowns
!c           totconc   = compute total aqueous component
!c                       concentrations based on concentrations
!c                       of free species and secondary aqueous
!c                       species
!c           totconcg  = compute total gaseous component
!c                       concentrations based on concentrations
!c                       of gases
!c ----------------------------------------------------------------------
 
      subroutine tranbcrt(tid)
 
      use parm
      use gen
      use chem

#ifdef PETSC
      use petsc_mpi_common, only : petsc_mpi_finalize
#endif
      implicit none      
      
     
      integer :: tid, i, ibrt, ibrt_start, ibrt_stop, ibz, ic, icount, &
                 ig, itemp, ivol, iaq, itid, ierrcd, l_string
      real*8 ::  sac, sgc, porc
      real*8, external :: boundary_func
      
      logical found, found_subsection, bupdate_zone
      character*32 btypezn
      character*72 subsection

      external comptotc, findstrg, findzone, guess, gcreact,           &
               icbcrt, outputlc, minmaxwd,                             &
               rtrvpprm, setsize, totconc, totconcg, minmaxwd_mpi

      real*8, parameter :: r1 = 1.0d0, r1000 = 1.0d+3

      ierrcd = 0

      do ibz = 1,nbzrt                      !loop over number of zones  
          
        bupdate_zone = .false.
          
!c  find the time range
        if (transient_source) then 
          if (ibz == 1) then
!c  control parameters for processing initial condition for minerals
!c  only equilibrium for source chemistry
            reactive_minerals = .false.
            delt_lc(:) = r1       
!c  search for data for current target read time in input file
!c  and write data to temporary file
            call readtime(idat,itmp,ilog,itsrc,found)
          end if  
            
!c  read source chemistry data for current target read time          
!c  find current zone in input file and write to temporary file
          subsection = 'number and name of zone'

          call findzone(subsection,itmp,found_subsection,ibz,zone_name)

          if (found_subsection) then

            call readzone(itmp,icnv,ilog,zone_name,found_subsection)

!c  define length of zone name

            l_zone_name = index(zone_name,'  ')-1
            if (l_zone_name.lt.0.or.l_zone_name.gt.72) then
              l_zone_name = 72
            end if

!c  write current update information to generic output file
            if (b_enable_output .and. b_enable_output_gen) then
              write(igen,'(/72a)')('-',i=1,72)
              write(igen,'(a,1pe15.6e3,1x,a)')                         &
                    'updating boundary conditions, T = ',              &
                     time_io, time_unit                                    
              write(igen,'(72a)')('-',i=1,72)
            end if
                                                                      
!c  write header for boundary zone to generic output file
            if (b_enable_output .and. b_enable_output_gen) then                                                             
              write(igen,'(/a,i0,a,1x,a)') 'zone ',ibz,':',            &
                                           zone_name(:l_zone_name)
              write(igen,'(72a)')('-',i=1,72)
            end if

!c  concentration input for current zone
            if (rank == 0 .and. b_enable_output) then
              write(ilog,'(a/72a)') zone_name,('-',i=1,72)
            end if

!c  read boundary type for current zone
            subsection = 'boundary type'

            call findstrg(subsection,icnv,found_subsection)

            if (found_subsection) then
              read(icnv,*,err=999,end=999) btypezn
            else
              btypezn = ''
            end if

            if (btypezn.eq.'second') then
              !c no update is required for second type boundary condition
              if (b_enable_output .and. b_enable_output_gen) then
                write(igen,'(3a)') 'boundary type: ',trim(btypezn),    &
                      ', no update is required'
              end if
              exit
            else
              if (b_enable_output .and. b_enable_output_gen) then
                write(igen,'(2a)') 'boundary type: ',trim(btypezn)
              end if
            end if

!c  read concentration input for current zone
            subsection = 'concentration input'

            call findstrg(subsection,icnv,found_subsection)

            if (found_subsection) then

              do ic=1,nc-1

                itemp = ncorder(ic)                     !internal order

                if (component_type(itemp).eq.'aqueous'.or.             &
                    component_type(itemp).eq.'biomass') then

                  ierrcd = 1
                  read(icnv,*,err=999,end=999) totco(itemp,tid),       &
                       ctype(itemp)
                
                  totco(itemp,:) = totco(itemp,tid)

!c  -> convert input units to internal units [moles/l]

                if (ctype(itemp).ne.'ph'.and.     &
                    ctype(itemp).ne.'eh'.and.     &
                    ctype(itemp).ne.'pe'.and.     &
                    ctype(itemp).ne.'po2'.and.    &
                    ctype(itemp).ne.'pn2'.and.    &
                    ctype(itemp).ne.'pch4'.and.   &
                    ctype(itemp).ne.'ph2'.and.    &
                    ctype(itemp).ne.'pco2x'.and.  &
                    ctype(itemp).ne.'par'.and.    &
                    ctype(itemp).ne.'pco2') then
                    if (input_units.eq.'mmol/l') then
                      totco(itemp,:) = totco(itemp,:) / r1000
                    elseif (input_units.eq.'mg/l') then
                      totco(itemp,:) = totco(itemp,:) / r1000 /         &
                                       gfwc(itemp)
                    elseif (input_units.eq.'g/l') then
                      totco(itemp,:) = totco(itemp,:) / gfwc(itemp)
                    end if
                  end if
                end if              !component_type(itemp)
              end do                !loop over components
              
            else

              l_string = index(subsection,' ')-1
            
              if (rank == 0) then
                write(ilog,*) 'SIMULATION TERMINATED'
                write(ilog,*) 'error reading input file'
                write(ilog,*) 'section "',trim(section_header),'"'
                write(ilog,*) 'zone "', trim(zone_name),'"'
                write(ilog,*) 'subsection "',trim(subsection),'" missing'
                close(ilog)
              end if
#ifdef PETSC
              call petsc_mpi_finalize
#endif
              stop

            end if

!c  define guess for pH

            subsection = 'guess for ph'

            call findstrg(subsection,icnv,found_subsection)

            if (found_subsection) then
              ierrcd = 2
              read(icnv,*,err=999,end=999) phguess
            else
              phguess = 7.0d0
            end if
          
!c_bubbles - spatial dependent intra-aqueous scaling factors

            subsection = 'scaling for intra-aqueous kinetic reactions'

            call findstrg(subsection,icnv,found_subsection)

            if (found_subsection) then

              do iaq = 1,naq
                ierrcd = 3
                read(icnv,*,err=999,end=999) scalfac_aq(iaq)
              end do
            end if            
              
            bupdate_zone = .true.
            
          end if              !'number and name of zone'

        else if (transient_source_function) then
          if (b_update_zone_func(ibz)) then
            ctype(1:nc-1) = ctype_bzrt_init(1:nc-1,ibz)
            
            do ic = 1, nc-1
              totco(ic,tid) = boundary_func(6,totco_func(1:6,ic,ibz),  &
                                            time)
            end do
             
            do itid = 1, nthreads
              totco(1:nc-1,itid) = totco(1:nc-1,tid)
            end do

!c  define guess for pH 
            phguess = boundary_func(6,phguess_func(1:6,ibz),time)
         
!c_bubbles - spatial dependent intra-aqueous scaling factors
            do iaq = 1, naq
              scalfac_aq(1:naq) = boundary_func(6,                     &
                      scalfac_aq_func(1:6,iaq,ibz),time)
            end do
 
            bupdate_zone = .true. 
            
          end if
        end if        

        if (bupdate_zone) then            

!c  guess for concentrations of free species
            call guess(ccnew,ccold,tempk,ilog,tid)

!c  write input parameters for current zone to generic output file
            if (b_enable_output .and. b_enable_output_gen) then
                
              write(igen,'(/2a)') 'control parameters: ',zone_name
              write(igen,'(72a/)') ('-',i=1,72)
              
              write(igen,'(a/)') 'equilibration of aqueous species'
              
              write(igen,'(/2a)') 'input parameters: ',zone_name
              write(igen,'(72a)')('-',i=1,72)
              
              write(igen,'(/a)')'total aqueous component concentrations:'
              write(igen,'(a)')'---------------------------------------'
              write(igen,'(a)')'component             conc.'
              write(igen,'(a)')'---------------------------'
              do ic=1,nc-1
                if (component_type(ic).eq.'aqueous'.and.               &
                    ctype(ic).eq.'free') then
                  write(igen,'(a12,1x,1pe15.6e3)') namec(ic),totco(ic,tid)
                end if
              end do
              
              icount = 0
              do ic=1,nc-1
                if (ctype(ic).eq.'fixed') then
                  icount = icount+1
                  if (icount.eq.1) then
                    write(igen,'(/a)')'fixed activities:'
                    write(igen,'(a)')'------------------'
                    write(igen,'(a)')'species               actv.'
                    write(igen,'(a)')'---------------------------'
                  end if
                  write(igen,'(a12,1x,(1pe15.6e3))') namec(ic),actv(ic)
                end if
              end do
              
              do ic=1,nc-1
                if (ctype(ic).eq.'charge') then
                  write(igen,'(/3a)')'total aqueous component ',         &
                                     'concentrations of component ',     &
                                      namec(ic)(:l_namec(ic))              
                  write(igen,'(a)')'to be determined by charge balance'    
                end if                                                     
              end do
          
!c  biomass concentrations
          
              if (nbio.gt.0) then
                
                write(igen,'(/a)')'biomass concentrations:'
                write(igen,'(a)')'-----------------------'
                write(igen,'(a)')'component             conc.'
                write(igen,'(a)')'---------------------------'
                do ic=1,nc-1
                  if (component_type(ic).eq.'biomass'.and. &
                      ctype(ic).eq.'free') then
                    write(igen,'(a12,1x,(1pe15.6e3))') namec(ic),totco(ic,tid)
                  end if
                end do
                
              end if
        
!c  guess for pH                    
                                                                       
              write(igen,'(/a,f8.4)')                                    &
                   'guess for pH of solution:          pH =', phguess            
            end if

!c  set number of primary unknowns for current batch problem
            call setsize(redox_equil_lc)

!c  retrieve physical parameters for scaling

            section_header = 'boundary conditions - reactive transport'
            call rtrvpprm(sac,sgc,porc,r1,section_header)

!c  temperature correction
            if (temp_corr.or.heat_transport) then
              do itid = 1, nthreads
                call tcorr(tempk,0,itid)
              end do
            end if

!c  compute concentration distribution at boundary

            call gcreact(ccnew,ccold,cxc,gamma_l(1),gamma_l(nc+1),     &
                       cgc,sac,sgc,porc,igen,ilog,tid,idbg,tec_header, &
                       prefix,l_prfx,zone_name,l_zone_name,            &
                       mtime,i_append_sim,mtime_append)

!c  determine minimum total aqueous component concentrations and maximum
!c  secondary aqueous species concentration in solution domain

            call minmaxwd(cxc,totcn(:,tid))

!c  write results to generic output file
            if(b_enable_output .and. b_enable_output_gen)  then 
              call outputlc(ccnew,cxc,gamma_l(1),gamma_l(nc+1),        &
                            cgc,igen,ilog,tid,section_header)
            end if

!c  assign boundary condition to control volumes located in boundary zone

!c  write extent and type of boundary zone to generic output file
            if (b_enable_output .and. b_enable_output_gen) then              
              write(igen,'(/2a)') 'extent of ',zone_name(:l_zone_name)
              write(igen,'(72a/)')('-',i=1,72)
#ifdef PETSC  
              write(igen,'(2(a,3x),a/)') 'local volume',               &
                    'global volume','boundary type'
#else         
              write(igen,'(2x,a,3x,a/)') 'volume','boundary type'
#endif
            end if
          
            ibrt_start = iabrt(ibz)
            ibrt_stop = iabrt(ibz+1)-1
          
            if (b_enable_output .and. b_enable_output_gen) then 
          
              do ibrt = ibrt_start,ibrt_stop
                  
                ivol = jabrt(ibrt)             !pointer to control volume
                if (ivol < 0) then
                  cycle
                end if

                if (compute_ice_sheet_loading) then
                  if (.not. b_jabrt_ice(ibrt)) then
                    cycle
                  end if
                end if

#ifdef PETSC  
                write(igen,'(2(i10,5x),a16)') ivol,node_idx_lg2g(ivol),&
                                              btypert(ivol)
#else         
                write(igen,'(i8,3x,a16)') ivol,btypert(ivol)
#endif        
              end do
          
            end if

!c  assign boundary conditions to global system

            do ibrt = ibrt_start,ibrt_stop              !boundary zone
                
              ivol = jabrt(ibrt)             !pointer to control volume
              if (ivol < 0) then
                cycle
              end if

              if (compute_ice_sheet_loading) then
                if (.not. b_jabrt_ice(ibrt)) then
                  cycle
                end if
              end if

!c  first type boundary condition (background concentrations in terms
!c  of free species concentrations)

              if (btypert(ivol).eq.'first') then
              
                do ic = 1,nc
                  bcondrt_a(ic,ibrt) = ccnew(ic)
                end do
                call icbcrt(ivol,1,tid,.true.)

!c  third type boundary condition (specified source concentrations 
!c  in terms of total aqueous component concentrations)

!c  temporary treatment here THH 2/11/03

              elseif ((btypert(ivol).eq.'third').or.                   &
                      (btypert(ivol).eq.'third-evap').or.              &
                      (btypert(ivol).eq.'point')) then
              
!c  compute total aqueous component concentrations

                call totconc(ccnew,cxc,totcn(:,tid))

!c  compress total aqueous component concentration vector in case
!c  of redox equilibrium reactions

                if (redox_equil_rt.and.nr.gt.0) then
                  call comptotc(totcn(:,tid))
                end if

!c  assign boundary condition

                do ic=1,nc-1
                  bcondrt_a(ic,ibrt) = totcn(ic,tid)   !total aqueous component
                end do                                 !concentrations

!c  mixed type boundary condition (specified source concentrations 
!c  in terms of total aqueous component concentrations and total
!c  gaseous component concentrations, also assign gas concentrations
!c  for mass balance calculations)

              elseif (btypert(ivol).eq.'mixed' .or. btypert(ivol).eq.'mixed-evap') then

!c  compute total aqueous component concentrations

                call totconc(ccnew,cxc,totcn(:,tid))

!c  compress total aqueous component concentration vector in case
!c  of redox equilibrium reactions

                if (redox_equil_rt.and.nr.gt.0) then
                  call comptotc(totcn(:,tid))
                end if

!c  assign boundary condition

                do ic=1,nc-1
                  bcondrt_a(ic,ibrt) = totcn(ic,tid)   !total aqueous component
                end do                                 !concentrations

                if (ng.gt.0) then

!c  compute total gaseous component concentrations

                  call totconcg(cgc,totgn(:,tid))

!c  compress total gaseous component concentration vector in case
!c  of redox equilibrium reactions

                  if (redox_equil_rt.and.nr.gt.0) then
                    call comptotc(totgn(:,tid))
                  end if

!c  assign boundary condition

                  do ic=1,nc-1
                    bcondrt_g(ic,ibrt) = totgn(ic,tid) !total gaseous component
                  end do                               !concentrations
                  do ig = 1,ng
                    gbrt(ig,ibrt) = cgc(ig)        !gas concentrations
                  end do
                end if

              end if                               !boundary type

            end do                                 !boundary zone

       
        end if                                     !update boundary for zone

      end do                                       !number of zones

#ifdef PETSC
      call minmaxwd_mpi
#endif

!c  clear array ctype for transport calculations

      do ic = 1,nc-1
        ctype(ic) = 'free'
      end do

!c  save the updated boundary condition when ice loading is considered
      if (compute_ice_sheet_loading) then 
        bcondrt_a0 = bcondrt_a
      end if

      goto 1000

999   continue
!c  redefine length of section header

      if (rank == 0) then
        l_string = index(section_header,'  ')-1
        if (l_string.eq.-1.or.l_string.gt.72) then
           l_string=72
        end if
        
        write(ilog,*) 'SIMULATION TERMINATED'
        write(ilog,*) 'error reading input file, error code ', ierrcd
        write(ilog,*) 'section "',section_header(:l_string),'"'
        write(ilog,*) 'zone "', zone_name(:l_zone_name),'"'
        close(ilog)
      end if
#ifdef PETSC
      call petsc_mpi_finalize
#endif
      stop

1000  return
      end
