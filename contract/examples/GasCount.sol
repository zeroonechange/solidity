pragma solidity ^0.4.24;
contract SimpleContract {
    function add() public pure returns (uint) {
        uint a = 1; 
        uint b = 2; 
        return (a+b);
    }
}