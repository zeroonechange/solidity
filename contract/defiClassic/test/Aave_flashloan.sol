// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "forge-std/Test.sol";
import "./interfaces/IUSDT.sol";
import "./interfaces/ILendingPool.sol";
import "./interfaces/IERC20.sol";

/*
Running 1 test for test/Aave_flashloan.sol:ContractTest
[PASS] testAave_flashloan() (gas: 233632)
Logs:
  Before flashloan, balance of WBTC:: 2430000000
  After flashloan repaid, balance of WBTC:: 0

Test result: ok. 1 passed; 0 failed; finished in 21.88s*/
contract ContractTest is Test {
    using SafeMath for uint256;

    IERC20 WBTC = IERC20(0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599);  
    IERC20 DAI = IERC20(0x6B175474E89094C44Da98b954EedeAC495271d0F);
    USDT usdt = USDT(0xdAC17F958D2ee523a2206206994597C13D831ec7);

    ILendingPool aaveLendingPool = ILendingPool(0x7d2768dE32b0b80b7a3454c06BdAc94A69DDc7A9);

    address[] assets = [0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599];
                       //2700000000000
    uint256[] amounts = [2800000000000];
    uint256[] modes = [0];

    event Log(string message, uint256 val);

    function setUp() public {
        vm.createSelectFork("https://eth-mainnet.g.alchemy.com/v2/qXFbrurfVJ5Le9N3T3HwEi8Wc06v0Ud3", 15141656);
    }

    function testAave_flashloan() public {
        vm.prank(0x218B95BE3ed99141b0144Dba6cE88807c4AD7C09);
        WBTC.transfer(address(this), 1000000000000);
        
        console2.log("total usdt amout at pool", usdt.balanceOf(address(aaveLendingPool)));
        console2.log("total DAI amout at pool", DAI.balanceOf(address(aaveLendingPool)));
        console2.log("total WBTC amout at pool", WBTC.balanceOf(address(aaveLendingPool)));

        console2.log("Before flashloan, balance of WBTC:", WBTC.balanceOf(address(this)));
        aaveLendingPool.flashLoan(address(this), assets, amounts, modes, address(this), "0x", 0);
        console2.log("After flashloan repaid, balance of WBTC:", WBTC.balanceOf(address(this)));
    }

    function executeOperation(
        address[] memory assets,
        uint256[] memory amounts,
        uint256[] memory premiums,
        address initiator,
        bytes memory params
    ) public returns (bool) {
        assets;
        amounts;
        premiums;
        params;
        initiator;
        for (uint256 i = 0; i < assets.length; i++) {
            console2.log("borrowed", amounts[i]);
            console2.log("fee", premiums[i]);
            uint256 amountOwing = amounts[i].add(premiums[i]);
            WBTC.approve(address(aaveLendingPool), amountOwing);
        }
        return true;
    }

    receive() external payable {}
}
