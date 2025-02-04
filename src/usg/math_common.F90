!*****Revision Informations Automatically Generated by VisualSVN*****!
!---------------------------------------------------------------------
!> $ID:$
!> $Revision: 869 $
!> $Author: dsu $
!> $Date: 2023-08-18 09:44:21 -0700 (Fri, 18 Aug 2023) $
!> $URL: https://min3psvn.ubc.ca/svn/min3p_thcm/branches/dsu_new_add_2024Jan/src/usg/math_common.F90 $
!---------------------------------------------------------------------
!********************************************************************!


! --------------------------------------------------------------------
!> Module of mathematic functions
!>
!> Module description: common used mathematic functions
!>
!> Written by:    Danyang Su - Jan. 20, 2017
!>
!> Last modified:
!>
! --------------------------------------------------------------------
module math_common

  use geometry_definition

  implicit none

  interface math_common_harmonic
    module procedure math_common_harmonic_r
    module procedure math_common_harmonic_v
    module procedure math_common_harmonic_t
    module procedure math_common_harmonic_nr
    module procedure math_common_harmonic_nv
    module procedure math_common_harmonic_nt
  end interface math_common_harmonic

  interface math_common_arithmetic
    module procedure math_common_vec_arithmetic1
    module procedure math_common_vec_arithmetic2
    module procedure math_common_vec_arithmetic3
    module procedure math_common_tensor_arithmetic
  end interface math_common_arithmetic

  interface math_common_min
    module procedure math_common_vec_min1
    module procedure math_common_vec_min2
    module procedure math_common_tensor_min1
    module procedure math_common_tensor_min2
  end interface math_common_min

  interface math_common_max
    module procedure math_common_vec_max1
    module procedure math_common_vec_max2
  end interface math_common_max

  interface math_common_tensor_det
    module procedure math_common_tensor_det1
  end interface math_common_tensor_det

  interface operator(+)
    !> return the result of vector a add vector b
    procedure math_common_vec_add
    procedure math_common_vec_add_scalar
    procedure math_common_vec_add1d
    procedure math_common_vec_add2d
    procedure math_common_tensor_add
    procedure math_common_tensor_add_scalar
  end interface

  interface operator(-)
    !> return the result of vector a subtract vector b
    procedure math_common_vec_neg
    procedure math_common_vec_subtract
    procedure math_common_vec_subtract_scalar
    procedure math_common_vec_subtract1d
    procedure math_common_vec_subtract2d
    procedure math_common_tensor_subtract
    procedure math_common_tensor_subtract_scalar
  end interface

  interface operator(.dot.)
    !> return the result of vector a dot product vector b
    procedure math_common_vec_dot
    procedure math_common_tensor_dot
  end interface

  interface operator(.cross.)
    !> return the result of vector a cross product vector b
    procedure math_common_vec_cross
    procedure math_common_mat_vec_product
  end interface

  interface operator(.times.)
    !> return the result of vector a multiply vector b
    procedure math_common_vec_times
  end interface

  interface operator(*)
    !> return the result of vector times a scalar
    procedure math_common_vec_scale_i
    procedure math_common_vec_scale
    procedure math_common_vec_scale1d
    procedure math_common_vec_scale2d
    procedure math_common_tensor_scale_i
    procedure math_common_tensor_scale
  end interface

  interface operator(/)
    !> return the result of vector divided by a scalar
    procedure math_common_vec_divide_i
    procedure math_common_vec_divide
    procedure math_common_vec_divide1d
    procedure math_common_vec_divide2d
    procedure math_common_tensor_divide_i
    procedure math_common_tensor_divide
  end interface

  interface operator(==)
    !> return true if vector is equal
    procedure math_common_vector_eq
  end interface

  interface operator(/=)
    !> return true if vector is not equal
    procedure math_common_vector_neq
  end interface

  interface math_common_zero
    module procedure math_common_zero_vec
    module procedure math_common_zero_vecs
    module procedure math_common_zero_vecs2
  end interface

  contains

  !>
  !> determinant value of a given matrix size 4x4
  !> this function is converted from matlab det(A)
  !>
  function math_common_determinant(mat) result(det)

    implicit none

    real*8, intent(in) :: mat(4,4)
    real*8 :: det

    det = mat(1,1)*mat(2,2)*mat(3,3)*mat(4,4) -                        &
          mat(1,1)*mat(2,2)*mat(3,4)*mat(4,3) -                        &
          mat(1,1)*mat(2,3)*mat(3,2)*mat(4,4) +                        &
          mat(1,1)*mat(2,3)*mat(3,4)*mat(4,2) +                        &
          mat(1,1)*mat(2,4)*mat(3,2)*mat(4,3) -                        &
          mat(1,1)*mat(2,4)*mat(3,3)*mat(4,2) -                        &
          mat(1,2)*mat(2,1)*mat(3,3)*mat(4,4) +                        &
          mat(1,2)*mat(2,1)*mat(3,4)*mat(4,3) +                        &
          mat(1,2)*mat(2,3)*mat(3,1)*mat(4,4) -                        &
          mat(1,2)*mat(2,3)*mat(3,4)*mat(4,1) -                        &
          mat(1,2)*mat(2,4)*mat(3,1)*mat(4,3) +                        &
          mat(1,2)*mat(2,4)*mat(3,3)*mat(4,1) +                        &
          mat(1,3)*mat(2,1)*mat(3,2)*mat(4,4) -                        &
          mat(1,3)*mat(2,1)*mat(3,4)*mat(4,2) -                        &
          mat(1,3)*mat(2,2)*mat(3,1)*mat(4,4) +                        &
          mat(1,3)*mat(2,2)*mat(3,4)*mat(4,1) +                        &
          mat(1,3)*mat(2,4)*mat(3,1)*mat(4,2) -                        &
          mat(1,3)*mat(2,4)*mat(3,2)*mat(4,1) -                        &
          mat(1,4)*mat(2,1)*mat(3,2)*mat(4,3) +                        &
          mat(1,4)*mat(2,1)*mat(3,3)*mat(4,2) +                        &
          mat(1,4)*mat(2,2)*mat(3,1)*mat(4,3) -                        &
          mat(1,4)*mat(2,2)*mat(3,3)*mat(4,1) -                        &
          mat(1,4)*mat(2,3)*mat(3,1)*mat(4,2) +                        &
          mat(1,4)*mat(2,3)*mat(3,2)*mat(4,1)


  end function math_common_determinant

  !>
  !> calculate average of a given scalar array
  !>
  function math_common_ave(n, vals) result(ave)

    implicit none

    integer, intent(in) :: n
    real*8, intent(in) :: vals(n)
    real*8 :: ave

    !c local variables
    integer :: i

    ave = 0.0d0
    do i = 1, n
      ave = ave + vals(i)
    end do
    ave = ave / n

  end function math_common_ave

  !>
  !> calculate standard deviation of a given scalar array
  !>
  function math_common_stdev(n, vals) result(stdev)

    implicit none

    integer, intent(in) :: n
    real*8, intent(in) :: vals(n)
    real*8 :: stdev

    !c local variables
    integer :: i
    real*8 :: ave

    ave = math_common_ave(n, vals)
    stdev = 0.0d0
    do i = 1, n
      stdev = stdev + (vals(i)-ave)**2
    end do

    stdev = sqrt(stdev/n)

  end function math_common_stdev

  !>
  !> linear interpolation for general purpose
  !>
  function math_common_linear(t1,t2,v1,v2,t_in) result(v_out)

    implicit none

    real*8, intent(in) :: t1, t2, v1, v2, t_in
    real*8 :: v_out

    if (t1 == t2) then
      v_out = (v1+v2)*0.5d0
    else
      v_out = (t_in-t1)/(t2-t1)*(v2-v1)+v1
    end if

  end function math_common_linear

  !>
  !> harmonic mean for general purpose
  !>
  function math_common_harmonic_r(v1, v2) result(v_out)

    implicit none

    real*8, intent(in) :: v1, v2
    real*8 :: v_out

    !c local variables
    real*8, parameter :: r0 = 0.0d0, r2 = 2.0d0

    if (v1+v2 == r0) then
      v_out = r0
    else
      v_out = r2*v1*v2/(v1+v2)
    end if

  end function math_common_harmonic_r

  !>
  !> harmonic mean for general purpose
  !>
  function math_common_harmonic_nr(n,vn) result(v_out)

    implicit none

    integer, intent(in) :: n
    real*8, intent(in) :: vn(n)
    real*8 :: v_out

    !c local variables
    integer :: i
    real*8 :: rtemp
    real*8, parameter :: r0 = 0.0d0, r1 = 1.0d0

    rtemp = r0
    do i = 1, n
      if (vn(i) /= r0) then
        rtemp = rtemp + r1/vn(i)
      end if
    end do
    if (rtemp /= r0) then
      v_out = n/rtemp
    else
      v_out = r0
    end if

  end function math_common_harmonic_nr

  !>
  !> harmonic mean for general purpose
  !>
  function math_common_harmonic_v(v1, v2) result(v_out)

    implicit none

    type(point), intent(in) :: v1, v2
    type(point) :: v_out

    !c local variables
    real*8, parameter :: r0 = 0.0d0, r2 = 2.0d0

    if (v1%x+v2%x == r0) then
      v_out%x = r0
    else
      v_out%x = r2*v1%x*v2%x/(v1%x+v2%x)
    end if

    if (v1%y+v2%y == r0) then
      v_out%y = r0
    else
      v_out%y = r2*v1%y*v2%y/(v1%y+v2%y)
    end if

    if (v1%z+v2%z == r0) then
      v_out%z = r0
    else
      v_out%z = r2*v1%z*v2%z/(v1%z+v2%z)
    end if

  end function math_common_harmonic_v

    !>
  !> harmonic mean for general purpose
  !>
  function math_common_harmonic_nv(n, nv) result(v_out)

    implicit none

    integer, intent(in) :: n
    type(point), intent(in) :: nv(n)
    type(point) :: v_out

    !c local variables
    if (n > 0) then
      v_out%x = math_common_harmonic_nr(n,nv(:)%x)
      v_out%y = math_common_harmonic_nr(n,nv(:)%y)
      v_out%z = math_common_harmonic_nr(n,nv(:)%z)
    else
      v_out = vector_zero
    end if

  end function math_common_harmonic_nv

  !>
  !> harmonic mean for general purpose
  !>
  function math_common_harmonic_t(v1, v2) result(v_out)

    implicit none

    type(tensor), intent(in) :: v1, v2
    type(tensor) :: v_out

    !c local variables
    real*8, parameter :: r0 = 0.0d0, r2 = 2.0d0

    if (v1%xx+v2%xx == r0) then
      v_out%xx = r0
    else
      v_out%xx = r2*v1%xx*v2%xx/(v1%xx+v2%xx)
    end if

    if (v1%xy+v2%xy == r0) then
      v_out%xy = r0
    else
      v_out%xy = r2*v1%xy*v2%xy/(v1%xy+v2%xy)
    end if

    if (v1%xz+v2%xz == r0) then
      v_out%xz = r0
    else
      v_out%xz = r2*v1%xz*v2%xz/(v1%xz+v2%xz)
    end if

    if (v1%yx+v2%yx == r0) then
      v_out%yx = r0
    else
      v_out%yx = r2*v1%yx*v2%yx/(v1%yx+v2%yx)
    end if

    if (v1%yy+v2%yy == r0) then
      v_out%yy = r0
    else
      v_out%yy = r2*v1%yy*v2%yy/(v1%yy+v2%yy)
    end if

    if (v1%yz+v2%yz == r0) then
      v_out%yz = r0
    else
      v_out%yz = r2*v1%yz*v2%yz/(v1%yz+v2%yz)
    end if

    if (v1%zx+v2%zx == r0) then
      v_out%zx = r0
    else
      v_out%zx = r2*v1%zx*v2%zx/(v1%zx+v2%zx)
    end if

    if (v1%zy+v2%zy == r0) then
      v_out%zy = r0
    else
      v_out%zy = r2*v1%zy*v2%zy/(v1%zy+v2%zy)
    end if

    if (v1%zz+v2%zz == r0) then
      v_out%zz = r0
    else
      v_out%zz = r2*v1%zz*v2%zz/(v1%zz+v2%zz)
    end if

  end function math_common_harmonic_t

  !>
  !> harmonic mean for general purpose
  !>
  function math_common_harmonic_nt(n,nv) result(v_out)

    implicit none
    
    integer, intent(in) :: n
    type(tensor), intent(in) :: nv(n)
    type(tensor) :: v_out

    !c local variables

    v_out%xx = math_common_harmonic_nr(n,nv(:)%xx)
    v_out%xy = math_common_harmonic_nr(n,nv(:)%xy)
    v_out%xz = math_common_harmonic_nr(n,nv(:)%xz)

    v_out%yx = math_common_harmonic_nr(n,nv(:)%yx)
    v_out%yy = math_common_harmonic_nr(n,nv(:)%yy)
    v_out%yz = math_common_harmonic_nr(n,nv(:)%yz)

    v_out%zx = math_common_harmonic_nr(n,nv(:)%zx)
    v_out%zy = math_common_harmonic_nr(n,nv(:)%zy)
    v_out%zz = math_common_harmonic_nr(n,nv(:)%zz)

  end function math_common_harmonic_nt

  !>
  !> return arithmetic average of vectors
  !>
  function math_common_vec_arithmetic1(n, vecs) result(vec_ave)

    implicit none

    integer, intent(in) :: n
    type(point) :: vecs(n)
    type(point) :: vec_ave

    !c local variable
    integer :: i

    vec_ave = vector_zero
    do i = 1, n
      vec_ave = vec_ave + vecs(i)
    end do

    if (n > 0) then
      vec_ave = vec_ave/real(n,8)
    end if

  end function math_common_vec_arithmetic1

  !>
  !> return arithmetic average of vectors with spatial weighting
  !>
  function math_common_vec_arithmetic2(n, vecs, weights) result(vec_ave)

    implicit none

    integer, intent(in) :: n
    type(point) :: vecs(n)
    real*8 :: weights(n)
    type(point) :: vec_ave

    !c local variable
    integer :: i
    real*8 :: weight_tot

    vec_ave = vector_zero
    weight_tot = 0.0d0
    do i = 1, n
      vec_ave = vec_ave + vecs(i)*weights(i)
      weight_tot = weight_tot + weights(i)
    end do
    
    if (n > 0) then
      vec_ave = vec_ave/weight_tot
    end if

  end function math_common_vec_arithmetic2

  !>
  !> return arithmetic average of vectors
  !>
  function math_common_vec_arithmetic3(n1, n2, vecs) result(vec_ave)

    implicit none

    integer, intent(in) :: n1, n2
    type(point) :: vecs(n1,n2)
    type(point) :: vec_ave

    !c local variable
    integer :: i, j

    vec_ave = vector_zero
    do j = 1, n2
      do i = 1, n1
        vec_ave = vec_ave + vecs(i,j)
      end do
    end do

    vec_ave = vec_ave/real(n1*n2,8)

  end function math_common_vec_arithmetic3

  !>
  !> return arithmetic average of vectors
  !>
  function math_common_vec_min1(vec1,vec2) result(vec_min)

    implicit none

    type(point) :: vec1, vec2
    type(point) :: vec_min

    !c local variable
    real*8 :: vec_len1, vec_len2

    !c check if vector length is zero
    vec_len1 = vec1%x*vec1%x+vec1%y*vec1%y+vec1%z*vec1%z
    vec_len2 = vec2%x*vec2%x+vec2%y*vec2%y+vec2%z*vec2%z
    if (vec_len1 < vec_len2) then
      vec_min = vec1
    else
      vec_min = vec2
    end if

  end function math_common_vec_min1

  !>
  !> return arithmetic average of vectors
  !>
  function math_common_vec_min2(n, vecs) result(vec_min)

    implicit none

    integer, intent(in) :: n
    type(point) :: vecs(n)
    type(point) :: vec_min

    !c local variable
    integer :: i, j
    type(point) :: vec_loc
    real*8 :: vec_min_len, vec_len

    !c check if vector length is zero
    if (n > 0) then
      vec_min_len = vecs(1)%x*vecs(1)%x+vecs(1)%y*vecs(1)%y+vecs(1)%z*vecs(1)%z
      j = 1
      do i = 2, n
        vec_len = vecs(i)%x*vecs(i)%x+vecs(i)%y*vecs(i)%y+vecs(i)%z*vecs(i)%z
        if (vec_len < vec_min_len) then
          vec_min_len = vec_len
          j = i
        end if
      end do
      vec_min = vecs(j)
    else
      vec_min = vector_zero
    end if

  end function math_common_vec_min2

  !>
  !> return arithmetic average of vectors
  !>
  function math_common_vec_max1(vec1,vec2) result(vec_max)

    implicit none

    type(point) :: vec1, vec2
    type(point) :: vec_max

    !c local variable
    real*8 :: vec_len1, vec_len2

    !c check if vector length is zero
    vec_len1 = vec1%x*vec1%x+vec1%y*vec1%y+vec1%z*vec1%z
    vec_len2 = vec2%x*vec2%x+vec2%y*vec2%y+vec2%z*vec2%z
    if (vec_len1 > vec_len2) then
      vec_max = vec1
    else
      vec_max = vec2
    end if

  end function math_common_vec_max1

  !>
  !> return arithmetic average of vectors
  !>
  function math_common_vec_max2(n, vecs) result(vec_max)

    implicit none

    integer, intent(in) :: n
    type(point) :: vecs(n)
    type(point) :: vec_max

    !c local variable
    integer :: i, j
    type(point) :: vec_loc
    real*8 :: vec_max_len, vec_len

    !c check if vector length is zero
    if (n > 0) then
      vec_max_len = vecs(1)%x*vecs(1)%x+vecs(1)%y*vecs(1)%y+vecs(1)%z*vecs(1)%z
      j = 1
      do i = 2, n
        vec_len = vecs(i)%x*vecs(i)%x+vecs(i)%y*vecs(i)%y+vecs(i)%z*vecs(i)%z
        if (vec_len > vec_max_len) then
          vec_max_len = vec_len
          j = i
        end if
      end do
      vec_max = vecs(j)
    else
      vec_max = vector_zero
    end if

  end function math_common_vec_max2

  !>
  !> return arithmetic average of vectors
  !>
  function math_common_tensor_arithmetic(n, tensors) result(tensor_ave)

    implicit none

    integer, intent(in) :: n
    type(tensor) :: tensors(n)
    type(tensor) :: tensor_ave

    !c local variable
    integer :: i

    tensor_ave = tensor_zero
    do i = 1, n
      tensor_ave = tensor_ave + tensors(i)
    end do

    if (n > 0) then
      tensor_ave = tensor_ave/real(n,8)
    end if

  end function math_common_tensor_arithmetic

  !>
  !> return arithmetic average of vectors
  !>
  function math_common_tensor_min1(tensor1,tensor2) result(tensor_min)

    implicit none

    type(tensor) :: tensor1, tensor2
    type(tensor) :: tensor_min

    !c local variable
    real*8 :: tensor_det1, tensor_det2

    !c check if vector length is zero
    tensor_det1 = math_common_tensor_det1(tensor1)
    tensor_det2 = math_common_tensor_det1(tensor2)
    if (tensor_det1 < tensor_det2) then
      tensor_min = tensor1
    else
      tensor_min = tensor2
    end if

  end function math_common_tensor_min1

  !>
  !> return arithmetic average of vectors
  !>
  function math_common_tensor_min2(n,tensors) result(tensor_min)

    implicit none

    integer, intent(in) :: n
    type(tensor) :: tensors(n)
    type(tensor) :: tensor_min

    !c local variable
    integer :: i
    real*8 :: det_min, det_min2

    !c check if vector length is zero
    if (n > 0) then    
      det_min = math_common_tensor_det1(tensors(1))
      tensor_min = tensors(1)
    
      do i = 2, n
        det_min2 = math_common_tensor_det1(tensors(i))
        if (det_min2 < det_min) then
          det_min = det_min2
          tensor_min = tensors(i)
        end if
      end do
    else
      tensor_min = tensor_zero
    end if

  end function math_common_tensor_min2

  !>
  !> determinant of 3x3 matrix (tensor)
  !>
  function math_common_tensor_det1(tenf) result(det)

    implicit none

    type(tensor), intent(in) :: tenf
    real*8 :: det
    det = tenf%xx*(tenf%yy*tenf%zz-tenf%yz*tenf%zy) - &
          tenf%xy*(tenf%yx*tenf%zz-tenf%yz*tenf%zx) + &
          tenf%xz*(tenf%yx*tenf%zy-tenf%yy*tenf%zx)

  end function math_common_tensor_det1

  !>
  !> set zero value to vector
  !>
  subroutine math_common_zero_vec(a)

    implicit none

    type(point), intent(inout) :: a

    a%x = 0.0d0
    a%y = 0.0d0
    a%z = 0.0d0

  end subroutine math_common_zero_vec

  !>
  !> set zero value to vectors
  !>
  subroutine math_common_zero_vecs(a,n)

    implicit none

    integer, intent(in) :: n
    type(point), intent(inout) :: a(n)

    !c local variable
    integer :: i

    do i = 1, n
      a(i)%x = 0.0d0
      a(i)%y = 0.0d0
      a(i)%z = 0.0d0
    end do

  end subroutine math_common_zero_vecs

  !>
  !> set zero value to vectors
  !>
  subroutine math_common_zero_vecs2(a,n1,n2)

    implicit none

    integer, intent(in) :: n1, n2
    type(point),  intent(inout) :: a(n1,n2)

    !c local variable
    integer :: i, j

    do j = 1, n2
      do i = 1,n1
        a(i,j)%x = 0.0d0
        a(i,j)%y = 0.0d0
        a(i,j)%z = 0.0d0
      end do
    end do

  end subroutine math_common_zero_vecs2

  !>
  !> set value to vector
  !>
  function math_common_set_vector(x,y,z) result(pt)

    implicit none

    real*8, intent(in) :: x, y, z
    type(point) :: pt
    pt%x = x
    pt%y = y
    pt%z = z

  end function math_common_set_vector

  !>
  !> return the result of vector a add vector b
  !>
  function math_common_vec_add(a,b) result(addval)

    implicit none

    type(point), intent(in) :: a, b

    type(point) :: addval

    addval%x = a%x + b%x
    addval%y = a%y + b%y
    addval%z = a%z + b%z

  end function math_common_vec_add

  !>
  !> return the result of vector a add scalar b
  !>
  function math_common_vec_add_scalar(a,b) result(addval)

    implicit none

    type(point), intent(in) :: a
    real*8, intent(in) :: b

    type(point) :: addval

    addval%x = a%x + b
    addval%y = a%y + b
    addval%z = a%z + b

  end function math_common_vec_add_scalar  

  !>
  !> return the result of vector a add vector b
  !>
  function math_common_vec_add1d(a,b) result(addval)

    implicit none

    type(point), intent(in), dimension(:) :: a
    type(point), intent(in), dimension(size(a,1)) :: b
    type(point), dimension(size(a,1)) :: addval

    !c local variable
    integer :: i, n

    n = size(a,1)

    do i = 1, n
      addval(i)%x = a(i)%x + b(i)%x
      addval(i)%y = a(i)%y + b(i)%y
      addval(i)%z = a(i)%z + b(i)%z
    end do

  end function math_common_vec_add1d

  !>
  !> return the result of vector a add vector b
  !>
  function math_common_vec_add2d(a,b) result(addval)

    implicit none

    type(point), intent(in), dimension(:,:) :: a
    type(point), intent(in), dimension(size(a,1),size(a,2)) :: b
    type(point), dimension(size(a,1),size(a,2)) :: addval

    !c local variable
    integer :: i1, i2, n1, n2

    n1 = size(a,1)
    n2 = size(a,2)

    do i2 = 1, n2
      do i1 = 1, n1
        addval(i1,i2)%x = a(i1,i2)%x + b(i1,i2)%x
        addval(i1,i2)%y = a(i1,i2)%y + b(i1,i2)%y
        addval(i1,i2)%z = a(i1,i2)%z + b(i1,i2)%z
      end do
    end do

  end function math_common_vec_add2d

