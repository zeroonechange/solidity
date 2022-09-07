pragma solidity ^0.8.9;

import "hardhat/console.sol";

contract StorageImplementation{

    function add(uint256 a, uint256 b) public returns (uint256) {
        console.log("add function called");
        return a+b;
    }
    
    function hello() public returns (string memory){
        console.log("hello function called");
        return "hello";
    }
}
