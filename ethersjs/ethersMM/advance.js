const ethers = require("ethers");
const { exit } = require("process");

const privateKey = 'a028b80f557f2ff8edd2b39fe749b21c10669d78381df8c6e2f2afc362efa1ee'

const providerETH = new ethers.providers.JsonRpcProvider(`https://eth-mainnet.g.alchemy.com/v2/qXFbrurfVJ5Le9N3T3HwEi8Wc06v0Ud3`);  
const providerGerli = new ethers.providers.JsonRpcProvider('https://eth-goerli.g.alchemy.com/v2/ybl4NUkj7Q4_odQ1NWNL2ZyYCFcOMSd5');

const vitalik_eth = "0xd8dA6BF26964aF9D7eEd9e03E53415D37aA96045";

/**
 * 合约类的callStatic方法，在发送交易之前检查交易是否会失败，节省大量gas
 * 在ethers.js中你可以利用contract对象的callStatic()来调用以太坊节点的eth_call。如果调用成功，则返回ture；如果失败，则报错并返回失败原因。
 */
const callstatic = async() => {
    const wallet = new ethers.Wallet(privateKey, providerETH)
    // DAI的ABI
    const abiDAI = [
        "function balanceOf(address) public view returns(uint)",
        "function transfer(address, uint) public returns (bool)",
    ];
    // DAI合约地址（主网）
    const addressDAI = '0x6B175474E89094C44Da98b954EedeAC495271d0F' // DAI Contract
    // 创建DAI合约实例
    const contractDAI = new ethers.Contract(addressDAI, abiDAI, providerETH)
    try {
        const address = await wallet.getAddress()
        // 1. 读取DAI合约的链上信息
        console.log("\n1. 读取测试钱包的DAI余额")
        const balanceDAI = await contractDAI.balanceOf(address)
        console.log(`DAI持仓: ${ethers.utils.formatEther(balanceDAI)}\n`)

        // 2. 用callStatic尝试调用transfer转账10000 DAI，msg.sender为V神，交易将成功
        console.log("\n2.  用callStatic尝试调用transfer转账1 DAI，msg.sender为V神地址")
        // 发起交易
        const tx = await contractDAI.callStatic.transfer(vitalik_eth, ethers.utils.parseEther("10000"), {from: vitalik_eth})
        console.log(`交易会成功吗？：`, tx)

        // 3. 用callStatic尝试调用transfer转账10000 DAI，msg.sender为测试钱包地址，交易将失败
        console.log("\n3.  用callStatic尝试调用transfer转账1 DAI，msg.sender为测试钱包地址")
        const tx2 = await contractDAI.callStatic.transfer(vitalik_eth, ethers.utils.parseEther("10000"), {from: address})
        console.log(`交易会成功吗？：`, tx2)
    } catch (e) {
        console.log(e);
    }   
}
// callstatic()


/**
 * 识别一个合约是否为ERC721标准
 * ERC721是以太坊上流行的非同质化代币（NFT）标准

    function supportsInterface(bytes4 interfaceId)
        external
        pure
        override
        returns (bool)
    {
        return
            interfaceId == type(IERC721).interfaceId 
    }
 */
const erc721_checker = async() => {
    // 合约abi
    const abiERC721 = [
        "function name() view returns (string)",
        "function symbol() view returns (string)",
        "function supportsInterface(bytes4) public view returns(bool)",
    ];
    // ERC721的合约地址，这里用的BAYC
    const addressBAYC = "0xbc4ca0eda7647a8ab7c2061c2e118a18a936f13d"
    // 创建ERC721合约实例
    const contractERC721 = new ethers.Contract(addressBAYC, abiERC721, providerETH)
    // ERC721接口的ERC165 identifier
    const selectorERC721 = "0x80ac58cd"   // ERC721接口id  =  type(IERC721).interfaceId
    try {
        // 1. 读取ERC721合约的链上信息
        const nameERC721 = await contractERC721.name()
        const symbolERC721 = await contractERC721.symbol()
        console.log("\n1. 读取ERC721合约信息")
        console.log(`合约地址: ${addressBAYC}`)
        console.log(`名称: ${nameERC721}`)
        console.log(`代号: ${symbolERC721}`)
    
        // 2. 利用ERC165的supportsInterface，确定合约是否为ERC721标准
        const isERC721 = await contractERC721.supportsInterface(selectorERC721)
        console.log("\n2. 利用ERC165的supportsInterface，确定合约是否为ERC721标准")
        console.log(`合约是否为ERC721标准: ${isERC721}`)
    }catch (e) {
        // 如果不是ERC721，则会报错
        console.log(e);
    }
}
// erc721_checker()


