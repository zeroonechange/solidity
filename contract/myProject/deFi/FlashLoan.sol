

/**
 * 
 * 今天看了一些比较有名的deFi项目  例如 dai - makerDao  稳定币 拿东西抵押的  比luna算法稳定币要稳定的多 
 * 还有就是  aave  这种 流动池 做p2p贷款  还有闪电贷  这种很新型的思想 
 * curve 目前还在了解 比较复杂里面各种pool  
 * 预计国庆彻底把经济模型还有代码都老老实实的啃一遍    实在是太精彩了 很多黑话 
 * 
 * 
 * 
 * uniswap 适合非稳定币  不适合大额交易  因为滑点太大了   适合交易者  套利者   恒定乘积做市商  
Curve 适合稳定币的兑换  基本上没啥无常损失  支持大额交易  比如一个亿 
	池子 靠前的都是稳定币   
	为什么稳定币需要到curve上面来做池子？
		为了币价都为1美刀  除了usdt 或者 usdc 背后有中心机构信用背书  
		大部分链上的稳定币没有 靠链上的增发  或者其他方式来锚定 
		所以需要有个池子来锚定  无论外面怎么变  这个池子的深度是最大的 可随时兑换出特别多的稳定币 
		可以补平 跟外面的世界的价格的差异   curve的优势就体现出来了  
		池子非常深 滑点特别低  稳定币的波动非常小  
	Curve V1 和一次方程一样  后面团队发现不仅仅稳定币的资产还能像uniswap一样 做一些非稳定币的资产
	所以在 Curve V2 版本中 将函数曲线做了一个调整   中心点保障了低滑点  俩边的曲线变的圆滑支持非稳定币
	V1 曲线如此平滑 池子可能被掏空的可能  V2就不可能了  
	对于自己的预言机进行了改变  例如 uniswap 由 chainlink 预言机进行报价  预言机可能被攻击 
	以它自己内部的数据作为一个参考  EMA  移动平均指数   根据历史交易数据来进行一个报价  
	
	curve算法，根据市场的情况以及历史数据，来调整每个池子的一个曲线的一个弧度
	以此来提高最高的一个资金利用率   	
	curve 将底层算法设计好  只需要存钱取钱  其他的都由团队给你解决了  
	curve 适合普通的小白用户以及资产比较多但是没有太多精力去研究相关策略的一些用户 
	
	uniswap 将所有的策略交给用户  对用户也有一定的门槛   专业玩家才能玩的
	
	代币治理模型   
		将代币抵押获得投票权   vCurve 代币 
		代币功能: 
			1.是否投票上币 入池  必须 30%的人同意才行  投票通过51% 才能
			2.流动性挖矿奖励  分配给谁  给多少   完全看 vCurve 投票的情况 
		所以将curve 换成 vcurve   平均锁仓 3.6年   保证了这个币不会崩盘   平台锁住更多的 Curve 代币 
		
	
	稳定币护城河 一家独大   不仅仅止步于稳定币交换的业务  还有 衍生品债券的交易业务 
	外汇交易平台  
	
 
	
	veCRV - vote-Escrowed CRV 
		将Curve 平台代币 CRV 进行锁仓后得到的锁仓凭证   一周到四年 
		1.治理权  2.50%的平台交易手续费分红  
		2.投票给哪个池子 获取收益  
	
	
	稳定币
		1.中心化机构1:1 抵押发行的锚定稳定币 USDT  USDC
		2.去中心化的超额抵押型稳定币 DAI MIM 
		3.通过算法平衡型的算法稳定币 UST FRAX 等
	算法稳定币  deFi真正的圣经 

https://www.youtube.com/watch?v=_7ryMR3mHrU
https://www.youtube.com/watch?v=JY5kImwSgbo

 */