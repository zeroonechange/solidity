// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

contract MagicNum {

  address public solver;

  constructor() public {}

  function setSolver(address _solver) public {
    solver = _solver;
  }

  /*
    ____________/\\\_______/\\\\\\\\\_____        
     __________/\\\\\_____/\\\///////\\\___       
      ________/\\\/\\\____\///______\//\\\__      
       ______/\\\/\/\\\______________/\\\/___     
        ____/\\\/__\/\\\___________/\\\//_____    
         __/\\\\\\\\\\\\\\\\_____/\\\//________   
          _\///////////\\\//____/\\\/___________  
           ___________\/\\\_____/\\\\\\\\\\\\\\\_ 
            ___________\///_____\///////////////__
  */
}
 

/*
    偏移    指令对应字节   实际汇编指令
    0000    60            PUSH1 0x0a
    0002    60            PUSH1 0x0c
    0004    60            PUSH1 0x00
    0006    39            CODECOPY
    0007    60            PUSH1 0x0a
    0009    60            PUSH1 0x00
    000B    F3            RETURN
    000C    60            PUSH1 0x2a
    000E    60            PUSH1 0x50
    0010    52            MSTORE
    0011    60            PUSH1 0x20
    0013    60            PUSH1 0x50
    0015    F3            RETURN
    上述汇编代码对应字节序列是 602a60505260206050f3 正好10个opcode 

bytecode = '600a600c600039600a6000f3602a60505260206050f3'
await web3.eth.sendTransaction({from: player, data: bytecode})    
        -> contractAddress: "0x60Bc1A9771C3F8216FbB111497e06C91724b58dC"  去etherscan看合约代码 就是10个opcode
await contract.setSolver('0x60Bc1A9771C3F8216FbB111497e06C91724b58dC')
submit 
*/
     
 