/**
 * 编码calldata   简单来说就是通过  interface 一些方法可以编码/解码 
 *  利用abi生成或者直接从合约中获取interface变量
        // 利用abi生成
        const interface = ethers.utils.Interface(abi)
        // 直接从contract中获取
        const interface2 = contract.interface

        getSighash()：获取函数选择器（function selector），参数为函数名或函数签名。
            interface.getSighash("balanceOf");
            // '0xddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef'

        encodeDeploy()：编码构造器的参数，然后可以附在合约字节码的后面。
            interface.encodeDeploy("Wrapped ETH", "WETH");

        encodeFunctionData()：编码函数的calldata。
            interface.encodeFunctionData("balanceOf", ["0xc778417e063141139fce010982780140aa0cd5ab"]);
            
        decodeFunctionResult()：解码函数的返回值。
            interface.decodeFunctionResult("balanceOf", resultData)    
 */
const interface_encode_calldata = async() => {
    const wallet = new ethers.Wallet(privateKey, providerGerli)
    // WETH的ABI
    const abiWETH = [
        "function balanceOf(address) public view returns(uint)",
        "function deposit() public payable",
    ];
    const addressWETH = '0xb4fbf271143f4fbf7b91a5ded31805e42b2208d6'  // WETH合约地址（Goerli测试网）
    const contractWETH = new ethers.Contract(addressWETH, abiWETH, wallet)
    const address = await wallet.getAddress()
    // 1. 读取WETH合约的链上信息（WETH abi）
    console.log("\n1. 读取WETH余额")
    // 编码calldata
    const param1 = contractWETH.interface.encodeFunctionData(
        "balanceOf",
        [address]
      );
    console.log(`编码结果： ${param1}`)
    // 创建交易
    const tx1 = {
        to: addressWETH,
        data: param1
    }
    // 发起交易，可读操作（view/pure）可以用 provider.call(tx)
    const balanceWETH = await providerGerli.call(tx1)
    console.log(`存款前WETH持仓: ${ethers.utils.formatEther(balanceWETH)}\n`)

    const balanceETH = await wallet.getBalance()
    if(ethers.utils.formatEther(balanceETH) > 0.0015){
        console.log("\n2. 调用desposit()函数，存入0.001 ETH")
        const param2 = contractWETH.interface.encodeFunctionData("deposit");    // 编码calldata
        console.log(`编码结果： ${param2}`)
        const tx2 = {
            to: addressWETH,
            data: param2,
            value: ethers.utils.parseEther("0.001")}
        // 发起交易，写入操作需要 wallet.sendTransaction(tx)
        const receipt1 = await wallet.sendTransaction(tx2)
        // 等待交易上链
        await receipt1.wait()

        console.log(`交易详情：`)
        console.log(receipt1)
        const balanceWETH_deposit = await contractWETH.balanceOf(address)
        console.log(`存款后WETH持仓: ${ethers.utils.formatEther(balanceWETH_deposit)}\n`)
    }else{
        // 如果ETH不足
        console.log("ETH不足，去水龙头领一些Goerli ETH")
        console.log("1. chainlink水龙头: https://faucets.chain.link/goerli")
        console.log("2. paradigm水龙头: https://faucet.paradigm.xyz/")
    }   
}
// interface_encode_calldata()


