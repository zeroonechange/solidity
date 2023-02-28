
const ethers = require("ethers");
const { exit } = require("process");

const ADDRESS_TEST = "0xAF2a5C615a154d50d41AC93f3903B97547Ca93A6"
const ADDRESS_VITALIK = "vitalik.eth"

// 简单测试下  走主网  查询下别人的余额  这里很卡  VPN开了全局还是很慢  
const main = async () => {
    // const provider = new ethers.providers.Web3Provider(window.ethereum)
    const provider = new ethers.getDefaultProvider();
    // const balance = await provider.getBalance(address_vitalik);  // vitalik的ETH余额
    const balance = await provider.getBalance(ADDRESS_TEST)
    console.log('==============  MMMMMMMMMMMM 你好呀 赛利亚  =================');
    console.log(`ETH Balance of vitalik: ${ethers.utils.formatEther(balance)} ETH`);}
// main()



const ALCHEMY_ID = 'qXFbrurfVJ5Le9N3T3HwEi8Wc06v0Ud3';

// 所以需要第三方的服务  走 alchemy  或者  infura   选择的是 alchemy  因为之前用过
const alchemy_test = async() => {
    const providerETH = new ethers.providers.JsonRpcProvider(`https://eth-mainnet.g.alchemy.com/v2/${ALCHEMY_ID}`); //这是主网  
    console.log("查询ETH余额");
    const balance = await providerETH.getBalance(ADDRESS_TEST);
    console.log(`ETH Balance : ${ethers.utils.formatEther(balance)} ETH`);

    console.log("\n\n查询provider连接到了哪条链")
    const network = await providerETH.getNetwork();
    console.log(network);

    console.log("\n\n查询区块高度")
    const blockNumber = await providerETH.getBlockNumber();
    console.log(blockNumber);

    console.log("\n\n查询当前gas price")
    const gasPrice = await providerETH.getGasPrice();
    console.log(gasPrice);

    console.log("\n\n查询当前建议的gas设置")
    const feeData = await providerETH.getFeeData();
    console.log(feeData);


    console.log("\n\n查询区块信息")
    const block = await providerETH.getBlock(0);
    console.log(block);

    console.log("\n\n给定合约地址查询合约bytecode，例子用的WETH地址")
    const code = await providerETH.getCode("0xc778417e063141139fce010982780140aa0cd5ab");
    console.log(code);

    exit()
}
// alchemy_test()




