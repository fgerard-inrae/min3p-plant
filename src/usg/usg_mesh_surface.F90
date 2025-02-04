!*****Revision Informations Automatically Generated by VisualSVN*****!
!---------------------------------------------------------------------
!> $ID:$
!> $Revision: 826 $
!> $Author: dsu $
!> $Date: 2022-03-24 10:10:16 -0700 (Thu, 24 Mar 2022) $
!> $URL: https://min3psvn.ubc.ca/svn/min3p_thcm/branches/dsu_new_add_2024Jan/src/usg/usg_mesh_surface.F90 $
!---------------------------------------------------------------------
!********************************************************************!

!c ----------------------------------------------------------------------
!c module usg_mesh_surface
!c ----------------------
!c
!c Surface model based on unstructured mesh.
!c The following models are included: 
!c 1. icesheet fitting model
!c
!c written by:      Danyang Su - March. 24, 2020
!c
!c last modified:
!c
!c ----------------------------------------------------------------------
#ifdef USG
module usg_mesh_surface


  implicit none

  !>
  !> cell type of surface mesh
  !>
  integer :: cell_type_sn

  !>
  !> number of nodes per surface cell
  !>
  integer :: num_nodes_sn_per_cell

  !>
  !> number of ice sheet basal volume (surface node), local owned nodes
  !>
  integer :: num_nodes_sn_loc

  !>
  !> number of ice sheet basal volume (surface node), local and ghost nodes
  !>
  integer :: num_nodes_sn

  !>
  !> number of ice sheet basal volume (surface node) global mesh
  !>
  integer :: num_nodes_sn_gbl

  !>
  !> number of ice sheet basal cell (surface cells), local owned cells
  !>
  integer :: num_cells_sn_loc

  !>
  !> number of ice sheet basal cell (surface cells), local and ghost cells
  !>
  integer :: num_cells_sn

  !>
  !> number of ice sheet basal cell (surface cell) global mesh
  !>
  integer :: num_cells_sn_gbl

  !>
  !> number of node offset value
  !>
  integer :: offset_nodes_sn

  !>
  !> number of cell offset value
  !>
  integer :: offset_cells_sn

  !>
  !> number of local nodes owned by each processor, public to all processors
  !>
  integer, allocatable :: num_nodes_sn_rank(:)  

  !>
  !> number of local cells owned by each processor, public to all processors
  !>
  integer, allocatable :: num_cells_sn_rank(:)

  !>
  !> ice sheet basal node (surface node) to MIN3P local volume number with ghost node
  !>
  integer, allocatable :: node_idx_sn2lg(:)

  !>
  !> ice sheet basal node (surface node) to MIN3P global surface number with ghost node
  !> note: global surface number is in PETSc surface node ordering, not natural ordering
  !>
  integer, allocatable :: node_idx_sn2sg(:)

  !>
  !> ice sheet basal node (surface node) to MIN3P ice sheet boundary zone
  !>
  integer, allocatable :: node_idx_sn2bz(:)  

  !>
  !> MIN3P local volume number with ghost node to ice sheet basal node (surface node)
  !> Note: only the surface nodes are saved in this array.
  !> To get sn from ivol for inside nodes, please use 
  !> ivol_ln = node_to_layer_node(ivol) and ivol_sn = node_idx_ln2sn(ivol_ln) instead
  !>
  integer, allocatable :: node_idx_lg2sn(:)

  !>
  !> index of layer node (top surface) to ice sheet basal node (surface node)
  !>
  integer, allocatable :: node_idx_ln2sn(:)

  !>
  !> ice sheet basal cell (surface cell) to MIN3P local cell number with ghost cell
  !>
  integer, allocatable :: cell_idx_sn2lg(:)

  contains

  !>
  !>
  !>
  subroutine usg_mesh_surface_output()

    implicit none

    !c to be added

  end subroutine usg_mesh_surface_output

end module usg_mesh_surface
#endif