/**
 * 写一个批量生成钱包的脚本
 *  HD钱包（Hierarchical Deterministic Wallet，多层确定性钱包）是一种数字钱包 ，通常用于存储比特币和以太坊等加密货币持有者的数字密钥。
 *  通过它，用户可以从一个随机种子创建一系列密钥对，更加便利、安全、隐私。要理解HD钱包，我们需要简单了解比特币的BIP32，BIP44，和BIP39。
 *  
 *  在BIP32推出之前，用户需要记录一堆的私钥才能管理很多钱包。BIP32提出可以用一个随机种子衍生多个私钥，更方便的管理多个钱包。钱包的地址由衍生路径决定，例如“m/0/0/1”。
 * 
 *  BIP44为BIP32的衍生路径提供了一套通用规范，适配比特币、以太坊等多链。这一套规范包含六级，每级之间用"/"分割： 
 *          m / purpose' / coin_type' / account' / change / address_index
 *          m: 固定为"m"
            purpose：固定为"44"
            coin_type：代币类型，比特币主网为0，比特币测试网为1，以太坊主网为60
            account：账户索引，从0开始。
            change：是否为外部链，0为外部链，1为内部链，一般填0.
            address_index：地址索引，从0开始，想生成新地址就把这里改为1，2，3。
            举个例子，以太坊的默认衍生路径为"m/44'/60'/0'/0/0"。

    BIP39让用户能以一些人类可记忆的助记词的方式保管私钥，而不是一串16进制的数字：
        //私钥
        0x813f8f0a4df26f6455814fdd07dd2ab2d0e2d13f4d2f3c66e7fd9e3856060f89
        //助记词
        air organ twist rule prison symptom jazz cheap rather dizzy verb glare jeans orbit weapon universe require tired sing casino business anxiety seminar hunt
 *  ethers.js提供了HDNode类，方便开发者使用HD钱包
 */
const HD_WALLET_GENERATOR = async() => {
    // 1. 创建HD钱包
    console.log("\n1. 创建HD钱包")
    // 生成随机助记词
    const mnemonic = ethers.utils.entropyToMnemonic(ethers.utils.randomBytes(32))
    console.log(`随机助记词 ${mnemonic}`)
    // 创建HD钱包
    const hdNode = ethers.utils.HDNode.fromMnemonic(mnemonic)
    console.log(hdNode);

    // 2. 通过HD钱包派生20个钱包
    console.log("\n2. 通过HD钱包派生20个钱包")
    const numWallet = 20
    // 派生路径：m / purpose' / coin_type' / account' / change / address_index
    // 我们只需要切换最后一位address_index，就可以从hdNode派生出新钱包
    let basePath = "m/44'/60'/0'/0";
    let wallets = [];
    for (let i = 0; i < numWallet; i++) {
        let hdNodeNew = hdNode.derivePath(basePath + "/" + i);
        let walletNew = new ethers.Wallet(hdNodeNew.privateKey);
        console.log(`第${i+1}个钱包地址： ${walletNew.address} \t 路径 --->  ${hdNodeNew.path} `)
        wallets.push(walletNew);
    }

    // 3. 保存钱包（加密json）
    console.log("\n3. 保存钱包（加密json）")
    const wallet = ethers.Wallet.fromMnemonic(mnemonic)
    console.log("通过助记词创建钱包：")
    console.log(wallet)
    // 加密json用的密码，可以更改成别的
    const pwd = "password"
    const json = await wallet.encrypt(pwd)
    console.log("钱包的加密json：")
    console.log(json)

    // 4. 从加密json读取钱包
    const wallet2 = await ethers.Wallet.fromEncryptedJson(json, pwd);
    console.log("\n4. 从加密json读取钱包：")
    console.log(wallet2)    
    
    exit()
}
// HD_WALLET_GENERATOR()



/**
 * 批量转账             空投中的Airdrop合约  查看 airdrop下面的合约代码 
 * 调用Airdrop合约将ETH（原生代币）和WETH（ERC20代币）转账给20个地址
 * 
 */
