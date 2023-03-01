const ethers = require("ethers");
const { exit } = require("process");
const { FlashbotsBundleProvider, FlashbotsBundleResolution } = require("@flashbots/ethers-provider-bundle");

const privateKey = 'a028b80f557f2ff8edd2b39fe749b21c10669d78381df8c6e2f2afc362efa1ee'

const providerETH = new ethers.providers.JsonRpcProvider(`https://eth-mainnet.g.alchemy.com/v2/qXFbrurfVJ5Le9N3T3HwEi8Wc06v0Ud3`);
const providerGerli = new ethers.providers.JsonRpcProvider('https://eth-goerli.g.alchemy.com/v2/ybl4NUkj7Q4_odQ1NWNL2ZyYCFcOMSd5');

const vitalik_eth = "0xd8dA6BF26964aF9D7eEd9e03E53415D37aA96045";

// 靓号生成器
const vanity_address = async () => {
    var wallet // 钱包
    const regex = /^0x000.*$/ // 表达式
    var isValid = false
    while (!isValid) {
        wallet = ethers.Wallet.createRandom() // 随机生成钱包，安全
        isValid = regex.test(wallet.address) // 检验正则表达式
        console.log(wallet.address)
    }
    // 打印靓号地址与私钥
    console.log(`\n靓号地址：${wallet.address}`)
    console.log(`靓号私钥：${wallet.privateKey}\n`)
    exit()
}
// vanity_address()


//读取智能合约的任意数据   包括  private 变量 
const read_slot_data = async () => {
    // 目标合约地址: Arbitrum ERC20 bridge（主网）
    const addressBridge = '0x8315177aB297bA92A06054cE80a67Ed4DBd7ed3a' // DAI Contract
    // 合约所有者 slot
    const slot = `0xb53127684a568b3173ae13b9f8a6016e243e63b6e8ee1178d6a717850b5d6103`
    console.log("开始读取特定slot的数据")
    const privateData = await providerETH.getStorageAt(addressBridge, slot)
    console.log("读出的数据（owner地址）: ", ethers.utils.getAddress(ethers.utils.hexDataSlice(privateData, 12)))
}
// read_slot_data()


// 抢跑机器人  这里需要用到 foundry 后面在一起
// Foundry的anvil工具搭建本地测试链     remix进行NFT合约的部署和铸造      etherjs脚本监听mempool并进行抢跑
const hacker_helloworld = async () => {
    // 1. 创建provider
    var url = "http://127.0.0.1:8545";
    const provider = new ethers.providers.WebSocketProvider(url);
    let network = provider.getNetwork()
    network.then(res => console.log(`[${(new Date).toLocaleTimeString()}] 连接到 chain ID ${res.chainId}`));

    // 2. 创建interface对象，用于解码交易详情。
    const iface = new ethers.utils.Interface([
        "function mint() external",
    ])

    // 3. 创建钱包，用于发送抢跑交易
    const wallet = new ethers.Wallet(privateKey, provider)

    // 4. 监听pending交易，获取txHash，输出交易详情，发送抢跑交易。
    console.log("\n4. 监听pending交易，获取txHash，输出交易详情，发送抢跑交易。")
    provider.on("pending", async (txHash) => {
        if (txHash) {
            // 获取tx详情
            let tx = await provider.getTransaction(txHash);
            if (tx) {
                // filter pendingTx.data
                if (tx.data.indexOf(iface.getSighash("mint")) !== -1 && tx.from != wallet.address) {
                    // 打印txHash
                    console.log(`\n[${(new Date).toLocaleTimeString()}] 监听Pending交易: ${txHash} \r`);

                    // 打印原始交易
                    console.log("raw transaction")
                    console.log(tx);

                    // 打印交易解码后结果
                    let parsedTx = iface.parseTransaction(tx)
                    console.log("pending交易详情解码：")
                    console.log(parsedTx);

                    // 构建抢跑tx
                    const txFrontrun = {
                        to: tx.to,
                        value: tx.value,
                        maxPriorityFeePerGas: tx.maxPriorityFeePerGas * 1.2,
                        maxFeePerGas: tx.maxFeePerGas * 1.2,
                        gasLimit: tx.gasLimit * 2,
                        data: tx.data
                    }
                    // 发送抢跑交易
                    var txResponse = await wallet.sendTransaction(txFrontrun)
                    console.log(`正在frontrun交易`)
                    await txResponse.wait()
                    console.log(`frontrun 交易成功`)
                }
            }
        }
    });

    provider._websocket.on("error", async () => {
        console.log(`Unable to connect to ${ep.subdomain} retrying in 3s...`);
        setTimeout(init, 3000);
    });

    provider._websocket.on("close", async (code) => {
        console.log(
            `Connection lost with code ${code}! Attempting reconnect in 3s...`
        );
        provider._websocket.terminate();
        setTimeout(init, 3000);
    });
}



