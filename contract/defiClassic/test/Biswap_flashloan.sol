// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.10;

import "forge-std/Test.sol";
import "./interfaces/IPancakePair.sol";
import "./interfaces/IWBNB.sol";
import "./interfaces/IERC20.sol";


// https://github.com/biswap-org/periphery/blob/main/contracts/examples/ExampleFlashSwap.sol
// 就是抄袭 uniswap v2 的代码  不要脸  函数名字都没怎么改变  shit  fuck 
contract Exploit is Test {
    IPancakePair wbnbBusdPair = IPancakePair(0xaCAac9311b0096E04Dfe96b6D87dec867d3883Dc);
    WBNB wbnb = WBNB(0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c);
    IERC20 busd = IERC20(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56);

    function setUp() public {
        vm.createSelectFork("https://rpc.ankr.com/bsc", 18671800);
    }

    function testBiswap_flashloan() public {
        (uint112 _reserve0, uint112 _reserve1,) = wbnbBusdPair.getReserves();
        console2.log("balance0:", _reserve0 / 1e18, "\t balance1:", _reserve1  / 1e18);
        // deal(address(wbnb), address(this), _reserve0*1/100);
        // deal(address(busd), address(this), _reserve1*1/100);
        wbnbBusdPair.swap(_reserve0 - 1, _reserve1 - 1, address(this), new bytes(1));
    }

    function BiswapCall(address sender, uint256 amount0, uint256 amount1, bytes calldata data) public {
        console2.log("After flashswap, WBNB balance of user:", wbnb.balanceOf(address(this)) / 1e18);
        console2.log("After flashswap, BUSD balance of user:", busd.balanceOf(address(this)) / 1e18);
        wbnb.transfer(address(wbnbBusdPair), wbnb.balanceOf(address(this)));
        busd.transfer(address(wbnbBusdPair), busd.balanceOf(address(this)));
        //No enough balance, of course failed
    }

    receive() external payable {}
}