const batch_transfer_airdrop = async() => {
    // 1. 创建HD钱包
    console.log("\n1. 创建HD钱包")
    // 通过助记词生成HD钱包
    const mnemonic = `air organ twist rule prison symptom jazz cheap rather dizzy verb glare jeans orbit weapon universe require tired sing casino business anxiety seminar hunt`
    const hdNode = ethers.utils.HDNode.fromMnemonic(mnemonic)
    console.log(hdNode);

    // 2. 获得20个钱包的地址
    console.log("\n2. 通过HD钱包派生20个钱包")
    const numWallet = 20
    // 派生路径：m / purpose' / coin_type' / account' / change / address_index
    // 我们只需要切换最后一位address_index，就可以从hdNode派生出新钱包
    let basePath = "m/44'/60'/0'/0";
    let addresses = [];
    for (let i = 0; i < numWallet; i++) {
        let hdNodeNew = hdNode.derivePath(basePath + "/" + i);
        let walletNew = new ethers.Wallet(hdNodeNew.privateKey);
        addresses.push(walletNew.address);
    }
    console.log(addresses)
    const amounts = Array(20).fill(ethers.utils.parseEther("0.0001"))
    console.log(`发送数额：${amounts}`)

    const wallet = new ethers.Wallet(privateKey, providerGerli)

    // 4. 声明Airdrop合约
    // Airdrop的ABI
    const abiAirdrop = [
        "function multiTransferToken(address,address[],uint256[]) external",
        "function multiTransferETH(address[],uint256[]) public payable",
    ];
    // Airdrop合约地址（Goerli测试网）
    const addressAirdrop = '0x71C2aD976210264ff0468d43b198FD69772A25fa' // Airdrop Contract
    // 声明Airdrop合约
    const contractAirdrop = new ethers.Contract(addressAirdrop, abiAirdrop, wallet)

    // 5. 声明WETH合约
    // WETH的ABI
    const abiWETH = [
        "function balanceOf(address) public view returns(uint)",
        "function transfer(address, uint) public returns (bool)",
        "function approve(address, uint256) public returns (bool)"
    ];
    // WETH合约地址（Goerli测试网）
    const addressWETH = '0xB4FBF271143F4FBf7B91A5ded31805e42b2208d6' // WETH Contract
    // 声明WETH合约
    const contractWETH = new ethers.Contract(addressWETH, abiWETH, wallet)    

    // 6. 读取一个地址的ETH和WETH余额
    console.log("\n3. 读取一个地址的ETH和WETH余额")
    //读取WETH余额
    const balanceWETH = await contractWETH.balanceOf(addresses[10])
    console.log(`WETH持仓: ${ethers.utils.formatEther(balanceWETH)}\n`)
    //读取ETH余额
    const balanceETH = await providerGerli.getBalance(addresses[10])
    console.log(`ETH持仓: ${ethers.utils.formatEther(balanceETH)}\n`)

    const myETH = await wallet.getBalance()
    const myToken = await contractWETH.balanceOf(wallet.getAddress())
    // 如果钱包ETH足够和WETH足够
    if(ethers.utils.formatEther(myETH) > 0.002 && ethers.utils.formatEther(myToken) >= 0.002){

        // 7. 调用multiTransferETH()函数，给每个钱包转 0.0001 ETH
        console.log("\n4. 调用multiTransferETH()函数，给每个钱包转 0.0001 ETH")
        // 发起交易
        const tx = await contractAirdrop.multiTransferETH(addresses, amounts, {value: ethers.utils.parseEther("0.002")})
        // 等待交易上链
        await tx.wait()
        // console.log(`交易详情：`)
        // console.log(tx)
        const balanceETH2 = await providerGerli.getBalance(addresses[10])
        console.log(`发送后该钱包ETH持仓: ${ethers.utils.formatEther(balanceETH2)}\n`)
        
        // 8. 调用multiTransferToken()函数，给每个钱包转 0.0001 WETH
        console.log("\n5. 调用multiTransferToken()函数，给每个钱包转 0.0001 WETH")
        // 先approve WETH给Airdrop合约
        const txApprove = await contractWETH.approve(addressAirdrop, ethers.utils.parseEther("1"))
        await txApprove.wait()
        // 发起交易
        const tx2 = await contractAirdrop.multiTransferToken(addressWETH, addresses, amounts)
        // 等待交易上链
        await tx2.wait()
        // console.log(`交易详情：`)
        // console.log(tx2)
        // 读取WETH余额
        const balanceWETH2 = await contractWETH.balanceOf(addresses[10])
        console.log(`发送后该钱包WETH持仓: ${ethers.utils.formatEther(balanceWETH2)}\n`)
    }else{
        // 如果ETH和WETH不足
        console.log("ETH不足，去水龙头领一些Goerli ETH，并兑换一些WETH")
        console.log("1. chainlink水龙头: https://faucets.chain.link/goerli")
        console.log("2. paradigm水龙头: https://faucet.paradigm.xyz/")
    }
}
// batch_transfer_airdrop()