// 合约交互-READ-读取合约信息     https://etherscan.io/token/0xc02aaa39b223fe8d0a0e5c4f27ead9083c756cc2#readContract
const read_ContractInfo = async() => {
    const providerETH = new ethers.providers.JsonRpcProvider(`https://eth-mainnet.g.alchemy.com/v2/${ALCHEMY_ID}`);
    const addressWETH = '0xc02aaa39b223fe8d0a0e5c4f27ead9083c756cc2' // WETH Contract
    const abiWETH = '[{"constant":true,"inputs":[],"name":"name","outputs":[{"name":"","type":"string"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":false,"inputs":[{"name":"guy","type":"address"},{"name":"wad","type":"uint256"}],"name":"approve","outputs":[{"name":"","type":"bool"}],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":true,"inputs":[],"name":"totalSupply","outputs":[{"name":"","type":"uint256"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":false,"inputs":[{"name":"src","type":"address"},{"name":"dst","type":"address"},{"name":"wad","type":"uint256"}],"name":"transferFrom","outputs":[{"name":"","type":"bool"}],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":false,"inputs":[{"name":"wad","type":"uint256"}],"name":"withdraw","outputs":[],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":true,"inputs":[],"name":"decimals","outputs":[{"name":"","type":"uint8"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":true,"inputs":[{"name":"","type":"address"}],"name":"balanceOf","outputs":[{"name":"","type":"uint256"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":true,"inputs":[],"name":"symbol","outputs":[{"name":"","type":"string"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":false,"inputs":[{"name":"dst","type":"address"},{"name":"wad","type":"uint256"}],"name":"transfer","outputs":[{"name":"","type":"bool"}],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":false,"inputs":[],"name":"deposit","outputs":[],"payable":true,"stateMutability":"payable","type":"function"},{"constant":true,"inputs":[{"name":"","type":"address"},{"name":"","type":"address"}],"name":"allowance","outputs":[{"name":"","type":"uint256"}],"payable":false,"stateMutability":"view","type":"function"},{"payable":true,"stateMutability":"payable","type":"fallback"},{"anonymous":false,"inputs":[{"indexed":true,"name":"src","type":"address"},{"indexed":true,"name":"guy","type":"address"},{"indexed":false,"name":"wad","type":"uint256"}],"name":"Approval","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"name":"src","type":"address"},{"indexed":true,"name":"dst","type":"address"},{"indexed":false,"name":"wad","type":"uint256"}],"name":"Transfer","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"name":"dst","type":"address"},{"indexed":false,"name":"wad","type":"uint256"}],"name":"Deposit","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"name":"src","type":"address"},{"indexed":false,"name":"wad","type":"uint256"}],"name":"Withdrawal","type":"event"}]';
    const contractWETH = new ethers.Contract(addressWETH, abiWETH, providerETH)
    
    const nameWETH = await contractWETH.name()
    const symbolWETH = await contractWETH.symbol()
    const totalSupplyWETH = await contractWETH.totalSupply()

    console.log("\n1. 读取WETH合约信息")
    console.log(`合约地址: ${addressWETH}`)
    console.log(`名称: ${nameWETH}`)
    console.log(`代号: ${symbolWETH}`)
    console.log(`总供给: ${ethers.utils.formatEther(totalSupplyWETH)}`)
    const balanceWETH = await contractWETH.balanceOf(ADDRESS_VITALIK)
    console.log(`Vitalik持仓: ${ethers.utils.formatEther(balanceWETH)}\n`)


    const abiERC20 = [
        "function name() view returns (string)",
        "function symbol() view returns (string)",
        "function totalSupply() view returns (uint256)",
        "function balanceOf(address) view returns (uint)",
    ];
    const addressDAI = '0x6B175474E89094C44Da98b954EedeAC495271d0F' // DAI Contract
    const contractDAI = new ethers.Contract(addressDAI, abiERC20, providerETH)
    const nameDAI = await contractDAI.name()
    const symbolDAI = await contractDAI.symbol()
    const totalSupplDAI = await contractDAI.totalSupply()
    console.log("\n2. 读取DAI合约的链上信息（IERC20接口合约）")
    console.log(`合约地址: ${addressDAI}`)
    console.log(`名称: ${nameDAI}`)
    console.log(`代号: ${symbolDAI}`)
    console.log(`总供给: ${ethers.utils.formatEther(totalSupplDAI)}`)
    const balanceDAI = await contractDAI.balanceOf('vitalik.eth')
    console.log(`Vitalik持仓: ${ethers.utils.formatEther(balanceDAI)}\n`)

    exit()
}
// read_ContractInfo()




//发送ETH   介绍Signer签名者类和它派生的Wallet钱包类，并利用它来发送ETH
//Wallet类继承了Signer类，并且开发者可以像包含私钥的外部拥有帐户（EOA）一样，用它对交易和消息进行签名。
//方法1：创建随机的wallet对象
//方法2：用私钥创建wallet对象
//方法3：从助记词创建wallet对象
//其他方法：通过JSON文件创建wallet对象

const ALCHEMY_GOERLI_URL = 'https://eth-goerli.g.alchemy.com/v2/ybl4NUkj7Q4_odQ1NWNL2ZyYCFcOMSd5';  //这是 goerli 测试网
const privateKey = 'a028b80f557f2ff8edd2b39fe749b21c10669d78381df8c6e2f2afc362efa1ee'

