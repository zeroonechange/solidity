
contract Storage {
    uint64 a = 1;
    uint64 b = 2;
    uint128 c = 3;

    function getSlotNumbers() public view returns(uint256 slotA, uint256 slotB, uint256 slotC) {
        assembly {
            slotA := a.slot  // 0 
            slotB := b.slot // 0
            slotC := c.slot // 0 
        }
    }

    function getVariableOffsets() public view returns(uint256 offsetA, uint256 offsetB, uint256 offsetC) {
        assembly {
            offsetA := a.offset  // 0
            offsetB := b.offset  // 8
            offsetC := c.offset  // 16 
        }
    }
}