/**
 * 批量归集    要将多个钱包的资产进行归集管理
 */
const batch_collect = async() => {
    const wallet = new ethers.Wallet(privateKey, providerGerli)
    // 2. 声明WETH合约
    // WETH的ABI
    const abiWETH = [
        "function balanceOf(address) public view returns(uint)",
        "function transfer(address, uint) public returns (bool)",
    ];
    // WETH合约地址（Goerli测试网）
    const addressWETH = '0xB4FBF271143F4FBf7B91A5ded31805e42b2208d6' // WETH Contract
    // 声明WETH合约
    const contractWETH = new ethers.Contract(addressWETH, abiWETH, wallet)

    // 3. 创建HD钱包
    console.log("\n1. 创建HD钱包")
    // 通过助记词生成HD钱包
    const mnemonic = `air organ twist rule prison symptom jazz cheap rather dizzy verb glare jeans orbit weapon universe require tired sing casino business anxiety seminar hunt`
    const hdNode = ethers.utils.HDNode.fromMnemonic(mnemonic)
    console.log(hdNode);

    // 4. 获得20个钱包
    console.log("\n2. 通过HD钱包派生20个钱包")
    const numWallet = 20
    // 派生路径：m / purpose' / coin_type' / account' / change / address_index
    // 我们只需要切换最后一位address_index，就可以从hdNode派生出新钱包
    let basePath = "m/44'/60'/0'/0";
    let wallets = [];
    for (let i = 0; i < numWallet; i++) {
        let hdNodeNew = hdNode.derivePath(basePath + "/" + i);
        let walletNew = new ethers.Wallet(hdNodeNew.privateKey);
        wallets.push(walletNew);
        console.log(walletNew.address)
    }
    // 定义发送数额
    const amount = ethers.utils.parseEther("0.0001")
    console.log(`发送数额：${amount}`)

    // 5. 读取一个地址的ETH和WETH余额
    console.log("\n3. 读取一个地址的ETH和WETH余额")
    //读取WETH余额
    const balanceWETH = await contractWETH.balanceOf(wallets[19].address)
    console.log(`WETH持仓: ${ethers.utils.formatEther(balanceWETH)}`)
    //读取ETH余额
    const balanceETH = await providerGerli.getBalance(wallets[19].address)
    console.log(`ETH持仓: ${ethers.utils.formatEther(balanceETH)}\n`)

    // 如果钱包ETH足够
    if(ethers.utils.formatEther(balanceETH) > ethers.utils.formatEther(amount) && ethers.utils.formatEther(balanceWETH) >= ethers.utils.formatEther(amount)){
        // 6. 批量归集钱包的ETH
        console.log("\n4. 批量归集20个钱包的ETH")
        const txSendETH = {
            to: wallet.address,
            value: amount
        }
        for (let i = 0; i < numWallet; i++) {
            // 将钱包连接到provider
            let walletiWithProvider = wallets[i].connect(providerGerli)
            var tx = await walletiWithProvider.sendTransaction(txSendETH)
            console.log(`第 ${i+1} 个钱包 ${walletiWithProvider.address} ETH 归集开始`)
        }
        await tx.wait()
        console.log(`ETH 归集结束`)

        // 7. 批量归集钱包的WETH
        console.log("\n5. 批量归集20个钱包的WETH")
        for (let i = 0; i < numWallet; i++) {
            // 将钱包连接到provider
            let walletiWithProvider = wallets[i].connect(providerGerli)
            // 将合约连接到新的钱包
            let contractConnected = contractWETH.connect(walletiWithProvider)
            var tx = await contractConnected.transfer(wallet.address, amount)
            console.log(`第 ${i+1} 个钱包 ${wallets[i].address} WETH 归集开始`)
        }
        await tx.wait()
        console.log(`WETH 归集结束`)

        // 8. 读取一个地址在归集后的ETH和WETH余额
        console.log("\n6. 读取一个地址在归集后的ETH和WETH余额")
        // 读取WETH余额
        const balanceWETHAfter = await contractWETH.balanceOf(wallets[19].address)
        console.log(`归集后WETH持仓: ${ethers.utils.formatEther(balanceWETHAfter)}`)
        // 读取ETH余额
        const balanceETHAfter = await providerGerli.getBalance(wallets[19].address)
        console.log(`归集后ETH持仓: ${ethers.utils.formatEther(balanceETHAfter)}\n`)
    }else{
        console.log("钱不够---去领一点钱吧")
    }    
}
// batch_collect()


