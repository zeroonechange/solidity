// SPDX-License-Identifier: UNLICENSED

pragma solidity >=0.7.0 <0.9.0;

import "forge-std/Test.sol";
import "./interfaces/IUSDT.sol";
import "./interfaces/IDVM.sol";

interface Token {
    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);
}

/*
[PASS] testDODO_flashloan() (gas: 110415)
Logs:
  FlashLoan wCRES Balance: 130000000000000000000000
  FlashLoan USDT Balance: 1100000000000
  After repay, wCRES Balance: 0
  After repay, USDT Balance: 0

Test result: ok. 1 passed; 0 failed; finished in 8.70s*/
contract ContractTest is Test {
    uint256 wCRES_amount = 130000000000000000000000;

    uint256 usdt_amount = 1100000000000;

    Token wCRES_token = Token(0xa0afAA285Ce85974c3C881256cB7F225e3A1178a);

    USDT usdt_token = USDT(0xdAC17F958D2ee523a2206206994597C13D831ec7);
    DVM dvm = DVM(0x051EBD717311350f1684f89335bed4ABd083a2b6);

    function setUp() public {
        vm.createSelectFork("https://eth-mainnet.g.alchemy.com/v2/qXFbrurfVJ5Le9N3T3HwEi8Wc06v0Ud3", 12000000);
    }

    function testDODO_flashloan() public {
        address me = address(this);
        dvm.flashLoan(wCRES_amount, usdt_amount, me, "whatever");

        //  emit log_named_uint("Exploit completed, WBNB Balance",wbnb.balanceOf(address(this)));
    }

    function DVMFlashLoanCall(address a, uint256 b, uint256 c, bytes memory d) public {
        emit log_named_uint("FlashLoan wCRES Balance", wCRES_token.balanceOf(address(this)));
        emit log_named_uint("FlashLoan USDT Balance", usdt_token.balanceOf(address(this)));
        wCRES_token.transfer(0x051EBD717311350f1684f89335bed4ABd083a2b6, wCRES_token.balanceOf(address(this)));
        usdt_token.transfer(0x051EBD717311350f1684f89335bed4ABd083a2b6, usdt_token.balanceOf(address(this)));
        emit log_named_uint("After repay, wCRES Balance", wCRES_token.balanceOf(address(this)));
        emit log_named_uint("After repay, USDT Balance", usdt_token.balanceOf(address(this)));
    }
}
