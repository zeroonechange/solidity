// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Test.sol";

interface AggregatorV3Interface {
    function latestRoundData()
        external
        view
        returns (uint80 roundId, int256 answer, uint256 startedAt, uint256 updatedAt, uint80 answeredInRound);
}

// 获取最新价格走势 
contract ContractTest is Test {
    AggregatorV3Interface chainlink = AggregatorV3Interface(0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419);

    function setUp() public {
        vm.createSelectFork("https://eth-mainnet.g.alchemy.com/v2/qXFbrurfVJ5Le9N3T3HwEi8Wc06v0Ud3", 15327756);
    }

    function testgetLatestPrice() public {
        (uint80 roundID, int256 price, uint256 startedAt, uint256 timeStamp, uint80 answeredInRound) = chainlink.latestRoundData();
        console2.log(" roundID:", roundID);
        console2.log(" price:", price / 1e8);
        console2.log(" startedAt:", startedAt, "\t timeStamp:", timeStamp);
        console2.log(" answeredInRound:", answeredInRound);
    }
}