const sent_ETH = async() => {
    // 利用Alchemy的rpc节点连接以太坊测试网络
    const providerGerli = new ethers.providers.JsonRpcProvider(ALCHEMY_GOERLI_URL);

    // 1 创建随机的wallet对象
    const wallet1 = ethers.Wallet.createRandom()
    const wallet1WithProvider = wallet1.connect(providerGerli)
    const mnemonic = wallet1.mnemonic // 获取助记词

    // 2 利用私钥和provider创建wallet对象
    const wallet2 = new ethers.Wallet(privateKey, providerGerli)

    // 3 从助记词创建wallet对象
    const wallet3 = new ethers.Wallet.fromMnemonic(mnemonic.phrase)

     // 1. 获取钱包地址
     const address1 = await wallet1.getAddress()
     const address2 = await wallet2.getAddress() 
     const address3 = await wallet3.getAddress() // 获取地址
     console.log(`1. 获取钱包地址`);
     console.log(`钱包1地址: ${address1}`);
     console.log(`钱包2地址: ${address2}`);
     console.log(`钱包3地址: ${address3}`);
     console.log(`钱包1和钱包3的地址是否相同: ${address1 === address3}`);
     
     // 2. 获取助记词
    console.log(`\n2. 获取助记词`);
    console.log(`钱包1助记词: ${wallet1.mnemonic.phrase}`)
    // 注意：从private key生成的钱包没有助记词
    // console.log(wallet2.mnemonic.phrase)

    // 3. 获取私钥
    console.log(`\n3. 获取私钥`);
    console.log(`钱包1私钥: ${wallet1.privateKey}`)
    console.log(`钱包2私钥: ${wallet2.privateKey}`)

    // exit()

    // 4. 获取链上发送交易次数    
    console.log(`\n4. 获取链上交易次数`);
    const txCount1 = await wallet1WithProvider.getTransactionCount()
    const txCount2 = await wallet2.getTransactionCount()
    console.log(`钱包1发送交易次数: ${txCount1}`)
    console.log(`钱包2发送交易次数: ${txCount2}`)

    // 5. 发送ETH
    // 1. chainlink水龙头: https://faucets.chain.link/goerli
    // 2. paradigm水龙头: https://faucet.paradigm.xyz/
    console.log(`\n5. 发送ETH（测试网）`);
    // i. 打印交易前余额
    console.log(`i. 发送前余额`)
    console.log(`钱包1: ${ethers.utils.formatEther(await wallet1WithProvider.getBalance())} ETH`)
    console.log(`钱包2: ${ethers.utils.formatEther(await wallet2.getBalance())} ETH`)
    // ii. 构造交易请求，参数：to为接收地址，value为ETH数额
    const tx = {
        to: address1,
        value: ethers.utils.parseEther("0.001")
    }
    // iii. 发送交易，获得收据
    console.log(`\nii. 等待交易在区块链确认（需要几分钟）`)
    const receipt = await wallet2.sendTransaction(tx)
    await receipt.wait() // 等待链上确认交易
    console.log(receipt) // 打印交易详情
    // iv. 打印交易后余额
    console.log(`\niii. 发送后余额`)
    console.log(`钱包1: ${ethers.utils.formatEther(await wallet1WithProvider.getBalance())} ETH`)
    console.log(`钱包2: ${ethers.utils.formatEther(await wallet2.getBalance())} ETH`)

    exit()
}
// sent_ETH()



