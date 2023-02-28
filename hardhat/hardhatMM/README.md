# Sample Hardhat Project
 
 

https://hardhat.org/hardhat-runner/docs/getting-started#overview



## 高阶玩法 

```shell
Hardhat Runtime Environment (HRE)
    HRE = Hardhat Runtime Environment
    added to the HRE. This includes tasks, configs and plugins
    const hardhat = require(\"hardhat\"))  == you re getting an instance of the HRE.
    use require(\"hardhat\") to import the HRE.
    HRE only provides the core functionality
    hook into the HRE construction
    Hardhat lets you hook into the HRE construction, and extend it with new functionality. This way, you only have to initialize everything once, and your new features or libraries will be available everywhere the HRE is used.
    总结: 运行环境 获取环境实例  可以让你 hook 在这个基础上扩展 写自己的东西  只需要初始化一次  任意的地方都可以用到  任意地方指的是 task script test 

Compilation artifacts
    An artifact has all the information that is necessary to deploy and interact with the contract.
        contractName
        abi
        bytecode
        deployedBytecode
        linkReferences
        deployedLinkReferences
    get a list with the paths to all artifacts by calling hre.artifacts.getArtifactPaths()
    read an artifact using the name of the contract by calling hre.artifacts.readArtifact("Bar")
    use the Fully Qualified Name of the contract: hre.artifacts.readArtifact("contracts/Bar.sol:Bar")
    The debug file has all the information that is necessary to reproduce the compilation and to debug the contracts: this includes the original solc input and output, and the solc version used to compile it.
    contains one artifact (.json) file and one debug (.dbg.json) file for each contract in that file
    总结:  每一个 .sol 文件编译后会得到 俩个json文件  里面包含了很多信息    可以通过 hre获取到这些信息 

Multiple Solidity versions
    可以让A.sol编译用 solidity 0.5.5   B.sol编译用 solidity 0.8.0

Creating a task
    addOptionalParam
    Overriding tasks
    Subtasks

Writing scripts with Hardhat
    arguments
        HARDHAT_NETWORK: Sets the network to connect to.
        HARDHAT_SHOW_STACK_TRACES: Enables JavaScript stack traces of expected errors.
        HARDHAT_VERBOSE: Enables Hardhat verbose logging.
        HARDHAT_MAX_MEMORY: Sets the maximum amount of memory that Hardhat can use.
    例子:
    instead of doing npx hardhat --network localhost run script.js, you can do HARDHAT_NETWORK=localhost node script.js

Building plugins
    继承 HRE   创建自己的 plugin 


Integrating with Foundry
    using our  @nomicfoundation/hardhat-foundry plugin 
    If you have an existing Hardhat project and you want to use Foundry in it, you should follow these steps.
    If you have an existing Foundry project and you want to use Hardhat in it, follow these steps.

Flattening your contracts
    combine the source code of multiple Solidity files
    合并多个合约的代码到一个文件里面去  

Running tests in Visual Studio Code
    using Mocha Test Explorer     BY    npm install --save-dev mocha
    a file named .mocharc.json:
                    {
                    "require": "hardhat/register",
                    "timeout": 40000,
                    "_": ["test/**/*.ts"]
                    }   
    设置测试的运行参数 


Working with blockchain oracles
    预言机 
        Getting Price Data   
            import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
            priceFeed = AggregatorV3Interface(0xD4a33860578De61DBAbDc8BFdb98FD742fA7028e);
    随机数 Randomness 
        npm install --save-dev @chainlink/hardhat-chainlink
        import "@chainlink/hardhat-chainlink";
    Use blockchain oracles
        Chainlink  - Chainlink decentralized oracle networks provide tamper-proof inputs, outputs, and computations to support advanced smart contracts on any blockchain. 
        Witnet - Witnet is a permissionless, decentralized, and censorship-resistant oracle helping smart contracts to react to real world events with strong crypto-economic guarantees.
        UMA Oracle - UMA\'s optimistic oracle allows smart contracts to quickly and receive any kind of data for different applications, including insurance, financial derivatives, and prediction market. 
        。。。

Verbose logging
    print a lot of output that can be super useful for debugging 
    npx hardhat test --verbose

Common problems
    Out of memory errors when compiling large projects
        npx hardhat --max-memory 4096 compile

Hardhat errors

```






