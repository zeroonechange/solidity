


```c

实际tick 不会存储很多  只有俩个 max 和 min  这俩个tick 才有流动性





跨tick交易
	不同价格区间
		挂限价单  添加流动性 可以只添加一种token  只要偏离现货价格比如  p<lower  p>upper 
	跨tick交易
		价格区间在这里得到了全面的解释   
		不同价格区间 会叠加  而且只记录 lower 和 uppger  叠加没事  反正能找到  
	滑点保护
		防止三明治攻击  前后插入交易  导致自己成交价格偏离太多 
		swap时 多加一个参数  sqrtPriceLimitX96  只要大于这个就revert 
		添加流动性时也要 amount0Min  amount1Min 就是滑点的边界值  最后再检查 如果低于这个就revert 
	流动性计算
		计算俩个 L   取最小的  
	关于定点数的拓展
		将价格转换成 tick 
		solidity不支持浮点数运算  不支持开根号  会失去精度
		一个十进制  一个二进制   就是左右移动 
		https://github.com/paulrberg/prb-math
		https://github.com/abdk-consulting/abdk-libraries-solidity
	闪电贷
		和V2不同 这个功能分离出来了  原理差不多 


第二笔交易
	数学库
		solidity不支持浮点数运算  PRBMath 
		tick 和 price 相互转换    TickMath
	Tick Bitmap Index 
		bitmap就是像素点 0和1组成  看作一个flag  布隆过滤器 
		tick 索引  一个无穷的数组 由01组成  一个字数256位  根据tick 得到字数的位置 和bit位 
		wordPos=tick/256     bitPos=tick%256  
		在同一个字数里面  有256位  
		如果当前tick流动性没了 找下一个流动性 会去俩边看看是否有tick=1  表示已激活=有流动性 
		在这样的大数组中更新某一个位 肯定是用掩码 和之前 EVM的检查地址合法性一样  比如要添加流动性
	通用mint ***
	通用swap *****
		// 全局的  维护swap状态
		struct SwapState {
			uint256 amountSpecifiedRemaining;  // 还需要从池子中获取的 token 数量  为0  就填满了
			uint256 amountCalculated;   //由合约计算出的输出数量
			uint160 sqrtPriceX96;  // 交易结束后的价格 
			int24 tick;  // 交易结束后的 tick
		}
		// 在当前tick上交易的状态  会循环  
		struct StepState {
			uint160 sqrtPriceStartX96;  // 循环开始时的价格
			int24 nextTick;    // 为交易提供流动性的下一个已初始化的tick
			uint160 sqrtPriceNextX96; // 下一个 tick 的价格
			uint256 amountIn;    // 当前循环中流动性能够提供的数量
			uint256 amountOut;   // 当前循环中流动性能够提供的数量 
		}	
		while (state.amountSpecifiedRemaining > 0) {
			循环 
			通过 tick bitmap 查找下一个有流动性的tick  
			然后 通过 TickMath.getSqrtRatioAtTick 获取下一个tick对应的价格
			计算 一个价格区间内部的交易数量以及对应的流动性。
			返回 新的现价、输入 token 数量、输出 token 数量
			...
			填满后  计算输出和输入价格  找到新的价格 和 tick  
			更新合约状态  将token发给用户  通过回调从用户获得token 
		}
	报价合约 
		在交易前能计算出能换出多少token 
		再弄个辅助合约  直接调用 V3Pool.swap   然后捕捉异常  
		在 uniswapV3SwapCallback  回调中  把数据通过 assembly{} 写到内存中去  然后 revert 
		这会导致程序捕捉到 异常  在 try-catch 中 通过 abi.decode 得到想要的数据  



第一笔交易
	ETH/USDC   1 ETH = 5000 USDC   
	现货价格 = 5000  min=4545   max=5599 
	tick index = 85176  min=84222   max=86129 
	质押token  获得多少流动性L    池子区间被耗尽 ΔX  ΔY  看那个最小  然后再退回来一些 

	计算流动性
		先根据现货价格  最大价格  最小价格  算出来 三个 tick 
		然后计算 俩种token 耗尽后的流动性是多少  取最小值  计算和 最大价格/最小价格 现货价格 相关
				 最后重新计算需要多少token  
	提供流动性
		ticks 只保存 lowerTick  upperTick 的流动性 是否被激活      和用户无关 
		position 根据 kecca256(owner  lowerTick  upperTick)  得到key  然后累加流动性    和用户相关 
		合约需要有回调函数 uniswapV3MintCallback  用于转账 
	第一笔交易
		添加 42 USDC   能拿多少 ETH 
		sqrtPriceX96 = 5602277097478614198912276234240
		pool.liquidity() = 1517882343751509868544
		ΔP = 2192253463713690532467206957  
		5602277097478614198912276234240
		   2192253463713690532467206957 	
		P = sqrtPriceX96 + ΔP = 5604469350942327889444743441197
		amount_in = 42 * eth 
		price_diff = (amount_in * q96) // liq   //  2192253463713690532467206957
		price_next = sqrtp_cur + price_diff     //  5604469350942327889444743441197
		
		参数如下:
		...
			int24 nextTick = 85184;
			uint160 nextPrice = 5604469350942327889444743441197;

			amount0 = -0.008396714242162444 ether;
			amount1 = 42 ether;
		...
		更新 tick 和  现货价格   把ETH转账   通过回调把USDC发过来
		...
			(slot0.tick, slot0.sqrtPriceX96) = (nextTick, nextPrice);
			
			IERC20(token0).transfer(recipient, uint256(-amount0));
			
			uint256 balance1Before = balance1();
			IUniswapV3SwapCallback(msg.sender).uniswapV3SwapCallback(
				amount0,
				amount1
			);
			if (balance1Before + uint256(amount1) < balance1())
				revert InsufficientInputAmount();
		...
		
	管理合约
		mint  swap 需要 uniswapV3MintCallback   uniswapV3SwapCallback  来进行转账 
		这里面需要的参数  token0  token1  payer  
		把这三个东西放到一个 struct里面  通过 abi.encode 编码成 calldata  传给pool  pool会通过回调继续执行 
		简单来说就是 把需要的东西提前封装好  便于后面回调使用 
```


V3
官方文档                            https://docs.uniswap.org/contracts/v2/overview
深入理解 Uniswap v3 白皮书          https://hackmd.io/d4GTJiyrQFigUp80IFb-gQ
深入理解 Uniswap v3 合约代码 （一）  https://hackmd.io/TDPPCAIgRRqVDPwsSm6Kfw#Uniswap-v3-core
深入理解 Uniswap v3 合约代码 （二）  https://hackmd.io/cTPg4x2TR4WthYEF8anLug
 



V2
由 factor 创建 pair     pair就是交易对 例如 (USDT, ETH)  里面包含核心的计算逻辑  
Router 提供给前端使用  封装了 pair 的核心方法  添加流动性  swap    还有多种选择 多个参数  

加权平均价格  UQ112.112    闪电贷  协议手续费  sync()和skim()  LOCK同步锁  首次铸币攻击  WETH   CREATE2确定contract address     最大代币余额

更多看源码注释 和下面的链接  

https://docs.uniswap.org/contracts/v2/overview
https://mirror.xyz/adshao.eth/g3EINzP2bfUniZNSs8aOHYsp96NMHHbTqYMnkIAa_pQ

