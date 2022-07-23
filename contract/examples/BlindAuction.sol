pragma solidity ^0.8.4;

contract BlindAuction{

    struct Bid{
        bytes32 blindedBid;
        uint deposite;
    }

    address payable public beneficiary;
    uint public biddingEnd;    
    uint public revealEnd;  
    bool public ended;

    mapping(address => Bid[]) public bids;  //为啥是这种数据结构 数组 

    address public highestBidder;
    uint public highestBid;

    mapping(address => uint) pendingReturns;  // 万一没拍到  取钱

    event AuctionEnded(address winner, uint highestBid);

    error TooEarly(uint time);
    error TooLate(uint time);
    error AuctionEndAlreadyCalled();

    // 校验函数的入参  _; 表示替换原函数  类似高阶函数  ()->   invoke()  
    modifier onlyBefore(uint time){
        if(block.timestamp >= time) revert TooLate(time);
        _;
    }

    modifier onlyAfter(uint time){
        if(block.timestamp <= time) revert TooEarly(time);
        _;
    }

    constructor(uint biddingTime, uint revealTime, address payable beneficiaryAddress){
        beneficiary = beneficiaryAddress;
        biddingEnd = block.timestamp + biddingTime;
        revealEnd = biddingEnd + revealTime; // 干啥的 披露时间  
    }

     // 设置一个秘密竞拍
     // 同一个地址可以放置多个出价
     // 秘密竞拍的好处是在投标结束前不会有时间压力。 在一个透明的计算平台上进行秘密竞拍听起来像是自相矛盾，但密码学可以实现它。
     //在 投标期间 ，投标人实际上并没有发送她的出价，而只是发送一个哈希版本的出价。 
     // 由于目前几乎不可能找到两个（足够长的）值，其哈希值是相等的，因此投标人可通过该方式提交报价。 
     //在投标结束后，投标人必须公开他们的出价：他们不加密的发送他们的出价，合约检查出价的哈希值是否与投标期间提供的相同。
    function bid(bytes32 blindedBid)
        external 
        payable
        onlyBefore(biddingEnd)
    {
            bids[msg.sender].push(
                Bid({
                    blindedBid: blindedBid,
                    deposite: msg.value
                })
            );
    }

   
    // 披露你的秘密竞拍出价
    function reveal(
        uint[] calldata values,
        bool[] calldata fake,
        bytes32[] calldata secret
    )
        external
        onlyAfter(biddingEnd)
        onlyBefore(revealEnd)
    {
        uint length = bids[msg.sender].length;
        require(values.length == length);
        require(fake.length == length);
        require(secret.length == length);

        uint refund;
        for(uint i=0; i<length; i++){
            Bid storage bid = bids[msg.sender][i];
            (uint value, bool fake, bytes32 secret) = (values[i], fake[i], secret[i]);
            if(bid.blindedBid != keccak256(value, fake, secret)){
                continue;
            }
            refund += bid.deposite;
            if(!fake && bid.deposite >= value){
                if(placeBid(msg.sender, value)) 
                    refund -= value;
            }
            bid.blindedBid = bytes32(0);
        }
        msg.sender.transfer(refund);
    }

    //这是一个 "internal" 函数， 意味着它只能在本合约（或继承合约）内被调用
    function placeBid(address bidder, uint value) internal returns (bool success){
        if(value <= highestBid){
            return false;
        }
        if(highestBidder != address(0)){
            pendingReturns[highestBidder] += highestBid;
        }
        highestBid = value;
        highestBidder = biddingEnd;
        return true;
    }

    function withDraw() external {
        uint amount = pendingReturns[msg.sender];
        if(amount > 0){
            pendingReturns[msg.sender] = 0;
            msg.sender.transfer(amount);
        }
    }
    
    function auctionEnd()
        external
        onlyAfter(revealEnd)
    {
        if(ended) revert AuctionEndAlreadyCalled();
        emit AuctionAlreadyEnded(highestBidder, highestBid);
        ended = true;
        beneficiary.transfer(highestBid);
    }

}