//MerkleTree脚本  不整了 就是库的调用  和 ethers.js 没多大关系  


/**
 * 数字签名脚本  以太坊中的数字签名ECDSA   双椭圆曲线数字签名算法 
    私钥: 0x227dbb8586117d55284e26620bc76534dfbd2394be34cf4a09cb775d593b6f2b
    公钥: 0xe16C1623c1AA7D919cd2241d8b36d9E79C1Be2A2
    消息: 0x1bf2c0ce4546651a1a2feb457b39d891a6b83931cc2454434f39961345ac378c
    以太坊签名消息: 0xb42ca4636f721c7a331923e764587e98ec577cea1a185f60dfcc14dbb9bd900b
    签名: 0x390d704d7ab732ce034203599ee93dd5d3cb0d4d1d7c600ac11726659489773d559b12d220f99f41d17651b0c1c6a669d346a397f8541760d6b32a5725378b241c

https://github.com/WTFAcademy/WTF-Ethers/blob/main/18_Signature/readme.md
https://github.com/AmazingAng/WTF-Solidity/blob/main/37_Signature/readme.md

这些后面再补吧  先过了 
 */



/**
 * 监听 Mempool
 *  MEV（Maximal Extractable Value，最大可提取价值）  在区块链中，矿工可以通过打包、排除或重新排序他们产生的区块中的交易来获得一定的利润，而MEV是衡量这种利润的指标。
 *  在用户的交易被矿工打包进以太坊区块链之前，所有交易会汇集到Mempool（交易内存池）中。矿工也是在这里寻找费用高的交易优先打包，实现利益最大化。通常来说，gas price越高的交易，越容易被打包。
 *  同时，一些MEV机器人也会搜索mempool中有利可图的交易。比如，一笔滑点设置过高的swap交易可能会被三明治攻击：通过调整gas，机器人会在这笔交易之前插一个买单，之后发送一个卖单，等效于把把代币以高价卖给用户（抢跑）。
 *  可以利用ethers.js的Provider类提供的方法，监听mempool中的pending（未决，待打包）交易 
 */
