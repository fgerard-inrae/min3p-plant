!*****Revision Informations Automatically Generated by VisualSVN*****!
!---------------------------------------------------------------------
!> $ID:$
!> $Revision: 875 $
!> $Author: dsu $
!> $Date: 2024-01-21 12:55:48 -0800 (Sun, 21 Jan 2024) $
!> $URL: https://min3psvn.ubc.ca/svn/min3p_thcm/branches/dsu_new_add_2024Jan/src/min3p/serveParams.F90 $
!---------------------------------------------------------------------
!********************************************************************!

!c ----------------------------------------------------------------------
!c Module ServeParameters
!c ----------------
!c
!c Serve parameters that are required before or inside timeloop
!c 
!c
!c written by:      Danyang Su - Sept 11, 2023
!c
!c last modified:   
!c
!c
!c

      module serveParams

      implicit none

      contains

!c  initialize component-mineral recycle parameters
      subroutine serveParams_rcm_uptake

        use gen
        use biol

        implicit none

        integer :: itz

        ircm_tz_restart = .false.
        ircm_tz = 0
        if ((passive_uptake .or. root_uptake) .and. nrcm_tz > 0) then
          if (ircm_tz == 0) then
            do itz = 1, nrcm_tz
              if (time <= rcm_time(1,itz)) then
                ircm_tz = itz-1
                exit
              end if
            end do
            if (time > rcm_time(1,nrcm_tz) .and. time <= rcm_time(3,nrcm_tz)) then
              ircm_tz = nrcm_tz
            end if
            if (time > rcm_time(3,nrcm_tz)) then
              ircm_tz = nrcm_tz+1
            end if
          end if
        end if

      end subroutine serveParams_rcm_uptake


!c  initialize rate coefficient for intermittent reaction of minerals. 

      subroutine serveParams_irm

        use gen

        implicit none

        integer :: i, i1, im, iiz, niz, istart, iend, iskip

        if (flag_intermittent_react) then
          niz = size(iairm) - 1
          do iiz = 1, niz
            
            istart = iairt(iiz)
            iend = iairt(iiz+1)-1

            iskip = 0

            if (iend >= istart) then          
              if (time >= irt(iend)) then
                iskip = iend - istart + 1
              else if (time >= irt(istart)) then
                do i = istart, iend            
                  if (time >= irt(i)) then
                    iskip = iskip + 1
                  end if 
                end do
              end if
            end if

            if (iskip > 0) then
              istart = iairm(iiz)
              iend = iairm(iiz+1) - 1
              do i = istart, iend
                im = jairm(i)
                i1 = i - istart + iairc(iiz) + (iskip-1)*(iend-istart+1)
                imizn2irc(im,iiz) = irc(i1)
              end do
            end if
  
          end do
        end if

      end subroutine serveParams_irm   

     end module serveParams
