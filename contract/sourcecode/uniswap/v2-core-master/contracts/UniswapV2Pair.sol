pragma solidity =0.5.16;

import './interfaces/IUniswapV2Pair.sol';
import './UniswapV2ERC20.sol';
import './libraries/Math.sol';
import './libraries/UQ112x112.sol';
import './interfaces/IERC20.sol';
import './interfaces/IUniswapV2Factory.sol';
import './interfaces/IUniswapV2Callee.sol';

contract UniswapV2Pair is IUniswapV2Pair, UniswapV2ERC20 {
    using SafeMath  for uint;
    using UQ112x112 for uint224;

    uint public constant MINIMUM_LIQUIDITY = 10**3;
    bytes4 private constant SELECTOR = bytes4(keccak256(bytes('transfer(address,uint256)')));

    address public factory;
    address public token0;
    address public token1;

    uint112 private reserve0;           // uses single storage slot, accessible via getReserves
    uint112 private reserve1;           // uses single storage slot, accessible via getReserves
    uint32  private blockTimestampLast; // uses single storage slot, accessible via getReserves

    uint public price0CumulativeLast;
    uint public price1CumulativeLast;
    uint public kLast; // reserve0 * reserve1, as of immediately after the most recent liquidity event

    uint private unlocked = 1;

    //控制同步锁
    modifier lock() {
        require(unlocked == 1, 'UniswapV2: LOCKED');
        unlocked = 0;
        _;
        unlocked = 1;
    }

    function getReserves() public view returns (uint112 _reserve0, uint112 _reserve1, uint32 _blockTimestampLast) {
        _reserve0 = reserve0;
        _reserve1 = reserve1;
        _blockTimestampLast = blockTimestampLast;
    }

    function _safeTransfer(address token, address to, uint value) private {
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(SELECTOR, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'UniswapV2: TRANSFER_FAILED');
    }

    event Mint(address indexed sender, uint amount0, uint amount1);
    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    constructor() public {
        factory = msg.sender;
    }

    // called once by the factory at time of deployment
    function initialize(address _token0, address _token1) external {
        require(msg.sender == factory, 'UniswapV2: FORBIDDEN'); // sufficient check
        token0 = _token0;
        token1 = _token1;
    }

    // update reserves and, on the first call per block, price accumulators
    // balance 是 pair上的余额   是最新值   reserve是旧的 
    // 价格更新 加权平均价格 TWAP 
    function _update(uint balance0, uint balance1, uint112 _reserve0, uint112 _reserve1) private {
        require(balance0 <= uint112(-1) && balance1 <= uint112(-1), 'UniswapV2: OVERFLOW'); 
        // block.timestamp is a uint256 value in seconds since the epoch.
        uint32 blockTimestamp = uint32(block.timestamp % 2**32);  // Unix时间戳溢出32位 发生在 02/07/2106年
        uint32 timeElapsed = blockTimestamp - blockTimestampLast; // overflow is desired
        if (timeElapsed > 0 && _reserve0 != 0 && _reserve1 != 0) {
            // * never overflows, and + overflow is desired
            //  uint112 as a UQ112x112 
            // 采用二进制定点制进行编码和操作价格 UQ112.112 左右俩边112位表示精度 [0, 2^112-1]  这样就224位   剩余256-224=32位
            // 多出来的 32位 存储由于重复累计价格导致的溢出数据 
            price0CumulativeLast += uint(UQ112x112.encode(_reserve1).uqdiv(_reserve0)) * timeElapsed;  // 加权价格平均 
            price1CumulativeLast += uint(UQ112x112.encode(_reserve0).uqdiv(_reserve1)) * timeElapsed;
        }
        reserve0 = uint112(balance0);         // 更新池子里的token数量 
        reserve1 = uint112(balance1);
        blockTimestampLast = blockTimestamp;   // 记录最后一次的时间戳 
        emit Sync(reserve0, reserve1);         // 发送事件
    }

    // if fee is on, mint liquidity equivalent to 1/6th of the growth in sqrt(k)
    // 如果费用开启了 0.005% 给协议 
    function _mintFee(uint112 _reserve0, uint112 _reserve1) private returns (bool feeOn) {
        address feeTo = IUniswapV2Factory(factory).feeTo();
        feeOn = feeTo != address(0);
        uint _kLast = kLast; // gas savings
        if (feeOn) {
            if (_kLast != 0) {
                uint rootK = Math.sqrt(uint(_reserve0).mul(_reserve1));
                uint rootKLast = Math.sqrt(_kLast);
                if (rootK > rootKLast) {
                    uint numerator = totalSupply.mul(rootK.sub(rootKLast));
                    uint denominator = rootK.mul(5).add(rootKLast);
                    uint liquidity = numerator / denominator;
                    if (liquidity > 0) _mint(feeTo, liquidity);
                }
            }
        } else if (_kLast != 0) {
            kLast = 0;
        }
    }

    // this low-level function should be called from a contract which performs important safety checks
    // 
    function mint(address to) external lock returns (uint liquidity) {
        (uint112 _reserve0, uint112 _reserve1,) = getReserves(); // gas savings   流动性   还没更新 
        uint balance0 = IERC20(token0).balanceOf(address(this));  // 余额
        uint balance1 = IERC20(token1).balanceOf(address(this));  
        uint amount0 = balance0.sub(_reserve0);  // 差额  添加流动性前后差额
        uint amount1 = balance1.sub(_reserve1);

        bool feeOn = _mintFee(_reserve0, _reserve1);  // 协议费用  
        uint _totalSupply = totalSupply; // gas savings, must be defined here since totalSupply can update in _mintFee
        if (_totalSupply == 0) {  // 如果总供应量=0  就是池子里还没任何东西  
            liquidity = Math.sqrt(amount0.mul(amount1)).sub(MINIMUM_LIQUIDITY); // 流动性 = sqrt(ab) - 1000     防止 首次铸币攻击 
            // 首次铸币攻击是指攻击者在第一次添加流动性时存入最小单位（10的-18次方，即1 wei）的流动性，比如1 wei ABC和1 wei XYZ，此时将铸造1 wei 流动性代币（根号1）；
            // 同时，攻击者在同一个交易中继续向池子转入（非铸造）100万个ABC和100万个XYZ，接着调用 sync()方法更新缓存余额，
            // 此时1 wei的流动性代币价值100万+(10的-18次方)ABC和100万+(10的-18次方)XYZ，其他流动性参与者要想添加流动性，需要等价的大量代币，其价格可能高到大部分人无法参与。
           _mint(address(0), MINIMUM_LIQUIDITY); // permanently lock the first MINIMUM_LIQUIDITY tokens   直接 mint 1000个给 地址0  
        } else {
            // 根据俩种 token 的总比例 算出  取最小值 
            liquidity = Math.min(amount0.mul(_totalSupply) / _reserve0, amount1.mul(_totalSupply) / _reserve1);
        }
        require(liquidity > 0, 'UniswapV2: INSUFFICIENT_LIQUIDITY_MINTED');
        _mint(to, liquidity);  // 添加流动性   pair 其实也是一种 ERC20 token 

        _update(balance0, balance1, _reserve0, _reserve1);  // 更新 池子中的 reserve 数量    加权平均  记录时间戳 
        if (feeOn) kLast = uint(reserve0).mul(reserve1); // reserve0 and reserve1 are up-to-date   如果开启了协议费用 k值需要更新  重新算乘积
        emit Mint(msg.sender, amount0, amount1);  // 发送事件  
    }

    // this low-level function should be called from a contract which performs important safety checks
    // 加锁  去除流动性时    根据流动性计算该返回的token数量 
    function burn(address to) external lock returns (uint amount0, uint amount1) {
        (uint112 _reserve0, uint112 _reserve1,) = getReserves(); // gas savings
        address _token0 = token0;                                // gas savings
        address _token1 = token1;                                // gas savings
        uint balance0 = IERC20(_token0).balanceOf(address(this)); //获取最新余额 
        uint balance1 = IERC20(_token1).balanceOf(address(this));
        uint liquidity = balanceOf[address(this)]; //获取最新的流动性  因为burn之前就把LP的liquidity转到这个合约里面来了

        bool feeOn = _mintFee(_reserve0, _reserve1);
        uint _totalSupply = totalSupply; // gas savings, must be defined here since totalSupply can update in _mintFee
        // 根据流动性 和 余额 计算返还的 token 数量 
        amount0 = liquidity.mul(balance0) / _totalSupply; // using balances ensures pro-rata distribution
        amount1 = liquidity.mul(balance1) / _totalSupply; // using balances ensures pro-rata distribution
        require(amount0 > 0 && amount1 > 0, 'UniswapV2: INSUFFICIENT_LIQUIDITY_BURNED');
        _burn(address(this), liquidity); // 焚烧流动性 
        _safeTransfer(_token0, to, amount0); // 把 token 还给 LP
        _safeTransfer(_token1, to, amount1);
        balance0 = IERC20(_token0).balanceOf(address(this));  // 更新余额
        balance1 = IERC20(_token1).balanceOf(address(this));

        _update(balance0, balance1, _reserve0, _reserve1);
        if (feeOn) kLast = uint(reserve0).mul(reserve1); // reserve0 and reserve1 are up-to-date
        emit Burn(msg.sender, amount0, amount1, to);
    }

    // this low-level function should be called from a contract which performs important safety checks
    // 0, amountOut, pair(ETH,BNB), bytes[0]
    // pair(USDT,ETH).swap(0, amountOut, pair(ETH,BNB), bytes[0])
    // 这代码写的真精巧 
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external lock {
        require(amount0Out > 0 || amount1Out > 0, 'UniswapV2: INSUFFICIENT_OUTPUT_AMOUNT');
        (uint112 _reserve0, uint112 _reserve1,) = getReserves(); // gas savings   看看这个池子里还有多少liquidity
        require(amount0Out < _reserve0 && amount1Out < _reserve1, 'UniswapV2: INSUFFICIENT_LIQUIDITY');

        uint balance0;
        uint balance1;
        { // scope for _token{0,1}, avoids stack too deep errors
            address _token0 = token0;
            address _token1 = token1;
            require(to != _token0 && to != _token1, 'UniswapV2: INVALID_TO');
            if (amount0Out > 0) _safeTransfer(_token0, to, amount0Out); // optimistically transfer tokens    
            if (amount1Out > 0) _safeTransfer(_token1, to, amount1Out); // ETH token   从pair(USDT,ETH) 转给 pair(ETH,BNB)
            // 闪电贷的实现原理就是在这里  实现IUniswapV2Callee 接口  在里面写具体的逻辑
            // 在借到钱后  执行自己的逻辑  必须及时还   不然后面的 balance1Adjusted*balance1Adjusted >= _reserve0*_reserve1  对不上 
            if (data.length > 0) IUniswapV2Callee(to).uniswapV2Call(msg.sender, amount0Out, amount1Out, data); // 默认是空的    这里应该是闪电贷的起点  
            balance0 = IERC20(_token0).balanceOf(address(this));  // 转账后查询池子余额
            balance1 = IERC20(_token1).balanceOf(address(this));  // 这个余额减少 
        }

        // 这个时候 balance是最新的   reserve还没更新    reserve=100  balance=150  amountOut=0
        uint amount0In = balance0 > _reserve0 - amount0Out ? balance0 - (_reserve0 - amount0Out) : 0;  // 50 
        uint amount1In = balance1 > _reserve1 - amount1Out ? balance1 - (_reserve1 - amount1Out) : 0;
        require(amount0In > 0 || amount1In > 0, 'UniswapV2: INSUFFICIENT_INPUT_AMOUNT');
        { // scope for reserve{0,1}Adjusted, avoids stack too deep errors
            uint balance0Adjusted = balance0.mul(1000).sub(amount0In.mul(3));    // 为啥要这么写?   Adjustment for fee 手续费调整  
            // Uniswap的swap方法可以同时支持闪电贷和交易功能，当通过闪电贷同时借出x和y两种代币时，需要分别对x和y收取0.3%的手续费，因此需要先扣除手续费，再保证余额满足k值约束。 
            uint balance1Adjusted = balance1.mul(1000).sub(amount1In.mul(3));
            require(balance0Adjusted.mul(balance1Adjusted) >= uint(_reserve0).mul(_reserve1).mul(1000**2), 'UniswapV2: K'); // 保持常数K的恒定    闪电贷 
        }

        _update(balance0, balance1, _reserve0, _reserve1);  //更新池子中的流动性
        emit Swap(msg.sender, amount0In, amount1In, amount0Out, amount1Out, to);
    }

    // force balances to match reserves
    // 通货膨胀  将多余的流动性转给任何人   
    // Uniswap v2只支持缓存代币余额的最大值为(2的112次方)-1。该数字已经大到可以支持代币总量超过千万亿的18位小数代币。
    // 如果任意一种代币余额超过最大值，swap方法的调用将会失败（由于_update()方法的检查导致）。
    // 为了从这种状况中恢复，任何人都可以调用skim()方法来从池子中移除多余的代币。  
    function skim(address to) external lock {
        address _token0 = token0; // gas savings
        address _token1 = token1; // gas savings
        _safeTransfer(_token0, to, IERC20(_token0).balanceOf(address(this)).sub(reserve0));
        _safeTransfer(_token1, to, IERC20(_token1).balanceOf(address(this)).sub(reserve1));
    }

    // force reserves to match balances
    // 通缩    根据token 缓存余额  去更新流动性    
    function sync() external lock {
        _update(IERC20(token0).balanceOf(address(this)), IERC20(token1).balanceOf(address(this)), reserve0, reserve1);
    }
}
