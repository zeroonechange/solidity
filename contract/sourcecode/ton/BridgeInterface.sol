pragma solidity ^0.8.0;
pragma experimental ABIEncoderV2;

import "./TonUtils.sol";


interface BridgeInterface is TonUtils {
    // 为了挖矿而投票
  function voteForMinting(SwapData memory data, Signature[] memory signatures) external;
  // 为了新的oracleset 投票 
  function voteForNewOracleSet(int oracleSetHash, address[] memory newOracles, Signature[] memory signatures) external;
  // 为了 切换销毁 投票
  function voteForSwitchBurn(bool newBurnStatus, int nonce, Signature[] memory signatures) external;
  event NewOracleSet(int oracleSetHash, address[] newOracles);
}