// 合约交互-WRITE-往合约写入信息 
const writeContract = async() => {
    const providerGerli = new ethers.providers.JsonRpcProvider(ALCHEMY_GOERLI_URL);
    // 利用私钥和provider创建wallet对象
    const wallet = new ethers.Wallet(privateKey, providerGerli)

    // ERC20的人类可读abi
    const abiERC20 = [
        "constructor(string memory name_, string memory symbol_)",
        "function name() view returns (string)",
        "function symbol() view returns (string)",
        "function totalSupply() view returns (uint256)",
        "function balanceOf(address) view returns (uint)",
        "function transfer(address to, uint256 amount) external returns (bool)",
        "function mint(uint amount) external",
    ];

    // 合约字节码，在remix中，你可以在两个地方找到Bytecode
    // 1. 部署面板的Bytecode按钮
    // 2. 文件面板artifact文件夹下与合约同名的json文件中
    // 里面"object"字段对应的数据就是Bytecode，挺长的，608060起始
    // "object": "608060405260646000553480156100...
    const bytecodeERC20 = "60806040526012600560006101000a81548160ff021916908360ff1602179055503480156200002d57600080fd5b5060405162001166380380620011668339818101604052810190620000539190620001bb565b81600390805190602001906200006b9291906200008d565b508060049080519060200190620000849291906200008d565b505050620003c4565b8280546200009b90620002d5565b90600052602060002090601f016020900481019282620000bf57600085556200010b565b82601f10620000da57805160ff19168380011785556200010b565b828001600101855582156200010b579182015b828111156200010a578251825591602001919060010190620000ed565b5b5090506200011a91906200011e565b5090565b5b80821115620001395760008160009055506001016200011f565b5090565b6000620001546200014e8462000269565b62000240565b905082815260208101848484011115620001735762000172620003a4565b5b620001808482856200029f565b509392505050565b600082601f830112620001a0576200019f6200039f565b5b8151620001b28482602086016200013d565b91505092915050565b60008060408385031215620001d557620001d4620003ae565b5b600083015167ffffffffffffffff811115620001f657620001f5620003a9565b5b620002048582860162000188565b925050602083015167ffffffffffffffff811115620002285762000227620003a9565b5b620002368582860162000188565b9150509250929050565b60006200024c6200025f565b90506200025a82826200030b565b919050565b6000604051905090565b600067ffffffffffffffff82111562000287576200028662000370565b5b6200029282620003b3565b9050602081019050919050565b60005b83811015620002bf578082015181840152602081019050620002a2565b83811115620002cf576000848401525b50505050565b60006002820490506001821680620002ee57607f821691505b6020821081141562000305576200030462000341565b5b50919050565b6200031682620003b3565b810181811067ffffffffffffffff8211171562000338576200033762000370565b5b80604052505050565b7f4e487b7100000000000000000000000000000000000000000000000000000000600052602260045260246000fd5b7f4e487b7100000000000000000000000000000000000000000000000000000000600052604160045260246000fd5b600080fd5b600080fd5b600080fd5b600080fd5b6000601f19601f8301169050919050565b610d9280620003d46000396000f3fe608060405234801561001057600080fd5b50600436106100a95760003560e01c806342966c681161007157806342966c681461016857806370a082311461018457806395d89b41146101b4578063a0712d68146101d2578063a9059cbb146101ee578063dd62ed3e1461021e576100a9565b806306fdde03146100ae578063095ea7b3146100cc57806318160ddd146100fc57806323b872dd1461011a578063313ce5671461014a575b600080fd5b6100b661024e565b6040516100c39190610b02565b60405180910390f35b6100e660048036038101906100e19190610a14565b6102dc565b6040516100f39190610ae7565b60405180910390f35b6101046103ce565b6040516101119190610b24565b60405180910390f35b610134600480360381019061012f91906109c1565b6103d4565b6040516101419190610ae7565b60405180910390f35b610152610583565b60405161015f9190610b3f565b60405180910390f35b610182600480360381019061017d9190610a54565b610596565b005b61019e60048036038101906101999190610954565b61066d565b6040516101ab9190610b24565b60405180910390f35b6101bc610685565b6040516101c99190610b02565b60405180910390f35b6101ec60048036038101906101e79190610a54565b610713565b005b61020860048036038101906102039190610a14565b6107ea565b6040516102159190610ae7565b60405180910390f35b61023860048036038101906102339190610981565b610905565b6040516102459190610b24565b60405180910390f35b6003805461025b90610c88565b80601f016020809104026020016040519081016040528092919081815260200182805461028790610c88565b80156102d45780601f106102a9576101008083540402835291602001916102d4565b820191906000526020600020905b8154815290600101906020018083116102b757829003601f168201915b505050505081565b600081600160003373ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff16815260200190815260200160002060008573ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff168152602001908152602001600020819055508273ffffffffffffffffffffffffffffffffffffffff163373ffffffffffffffffffffffffffffffffffffffff167f8c5be1e5ebec7d5bd14f71427d1e84f3dd0314c0f7b2291e5b200ac8c7c3b925846040516103bc9190610b24565b60405180910390a36001905092915050565b60025481565b600081600160008673ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff16815260200190815260200160002060003373ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff16815260200190815260200160002060008282546104629190610bcc565b92505081905550816000808673ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff16815260200190815260200160002060008282546104b79190610bcc565b92505081905550816000808573ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff168152602001908152602001600020600082825461050c9190610b76565b925050819055508273ffffffffffffffffffffffffffffffffffffffff168473ffffffffffffffffffffffffffffffffffffffff167fddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef846040516105709190610b24565b60405180910390a3600190509392505050565b600560009054906101000a900460ff1681565b806000803373ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff16815260200190815260200160002060008282546105e49190610bcc565b9250508190555080600260008282546105fd9190610bcc565b92505081905550600073ffffffffffffffffffffffffffffffffffffffff163373ffffffffffffffffffffffffffffffffffffffff167fddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef836040516106629190610b24565b60405180910390a350565b60006020528060005260406000206000915090505481565b6004805461069290610c88565b80601f01602080910402602001604051908101604052809291908181526020018280546106be90610c88565b801561070b5780601f106106e05761010080835404028352916020019161070b565b820191906000526020600020905b8154815290600101906020018083116106ee57829003601f168201915b505050505081565b806000803373ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff16815260200190815260200160002060008282546107619190610b76565b92505081905550806002600082825461077a9190610b76565b925050819055503373ffffffffffffffffffffffffffffffffffffffff16600073ffffffffffffffffffffffffffffffffffffffff167fddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef836040516107df9190610b24565b60405180910390a350565b6000816000803373ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff168152602001908152602001600020600082825461083a9190610bcc565b92505081905550816000808573ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff168152602001908152602001600020600082825461088f9190610b76565b925050819055508273ffffffffffffffffffffffffffffffffffffffff163373ffffffffffffffffffffffffffffffffffffffff167fddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef846040516108f39190610b24565b60405180910390a36001905092915050565b6001602052816000526040600020602052806000526040600020600091509150505481565b60008135905061093981610d2e565b92915050565b60008135905061094e81610d45565b92915050565b60006020828403121561096a57610969610d18565b5b60006109788482850161092a565b91505092915050565b6000806040838503121561099857610997610d18565b5b60006109a68582860161092a565b92505060206109b78582860161092a565b9150509250929050565b6000806000606084860312156109da576109d9610d18565b5b60006109e88682870161092a565b93505060206109f98682870161092a565b9250506040610a0a8682870161093f565b9150509250925092565b60008060408385031215610a2b57610a2a610d18565b5b6000610a398582860161092a565b9250506020610a4a8582860161093f565b9150509250929050565b600060208284031215610a6a57610a69610d18565b5b6000610a788482850161093f565b91505092915050565b610a8a81610c12565b82525050565b6000610a9b82610b5a565b610aa58185610b65565b9350610ab5818560208601610c55565b610abe81610d1d565b840191505092915050565b610ad281610c3e565b82525050565b610ae181610c48565b82525050565b6000602082019050610afc6000830184610a81565b92915050565b60006020820190508181036000830152610b1c8184610a90565b905092915050565b6000602082019050610b396000830184610ac9565b92915050565b6000602082019050610b546000830184610ad8565b92915050565b600081519050919050565b600082825260208201905092915050565b6000610b8182610c3e565b9150610b8c83610c3e565b9250827fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff03821115610bc157610bc0610cba565b5b828201905092915050565b6000610bd782610c3e565b9150610be283610c3e565b925082821015610bf557610bf4610cba565b5b828203905092915050565b6000610c0b82610c1e565b9050919050565b60008115159050919050565b600073ffffffffffffffffffffffffffffffffffffffff82169050919050565b6000819050919050565b600060ff82169050919050565b60005b83811015610c73578082015181840152602081019050610c58565b83811115610c82576000848401525b50505050565b60006002820490506001821680610ca057607f821691505b60208210811415610cb457610cb3610ce9565b5b50919050565b7f4e487b7100000000000000000000000000000000000000000000000000000000600052601160045260246000fd5b7f4e487b7100000000000000000000000000000000000000000000000000000000600052602260045260246000fd5b600080fd5b6000601f19601f8301169050919050565b610d3781610c00565b8114610d4257600080fd5b50565b610d4e81610c3e565b8114610d5957600080fd5b5056fea2646970667358221220f87d0662c51e3b4b5e034fe8e1e7a10185cda3c246a5ba78e0bafe683d67789764736f6c63430008070033";

    const factoryERC20 = new ethers.ContractFactory(abiERC20, bytecodeERC20, wallet);

     // 读取钱包内ETH余额
     const balanceETH = await wallet.getBalance()

     // 如果钱包ETH足够
     if(ethers.utils.formatEther(balanceETH) > 0.002){
         // 1. 利用contractFactory部署ERC20代币合约
         console.log("\n1. 利用contractFactory部署ERC20代币合约")
         // 部署合约，填入constructor的参数
         const contractERC20 = await factoryERC20.deploy("WTF Token", "WTF")
         console.log(`合约地址: ${contractERC20.address}`);
         console.log("部署合约的交易详情")
         console.log(contractERC20.deployTransaction)
         console.log("\n等待合约部署上链")
         await contractERC20.deployed()
         
         // 也可以用 contractERC20.deployTransaction.wait()
         console.log(`合约已上链 地址是: ${contractERC20.address}`)
 
         // 2. 打印合约的name()和symbol()，然后调用mint()函数，给自己地址mint 10,000代币
         console.log("\n2. 调用mint()函数，给自己地址mint 10,000代币")
         console.log(`合约名称: ${await contractERC20.name()}`)
         console.log(`合约代号: ${await contractERC20.symbol()}`)
         let tx = await contractERC20.mint("10000")
         console.log("等待交易上链")
         await tx.wait()
         console.log(`mint后地址中代币余额: ${await contractERC20.balanceOf(wallet.address)}`)
         console.log(`代币总供给: ${await contractERC20.totalSupply()}`)
 
         // 3. 调用transfer()函数，给V神转账1000代币
         console.log("\n3. 调用transfer()函数，给V神转账1,000代币")
         tx = await contractERC20.transfer("vitalik.eth", "1000")
         console.log("等待交易上链")
         await tx.wait()
         console.log(`V神钱包中的代币余额: ${await contractERC20.balanceOf("vitalik.eth")}`)
     }else{
         // 如果ETH不足
         console.log("ETH不足，去水龙头领一些Goerli ETH")
         console.log("1. chainlink水龙头: https://faucets.chain.link/goerli")
         console.log("2. paradigm水龙头: https://faucet.paradigm.xyz/")
     }   

     exit()
}
// writeContract()


