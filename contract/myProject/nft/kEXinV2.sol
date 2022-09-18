// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract KEXin is ERC721, ERC721Burnable, Ownable {
    using Counters for Counters.Counter;

    Counters.Counter private _tokenIdCounter;
    uint256 MAX_SUPPLY = 8;

    constructor() ERC721("kEXin", "kEX") {}

    function _baseURI() internal pure override returns (string memory) {
        return "ipfs://QmUuS2crfcMRfHTj6eFfmMHyLsoJy5r6cCDeBjdF8QKJQw/";
    }

    function safeMint(address to) public onlyOwner {
        uint256 tokenId = _tokenIdCounter.current();
        require(tokenId < MAX_SUPPLY, "sry, canot mint anymore, more than 8 already minted");
        _tokenIdCounter.increment();
        _safeMint(to, tokenId);
    }
}

/**

自己再发一套

1.上传图片到 ifps  得到 CID
	QmUQgKka8EW7exiUHnMwZ4UoXA11wV7NFjHAogVAbasSYy
	QmPbxeGcXhYQQNgsC6a36dDyYUcHgMLnGKnF8pVFmGsvqi
	QmXkLGoGKXswr4YwkgPVfL7wmbvkRKabmh7WXmkACrgi68
	QmSg9bPzW9anFYc3wWU5KnvymwkxQTpmqcRSfYj7UmiBa7
	QmVvdAbabZ2awja88uUhYHFuq67iEiroFuwLGM6HyiWcc8
	QmadJd1GgsSgXn7RtrcL8FePionDyf4eQEsREcvdqh6eQe
	QmSQ5AxWbxsHJ4f1YcU4bV5qcwNFj12fAvN9NuCJos6xq4
	QmW3xKzepserVewHFFfCY2ifogiiEzDPvtPEsPmVC97x5M
2.准备json字符串   下标从0 开始 
	{"image":"ipfs://QmUQgKka8EW7exiUHnMwZ4UoXA11wV7NFjHAogVAbasSYy","attributes":[{"trait_type":"Earring","value":"Silver Hoop"},{"trait_type":"Background","value":"Orange"},{"trait_type":"Fur","value":"Robot"},{"trait_type":"Clothes","value":"Striped Tee"},{"trait_type":"Mouth","value":"Discomfort"},{"trait_type":"Eyes","value":"X Eyes"}]}

3.准备一个文件夹  把文件放一起   上传到 ifps 得到 CID 
	QmUuS2crfcMRfHTj6eFfmMHyLsoJy5r6cCDeBjdF8QKJQw
	
4.准备合约 部署   
	baseURI: ipfs://QmUuS2crfcMRfHTj6eFfmMHyLsoJy5r6cCDeBjdF8QKJQw/ 
	
	common 账号  环境 Goerli Test Network 
	合约地址:  0x808ae3F11400f7E4Fc8B6F3D4BA6716feFc2b5ae    
	owner： 0x5D9C8273bce3F1fe86C55c4D0fD4844636279393     privacy key: a40f68e080b908bfe99210d483cf5aa53dd2bde380cfba94f3b2de4149e2a562
	saftmint 一个后  得到 tokenURI  -> ipfs://QmUuS2crfcMRfHTj6eFfmMHyLsoJy5r6cCDeBjdF8QKJQw/0
	https://ipfs.io/ipfs/QmUuS2crfcMRfHTj6eFfmMHyLsoJy5r6cCDeBjdF8QKJQw/0
		{"image":"ipfs://QmUQgKka8EW7exiUHnMwZ4UoXA11wV7NFjHAogVAbasSYy","attributes":[{"trait_type":"Earring","value":"Silver Hoop"},{"trait_type":"Background","value":"Orange"},{"trait_type":"Fur","value":"Robot"},{"trait_type":"Clothes","value":"Striped Tee"},{"trait_type":"Mouth","value":"Discomfort"},{"trait_type":"Eyes","value":"X Eyes"}]}
	https://ipfs.io/ipfs/QmUQgKka8EW7exiUHnMwZ4UoXA11wV7NFjHAogVAbasSYy	  
	
	合约地址区块链  https://goerli.etherscan.io/address/0x808ae3f11400f7e4fc8b6f3d4ba6716fefc2b5ae 
	在 opensea 可以看到  https://testnets.opensea.io/collection/kexin-xkt9hwzeki
    接下来就是上架了  


5.BSC 上架后  opensea 上没有  
    合约地址  0xE3Ef5F09181843316724c8C562fD075f506F03F2
    owner： 0x5D9C8273bce3F1fe86C55c4D0fD4844636279393     privacy key: a40f68e080b908bfe99210d483cf5aa53dd2bde380cfba94f3b2de4149e2a562



1.BAYC - Bored Ape Yacht Club   
	contract address: 0xBC4CA0EdA7647A8aB7C2061c2E118A18a936f13D
	baseURI: ipfs://QmeSjSinHpPnmXmspMjwiXyN6zS4E9zccariGR3jxcaWtq/ 
	example tokenId: #9719
	tokenURI: ipfs://QmeSjSinHpPnmXmspMjwiXyN6zS4E9zccariGR3jxcaWtq/9719

		访问  tokenURI
		https://ipfs.io/ipfs/QmeSjSinHpPnmXmspMjwiXyN6zS4E9zccariGR3jxcaWtq/9719
		得到图片地址:
		{"image":"ipfs://QmQPv7YLw1nbaXJawarFgqu2yqw2gA8Zk2d7gssYHgvPcp","attributes":[{"trait_type":"Fur","value":"Black"},{"trait_type":"Eyes","value":"Crazy"},{"trait_type":"Clothes","value":"Black Holes T"},{"trait_type":"Background","value":"New Punk Blue"},{"trait_type":"Mouth","value":"Bored Unshaven"}]}
		https://ipfs.io/ipfs/QmQPv7YLw1nbaXJawarFgqu2yqw2gA8Zk2d7gssYHgvPcp

		所以 如何 在 ifps 中 弄一个 列表返回呢  也许是 一个大map集合?   
		ipfs://QmeSjSinHpPnmXmspMjwiXyN6zS4E9zccariGR3jxcaWtq/tokenId 


2.OTHR - Otherdeed for Otherside
	contract address: 0x34d85c9CDeB23FA97cb08333b511ac86E1C4E258
	no baseURI
	example tokenId: #7906
	tokenURI: https://api.otherside.xyz/lands/7906 
	
		返回 tokenURI
		得到图片地址：
		{"attributes":[{"trait_type":"Category","value":"Harsh"},{"trait_type":"Sediment","value":"Biogenic Swamp"},{"trait_type":"Sediment Tier","value":1,"display_type":"number"},{"trait_type":"Environment","value":"Wastes"},{"trait_type":"Environment Tier","value":1,"display_type":"number"},{"trait_type":"Eastern Resource","value":"Spikeweed"},{"trait_type":"Eastern Resource Tier","value":3,"display_type":"number"},{"trait_type":"Southern Resource","value":"Spikeweed"},{"trait_type":"Southern Resource Tier","value":2,"display_type":"number"},{"trait_type":"Western Resource","value":"Obsilica"},{"trait_type":"Western Resource Tier","value":3,"display_type":"number"},{"trait_type":"Northern Resource","value":"Runa"},{"trait_type":"Northern Resource Tier","value":2,"display_type":"number"},{"trait_type":"Artifact","value":"Mirror Mirror"},{"trait_type":"Koda","value":6456},{"trait_type":"Plot","value":7906,"display_type":"number"}],"image":"https://assets.otherside.xyz/otherdeeds/7ef60fda10607bc768faba57ba0e3521fb7788c9c4604b371a459c716d7d93c7.jpg"}
		https://assets.otherside.xyz/otherdeeds/7ef60fda10607bc768faba57ba0e3521fb7788c9c4604b371a459c716d7d93c7.jpg
		
		用自己的服务器  图片也托管在自己服务器上

3.ENS: Ethereum Name Service
	contract address: 0x57f1887a8BF19b14fC0dF6Fd9B2acc9Af147eA85
	no baseURI
	example tokenId: #lyza.eth ->  73505824785973318112972126194412577887226968786163903375021709859384363736277  
	tokenURI:  https://metadata.ens.domains/mainnet/0x57f1887a8bf19b14fc0df6fd9b2acc9af147ea85/73505824785973318112972126194412577887226968786163903375021709859384363736277 
	{"is_normalized":true,"name":"lyza.eth","description":"lyza.eth, an ENS name.","attributes":[{"trait_type":"Created Date","display_type":"date","value":1659558770000},{"trait_type":"Length","display_type":"number","value":4},{"trait_type":"Segment Length","display_type":"number","value":4},{"trait_type":"Character Set","display_type":"string","value":"letter"},{"trait_type":"Registration Date","display_type":"date","value":1659558770000},{"trait_type":"Expiration Date","display_type":"date","value":1691115722000}],"name_length":4,"segment_length":4,"url":"https://app.ens.domains/name/lyza.eth","version":0,"background_image":"https://metadata.ens.domains/mainnet/avatar/lyza.eth","image":"https://metadata.ens.domains/mainnet/0x57f1887a8bf19b14fc0df6fd9b2acc9af147ea85/0xa282d28e1328ce898a148ad6b8d88fa7812fd51578509bc20b373492540e5cd5/image","image_url":"https://metadata.ens.domains/mainnet/0x57f1887a8bf19b14fc0df6fd9b2acc9af147ea85/0xa282d28e1328ce898a148ad6b8d88fa7812fd51578509bc20b373492540e5cd5/image"}
	这里很特别 没有image  所有图片都是一样的  唯独 name 不一样  是域名  
	图片就是 background_image: https://metadata.ens.domains/mainnet/avatar/lyza.eth  
	这个和 标准的 opensea 好像不太一样了  不过确实有意思  

4.y00ts: mint t00b
	是SOL  合约地址 https://solscan.io/address/TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA
	y00ts: mint t00b #14398
	details 里面的东西应该是随便编辑的  
	tokenId: https://solscan.io/token/DLGRm6jNsVkYzwmUEwPnJioc5sgyjuk6X2SR6zu1ADDq
	metadata 用的是自己的服务器     是一个mp4文件  
	https://t00bs-metadata.y00ts.com/ipfs/QmPWBQ2imMe8mpACB5nh7PNjAKRzWx23HhdhJyLzxcmmwX/14398.json
	

6.MAYC - Mutant Ape Yacht Club
	contract address: 0x60E4d786628Fea6478F785A6d7e704777c86a7c6
	no baseURI
	example tokenId: #24829
	tokenURI: https://boredapeyachtclub.com/api/mutants/24829
	 
		访问 tokenURI 
		得到图片地址:
		{"image":"ipfs://QmSEwjvpx4fzMPwdymcqC56FwfBDuZ7A7qhJXQmY9KRbFF","attributes":[{"trait_type":"Background","value":"M2 New Punk Blue"},{"trait_type":"Fur","value":"M2 Brown"},{"trait_type":"Eyes","value":"M2 Sunglasses"},{"trait_type":"Hat","value":"M2 Trippy Captain's Hat"},{"trait_type":"Mouth","value":"M2 Grin"}]}
		https://ipfs.io/ipfs/QmSEwjvpx4fzMPwdymcqC56FwfBDuZ7A7qhJXQmY9KRbFF

		用自己的服务器返回tokenURI  图片资源上传到 ifps 上去了    错配了怎么办?   没


用自己的服务器搭建 baseURI 比较简单 容易理解 就不去弄了 
真正去中心化还是得看 ifps  目前来看 排名第一的 BAYC 就是这样的 
看文档 https://docs.ipfs.tech/concepts/file-systems/#mutable-file-system-mfs 
	1.先上传图片到 ifps   得到 CID  ->   ipfs://<CID>
	2.准备好 json   构建好节点   
	3.构建 directory  上传   
下个 ipfs desktop  然后把 CID = QmeSjSinHpPnmXmspMjwiXyN6zS4E9zccariGR3jxcaWtq 的文件夹 下过来就知道了 
那个 json 文件 没有后缀名  所以这个目录是可以扩展的  

可以考虑扩展 baseURI  这样 就可以切换了  放开 fallback 函数? 


	
以太坊 从 poW 向 poS merge   见证历史	

	after the merge 
	0.000092766000803972 Ether ($0.13)   0.13 USD 

	before the merge 
	0.00048766250234078 Ether  ($0.69)	 0.69 USD
	
	降低了 81%的 gas 费 

    那么 bsc 呢?   还不如 eth 主链呢 
    0.000738528 BNB ($0.20) 

 */