const { Wallet, providers } = require("ethers");



describe("可升级合约测试", function () {


    // --------------------------------------------------------------------------------


    // --------------------------------------------------------------------------------




    // --------------------------------------------------------------------------------
    // Wallet  钱包实例 
    //加载私钥
    let privateKey = "0x0123456789012345678901234567890123456789012345678901234567890123";
    let wallet = new ethers.Wallet(privateKey);

    // Connect a wallet to mainnet
    let provider = ethers.getDefaultProvider();
    let walletWithProvider = new ethers.Wallet(privateKey, provider);

    //创建一个随机钱包实例
    let randomWallet = ethers.Wallet.createRandom();

    //加载JSON钱包文件
    let data = {
        id: "fb1280c0-d646-4e40-9550-7026b1be504a",
        address: "88a5c2d9919e46f883eb62f7b8dd9d0cc45bc290",
        Crypto: {
            kdfparams: {
                dklen: 32,
                p: 1,
                salt: "bbfa53547e3e3bfcc9786a2cbef8504a5031d82734ecef02153e29daeed658fd",
                r: 8,
                n: 262144
            },
            kdf: "scrypt",
            ciphertext: "10adcc8bcaf49474c6710460e0dc974331f71ee4c7baa7314b4a23d25fd6c406",
            mac: "1cf53b5ae8d75f8c037b453e7c3c61b010225d916768a6b145adf5cf9cb3a703",
            cipher: "aes-128-ctr",
            cipherparams: {
                iv: "1dcdf13e49cea706994ed38804f6d171"
            }
        },
        "version": 3
    };

    let json = JSON.stringify(data);
    let password = "foo";

    ethers.Wallet.fromEncryptedJson(json, password).then(function (wallet) {
        console.log("Address: " + wallet.address);
        // "Address: 0x88a5C2d9919e46F883EB62F7b8Dd9d0CC45bc290"
    });

    //加载助记词
    let mnemonic = "radar blur cabbage chef fix engine embark joy scheme fiction master release";
    let mnemonicWallet = ethers.Wallet.fromMnemonic(mnemonic);

    // Load the second account from a mnemonic
    let path = "m/44'/60'/1'/0/0";
    let secondMnemonicWallet = ethers.Wallet.fromMnemonic(mnemonic, path);

    // Load using a non-english locale wordlist (the path "null" will use the default)
    let secondMnemonicWallet2 = ethers.Wallet.fromMnemonic(mnemonic, null, ethers.wordlists.ko);

    // 属性
    let lbcWallet = ethers.Wallet.createRandom();
    lbcWallet.address;  // "0x863e27dbD608649d08c69F83ccA51b045721f318"
    lbcWallet.privateKey; // "0x8bc2957edb0200357ddc30f681b5e5f235256e2812781f9b06415bbeb1e72b40"
    lbcWallet.mnemonic;
    lbcWallet.path

    //交易签名
    it(" 交易签名 ", async function () {

        let privateKey = "0x3141592653589793238462643383279502884197169399375105820974944592"
        let wallet = new ethers.Wallet(privateKey)

        console.log(wallet.address)  // "0x7357589f8e367c2C31F51242fB77B350A11830F3"

        // All properties are optional
        let transaction = {
            nonce: 0,
            gasLimit: 21000,
            gasPrice: utils.bigNumberify("20000000000"),

            to: "0x88a5C2d9919e46F883EB62F7b8Dd9d0CC45bc290",
            // ... or supports ENS names
            // to: "ricmoo.firefly.eth",

            value: utils.parseEther("1.0"),
            data: "0x",

            // 这可确保无法在不同网络上重复广播
            chainId: ethers.utils.getNetwork('homestead').chainId
        }

        let signPromise = wallet.sign(transaction)

        signPromise.then((signedTransaction) => {

            console.log(signedTransaction);
            // "0xf86c808504a817c8008252089488a5c2d9919e46f883eb62f7b8dd9d0cc45bc2
            //    90880de0b6b3a76400008025a05e766fa4bbb395108dc250ec66c2f88355d240
            //    acdc47ab5dfaad46bcf63f2a34a05b2cb6290fd8ff801d07f6767df63c1c3da7
            //    a7b83b53cd6cea3d3075ef9597d5"

            // 现在可以将其发送到以太坊网络
            let provider = ethers.getDefaultProvider()
            provider.sendTransaction(signedTransaction).then((tx) => {

                console.log(tx);
                // {
                //    // These will match the above values (excluded properties are zero)
                //    "nonce", "gasLimit", "gasPrice", "to", "value", "data", "chainId"
                //
                //    // These will now be present
                //    "from", "hash", "r", "s", "v"
                //  }
                // Hash:
            });
        })
    });


    it("签名文本消息", async function () {
        let privateKey = "0x3141592653589793238462643383279502884197169399375105820974944592"
        let wallet = new ethers.Wallet(privateKey);

        // 签名文本消息
        let signPromise = wallet.signMessage("Hello World!")

        signPromise.then((signature) => {

            // Flat-format
            console.log(signature);
            // "0xea09d6e94e52b48489bd66754c9c02a772f029d4a2f136bba9917ab3042a0474
            //    301198d8c2afb71351753436b7e5a420745fed77b6c3089bbcca64113575ec3c
            //    1c"

            // Expanded-format
            console.log(ethers.utils.splitSignature(signature));
            // {
            //   r: "0xea09d6e94e52b48489bd66754c9c02a772f029d4a2f136bba9917ab3042a0474",
            //   s: "0x301198d8c2afb71351753436b7e5a420745fed77b6c3089bbcca64113575ec3c",
            //   v: 28,
            //   recoveryParam: 1
            //  }
        });
    });


    it("签名二进制信息", async function () {
        let privateKey = "0x3141592653589793238462643383279502884197169399375105820974944592"
        let wallet = new ethers.Wallet(privateKey);

        // The 66 character hex string MUST be converted to a 32-byte array first!
        let hash = "0x3ea2f1d0abf3fc66cf29eebb70cbd4e7fe762ef8a09bcc06c8edf641230afec0";
        let binaryData = ethers.utils.arrayify(hash);

        let signPromise = wallet.signMessage(binaryData)

        signPromise.then((signature) => {

            console.log(signature);
            // "0x5e9b7a7bd77ac21372939d386342ae58081a33bf53479152c87c1e787c27d06b
            //    118d3eccff0ace49891e192049e16b5210047068384772ba1fdb33bbcba58039
            //    1c"
        });
    });

    it("与链交互", async function () {
        // . getBalance
        // . getTransactionCount 
        // . estimateGas
        // . sendTransaction

        // 查询网络
        // We require a provider to query the network
        let provider = ethers.getDefaultProvider();

        let privateKey = "0x3141592653589793238462643383279502884197169399375105820974944592"
        let wallet = new ethers.Wallet(privateKey, provider);

        let balancePromise = wallet.getBalance();

        balancePromise.then((balance) => {
            console.log(balance);
        });

        let transactionCountPromise = wallet.getTransactionCount();

        transactionCountPromise.then((transactionCount) => {
            console.log(transactionCount);
        });

        it("发送以太", async function () {
            // We require a provider to send transactions
            let provider = ethers.getDefaultProvider();

            let privateKey = "0x3141592653589793238462643383279502884197169399375105820974944592"
            let wallet = new ethers.Wallet(privateKey, provider);

            let amount = ethers.utils.parseEther('1.0');

            let tx = {
                to: "0x88a5c2d9919e46f883eb62f7b8dd9d0cc45bc290",
                // ... or supports ENS names
                // to: "ricmoo.firefly.eth",

                // We must pass in the amount as wei (1 ether = 1e18 wei), so we
                // use this convenience function to convert ether to wei.
                value: ethers.utils.parseEther('1.0')
            };

            let sendPromise = wallet.sendTransaction(tx);

            sendPromise.then((tx) => {
                console.log(tx);
                // {
                //    // All transaction fields will be present
                //    "nonce", "gasLimit", "pasPrice", "to", "value", "data",
                //    "from", "hash", "r", "s", "v"
                // }
            });
        });
    });

    // 很多系统以各种格式将私钥存储为加密的JSON钱包文件（keystore）。 keystore有好几个使用的格式和算法，ethers.js 都能够支持。
    // prototype . encrypt ( password [ , options [ , progressCallback ] ] )   =>   Promise<string>
    /**
    参数 options 是可选的，有效选项如下：
        salt — scrypt （一个秘钥衍生算法） 的盐
        iv — aes-ctr-128 需要使用的初始化矢量
        uuid — 钱包要用的 UUID
        scrypt — scrypt 算法的参数 (N, r 及 p)
        entropy — 通常不指定，钱包的助记词熵;
        mnemonic — 通常不指定，钱包的助记词
        path — t通常不指定，钱包的助记词路径 
     * 
     */
});