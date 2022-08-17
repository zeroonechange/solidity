// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Assembly{

    function addT(uint x, uint y) public pure returns (uint) {
        assembly{
            let result := add(x, y)
            mstore(0x00, result)
            return(0x00, 32)
        }
    }


}

