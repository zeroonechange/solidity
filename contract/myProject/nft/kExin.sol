// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract KExin is ERC721, ERC721Enumerable, ERC721URIStorage {
    using Counters for Counters.Counter;

    Counters.Counter private _tokenIdCounter;
     uint256 MAX_SUPPLY = 50;

    constructor() ERC721("kExin", "KX") {}

    function safeMint(address to, string memory uri) public {
        uint256 tokenId = _tokenIdCounter.current();
        require(tokenId <= MAX_SUPPLY, "sry, canot mint anymore, more than 50 already minted");
        _tokenIdCounter.increment();
        _safeMint(to, tokenId);
        _setTokenURI(tokenId, uri);
    }

    // The following functions are overrides required by Solidity.

    function _beforeTokenTransfer(address from, address to, uint256 tokenId)
        internal
        override(ERC721, ERC721Enumerable)
    {
        super._beforeTokenTransfer(from, to, tokenId);
    }

    function _burn(uint256 tokenId) internal override(ERC721, ERC721URIStorage) {
        super._burn(tokenId);
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        return super.tokenURI(tokenId);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721Enumerable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}

/**
 * 
------------------------------------------------------------------------------------------------------------------------

更新于 
    下一步该去了解 IPFS 怎么使用 
先把图片上传了  拿到url 
为每张图片生成一个json文件  再把json文件上传了  拿到一个url  这个url 就是 tokenuri 
实操
    图片上传
        可以弄到 github google drive aws  这些都是中心化的  不是去中心化的 容易被更改 如果服务器宕机了 数据没了
        IPFS服务器 永远存在 不会被修改  建议去 https://www.pinata.cloud/   1G 是免费的  
        上传的是folder  里面是 a.png b.png ... 
        folder 的 CID 是  Qmdv57DAE94x79TpgqW2Ui6fBB9FL9taga6kYQX7wtaeu3 
        ipfs://Qmdv57DAE94x79TpgqW2Ui6fBB9FL9taga6kYQX7wtaeu3  
        pinata 提供的访问uri
            https://gateway.pinata.cloud/ipfs/Qmdv57DAE94x79TpgqW2Ui6fBB9FL9taga6kYQX7wtaeu3
            https://gateway.pinata.cloud/ipfs/Qmdv57DAE94x79TpgqW2Ui6fBB9FL9taga6kYQX7wtaeu3/a.png
        统一标准下的url 
            https://ipfs.io/ipfs/Qmdv57DAE94x79TpgqW2Ui6fBB9FL9taga6kYQX7wtaeu3/a.png

    为图片生成 json 文件
        放到github里面  能不能访问呢  不然的话  怎么整  tokenId 是个 uint256 
        like: http://<test_domain>/api/token/1  -> 返回 json 

    https://raw.githubusercontent.com/zeroonechange/solidity/main/contract/myProject/nft/ifps/1
    那么 baseUrl -> https://raw.githubusercontent.com/zeroonechange/solidity/main/contract/myProject/nft/ifps/ 
    部署试试看 

    tokenId=1  uri = https://raw.githubusercontent.com/zeroonechange/solidity/main/contract/myProject/nft/ifps/1

    发行成功  https://testnets.opensea.io/assets/goerli/0xe374242f1b835aa3d15d482f43b195c0cf82eced/1

    后面多拍几张科兴的图  然后ps 处理下  再发到 BSC 上  上架 opensea  



更新于 2022/9/16 00:31
那个 metadata 里面存放的是 一些资源信息  是个json文件  例如图片网址 描述 之类的 
那个 tokenURI 是干啥的 比如 你的 baseTokenUrl = http://<test_domain>/api/token/  
那么 tokenURI(tokenId)  访问的就是 http://<test_domain>/api/token/tokenId  这就是个 json 文件  里面包含 matadata 信息  
这么做的好处是什么?  为了上架 opensea 
    上架的原理和流程:  登录后进入 opensea  链接钱包 然后输入已部署的合约地址  
        随便找个 藏品 右上角点击 sell  输入一些参数  开始上架   需要初始化钱包 这里其实是 再创建一个 proxy 合约的过程 
        然后 授权 这些资产的售卖 就是 approval 方法  参考 ERC721 协议  签名后完成了上架  

参考 : 
    https://zhuanlan.zhihu.com/p/516188462
    https://github.com/PatrickAlphaC/dungeons-and-dragons-nft
    https://github.com/PatrickAlphaC/nft-mix 
------------------------------------------------------------------------------------------------------------------------


简单来说                                    更新于 2022/9/15 14:00
    1.在 Open Zeppelin 生成合约
    2.在 Alchemy 上创建APP  把 API KEY , HTTPS 复制  去metamask 创建 一个网络  Name 随便 RPC URL 就是 https  Chain ID是5  Currency Symbol 是 ETH 
    3.remix 连接此网络  deploy 合约 
    4.去 Filebase 创建 bucket 在里面上传图片 得到 IFPS CID 
    5.在 remix 已创建合约 执行 safeMint  参数 to = 自己的钱包地址  uri = ipfs://QmW3xKzepserVewHFFfCY2ifogiiEzDPvtPEsPmVC97x5M    后面这个就是CID
    6.去 https://testnets.opensea.io/ 连接自己的钱包  查看刚刚发布的 nft 


合约地址: 0x1d74f4D8b0674f61255AF1DE8F688325a0AD37ad
 owner : 0xB14c48DFA7BA492Ae0De3c521Ce17c5aEA66ed04


https://ipfs.filebase.io/ipfs/QmUQgKka8EW7exiUHnMwZ4UoXA11wV7NFjHAogVAbasSYy
ipfs://<your_metadata_cid>

IPFS CID 

ipfs://QmUQgKka8EW7exiUHnMwZ4UoXA11wV7NFjHAogVAbasSYy 
ipfs://QmPbxeGcXhYQQNgsC6a36dDyYUcHgMLnGKnF8pVFmGsvqi
ipfs://QmXkLGoGKXswr4YwkgPVfL7wmbvkRKabmh7WXmkACrgi68
ipfs://QmSg9bPzW9anFYc3wWU5KnvymwkxQTpmqcRSfYj7UmiBa7
ipfs://QmVvdAbabZ2awja88uUhYHFuq67iEiroFuwLGM6HyiWcc8
ipfs://QmadJd1GgsSgXn7RtrcL8FePionDyf4eQEsREcvdqh6eQe
ipfs://QmSQ5AxWbxsHJ4f1YcU4bV5qcwNFj12fAvN9NuCJos6xq4
ipfs://QmW3xKzepserVewHFFfCY2ifogiiEzDPvtPEsPmVC97x5M

all comes from: https://betterprogramming.pub/how-to-create-your-own-nft-smart-contract-tutorial-1b90978bd7a3

------------------------------------------------------------------------------------------------------------------------
*/