const mempool_observe = async() => {
    // 1. 创建provider和wallet，监听事件时候推荐用wss连接而不是http
    console.log("\n1. 连接 wss RPC")
    const ALCHEMY_MAINNET_WSSURL = 'wss://eth-mainnet.g.alchemy.com/v2/qXFbrurfVJ5Le9N3T3HwEi8Wc06v0Ud3';
    const provider = new ethers.providers.WebSocketProvider(ALCHEMY_MAINNET_WSSURL);
    let network = provider.getNetwork()
    network.then(res => console.log(`[${(new Date).toLocaleTimeString()}] 连接到 chain ID ${res.chainId}`));

    console.log("\n2. 限制调用rpc接口速率")

    let i = 0;
    // 3. 监听pending交易，获取txHash
    console.log("\n3. 监听pending交易，打印txHash。")
    provider.on("pending", async (txHash) => {
        if (txHash && i < 100) {
            // 打印txHash
            console.log(`[${(new Date).toLocaleTimeString()}] 监听Pending交易 ${i}: ${txHash} \r`);
            i++
            }
    });

    // 4. 监听pending交易，并获取交易详情
    console.log("\n4. 监听pending交易，获取txHash，并输出交易详情。")
    let j = 0
    provider.on("pending", throttle(async (txHash) => {
        if (txHash && j <= 100) {
            // 获取tx详情
            let tx = await provider.getTransaction(txHash);
            console.log(`\n[${(new Date).toLocaleTimeString()}] 监听Pending交易 ${j}: ${txHash} \r`);
            console.log(tx);
            j++
        }
    }, 1000));
}
// mempool_observe()


// 2. 限制访问rpc速率，不然调用频率会超出限制，报错。
function throttle(fn, delay) {
    let timer;
    return function(){
        if(!timer) {
            fn.apply(this, arguments)
            timer = setTimeout(()=>{
                clearTimeout(timer)
                timer = null
            },delay)
        }
    }
}

/**
 * 解码交易详情
 *  未决交易（Pending Transaction）  未决交易是用户发出但没被矿工打包上链的交易，在mempool（交易内存池）中出现
 */

const decode_pending_transaction = async() => {
    // 1. 创建provider和wallet，监听事件时候推荐用wss连接而不是http
    const ALCHEMY_MAINNET_WSSURL = 'wss://eth-mainnet.g.alchemy.com/v2/qXFbrurfVJ5Le9N3T3HwEi8Wc06v0Ud3';
    const provider = new ethers.providers.WebSocketProvider(ALCHEMY_MAINNET_WSSURL);
    let network = provider.getNetwork()
    network.then(res => console.log(`[${(new Date).toLocaleTimeString()}] 连接到 chain ID ${res.chainId}`));

    // 2. 创建interface对象，用于解码交易详情。
    const iface = new ethers.utils.Interface([
        "function exactInputSingle(tuple(address tokenIn, address tokenOut, uint24 fee, address recipient, uint deadline, uint amountIn, uint amountOutMinimum, uint160 sqrtPriceLimitX96) calldata) external payable returns (uint amountOut)",
    ])

    // 4. 监听pending的uniswapV3交易，获取交易详情，然后解码。
    //  网络不活跃的时候，可能需要等待几分钟才能监听到一笔。
    console.log("\n4. 监听pending交易，获取txHash，并输出交易详情。")
    provider.on("pending", throttle(async (txHash) => {
        if (txHash) {
            // 获取tx详情
            let tx = await provider.getTransaction(txHash);
            if (tx) {
                // filter pendingTx.data
                if (tx.data.indexOf(iface.getSighash("exactInputSingle")) !== -1) {
                    // 打印txHash
                    console.log(`\n[${(new Date).toLocaleTimeString()}] 监听Pending交易: ${txHash} \r`);

                    // 打印解码的交易详情
                    let parsedTx = iface.parseTransaction(tx)
                    console.log("pending交易详情解码：")
                    console.log(parsedTx);
                    // Input data解码
                    console.log("Input Data解码：")
                    console.log(parsedTx.args);
                }
            }
        }
    }, 100));
}
decode_pending_transaction()