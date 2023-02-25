pragma solidity >=0.5.0;

import './../interfaces/IUniswapV2Pair.sol';
import "./SafeMath.sol";

library UniswapV2Library {
    using SafeMath for uint;

    // returns sorted token addresses, used to handle return values from pairs sorted in this order
    function sortTokens(address tokenA, address tokenB) internal pure returns (address token0, address token1) {
        require(tokenA != tokenB, 'UniswapV2Library: IDENTICAL_ADDRESSES');
        (token0, token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
        require(token0 != address(0), 'UniswapV2Library: ZERO_ADDRESS');
    }

    // calculates the CREATE2 address for a pair without making any external calls
    /**
     * 工厂地址  AB地址  获取 pair地址   因为用了 CREATE2  加了盐  和 nounce没关系  所以 地址是确定的  可以算出来  
     * @param factory 
     * @param tokenA 
     * @param tokenB 
     */
    function pairFor(address factory, address tokenA, address tokenB) internal pure returns (address pair) {
        (address token0, address token1) = sortTokens(tokenA, tokenB); //给俩个地址排序  
        pair = address(uint(keccak256(abi.encodePacked(
                hex'ff',
                factory,
                keccak256(abi.encodePacked(token0, token1)), // slat 
                hex'96e8ac4277198ff8b6f785478aa9a39f403cb768dd02cbee326c3e7da348845f' // init code hash
            ))));
    }

    // fetches and sorts the reserves for a pair
    // 
    function getReserves(address factory, address tokenA, address tokenB) internal view returns (uint reserveA, uint reserveB) {
        (address token0,) = sortTokens(tokenA, tokenB);
        // 根据工厂 俩个token地址 得到pair地址   然后得到池子中流动性的俩个token数量
        (uint reserve0, uint reserve1,) = IUniswapV2Pair(pairFor(factory, tokenA, tokenB)).getReserves();
        (reserveA, reserveB) = tokenA == token0 ? (reserve0, reserve1) : (reserve1, reserve0);
    }

    // given some amount of an asset and pair reserves, returns an equivalent amount of the other asset
    // 要放入A的数量   池子中A的数量  B的数量   --》 根据 放入A的数量  池子中AB数量  计算要放入B的数量 
    function quote(uint amountA, uint reserveA, uint reserveB) internal pure returns (uint amountB) {
        require(amountA > 0, 'UniswapV2Library: INSUFFICIENT_AMOUNT');
        require(reserveA > 0 && reserveB > 0, 'UniswapV2Library: INSUFFICIENT_LIQUIDITY');
        amountB = amountA.mul(reserveB) / reserveA;  // 
    }

    // given an input amount of an asset and pair reserves, returns the maximum output amount of the other asset
    // 拿多少A换  池子中A的数量  池子中B的数量   返回可以换到B的数量   
    //例如 amountIn=10   reserveIn=500  reserveOut=1000  ratio=A/B=0.5    amountOut=19.55
    //也就是说在一个A换2个B的情况下  拿10个A 能换到19.55个B token  
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) internal pure returns (uint amountOut) {
        require(amountIn > 0, 'UniswapV2Library: INSUFFICIENT_INPUT_AMOUNT');
        require(reserveIn > 0 && reserveOut > 0, 'UniswapV2Library: INSUFFICIENT_LIQUIDITY');
        uint amountInWithFee = amountIn.mul(997);   // 有 0.03%的费率    10*997=9,970
        uint numerator = amountInWithFee.mul(reserveOut);  // 9970*1000= 9,970,000
        uint denominator = reserveIn.mul(1000).add(amountInWithFee); // 500*1000+9,970=509,970
        amountOut = numerator / denominator;  //   9,970,000/509,970=19.55
    }

    // 根据要换多少目标token  确定要给多少token
    // given an output amount of an asset and pair reserves, returns a required input amount of the other asset
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) internal pure returns (uint amountIn) {
        require(amountOut > 0, 'UniswapV2Library: INSUFFICIENT_OUTPUT_AMOUNT');
        require(reserveIn > 0 && reserveOut > 0, 'UniswapV2Library: INSUFFICIENT_LIQUIDITY');
        uint numerator = reserveIn.mul(amountOut).mul(1000);
        uint denominator = reserveOut.sub(amountOut).mul(997);
        amountIn = (numerator / denominator).add(1);
    }

    // performs chained getAmountOut calculations on any number of pairs
    function getAmountsOut(address factory, uint amountIn, address[] memory path) internal view returns (uint[] memory amounts) {
        require(path.length >= 2, 'UniswapV2Library: INVALID_PATH'); // 这个path 应该是 [USDT, ETH]  USDT->ETH
        amounts = new uint[](path.length);
        amounts[0] = amountIn;  // 第一个为输入的数量
        for (uint i; i < path.length - 1; i++) {  
            //  根据工厂 俩个token地址 得到pair地址   然后得到池子中流动性的俩个token数量
            (uint reserveIn, uint reserveOut) = getReserves(factory, path[i], path[i + 1]); // 获取
            // 要换多少个  池子里俩个token的数量  ===> 可以换多少 
            amounts[i + 1] = getAmountOut(amounts[i], reserveIn, reserveOut);
        }
    }

    // performs chained getAmountIn calculations on any number of pairs
    // 根据最后想得到的token数量 逆推前面需要多少token 
    function getAmountsIn(address factory, uint amountOut, address[] memory path) internal view returns (uint[] memory amounts) {
        require(path.length >= 2, 'UniswapV2Library: INVALID_PATH');
        amounts = new uint[](path.length);
        amounts[amounts.length - 1] = amountOut;
        for (uint i = path.length - 1; i > 0; i--) {
            (uint reserveIn, uint reserveOut) = getReserves(factory, path[i - 1], path[i]);
            amounts[i - 1] = getAmountIn(amounts[i], reserveIn, reserveOut);
        }
    }
}
