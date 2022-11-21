// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

interface Building {
  function isLastFloor(uint) external returns (bool);
}


contract Elevator {
  bool public top;
  uint public floor;

  function goTo(uint _floor) public {
    Building building = Building(msg.sender);

    if (! building.isLastFloor(_floor)) {  // 肯定是false 
      floor = _floor;
      top = building.isLastFloor(floor);  // 肯定是 true 
    }
  }
}

// 谁特么的把外部实现暴露出来  Building里面的东西是可以自己随便实现的
// 那么实例化这个东西后  调用了 isLastFloor   下次返回就改变了  
// A B  实例B  B.goTo()  B依赖A  很低级的东西  