/** 
 检索事件
 智能合约释放出的事件存储于以太坊虚拟机的日志中。日志分为两个主题topics和数据data部分，其中事件哈希和indexed变量存储在topics中，作为索引方便以后搜索；
 没有indexed变量存储在data中，不能被直接检索，但可以存储更复杂的数据结构。
 event Transfer(address indexed from, address indexed to, uint256 amount);

{
  blockNumber: 8570943,
  blockHash: '0xb5362fd076052b793ea751c91b63a2db843a5c42b72236139848c37f436e064b',
  transactionIndex: 50,
  removed: false,
  address: '0xB4FBF271143F4FBf7B91A5ded31805e42b2208d6',
  data: '0x000000000000000000000000000000000000000000000000ebee346af5ae7f1d',
  topics: [
    '0xddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef',
    '0x0000000000000000000000007a250d5630b4cf539739df2c5dacb4c659f2488d',
    '0x00000000000000000000000088124ef4a9ec47e691f254f2e8e348fd1e341e9b'
  ],
  transactionHash: '0xd84d4a119d12e324364eef2dd12e75675dd656505d1d7f43f73165c262efd298',
  getTransactionReceipt: [Function (anonymous)],
  event: 'Transfer',
  eventSignature: 'Transfer(address,address,uint256)',
  decode: [Function (anonymous)],
  args: [
    '0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D',
    '0x88124Ef4A9EC47e691F254F2E8e348fd1e341e9B',
    BigNumber { _hex: '0xebee346af5ae7f1d', _isBigNumber: true },
    from: '0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D',
    to: '0x88124Ef4A9EC47e691F254F2E8e348fd1e341e9B',
    amount: BigNumber { _hex: '0xebee346af5ae7f1d', _isBigNumber: true }
  ]
}
 */
