pragma solidity =0.6.6;

import './interfaces/IUniswapV2Factory.sol';
import './interfaces/IUniswapV2Router02.sol';
import './libraries/UniswapV2Library.sol';
import './libraries/TransferHelper.sol';
import './libraries/SafeMath.sol';
import './interfaces/IERC20.sol';
import './interfaces/IWETH.sol';

contract UniswapV2Router02 is IUniswapV2Router02 {
    using SafeMath for uint;

    address public immutable override factory;  // 工厂地址   用于生成 交易对 pair
    address public immutable override WETH;     // wrapper eth  包装 eth   因为eth不是标准的erc20 协议   
 
    modifier ensure(uint deadline) {
        require(deadline >= block.timestamp, 'UniswapV2Router: EXPIRED');
        _;
    }

    // 构造函数传入 工厂地址  和包装 eth 地址  默认是 0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f 
    // WETH  0xc02aaa39b223fe8d0a0e5c4f27ead9083c756cc2  
    constructor(address _factory, address _WETH) public {
        factory = _factory;
        WETH = _WETH;
    }

    // 只接受 WETH 发送过来的 ETH 
    receive() external payable {
        assert(msg.sender == WETH); // only accept ETH via fallback from the WETH contract
    }

    /**  添加流动性到池子里面  Router充当外围角色 
     * 为了覆盖所有场景 msg.sender 应该给予 router  权限 allowance 
     * 根据价格比率  ratio = A/B  去添加流动性 
     * 如果不存在 pair 对  会自动创建
     * 
     * 这个方法 根据 想放入的数量  最低数量  池子中的数量  算出应该放多少    如果没池子就创建   一个内部  internal 方法 
    */
    function _addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,  // 放多少 A token 进去
        uint amountBDesired,
        uint amountAMin,      // 如果B/A上升了 意味着B升值了 防止revert  这个时候少放点A就可以继续 要求 amountAMin <= amountADesired
        uint amountBMin
    ) internal virtual returns (uint amountA, uint amountB) {  // 返回 放入了多少 A  多少 B token 
        // create the pair if it doesn't exist yet
        if (IUniswapV2Factory(factory).getPair(tokenA, tokenB) == address(0)) {  // 那以后不需要在自己合约做这个事情了  直接调用router去添加流动性 节省gas费用吗?
            IUniswapV2Factory(factory).createPair(tokenA, tokenB);
        }
        (uint reserveA, uint reserveB) = UniswapV2Library.getReserves(factory, tokenA, tokenB); // 查询当前池里A和B的数量 
        if (reserveA == 0 && reserveB == 0) {
            (amountA, amountB) = (amountADesired, amountBDesired);  // 如果 是空池  直接返回比例  第一次添加流动性 
        } else { 
            uint amountBOptimal = UniswapV2Library.quote(amountADesired, reserveA, reserveB);   // 根据 放入A的数量  池子中AB数量  计算要放入B的数量 
            if (amountBOptimal <= amountBDesired) {  // 如果 要放入的B 小于 即将放入的  
                require(amountBOptimal >= amountBMin, 'UniswapV2Router: INSUFFICIENT_B_AMOUNT');   // >=  最低放入
                (amountA, amountB) = (amountADesired, amountBOptimal);  // 放入的数量 就是  以A为基准  算出的B  
            } else {    // 要放入的B 大于 即将放入的   那肯定是A太多了  处理A的逻辑
                uint amountAOptimal = UniswapV2Library.quote(amountBDesired, reserveB, reserveA);  // 根据B为基准 算出该放多少A 
                assert(amountAOptimal <= amountADesired);     // 这个数量 <= 想放入的   同时必须 >= 最低放入 
                require(amountAOptimal >= amountAMin, 'UniswapV2Router: INSUFFICIENT_A_AMOUNT');
                (amountA, amountB) = (amountAOptimal, amountBDesired);  // 最后以B为基准  算出的A  
            }
        }
    }

    /**
     * 这是个 external 方法  给外部调用  
     * ensure(deadline)   ==  deadline >= block.timestamp  最迟时间 大于 当前时间 
     */
    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external virtual override ensure(deadline) returns (uint amountA, uint amountB, uint liquidity) {
        (amountA, amountB) = _addLiquidity(tokenA, tokenB, amountADesired, amountBDesired, amountAMin, amountBMin);  // 根据参数 得到想放多少 token 
        address pair = UniswapV2Library.pairFor(factory, tokenA, tokenB);  // 获得pair 地址 
        TransferHelper.safeTransferFrom(tokenA, msg.sender, pair, amountA); // 将 token A 从msg.sender 转到 pair里面去   数量为amountA
        TransferHelper.safeTransferFrom(tokenB, msg.sender, pair, amountB);  
        liquidity = IUniswapV2Pair(pair).mint(to); // 得到流动性 
    }


    //Adds liquidity to an ERC-20⇄WETH pool with ETH
    // msg.value is treated as a amountETHDesired
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external virtual override payable ensure(deadline) returns (uint amountToken, uint amountETH, uint liquidity) {
        (amountToken, amountETH) = _addLiquidity(
            token,
            WETH,
            amountTokenDesired,
            msg.value,
            amountTokenMin,
            amountETHMin
        );
        address pair = UniswapV2Library.pairFor(factory, token, WETH);
        TransferHelper.safeTransferFrom(token, msg.sender, pair, amountToken);
        //   balanceOf[msg.sender] += msg.value;  为啥还要做这个?  先存后转账  应该是用户把WETH转给ROUTER 然后ROUTER转给pair 
        IWETH(WETH).deposit{value: amountETH}();  
        assert(IWETH(WETH).transfer(pair, amountETH)); // 转账给 pair 
        liquidity = IUniswapV2Pair(pair).mint(to);
        // refund dust eth, if any
        if (msg.value > amountETH) TransferHelper.safeTransferETH(msg.sender, msg.value - amountETH); 
    }

    // **** REMOVE LIQUIDITY ****
    // 这个方法返回给LP多少的token数量  burn方法中有转账逻辑 
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin, // The minimum amount of tokenA that must be received for the transaction not to revert.
        uint amountBMin,
        address to,
        uint deadline
    ) public virtual override ensure(deadline) returns (uint amountA, uint amountB) {
        address pair = UniswapV2Library.pairFor(factory, tokenA, tokenB);  // 得到pair地址  
        IUniswapV2Pair(pair).transferFrom(msg.sender, pair, liquidity); // send liquidity to pair
        (uint amount0, uint amount1) = IUniswapV2Pair(pair).burn(to); // 先把 LP的 liquidity 发送给pair  销毁的时候  根据这个去计算该返回的 token 数量  这里会不会有bug 
        (address token0,) = UniswapV2Library.sortTokens(tokenA, tokenB);
        (amountA, amountB) = tokenA == token0 ? (amount0, amount1) : (amount1, amount0);
        // 如果收到的 token 数量 比 预期的还低  那不玩了  revert 直接回滚  
        require(amountA >= amountAMin, 'UniswapV2Router: INSUFFICIENT_A_AMOUNT');
        require(amountB >= amountBMin, 'UniswapV2Router: INSUFFICIENT_B_AMOUNT');
    }

    //Removes liquidity from an ERC-20⇄WETH pool and receive ETH.
    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) public virtual override ensure(deadline) returns (uint amountToken, uint amountETH) {
        (amountToken, amountETH) = removeLiquidity(
            token,
            WETH,
            liquidity,
            amountTokenMin,
            amountETHMin,
            address(this),   // 第一次先转给自己  然后再转给用户 
            deadline
        );
        // 把token转给LP   前面调用了 removeLiquidity  不会重复转俩次吗？  上面那个地址是 address(this)
        TransferHelper.safeTransfer(token, to, amountToken); 
        // 先把 WETH 取出来 
        IWETH(WETH).withdraw(amountETH);  //只能接收WETH 
        // 然后转给 LP  不明白是如何从 ROUTER 转给LP的    to是 LP 地址 ？
        // 懂了  WETH 的问题   实际上是发送ETH  不是WETH 我的脑子啊  就说这个 call 方法是怎么发 WETH的   要尊重事实  别事先揣测 
        // 想通了 奖励自己一根烟  2023/2/24 18:21 
        //This function transfers ether to an account. 
        // Any call to a different contract can attempt to send ether. Because we don't need to actually call any function, we don't send any data with the call.
        TransferHelper.safeTransferETH(to, amountETH); //  to.call{value: amountETH}(new bytes(0));
        
        // 这个合约 的receive 方法   msg.sender 只能是 WETH
        // receive() external payable 
        // assert(msg.sender == WETH); // only accept ETH via fallback from the WETH contract
    }

    // Removes liquidity from an ERC-20⇄ERC-20 pool without pre-approval, thanks to permit.
    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, 
        uint8 v,  //  The v component of the permit signature.
        bytes32 r, // The r component of the permit signature.
        bytes32 s  // The s component of the permit signature
    ) external virtual override returns (uint amountA, uint amountB) {
        address pair = UniswapV2Library.pairFor(factory, tokenA, tokenB);
        uint value = approveMax ? uint(-1) : liquidity;  // 如果批准最大 -1 就是 (uint).MAX 
        //EIP-712 解决的主要问题是确保用户确切地知道他们正在签署什么，合约地址和网络，并且每个签名最多只能使用一次
        IUniswapV2Pair(pair).permit(msg.sender, address(this), value, deadline, v, r, s); // 批准LP的token给router2使用   这里牵涉到了EIP-712签名   
        (amountA, amountB) = removeLiquidity(tokenA, tokenB, liquidity, amountAMin, amountBMin, to, deadline);  // 直接转给 to 地址  
    }

    //Removes liquidity from an ERC-20⇄WETTH pool and receive ETH without pre-approval, thanks to permit.
    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external virtual override returns (uint amountToken, uint amountETH) {
        address pair = UniswapV2Library.pairFor(factory, token, WETH);
        uint value = approveMax ? uint(-1) : liquidity;
        IUniswapV2Pair(pair).permit(msg.sender, address(this), value, deadline, v, r, s);
        (amountToken, amountETH) = removeLiquidityETH(token, liquidity, amountTokenMin, amountETHMin, to, deadline);
    }

    // **** REMOVE LIQUIDITY (supporting fee-on-transfer tokens) ****
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) public virtual override ensure(deadline) returns (uint amountETH) {
        (, amountETH) = removeLiquidity(
            token,
            WETH,
            liquidity,
            amountTokenMin,
            amountETHMin,
            address(this),  //先转给自己 
            deadline
        );
        // 把token转给LP 
        TransferHelper.safeTransfer(token, to, IERC20(token).balanceOf(address(this)));
        // 提取ETH到这个账号来 
        IWETH(WETH).withdraw(amountETH);
        // 把ETH转给LP
        TransferHelper.safeTransferETH(to, amountETH);
    }

    // 不同的实现方法
    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external virtual override returns (uint amountETH) {
        address pair = UniswapV2Library.pairFor(factory, token, WETH);
        uint value = approveMax ? uint(-1) : liquidity;
        IUniswapV2Pair(pair).permit(msg.sender, address(this), value, deadline, v, r, s);
        amountETH = removeLiquidityETHSupportingFeeOnTransferTokens(
            token, liquidity, amountTokenMin, amountETHMin, to, deadline
        );
    }

    // **** SWAP ****
    // requires the initial amount to have already been sent to the first pair
    // 已经把token转给第一个pair合约了  然后转给第二个  再第三个 如此往复 
    function _swap(uint[] memory amounts, address[] memory path, address _to) internal virtual {
        for (uint i; i < path.length - 1; i++) {  
            (address input, address output) = (path[i], path[i + 1]); // 合约对  例如 (USDT,ETH)
            (address token0,) = UniswapV2Library.sortTokens(input, output); // 排序
            // amounts[0] = amountIn  第一个是输入的USDT数量  第二个是换到的ETH数量  第三个是能换到的BNB数量 
            uint amountOut = amounts[i + 1];  //早就计算好的 能够拿到多少token  能拿多少 ETH
            (uint amount0Out, uint amount1Out) = input == token0 ? (uint(0), amountOut) : (amountOut, uint(0));  
            // 如果不是最后  那么就获取pair合约地址  否则就是接收者地址   妙啊  这个三目运算    
            // 这个 pair合约变成了 (ETH,BNB) 
            address to = i < path.length - 2 ? UniswapV2Library.pairFor(factory, output, path[i + 2]) : _to;  
            // 0, amountOut, pair(ETH,BNB), bytes[0]
            // pair(USDT,ETH).swap(0, amountOut, pair(ETH,BNB), bytes[0])
            // 把 ETH 发送给 pair(ETH,BNB)  更新pair(USDT,ETH)的流动性数值 
            IUniswapV2Pair(UniswapV2Library.pairFor(factory, input, output)).swap(
                amount0Out, amount1Out, to, new bytes(0)
            );
        }
    }

    // msg.sender should have already given the router an allowance of at least amountIn on the input token.
    function swapExactTokensForTokens(
        uint amountIn,          //要换多少
        uint amountOutMin,      //最低多少
        address[] calldata path, //swap路径  必须存在且有流动性  比如 USDT->ETH->BNB   这是前端传进来的 
        address to,              //接收者
        uint deadline
    ) external virtual override ensure(deadline) returns (uint[] memory amounts) {
        amounts = UniswapV2Library.getAmountsOut(factory, amountIn, path);  // 这个amounts 存了每次swap可以换多少token  
        require(amounts[amounts.length - 1] >= amountOutMin, 'UniswapV2Router: INSUFFICIENT_OUTPUT_AMOUNT');
        // token=path[0]  from=msg.sender  to=UniswapV2Library.pairFor(factory, path[0], path[1])   value=amouts[0]
        // 把第一个token转给 pair合约   转了USDT给 pair合约(USDT,ETH) 
        TransferHelper.safeTransferFrom(
            path[0], msg.sender, UniswapV2Library.pairFor(factory, path[0], path[1]), amounts[0]
        );
        _swap(amounts, path, to);  
    }

    function swapTokensForExactTokens(
        uint amountOut,   // The amount of output tokens to receive.  想要多少token  和上面是逆着来的 
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external virtual override ensure(deadline) returns (uint[] memory amounts) {
        amounts = UniswapV2Library.getAmountsIn(factory, amountOut, path);
        require(amounts[0] <= amountInMax, 'UniswapV2Router: EXCESSIVE_INPUT_AMOUNT');
        TransferHelper.safeTransferFrom(
            path[0], msg.sender, UniswapV2Library.pairFor(factory, path[0], path[1]), amounts[0]
        );
        _swap(amounts, path, to);
    }

    // 用WETH 换取其他token  用多少去换是确定的 根据 msg.value 来决定   WETH -> xxx -> XXX  第一个必须是 WETH   
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        virtual
        override
        payable
        ensure(deadline)
        returns (uint[] memory amounts)
    {
        require(path[0] == WETH, 'UniswapV2Router: INVALID_PATH');
        amounts = UniswapV2Library.getAmountsOut(factory, msg.value, path);
        require(amounts[amounts.length - 1] >= amountOutMin, 'UniswapV2Router: INSUFFICIENT_OUTPUT_AMOUNT');
        IWETH(WETH).deposit{value: amounts[0]}();
        assert(IWETH(WETH).transfer(UniswapV2Library.pairFor(factory, path[0], path[1]), amounts[0]));
        _swap(amounts, path, to);
    }

    //用其他 token 换取 WETH 换多少是确定的
    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
        external
        virtual
        override
        ensure(deadline)
        returns (uint[] memory amounts)
    {
        require(path[path.length - 1] == WETH, 'UniswapV2Router: INVALID_PATH');
        amounts = UniswapV2Library.getAmountsIn(factory, amountOut, path);
        require(amounts[0] <= amountInMax, 'UniswapV2Router: EXCESSIVE_INPUT_AMOUNT');
        TransferHelper.safeTransferFrom(
            path[0], msg.sender, UniswapV2Library.pairFor(factory, path[0], path[1]), amounts[0]
        );
        _swap(amounts, path, address(this));
        IWETH(WETH).withdraw(amounts[amounts.length - 1]);
        TransferHelper.safeTransferETH(to, amounts[amounts.length - 1]);
    }

    // 用其他 token 换取 WETH    用多少去换是确定的 
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        virtual
        override
        ensure(deadline)
        returns (uint[] memory amounts)
    {
        require(path[path.length - 1] == WETH, 'UniswapV2Router: INVALID_PATH');
        amounts = UniswapV2Library.getAmountsOut(factory, amountIn, path);
        require(amounts[amounts.length - 1] >= amountOutMin, 'UniswapV2Router: INSUFFICIENT_OUTPUT_AMOUNT');
        TransferHelper.safeTransferFrom(
            path[0], msg.sender, UniswapV2Library.pairFor(factory, path[0], path[1]), amounts[0]
        );
        _swap(amounts, path, address(this));
        IWETH(WETH).withdraw(amounts[amounts.length - 1]);
        TransferHelper.safeTransferETH(to, amounts[amounts.length - 1]);
    }

    // 用 WETH 换取其他 token  换多少是确定的
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        virtual
        override
        payable
        ensure(deadline)
        returns (uint[] memory amounts)
    {
        require(path[0] == WETH, 'UniswapV2Router: INVALID_PATH');
        amounts = UniswapV2Library.getAmountsIn(factory, amountOut, path);
        require(amounts[0] <= msg.value, 'UniswapV2Router: EXCESSIVE_INPUT_AMOUNT');
        IWETH(WETH).deposit{value: amounts[0]}();
        assert(IWETH(WETH).transfer(UniswapV2Library.pairFor(factory, path[0], path[1]), amounts[0]));
        _swap(amounts, path, to);
        // refund dust eth, if any
        if (msg.value > amounts[0]) TransferHelper.safeTransferETH(msg.sender, msg.value - amounts[0]);
    }

    // **** SWAP (supporting fee-on-transfer tokens) ****
    // requires the initial amount to have already been sent to the first pair
    function _swapSupportingFeeOnTransferTokens(address[] memory path, address _to) internal virtual {
        for (uint i; i < path.length - 1; i++) {
            (address input, address output) = (path[i], path[i + 1]);
            (address token0,) = UniswapV2Library.sortTokens(input, output);
            IUniswapV2Pair pair = IUniswapV2Pair(UniswapV2Library.pairFor(factory, input, output));
            uint amountInput;
            uint amountOutput;
            { // scope to avoid stack too deep errors
                (uint reserve0, uint reserve1,) = pair.getReserves();
                (uint reserveInput, uint reserveOutput) = input == token0 ? (reserve0, reserve1) : (reserve1, reserve0);
                amountInput = IERC20(input).balanceOf(address(pair)).sub(reserveInput);
                amountOutput = UniswapV2Library.getAmountOut(amountInput, reserveInput, reserveOutput);
            }
            (uint amount0Out, uint amount1Out) = input == token0 ? (uint(0), amountOutput) : (amountOutput, uint(0));
            address to = i < path.length - 2 ? UniswapV2Library.pairFor(factory, output, path[i + 2]) : _to;
            pair.swap(amount0Out, amount1Out, to, new bytes(0));
        }
    }

    // 任意token互换  界定输入多少  最小获取多少目标token数量  不符合就不交换了  有点像挂定价单    很耗费gas费感觉  
    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external virtual override ensure(deadline) {
        // 给第一个pair 发送 token 
        TransferHelper.safeTransferFrom(
            path[0], msg.sender, UniswapV2Library.pairFor(factory, path[0], path[1]), amountIn
        );
        // 最后一个 token的余额  
        uint balanceBefore = IERC20(path[path.length - 1]).balanceOf(to);
        _swapSupportingFeeOnTransferTokens(path, to);
        // 最后一个token  交换后的余额 - swap前的余额 >= amountOutMin    不然就不玩了  revert  
        require(
            IERC20(path[path.length - 1]).balanceOf(to).sub(balanceBefore) >= amountOutMin,
            'UniswapV2Router: INSUFFICIENT_OUTPUT_AMOUNT'
        );
    }

    // 用WETH换其他 token  确定最少获取多少目标token数量  不行拉倒  
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    )
        external
        virtual
        override
        payable
        ensure(deadline)
    {
        require(path[0] == WETH, 'UniswapV2Router: INVALID_PATH');
        uint amountIn = msg.value;
        IWETH(WETH).deposit{value: amountIn}();
        assert(IWETH(WETH).transfer(UniswapV2Library.pairFor(factory, path[0], path[1]), amountIn));
        uint balanceBefore = IERC20(path[path.length - 1]).balanceOf(to);
        _swapSupportingFeeOnTransferTokens(path, to);
        require(
            IERC20(path[path.length - 1]).balanceOf(to).sub(balanceBefore) >= amountOutMin,
            'UniswapV2Router: INSUFFICIENT_OUTPUT_AMOUNT'
        );
    }
    
    // 用其他 token 换取 WETH  确定输入token数量  和最后换取的最少数量   不行拉倒
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    )
        external
        virtual
        override
        ensure(deadline)
    {
        require(path[path.length - 1] == WETH, 'UniswapV2Router: INVALID_PATH');
        TransferHelper.safeTransferFrom(
            path[0], msg.sender, UniswapV2Library.pairFor(factory, path[0], path[1]), amountIn
        );
        _swapSupportingFeeOnTransferTokens(path, address(this));
        uint amountOut = IERC20(WETH).balanceOf(address(this));
        require(amountOut >= amountOutMin, 'UniswapV2Router: INSUFFICIENT_OUTPUT_AMOUNT');
        IWETH(WETH).withdraw(amountOut);
        TransferHelper.safeTransferETH(to, amountOut);
    }

    // 根据 放入A的数量  池子中AB数量  计算要放入B的数量 
    // **** LIBRARY FUNCTIONS ****  
    function quote(uint amountA, uint reserveA, uint reserveB) public pure virtual override returns (uint amountB) {
        return UniswapV2Library.quote(amountA, reserveA, reserveB);
    }

    // 拿多少A换  池子中A的数量  池子中B的数量   返回可以换到B的数量   
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut)
        public
        pure
        virtual
        override
        returns (uint amountOut)
    {
        return UniswapV2Library.getAmountOut(amountIn, reserveIn, reserveOut);
    }

    // 根据要换多少目标token  确定要给多少token
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut)
        public
        pure
        virtual
        override
        returns (uint amountIn)
    {
        return UniswapV2Library.getAmountIn(amountOut, reserveIn, reserveOut);
    }

    // 给定路径和token的数量  算出每一环能拿到多少token
    function getAmountsOut(uint amountIn, address[] memory path)
        public
        view
        virtual
        override
        returns (uint[] memory amounts)
    {
        return UniswapV2Library.getAmountsOut(factory, amountIn, path);
    }

    // 给定路径  和最后要多少token   算出每一环应该给多少token
    function getAmountsIn(uint amountOut, address[] memory path)
        public
        view
        virtual
        override
        returns (uint[] memory amounts)
    {
        return UniswapV2Library.getAmountsIn(factory, amountOut, path);
    }
}