//识别ERC20合约     获取合约代码，然后对比其是否包含 ERC20 标准中的函数    
//仅需检测 transfer(address, uint256) 和 balanceOf(address) 两个函数，而不用检查全部6个
// ERC20标准中只有 transfer(address, uint256) 不包含在 ERC721标准、ERC1155和ERC777标准中。因此如果一个合约包含 transfer(address, uint256) 的选择器，就能确定它是 ERC20 代币合约，而不是其他。
// 额外检测 balanceOf(address) 是为了防止选择器碰撞：一串随机的字节码可能和 transfer(address, uint256) 的选择器（4字节）相同
const erc20_checker = async () => {

    // 3. 检查函数，检查某个地址是否为ERC20合约
    async function erc20Checker(addr) {
        // 获取合约bytecode
        let code = await providerETH.getCode(addr)
        // 非合约地址的bytecode是0x
        if (code != "0x") {
            // 检查bytecode中是否包含transfer函数和balanceOf函数的selector
            if (code.includes("a9059cbb") && code.includes("18160ddd")) {
                // 如果有，则是ERC20
                return true
            } else {
                // 如果没有，则不是ERC20
                return false
            }
        } else {
            return null;
        }
    }

    // 2. 合约地址
    // DAI address (mainnet)
    const daiAddr = "0x6b175474e89094c44da98b954eedeac495271d0f"
    // BAYC address (mainnet)
    const baycAddr = "0xbc4ca0eda7647a8ab7c2061c2e118a18a936f13d"

    // 检查DAI合约是否为ERC20
    let isDaiERC20 = await erc20Checker(daiAddr)
    console.log(`1. Is DAI a ERC20 contract: ${isDaiERC20}`)

    // 检查BAYC合约是否为ERC20
    let isBaycERC20 = await erc20Checker(baycAddr)
    console.log(`2. Is BAYC a ERC20 contract: ${isBaycERC20}`)
}
// erc20_checker()



/**
 * Flashbots
 * 在以太坊转为 POS 之后，有超过 60% 的区块都是 flashbots 产出的
 * Flashbots 是致力于减轻 MEV（最大可提取价值）对区块链造成危害的研究组织。目前有以下几款产品:
 *      1.Flashbots RPC: 保护以太坊用户受到有害 MEV（三明治攻击）的侵害           类似于暗池
 *      2.Flashbots Bundle: 帮助 MEV 搜索者（Searcher）在以太坊上提取 MEV        按顺序交易  不能插入
 *      3.mev-boost: 帮助以太坊 POS 节点通过 MEV 获取更多的 ETH 奖励
 * 
 * Flashbots RPC 是一款面向以太坊普通用户的免费产品，你只需要在加密的钱包中将 RPC（网络节点）设置为Flashbots RPC，就可以将交易发送到Flashbots的私有交易缓存池（mempool）而非公开的，从而免受抢先交易/三明治攻击的损害
 * 
 */
