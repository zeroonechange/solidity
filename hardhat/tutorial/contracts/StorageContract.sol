pragma solidity ^0.8.9;

import "hardhat/console.sol";

contract StorageContract {

    address private implementation;

    function setImplementation(address storageimplementation) external {
        implementation = storageimplementation;
    }

    function getImplementation() public view returns (address){
        return implementation;
    }

    fallback() external payable {
        console.log("executing fallback-------");
        delegate(implementation);
    }

    function delegate(address a) internal{
        assembly{
            calldatacopy(0, 0, calldatasize())

            let result := delegatecall(gas(), a, 0, calldatasize(), 0, 0)

            returndatacopy(0, 0, returndatasize())

            switch result
            case 0
            {
                revert(0, returndatasize())
            }
            default
            {
                return(0, returndatasize())
            }
        }
    }
}




