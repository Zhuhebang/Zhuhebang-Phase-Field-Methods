!This file now is not used, it is a template for the future when
!specific charge distribution is necessary but defect is already
!used for other purposes
subroutine readChargeDistribution(filename, chargeDistribution)
    use mupro_double_precision
    implicit none
    character(len=8), intent(in) :: filename
    real(kind=rdp), intent(out), dimension(:, :, :) :: chargeDistribution

    if (.not. fileExist(trim(filename)//".in")) then
        message = "The"//filename//".in is missed. The program &
&            will go on without additional charge."
        call printWarning(message)
    else
        call inpuxN_P(filename, chargeDistribution)
    end if
end subroutine

subroutine setChargeDistribution(chargeDistribution)
    use mupro_double_precision
    implicit none
    real(kind=rdp), dimension(:, :, :), intent(out) :: chargeDistribution
    ! real(kind=rdp) ::
    integer i

    !select case()

end subroutine