const query_event = async() => {
    const providerGerli = new ethers.providers.JsonRpcProvider(ALCHEMY_GOERLI_URL);
    const abiWETH = [
        "event Transfer(address indexed from, address indexed to, uint amount)"
    ];
    // 测试网WETH地址
    const addressWETH = '0xb4fbf271143f4fbf7b91a5ded31805e42b2208d6'
    // 声明合约实例
    const contract = new ethers.Contract(addressWETH, abiWETH, providerGerli)
    // 获取过去10个区块内的Transfer事件
    console.log("\n1. 获取过去10个区块内的Transfer事件，并打印出1个");
    // 得到当前block
    const block = await providerGerli.getBlockNumber()
    console.log(`当前区块高度: ${block}`);
    console.log(`打印事件详情:`);
    const transferEvents = await contract.queryFilter('Transfer', block - 10, block)
    // 打印第1个Transfer事件
    console.log(transferEvents[0])

    // 解析Transfer事件的数据（变量在args中）
    console.log("\n2. 解析事件：")
    const amount = ethers.utils.formatUnits(ethers.BigNumber.from(transferEvents[0].args["amount"]), "ether");
    // 地址 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D 转账17.000583277363232541 WETH 到地址 0x88124Ef4A9EC47e691F254F2E8e348fd1e341e9B 
    // 0xebee346af5ae7f1d =》 17000583277363233000 
    console.log(`地址 ${transferEvents[0].args["from"]} 转账${amount} WETH 到地址 ${transferEvents[0].args["to"]}`)
    exit()
}
// query_event()




/**
 监听合约事件
 持续监听合约的事件     ：   contract.on("eventName", function)
 只监听一次合约释放事件 ：    contract.once("eventName", function)
 
 监听USDT合约
 */
