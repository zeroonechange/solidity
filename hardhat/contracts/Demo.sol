//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;
import "hardhat/console.sol";

contract Demo {
    event Error(string);
    fallback() external payable {
       console.log("---fallback---  Demo ");
      emit Error("call of a non-existent function");
    }
}