## 基础使用 
```shell

快速创建  {hardhat + ethers.js + typescript}
	npm init -y
	npm install --save-dev hardhat
	npx hardhat
	npm install --save-dev @nomicfoundation/hardhat-toolbox
	npm install --save-dev ts-node typescript
	npx hardhat help
	npx hardhat compile
	npx hardhat test
	npx hardhat node


必备插件
@nomicfoundation/hardhat-toolbox: 
    ethers.js -- interact with the network and with contracts
    hardhat-ethers plugin 
    Mocha -- test runner 
    Chai -- assertion library 
    Hardhat Chai Matchers  -- extend Chai with contracts-related functionality
    Hardhat Network Helpers
    hardhat-etherscan plugin -- Verify the source code
    hardhat-gas-reporter plugin -- Get metrics on the gas used
    TypeScript -> Typechain -- using TypeScript


compile 编译
   编译好的放在 artifacts/ 文件夹下  可以改变路径 
   可以强制编译   npx hardhat compile --force  或者  npx hardhat clean 清除缓存 
   可以在 hardhat.config.ts 中修改编译的配置   和 remix中类似 
   例如:
        solidity: {
            version: "0.8.9",
            settings: {
            optimizer: {
                enabled: true,
                runs: 1000,
            },
            },
        },   


test 测试
    只测试一个文件 可以 npx hardhat test test/my-tests.ts 

    import { time, loadFixture } from "@nomicfoundation/hardhat-network-helpers";   获取最新时间  time.latest  一团 attachment 
    import { anyValue } from "@nomicfoundation/hardhat-chai-matchers/withArgs";     任意值
    import { expect } from "chai";    用于断言 assert  主要是看是否相等 .to.equal  不对劲还能回退  .to.be.revertedWith("XXX") 
    import { ethers } from "hardhat";   ethers.js 

    用await 去获取值  否则就是一个 promise 
    操控网络环境   await time.increaseTo(unlockTime);
    使用不同的账号    const [owner, otherAccount] = await ethers.getSigners();  这个方法返回了很多账号 
    使用 fixtures   部署代码部分复用
    得到测试报告     在测试文件 test/XX.ts 添加 import 'solidity-coverage'  随后运行即可  npx hardhat coverage 

    使用gas 报告   安装 npm install hardhat-gas-reporter --save-dev   在测试文件添加  import "hardhat-gas-reporter"   配置文件添加
                        gasReporter: {
                            enabled: true,
                            currency: 'USD',
                            gasPrice: 20,
                        }   
        最后运行      npx hardhat test   得到 
                            PS C:\Users\Administrator\Desktop\hardhatMM> npx hardhat test

                            Lock
                                Deployment
                                √ Should set the right unlockTime
                                Transfers
                                    √ Should transfer the funds to the owner

                            ·-------------------------|----------------------------|-------------|-----------------------------·
                            |  Solc version: 0.8.17   ·  Optimizer enabled: false  ·  Runs: 200  ·  Block limit: 30000000 gas  │
                            ··························|····························|·············|······························
                            |  Methods                                                                                         │
                            ·············|············|··············|·············|·············|···············|··············
                            |  Contract  ·  Method    ·  Min         ·  Max        ·  Avg        ·  # calls      ·  usd (avg)  │
                            ·············|············|··············|·············|·············|···············|··············
                            |  Lock      ·  withdraw  ·           -  ·          -  ·      34096  ·            7  ·          -  │
                            ·············|············|··············|·············|·············|···············|··············
                            |  Deployments            ·                                          ·  % of limit   ·             │
                            ··························|··············|·············|·············|···············|··············
                            |  Lock                   ·           -  ·          -  ·     326016  ·        1.1 %  ·          -  │
                            ·-------------------------|--------------|-------------|-------------|---------------|-------------·

                            9 passing (2s)  
 
    测试并发运行   npx hardhat test --parallel
    更多请阅读  Mocha docs    有问题去 他们的 Troubleshooting  查看


部署合约
    选择本地节点 npx hardhat node
    用特定的节点 执行特定的脚本  npx hardhat run --network localhost scripts/deploy.ts
    npx hardhat run --network <your-network> scripts/deploy.js


上传源码至Etherscan   ...略


Writing task and scripts 
    常规task: 例如 compile  test   可以添加自己写的 task  在 hardhat.config.ts 中写  然后 npx hardhat taskName 
    scripts: 在 scripts/ 目录下    写好了执行 npx hardhat run scripts/xxx.ts 
    怎么选?  
        如果没啥参数 自动工作流 script最佳   
        如果需要参数  最好是创建 task 
        如果需要访问 hardhat runtime environment 最好 使用 script 


使用 hardhat console 
    导入依赖： import { ethers } from "hardhat";
    在 .ts 中使用:  console.log(`Lock with 1 ETH and unlock timestamp ${unlockTime} deployed to ${lock.address}`);


使用 typescript 
    install:  If you installed @nomicfoundation/hardhat-toolbox     --  using npm 7 or higher, you dont need to follow these steps.
        npm install --save-dev ts-node typescript
        npm install --save-dev chai @types/node @types/mocha @types/chai
    rename config file: mv hardhat.config.js hardhat.config.ts
    配置文件是  tsconfig.json 


从 hardhat-waffle 迁移到 hardhat toolbox    ...略


Getting help
    https://github.com/NomicFoundation/hardhat
    https://discord.com/invite/TETZs2KK4k

```