const observe_usdt_event = async() => {
    const providerETH = new ethers.providers.JsonRpcProvider(`https://eth-mainnet.g.alchemy.com/v2/${ALCHEMY_ID}`);
    // USDT的合约地址
    const contractAddress = '0xdac17f958d2ee523a2206206994597c13d831ec7'
    // 构建USDT的Transfer的ABI
    const abi = [
    "event Transfer(address indexed from, address indexed to, uint value)"
    ];
    // 生成USDT合约对象
    const contractUSDT = new ethers.Contract(contractAddress, abi, providerETH);
    var count = 0
    try{
        console.log("\n1. 利用contract.once()，监听一次Transfer事件");
        contractUSDT.once('Transfer', (from, to, value)=>{          // 只监听一次
          console.log(`once -->    ${from} -> ${to} ${ethers.utils.formatUnits(ethers.BigNumber.from(value),6)}`)
        })
       
        console.log("\n2. 利用contract.on()，持续监听Transfer事件");
        contractUSDT.on('Transfer', (from, to, value)=>{     // 持续监听USDT合约
          console.log( `${from} -> ${to} ${ethers.utils.formatUnits(ethers.BigNumber.from(value),6)}`)
          if(count++ > 10) {
            exit()
          }
        })
      }catch(e){
        console.log(e);
      }     
}
// observe_usdt_event()


/**
 事件过滤
 当合约创建日志（释放事件）时，它最多可以包含[4]条数据作为索引（indexed）  索引数据经过哈希处理并包含在布隆过滤器中
              [X,X,X,X]  
 topic[0]=A                              [A]   [A,NULL]  
 topic[1]=B                              [NULL, B]   [NULL, [B]] [NULL, [B], NULL]
 (topic[0] = A) AND (topic[1] = B)       [A,B]  [A,[B]]  [A,[ B], null]
 (topic[0] = A) OR (topic[0] = B)        [[A, B]]    [[A, B], null]
 [(topic[O] = A) OR (topic[O] = B)]AND[(topic[1] = C) OR (topic[1] = D)]      [[AB],[C,D]]

 过滤器详情:
 {
  address: '0xdac17f958d2ee523a2206206994597c13d831ec7',
  topics: [
    '0xddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef',
    null,
    '0x00000000000000000000000028c6c06298d514db089934071355e5743bf21d60'
  ]
}

用它监听任何你感兴趣的交易，发现smart money做了哪些新交易，NFT大佬冲了哪些新项目
 */
const filter_event = async() => {
    const providerETH = new ethers.providers.JsonRpcProvider(`https://eth-mainnet.g.alchemy.com/v2/${ALCHEMY_ID}`);
    // 合约地址
    const addressUSDT = '0xdac17f958d2ee523a2206206994597c13d831ec7'
    // 交易所地址
    const accountBinance = '0x28C6c06298d514Db089934071355E5743bf21d60'
    const abi = [
        "event Transfer(address indexed from, address indexed to, uint value)",
        "function balanceOf(address) public view returns(uint)",
      ];
    const contractUSDT = new ethers.Contract(addressUSDT, abi, providerETH);
    try {
        // 1. 读取币安热钱包USDT余额
        console.log("\n1. 读取币安热钱包USDT余额")
        const balanceUSDT = await contractUSDT.balanceOf(accountBinance)
        console.log(`USDT余额: ${ethers.utils.formatUnits(ethers.BigNumber.from(balanceUSDT), 6)}\n`)
    
        // 2. 创建过滤器，监听转移USDT进交易所
        console.log("\n2. 创建过滤器，监听转移USDT进交易所")
        let filterBinanceIn = contractUSDT.filters.Transfer(null, accountBinance);
        console.log("过滤器详情：")  
        console.log(filterBinanceIn);

        contractUSDT.on(filterBinanceIn, (from, to, value) => {
          console.log(`---------进入-------->>>  ${from} -> ${to} ${ethers.utils.formatUnits(ethers.BigNumber.from(value), 6)}`)
        }).on('error', (error) => {
          console.log(error)
        })
    
        // 3. 创建过滤器，监听交易所转出USDT
        let filterToBinanceOut = contractUSDT.filters.Transfer(accountBinance, null);
        console.log("\n3. 创建过滤器，监听转移USDT出交易所")
        console.log("过滤器详情：")
        console.log(filterToBinanceOut);

        contractUSDT.on(filterToBinanceOut, (from, to, value) => {
          console.log(`---------转出--------<<< ${from} -> ${to} ${ethers.utils.formatUnits(ethers.BigNumber.from(value), 6)}`)
        }).on('error', (error) => {
          console.log(error)
        });
      } catch (e) {
        console.log(e);
      }    
}
// filter_event()