/**
PS F:\allinweb3\solidity\workspace\solidity\ethersjs\ethersMM> node .\application.js
成功创建flashbotsProvider
nonce:  11
fee data:  {
  lastBaseFeePerGas: BigNumber { _hex: '0x483c52aa55', _isBigNumber: true },
  maxFeePerGas: BigNumber { _hex: '0x90d20d83aa', _isBigNumber: true },
  maxPriorityFeePerGas: BigNumber { _hex: '0x59682f00', _isBigNumber: true },
  gasPrice: BigNumber { _hex: '0x483c625030', _isBigNumber: true }
}
成功创建transactionBundle   开始模拟交易
模拟交易成功
{
  "bundleGasPrice": {
    "type": "BigNumber",
    "hex": "0x59682f00"
  },
  "bundleHash": "0x94f1df8382cf4d6807bc27fd54616ebed3f64db4d0d73c3a0bef18a12fa54e61",
  "coinbaseDiff": {
    "type": "BigNumber",
    "hex": "0x1ca62a4f7800"
  },
  "ethSentToCoinbase": {
    "type": "BigNumber",
    "hex": "0x00"
  },
  "gasFees": {
    "type": "BigNumber",
    "hex": "0x1ca62a4f7800"
  },
  "results": [
    {
      "txHash": "0x670b4a69ea7feceb2f8b4118df78215b6338a386c0b9de685e359bf22c860451",
      "gasUsed": 21000,
      "gasPrice": "1500000000",
      "gasFees": "31500000000000",
      "fromAddress": "0x5E46077F3DD9462D9F559FF38F76d54F762e79fF",
      "toAddress": "0x25df6DA2f4e5C178DdFF45038378C0b08E0Bce54",
      "coinbaseDiff": "31500000000000",
      "ethSentToCoinbase": "0",
      "value": "0x"
    }
  ],
  "stateBlockNumber": 8577066,
  "totalGasUsed": 21000
}
开始上测试网Flashbots 上链  循环100个区块
区块  8577067
请重试, 交易没有被纳入区块: 8577067
区块  8577068
请重试, 交易没有被纳入区块: 8577068
区块  8577069
请重试, 交易没有被纳入区块: 8577069
区块  8577070
恭喜, 交易成功上链，区块: 8577070
{
  "bundleTransactions": [
    {
      "signedTransaction": "0x02f872050b8459682f008590d20d83aa8252089425df6da2f4e5c178ddff45038378c0b08e0bce5487038d7ea4c6800080c080a0dc74f79edba3f28295c9ffd44affa47ae0a7a6af68ec7cb8d1bd3238e398ec35a02cf5ab0a1be3e6a0978d4455692141de15bf7c3ef80f5e54664df733e995eab6",
      "hash": "0x670b4a69ea7feceb2f8b4118df78215b6338a386c0b9de685e359bf22c860451",
      "account": "0x5E46077F3DD9462D9F559FF38F76d54F762e79fF",
      "nonce": 11
    }
  ],
  "bundleHash": "0x94f1df8382cf4d6807bc27fd54616ebed3f64db4d0d73c3a0bef18a12fa54e61"
}
 */
const flashbots_bundle = async () => {
    const CHAIN_ID = 5; // goerli测试网，如果用主网，chainid 改为 1

    // 2. flashbots声誉私钥，用于建立“声誉”，详情见: https://docs.flashbots.net/flashbots-auction/searchers/advanced/reputation
    // !!!注意: 这个账户，不要储存资金，也不是flashbots主私钥。
    // const authKey = '0x227dbb8586117d55284e26620bc76534dfbd2394be34cf4a09cb775d593b6f2c'
    const authKey = '0x2000000000000000000000000000000000000000000000000000000000000000'   // 这个key 也行的 
    const authSigner = new ethers.Wallet(authKey, providerGerli)

    // 3. flashbots rpc（goerli 测试网），用于发送交易
    const flashbotsProvider = await FlashbotsBundleProvider.create(
        providerGerli,
        authSigner,
        // 使用主网 Flashbots，需要把下面两行删去
        'https://relay-goerli.flashbots.net/',
        'goerli'
    );

    console.log("成功创建flashbotsProvider");

    // 4. 创建一笔交易    搞一个新的钱包  为啥?   用于签名交易  
    // 交易: 发送0.001 ETH测试币到 WTF Academy 地址
    const wallet = new ethers.Wallet(privateKey, providerGerli)

    let nonce = await providerGerli.getTransactionCount(wallet.address);
    console.log("nonce: " , nonce);

    let feeData = await providerGerli.getFeeData();
    console.log("fee data: ", feeData);

    // EIP 1559 transaction
    const transaction0 = {
        type: 2,
        nonce, nonce, 
        to: "0x25df6DA2f4e5C178DdFF45038378C0b08E0Bce54",
        value: ethers.utils.parseEther("0.001"),
        maxPriorityFeePerGas: feeData["maxPriorityFeePerGas"],
        maxFeePerGas: feeData["maxFeePerGas"],
        gasLimit: "21000",
        chainId: CHAIN_ID,
    }

    // 5. 创建交易 Bundle
    const transactionBundle = [
        {
            signer: wallet, // ethers signer
            transaction: transaction0 // ethers populated transaction object
        }
        // 也可以加入mempool中签名好的交易（可以是任何人发送的）
        // ,{
        //     signedTransaction: SIGNED_ORACLE_UPDATE_FROM_PENDING_POOL // serialized signed transaction hex
        // }
    ]
    console.log("成功创建transactionBundle   开始模拟交易");

    // 6. 模拟交易，交易模拟成功后才能执行
    const signedTransactions = await flashbotsProvider.signBundle(transactionBundle)  // 签名交易
    const targetBlockNumber = (await providerGerli.getBlockNumber()) + 1     // 设置交易的目标执行区块（在哪个区块执行）
    const simulation = await flashbotsProvider.simulate(signedTransactions, targetBlockNumber) // 模拟
    // 检查模拟是否成功
    if ("error" in simulation) {
        console.log(`模拟交易出错: ${simulation.error.message}`);
    } else {
        console.log(`模拟交易成功`);
        console.log(JSON.stringify(simulation, null, 2))
    }

    console.log("开始上测试网Flashbots 上链  循环100个区块 ");
    // 7. 发送交易上链
    // 因为测试网Flashbots的节点很少，需要尝试很多次才能成功上链，这里我们循环发送 100 个区块。
    for (let i = 1; i <= 100; i++) {
        let targetBlockNumberNew = targetBlockNumber + i - 1;
        // 发送交易
        console.log("区块 ", targetBlockNumberNew);
        const res = await flashbotsProvider.sendRawBundle(signedTransactions, targetBlockNumberNew);
        if ("error" in res) {
            throw new Error(res.error.message);
        }
        // 检查交易是否上链
        const bundleResolution = await res.wait();
        // 交易有三个状态: 成功上链/没有上链/Nonce过高。
        if (bundleResolution === FlashbotsBundleResolution.BundleIncluded) {  // 成功
            console.log(`恭喜, 交易成功上链，区块: ${targetBlockNumberNew}`);
            console.log(JSON.stringify(res, null, 2));
            process.exit(0);
        } else if (bundleResolution === FlashbotsBundleResolution.BlockPassedWithoutInclusion) { //失败
            console.log(`请重试, 交易没有被纳入区块: ${targetBlockNumberNew}`);
        } else if (bundleResolution === FlashbotsBundleResolution.AccountNonceTooHigh) {  //nonce太高
            console.log("Nonce 太高，请重新设置");
            process.exit(1);
        }
    }
}
// flashbots_bundle()