!>
  !> return the result of tensor a add tensor b
  !>
  function math_common_tensor_add(a,b) result(addval)

    implicit none

    type(tensor), intent(in) :: a, b

    type(tensor) :: addval

    addval%xx = a%xx + b%xx
    addval%xy = a%xy + b%xy
    addval%xz = a%xz + b%xz
    addval%yx = a%yx + b%yx
    addval%yy = a%yy + b%yy
    addval%yz = a%yz + b%yz
    addval%zx = a%zx + b%zx
    addval%zy = a%zy + b%zy
    addval%zz = a%zz + b%zz

  end function math_common_tensor_add

  !>
  !> return the result of tensor a add scalar b
  !>
  function math_common_tensor_add_scalar(a,b) result(addval)

    implicit none

    type(tensor), intent(in) :: a
    real*8, intent(in) :: b

    type(tensor) :: addval

    addval%xx = a%xx + b
    addval%xy = a%xy + b
    addval%xz = a%xz + b
    addval%yx = a%yx + b
    addval%yy = a%yy + b
    addval%yz = a%yz + b
    addval%zx = a%zx + b
    addval%zy = a%zy + b
    addval%zz = a%zz + b

  end function math_common_tensor_add_scalar

  !>
  !> return the result of vector a subtract vector b
  !>
  function math_common_vec_subtract(a,b) result(subval)

    implicit none

    type(point), intent(in) :: a, b

    type(point) :: subval

    subval%x = a%x - b%x
    subval%y = a%y - b%y
    subval%z = a%z - b%z

  end function math_common_vec_subtract

  !>
  !> return the result of vector a subtract scalar b
  !>
  function math_common_vec_subtract_scalar(a,b) result(subval)

    implicit none

    type(point), intent(in) :: a
    real*8, intent(in) :: b

    type(point) :: subval

    subval%x = a%x - b
    subval%y = a%y - b
    subval%z = a%z - b

  end function math_common_vec_subtract_scalar

  !>
  !> return the result of vector a subtract vector b
  !>
  function math_common_vec_subtract1d(a,b) result(subval)

    implicit none

    type(point), intent(in), dimension(:) :: a
    type(point), intent(in), dimension(size(a,1)) :: b
    type(point), dimension(size(a,1)) :: subval

    !c local variable
    integer :: i, n

    n = size(a,1)

    do i = 1, n
      subval(i)%x = a(i)%x - b(i)%x
      subval(i)%y = a(i)%y - b(i)%y
      subval(i)%z = a(i)%z - b(i)%z
    end do

  end function math_common_vec_subtract1d

  !>
  !> return the result of vector a subtract vector b
  !>
  function math_common_vec_subtract2d(a,b) result(subval)

    implicit none

    type(point), intent(in), dimension(:,:) :: a
    type(point), intent(in), dimension(size(a,1),size(a,2)) :: b
    type(point), dimension(size(a,1),size(a,2)) :: subval

    !c local variable
    integer :: i1, i2, n1, n2

    n1 = size(a,1)
    n2 = size(a,2)

    do i2 = 1, n2
      do i1 = 1, n1
      subval(i1,i2)%x = a(i1,i2)%x - b(i1,i2)%x
      subval(i1,i2)%y = a(i1,i2)%y - b(i1,i2)%y
      subval(i1,i2)%z = a(i1,i2)%z - b(i1,i2)%z
      end do
    end do

  end function math_common_vec_subtract2d

  !>
  !> return the result of tensor a subtract tensor b
  !>
  function math_common_tensor_subtract(a,b) result(subval)

    implicit none

    type(tensor), intent(in) :: a, b

    type(tensor) :: subval

    subval%xx = a%xx - b%xx
    subval%xy = a%xy - b%xy
    subval%xz = a%xz - b%xz
    subval%yx = a%yx - b%yx
    subval%yy = a%yy - b%yy
    subval%yz = a%yz - b%yz
    subval%zx = a%zx - b%zx
    subval%zy = a%zy - b%zy
    subval%zz = a%zz - b%zz

  end function math_common_tensor_subtract

  !>
  !> return the result of tensor a subtract scalar b
  !>
  function math_common_tensor_subtract_scalar(a,b) result(subval)

    implicit none

    type(tensor), intent(in) :: a
    real*8, intent(in) :: b

    type(tensor) :: subval

    subval%xx = a%xx - b
    subval%xy = a%xy - b
    subval%xz = a%xz - b
    subval%yx = a%yx - b
    subval%yy = a%yy - b
    subval%yz = a%yz - b
    subval%zx = a%zx - b
    subval%zy = a%zy - b
    subval%zz = a%zz - b

  end function math_common_tensor_subtract_scalar

  !>
  !> return the result of vector a dot product vector b
  !>
  function math_common_vec_dot(a,b) result(dotval)

    implicit none

    type(point), intent(in) :: a, b

    real*8 :: dotval

    dotval = a%x*b%x + a%y*b%y + a%z*b%z

  end function math_common_vec_dot

  !>
  !> return the result of tensor a dot product tensor b
  !>
  function math_common_tensor_dot(a,b) result(dotval)

    implicit none

    type(tensor), intent(in) :: a, b

    type(tensor) :: dotval

    dotval%xx = a%xx*b%xx+a%xy*b%yx+a%xz*b%zx
    dotval%xy = a%xx*b%xy+a%xy*b%yy+a%xz*b%zy
    dotval%xz = a%xx*b%xz+a%xy*b%yz+a%xz*b%zz

    dotval%yx = a%yx*b%xx+a%yy*b%yx+a%yz*b%zx
    dotval%yy = a%yx*b%xy+a%yy*b%yy+a%yz*b%zy
    dotval%yz = a%yx*b%xz+a%yy*b%yz+a%yz*b%zz

    dotval%zx = a%zx*b%xx+a%zy*b%yx+a%zz*b%zx
    dotval%zy = a%zx*b%xy+a%zy*b%yy+a%zz*b%zy
    dotval%zz = a%zx*b%xz+a%zy*b%yz+a%zz*b%zz

  end function math_common_tensor_dot

  !>
  !> return the dot product of a matrix and vector
  !>
  function math_common_mat_dot_vec(n,a,x) result(dotval)

    implicit none
    
    integer, intent(in) :: n
    real*8, intent(in) :: a(n,n), x(n)
    real*8 :: dotval(n)

    !c local variables
    integer :: i, j
    real*8, parameter :: r0 = 0.0d0

    dotval = r0

    !c method 1
    !do i = 1, n
    !  do j = 1, n
    !    dotval(i) = dotval(i) + a(i,j)*x(j)
    !  end do
    !end do

    !c method 2, more efficient in matrix and vector product
    do j = 1, n
      do i = 1, n
        dotval(i) = dotval(i) + a(i,j)*x(j)
      end do
    end do

  end function math_common_mat_dot_vec

  !>
  !> return the residual norm of linear solver
  !>
  function math_common_linear_norm(n,a,b,x) result(rnorm)

    implicit none
    
    integer, intent(in) :: n
    real*8, intent(in) :: a(n,n), b(n), x(n)
    real*8 :: rnorm

    !c local variables
    integer :: i, j
    real*8 :: rescurr, res(n)
    real*8, parameter :: r0 = 0.0d0
    
    rnorm = r0

    !c method 1
    !do i = 1, n
    !  rescurr = r0
    !  do j = 1, n
    !    rescurr = rescurr + a(i,j)*x(j)
    !  end do
    !  rescurr = rescurr - b(i)
    !  rnorm = rnorm + rescurr**2
    !end do
    !rnorm = sqrt(rnorm)

    !c method 2, more efficient in matrix and vector product
    res = math_common_mat_dot_vec(n,a,x)
    res = res - b
    do i = 1, n
      rnorm = rnorm + res(i)**2
    end do
    rnorm = sqrt(rnorm)

  end function math_common_linear_norm

  !>
  !> return the result of vector a cross product vector b
  !>
  function math_common_vec_cross(a,b) result(crossval)

    implicit none

    type(point), intent(in) :: a, b

    type(point) :: crossval

    crossval%x = a%y*b%z - a%z*b%y
    crossval%y = a%z*b%x - a%x*b%z
    crossval%z = a%x*b%y - a%y*b%x

  end function math_common_vec_cross

  !>
  !> return the result of vector times a scalar
  !>
  function math_common_vec_scale_i(a,i) result(tval)

    implicit none

    type(point), intent(in) :: a
    integer, intent(in) :: i

    type(point) :: tval

    tval%x = a%x*i
    tval%y = a%y*i
    tval%z = a%z*i

  end function math_common_vec_scale_i

  !>
  !> return the result of vector times a scalar
  !>
  function math_common_vec_scale(a,r) result(tval)

    implicit none

    type(point), intent(in) :: a
    real*8, intent(in) :: r

    type(point) :: tval

    tval%x = a%x*r
    tval%y = a%y*r
    tval%z = a%z*r

  end function math_common_vec_scale

  !>
  !> return the result of vector times a scalar
  !>
  function math_common_vec_scale1d(a,r) result(tval)

    implicit none

    type(point), intent(in), dimension(:) :: a
    real*8, intent(in) :: r

    type(point), dimension(size(a,1)) :: tval

    !c local variable
    integer :: i, n

    n = size(a,1)

    do i = 1, n
      tval(i)%x = a(i)%x*r
      tval(i)%y = a(i)%y*r
      tval(i)%z = a(i)%z*r
    end do

  end function math_common_vec_scale1d

  !>
  !> return the result of vector times a scalar
  !>
  function math_common_vec_scale2d(a,r) result(tval)

    implicit none

    type(point), intent(in), dimension(:,:) :: a
    real*8, intent(in) :: r

    type(point), dimension(size(a,1),size(a,2)) :: tval

    !c local variable
    integer :: i1, i2, n1, n2

    n1 = size(a,1)
    n2 = size(a,2)

    do i2 = 1, n2
      do i1 = 1, n1
        tval(i1,i2)%x = a(i1,i2)%x*r
        tval(i1,i2)%y = a(i1,i2)%y*r
        tval(i1,i2)%z = a(i1,i2)%z*r
      end do
    end do

  end function math_common_vec_scale2d

  !>
  !> return the result of tensor times a scalar
  !>
  function math_common_tensor_scale_i(a,i) result(tval)

    implicit none

    type(tensor), intent(in) :: a
    integer, intent(in) :: i

    type(tensor) :: tval

    tval%xx = a%xx*i
    tval%xy = a%xy*i
    tval%xz = a%xz*i
    tval%yx = a%yx*i
    tval%yy = a%yy*i
    tval%yz = a%yz*i
    tval%zx = a%zx*i
    tval%zy = a%zy*i
    tval%zz = a%zz*i

  end function math_common_tensor_scale_i

  !>
  !> return the result of tensor times a scalar
  !>
  function math_common_tensor_scale(a,r) result(tval)

    implicit none

    type(tensor), intent(in) :: a
    real*8, intent(in) :: r

    type(tensor) :: tval

    tval%xx = a%xx*r
    tval%xy = a%xy*r
    tval%xz = a%xz*r
    tval%yx = a%yx*r
    tval%yy = a%yy*r
    tval%yz = a%yz*r
    tval%zx = a%zx*r
    tval%zy = a%zy*r
    tval%zz = a%zz*r

  end function math_common_tensor_scale

  !>
  !> return the result of vector times a vector
  !>
  function math_common_vec_times(a, b) result(tval)

    implicit none

    type(point), intent(in) :: a, b

    type(point) :: tval

    tval%x = a%x*b%x
    tval%y = a%y*b%y
    tval%z = a%z*b%z

  end function math_common_vec_times

  !>
  !> return the result of vector times a scalar
  !>
  function math_common_vec_divide_i(a,i) result(dval)

    implicit none

    type(point), intent(in) :: a
    integer, intent(in) :: i

    type(point) :: dval

    dval%x = a%x/i
    dval%y = a%y/i
    dval%z = a%z/i

  end function math_common_vec_divide_i

  !>
  !> return the result of vector times a scalar
  !>
  function math_common_vec_divide(a,r) result(dval)

    implicit none

    type(point), intent(in) :: a
    real*8, intent(in) :: r

    type(point) :: dval

    dval%x = a%x/r
    dval%y = a%y/r
    dval%z = a%z/r

  end function math_common_vec_divide

  !>
  !> return the result of vector times a scalar
  !>
  function math_common_vec_divide1d(a,r) result(dval)

    implicit none

    type(point), intent(in), dimension(:) :: a
    real*8, intent(in) :: r

    type(point), dimension(size(a,1)) :: dval

    !c local variable
    integer :: i, n

    n = size(a,1)

    do i = 1, n
      dval(i)%x = a(i)%x/r
      dval(i)%y = a(i)%y/r
      dval(i)%z = a(i)%z/r
    end do

  end function math_common_vec_divide1d

  !>
  !> return the result of vector times a scalar
  !>
  function math_common_vec_divide2d(a,r) result(dval)

    implicit none

    type(point), intent(in), dimension(:,:) :: a
    real*8, intent(in) :: r

    type(point), dimension(size(a,1),size(a,2)) :: dval

    !c local variable
    integer :: i1, i2, n1, n2

    n1 = size(a,1)
    n2 = size(a,2)

    do i2 = 1, n2
      do i1 = 1, n1
        dval(i1,i2)%x = a(i1,i2)%x/r
        dval(i1,i2)%y = a(i1,i2)%y/r
        dval(i1,i2)%z = a(i1,i2)%z/r
      end do
    end do

  end function math_common_vec_divide2d

  !>
  !> return the result of tensor times a scalar
  !>
  function math_common_tensor_divide_i(a,i) result(dval)

    implicit none

    type(tensor), intent(in) :: a
    integer, intent(in) :: i

    type(tensor) :: dval

    dval%xx = a%xx/i
    dval%xy = a%xy/i
    dval%xz = a%xz/i
    dval%yx = a%yx/i
    dval%yy = a%yy/i
    dval%yz = a%yz/i
    dval%zx = a%zx/i
    dval%zy = a%zy/i
    dval%zz = a%zz/i

  end function math_common_tensor_divide_i

  !>
  !> return the result of tensor times a scalar
  !>
  function math_common_tensor_divide(a,r) result(dval)

    implicit none

    type(tensor), intent(in) :: a
    real*8, intent(in) :: r

    type(tensor) :: dval

    dval%xx = a%xx/r
    dval%xy = a%xy/r
    dval%xz = a%xz/r
    dval%yx = a%yx/r
    dval%yy = a%yy/r
    dval%yz = a%yz/r
    dval%zx = a%zx/r
    dval%zy = a%zy/r
    dval%zz = a%zz/r

  end function math_common_tensor_divide

  !>
  !> check if two vectors are equal
  !>
  function math_common_vector_eq(a,b) result(isequal)

    implicit none

    type(point), intent(in) :: a, b
    logical :: isequal

    if (a%x == b%x .and. a%y == b%y .and. a%z == b%z) then
      isequal = .true.
    else
      isequal = .false.
    end if

  end function math_common_vector_eq

  !>
  !> check if two vectors are not equal
  !>
  function math_common_vector_neq(a,b) result(isnotequal)

    implicit none

    type(point), intent(in) :: a, b
    logical :: isnotequal

    if (a%x == b%x .and. a%y == b%y .and. a%z == b%z) then
      isnotequal = .false.
    else
      isnotequal = .true.
    end if

  end function math_common_vector_neq

  !>
  !> return matrix vector product
  !>
  function math_common_mat_vec_product(mat,vec) result(mat_vec)

    implicit none

    type(tensor), intent(in) :: mat
    type(point), intent(in) :: vec
    type(point) :: mat_vec

    mat_vec%x = mat%xx*vec%x + mat%xy*vec%y + mat%xz*vec%z
    mat_vec%y = mat%yx*vec%x + mat%yy*vec%y + mat%yz*vec%z
    mat_vec%z = mat%zx*vec%x + mat%zy*vec%y + mat%zz*vec%z

  end function math_common_mat_vec_product

  !>
  !> return transpose of a matrix
  !>
  function math_common_tensor_transpose(a) result(a_t)

    implicit none

    type(tensor), intent(in) :: a
    type(tensor) :: a_t

    a_t%xx = a%xx
    a_t%xy = a%yx
    a_t%xz = a%zx
    a_t%yx = a%xy
    a_t%yy = a%yy
    a_t%yz = a%zy
    a_t%zx = a%xz
    a_t%zy = a%yz
    a_t%zz = a%zz

  end function math_common_tensor_transpose

  !>
  !> return the result of negative vector a
  !>
  function math_common_vec_neg(a) result(negval)

    implicit none

    type(point), intent(in) :: a

    type(point) :: negval

    negval%x = -a%x
    negval%y = -a%y
    negval%z = -a%z

  end function math_common_vec_neg

  !>
  !> convert a vector to a unit vector
  !>
  function math_common_vector_unit(vec) result(vec_unit)

    implicit none

    type(point), intent(in) :: vec
    type(point) :: vec_unit

    real*8, parameter ::rverysmall = 1.0d-30
    real*8 :: vec_len

    vec_len = sqrt(vec%x**2+vec%y**2+vec%z**2)

    if (vec_len < rverysmall) then
      call math_common_zero_vec(vec_unit)
    else
      vec_unit = vec / vec_len
    end if

  end function

end module math_common