/**
 BigNumber和单位转换
 以太坊中，许多计算都对超出JavaScript整数的安全值（js中最大安全整数为9007199254740991）。因此，ethers.js使用BigNumber类安全地对任何数量级的数字进行数学运算

1.利用ethers.BigNumber.from()函数将string，number，BigNumber等类型转换为BigNumber
2.BigNumber支持很多运算，例如加减乘除、取模mod，幂运算pow，绝对值abs等运算：
3.单位转换   1 ether等于10^18 wei
    formatUnits(变量, 单位)：格式化，小单位转大单位，比如wei -> ether，在显示余额时很有用
    parseUnits：解析，大单位转小单位，比如ether -> wei，在将用户输入的值转为wei为单位的数值很有用

 name    decimals 
  wei       0
  kwei      3
  mwei      6
  gwei      9
  szabo     12
  finney    15
  ether     18
 */

const unit_transfer = async() => {

  // 1. BigNumber
  console.group('\n1. BigNumber类');

  const oneGwei = ethers.BigNumber.from("1000000000"); // 从十进制字符串生成
  console.log(oneGwei)                             // BigNumber { _hex: '0x3b9aca00', _isBigNumber: true } 
  console.log(ethers.BigNumber.from("0x3b9aca00")) // 从hex字符串生成  BigNumber { _hex: '0x3b9aca00', _isBigNumber: true }
  console.log(ethers.BigNumber.from(1000000000)) // 从数字生成    BigNumber { _hex: '0x3b9aca00', _isBigNumber: true }
  // 不能从js最大的安全整数之外的数字生成BigNumber，下面代码会报错
  // ethers.BigNumber.from(Number.MAX_SAFE_INTEGER);
  console.log("js中最大安全整数：", Number.MAX_SAFE_INTEGER)   // js中最大安全整数： 9007199254740991

  // 运算
  console.log("加法：", oneGwei.add(1).toString())  // 加法： 1000000001
  console.log("减法：", oneGwei.sub(1).toString())  // 减法： 999999999
  console.log("乘法：", oneGwei.mul(2).toString())  // 乘法： 2000000000
  console.log("除法：", oneGwei.div(2).toString())  // 除法： 500000000
  // 比较
  console.log("是否相等：", oneGwei.eq("1000000000"))// 是否相等： true


  // 2. 格式化：小单位转大单位
  // 例如将wei转换为ether：formatUnits(变量, 单位)：单位填位数（数字）或指定的单位（字符串）
  console.group('\n2. 格式化：小单位转大单位，formatUnits');
  console.log(ethers.utils.formatUnits(oneGwei, 0));         // '1000000000'
  console.log(ethers.utils.formatUnits(oneGwei, "gwei"));    // '1.0'
  console.log(ethers.utils.formatUnits(oneGwei, 9));         // '1.0'
  console.log(ethers.utils.formatUnits(oneGwei, "ether"));   // `0.000000001`
  console.log(ethers.utils.formatUnits(1000000000, "gwei")); // '1.0'
  console.log(ethers.utils.formatEther(oneGwei));            // `0.000000001` 等同于formatUnits(value, "ether")
  console.groupEnd();


  // 3. 解析：大单位转小单位
  // 例如将ether转换为wei：parseUnits(变量, 单位)
  console.group('\n3. 解析：大单位转小单位，parseUnits');
  console.log(ethers.utils.parseUnits("1.0").toString());           // { BigNumber: "1000000000000000000" }
  console.log(ethers.utils.parseUnits("1.0", "ether").toString());  // { BigNumber: "1000000000000000000" }
  console.log(ethers.utils.parseUnits("1.0", 18).toString());       // { BigNumber: "1000000000000000000" }
  console.log(ethers.utils.parseUnits("1.0", "gwei").toString());   // { BigNumber: "1000000000" }
  console.log(ethers.utils.parseUnits("1.0", 9).toString());        // { BigNumber: "1000000000" }
  console.log(ethers.utils.parseEther("1.0").toString());           // { BigNumber: "1000000000000000000" } 等同于parseUnits(value, "ether")
  console.groupEnd();  
}
unit_transfer()




