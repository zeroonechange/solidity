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

简单来说
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


*/