/**
关于EIP-1559                https://www.quicknode.com/guides/ethereum-development/transactions/how-to-send-an-eip-1559-transaction/
    在EIP-1559之前，以太坊链上 gas 费用较低的交易通常会长时间悬而未决，因为区块总是充满了支付最高的交易。
    为了消除这种情况，EIP-1559 引入了一个更复杂、更公平的 gas 费用系统，每个区块收取基本费用，并给矿工小费。
    基本费用确保交易被包含在区块中，小费是为了奖励矿工。使用 EIP-1559，区块的气体限制翻了一番。
    EIP-1559 之前 100% 的完整区块在 EIP-1559 之后只有 50% 完整，这意味着有更多的空间进行额外的交易。

        baseFeePerGas：这是协议为每个区块头生成的每种gas的基本费用。
        maxPriorityFeePerGas：由用户设置。这是流向矿工的一部分。用户可以使用此变量为高优先级交易支付额外费用。每当一个区块 100% 满时，这就是交易优先级的决定因素，就像 1559 之前的时代一样。
        maxFeePerGas：由用户设置。这表示用户愿意为交易支付的最大 gas 费用（包括baseFeePerGas + maxPriorityFeePerGas）。一旦交易被确认，maxFeePerGas和baseFeePerGas + maxPriorityFeePerGas之间的差额将退还给交易的用户/发送者
 */

const init = async function () {
    const ethers = require("ethers");
    const wallet = new ethers.Wallet(privateKey);
    const address = wallet.address;
    console.log("Public Address:", address);

    const httpsUrl = "ADD_YOUR_HTTP_URL_HERE";
    console.log("HTTPS Target", httpsUrl);
    const httpsProvider = new ethers.providers.JsonRpcProvider(httpsurl);

    let nonce = await httpsProvider.getTransactionCount(address);
    console.log("Nonce:", nonce);

    let feeData = await httpsProvider.getFeeData();
    console.log("Fee Data:", feeData);

    const tx = {
        type: 2,
        nonce: nonce,
        to: "0x8D97689C9818892B700e27F316cc3E41e17fBeb9", // Address to send to
        maxPriorityFeePerGas: feeData["maxPriorityFeePerGas"], // Recommended maxPriorityFeePerGas
        maxFeePerGas: feeData["maxFeePerGas"], // Recommended maxFeePerGas
        value: ethers.utils.parseEther("0.01"), // .01 ETH
        gasLimit: "21000", // basic transaction costs exactly 21000
        chainId: 42, // Ethereum network id
    };
    console.log("Transaction Data:", tx);

    const signedTx = await wallet.signTransaction(tx);
    console.log("Signed Transaction:", signedTx);

    const txHash = ethers.utils.keccak256(signedTx);
    console.log("Precomputed txHash:", txHash);
    console.log(`https://kovan.etherscan.io/tx/${txHash}`);
    httpsProvider.sendTransaction(signedTx).then(console.log);
};
// init();

