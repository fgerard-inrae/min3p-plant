!*****Revision Informations Automatically Generated by VisualSVN*****!
!---------------------------------------------------------------------
!> $ID:$
!> $Revision: 786 $
!> $Author: dsu $
!> $Date: 2021-01-06 21:41:32 -0800 (Wed, 06 Jan 2021) $
!> $URL: https://min3psvn.ubc.ca/svn/min3p_thcm/branches/dsu_new_add_2024Jan/src/min3p/compute_sensible.F90 $
!---------------------------------------------------------------------
!********************************************************************!

!cprovi----------------------------------------------------------------------
!cprovi subroutine sensible
!cprovi
!cprovi Compute sensible heat 
!cprovi----------------------------------------------------------------------
!subroutine compute_sensible (hs,temp_ivol,rh_ivol,area_ivol)

subroutine compute_sensible (temp_ivol,area_ivol,hs,rh_ivol)
 
  use parm
  use gen
  use phys
  use dens
  use chem
 
  implicit none

  real*8, intent(in)  :: temp_ivol

  real*8, intent(in)  :: area_ivol

  real*8, intent(out) :: hs

  real*8, intent(out) :: rh_ivol                     ! Aerodynamic resistance 

  real*8, parameter  :: r0 = 0.0d0, &
                        rhalf = 0.5d0, &
                        rquarter = 0.25d0, & 
                        r1 = 1.0d0, &
                        r2 = 2.0d0, &
                        r3 = 3.0d0, &
                        r5 = 5.0d0, &
                        r16 = 16.0d0, &
                        rkelvin = 273.15d0, &
                        rcte1 = 4.7d0, &
                        rcte2 = 0.6d0, &
                        r86400 = 86400.0d0, &
                        rsmall = 1.0d-2, &
                        rsmall1 = 1.0d-20, &
                        tol = 1.0d-5, &
                        pi=3.14159265359d0    
  integer, parameter :: itermax=50

  integer :: iter
  real*8 :: densg, error, hs_old, stabfac_m_atm, stabfac_hs_atm, dtemp,&
            stab_loc, term1, term2, term3, wind_sec,                   &
            wind_fric, wind_fric3

  real*8 :: mo
!cprovi------------------------------------------------------------------
!cprovi Initialice variables 
!cprovi------------------------------------------------------------------
  densg = densg_atm + densv_atm
  stabfac_m_atm = r0 
  stabfac_hs_atm = r0 
  dtemp = dabs(temp_atm - temp_ivol)
!cprovi------------------------------------------------------------------
!cprovi Compute the initial wind friction 
!cprovi------------------------------------------------------------------
  term1 = dlog(screen_atm/roughness_atm) 
  wind_sec = wind_atm/r86400
  wind_fric = wind_sec*cvkarman/term1
  iter = 0 
!cprovi------------------------------------------------------------------
!cprovi KJ / m2 / day => KJ / m2 / s
!cprovi Compute initial values
!cprovi------------------------------------------------------------------
  term1 = dlog((screen_atm+roughness_atm)/roughness_atm) 
  term2 = dlog((screen_atm+roughness_atm)/roughness_atm)

!cdsu bug here, it does not work if wind_sec or rh_ivol is zero, which is possible.
  !rh_ivol = term1*term2/(wind_sec*cvkarman*cvkarman)
  !hs = area_ivol*densg*heatcapa*(temp_atm - temp_ivol)/rh_ivol

!cdsu revised version
  if (wind_sec == r0) then
    wind_sec = rsmall1
  end if
  rh_ivol = term1*term2/(wind_sec*cvkarman*cvkarman)

  if (rh_ivol == r0) then
    rh_ivol = rsmall1
  end if
  hs = area_ivol*densg*heatcapa*(temp_atm - temp_ivol)/rh_ivol

!cprovi------------------------------------------------------------------
!cprovi Store the previous value
!cprovi------------------------------------------------------------------
  hs_old = hs
  tempk = rkelvin + temp_atm
!cprovi------------------------------------------------------------------
!cprovi Iterative process
!cprovi------------------------------------------------------------------
  do 
  
    iter = iter + 1 
   
    term1 = dlog(screen_atm/roughness_atm) + stabfac_m_atm 
    wind_fric = wind_sec*cvkarman/term1
    wind_fric3 = wind_fric*wind_fric*wind_fric
    mo = heatcapa*densg*tempk*wind_fric3  / ((hs*gacc*cvkarman)+rsmall1)
  
    stab_loc = screen_atm / mo 
    !cprovi------------------------------------------------------------------
    !cprovi------------------------------------------------------------------
    !cprovi------------------------------------------------------------------
    if (dtemp<=rsmall) then
      stabfac_m_atm = r0 
      stabfac_hs_atm = r0 
    else
      if (mo>r0) then  
        if (stab_loc>=r0.and.stab_loc<=r1) then 
          stabfac_m_atm = r5 * stab_loc
          stabfac_hs_atm = r5 * stab_loc  
        else 
          stabfac_m_atm = r5 
          stabfac_hs_atm = r5
        end if   
      else if (mo<r0) then
        term1 = r1 + (r1-r16*stab_loc)**rhalf
        term2 = r1 + (r1-r16*stab_loc)**rquarter
        term3 = (r1 - r16*stab_loc)**rquarter 
        stabfac_hs_atm = -r2 * dlog (term1/r2)       
        stabfac_m_atm = -r2 * dlog (term2/r2) - dlog (term1/r2) + r2 * datan(term3) - pi/r2
      end if  
    end if
    !cprovi------------------------------------------------------------------
    !cprovi------------------------------------------------------------------
    !cprovi------------------------------------------------------------------
    term1 = dlog((screen_atm+roughness_atm)/roughness_atm) + stabfac_m_atm
    term2 = dlog((screen_atm+roughness_atm)/roughness_atm) + stabfac_hs_atm
    !cprovi------------------------------------------------------------------
    !cprovi------------------------------------------------------------------
    !cprovi------------------------------------------------------------------
  
    !cdsu bug here, it does not work if wind_sec or rh_ivol is zero, which is possible.
    !rh_ivol = term1*term2/(wind_sec*cvkarman*cvkarman)
    !hs = area_ivol*densg*heatcapa*(temp_atm - temp_ivol)/rh_ivol 
  
    if (wind_sec == r0) then
      wind_sec = rsmall1
    end if
    rh_ivol = term1*term2/(wind_sec*cvkarman*cvkarman)
  
    if (rh_ivol == r0) then
      rh_ivol = rsmall1
    end if
    hs = area_ivol*densg*heatcapa*(temp_atm - temp_ivol)/rh_ivol 
   
    !cdsu bug here, it does not work if hs_old is zero, which is possible.
    !error = dabs((hs_old - hs)/hs_old)
    if (hs == hs_old) then
      error = r0
    else if (hs_old == r0) then
      error = dabs((hs_old - hs)/hs)
    else
      error = dabs((hs_old - hs)/hs_old)
    end if
   
    if (error<=tol.or.iter>itermax) exit 
    
    hs_old = hs 
  
  end do
!cprovi------------------------------------------------------------------
!cprovi Change units KJ / m2 / s => KJ / m2 / day
!cprovi------------------------------------------------------------------
  hs = r86400*hs
!cprovi------------------------------------------------------------------
!cprovi Change units of resiatance s/m => day/m
!cprovi------------------------------------------------------------------
  rh_ivol = rh_ivol/r86400 
!cprovi------------------------------------------------------------------
!cprovi------------------------------------------------------------------
!cprovi------------------------------------------------------------------
  return

end subroutine