pragma solidity ^0.8.4;

// 简单竞拍 
contract SimpleAution{
    address payable public beneficiary;  // 拍卖人  
    uint public auctionEndTime;          // 结束拍卖的时间
    address public heighestBidder;       // 竞价最高者
    uint public highestBid;      

    mapping(address => uint) pendingReturns;  // 退钱

    bool ended; 

    event HighestBidIncreased(address bidder, uint amount);
    event AuctionEnded(address winner, uint amount);

    error AuctionAlreadyEnded();
    error BidNotHighEnough(uint highestBid);
    error AuctionNotYetEnded();
    error AuctionEndAlreadyCalled();

    constructor(uint biddingTime, address payable beneficiaryAddress){
        beneficiary = beneficiaryAddress;
        auctionEndTime = block.timestamp + biddingTime;
    }

    function bid() external payable{
        if(block.timestamp > auctionEndTime )  // 过时不候
            revert AuctionAlreadyEnded();
        if(msg.value <= highestBid)           // 竞拍钱太少了
            revert BidNotHighEnough(highestBid);
        if(highestBid != 0 ){          // 把之前最高价 退回去 
            pendingReturns[heighestBidder] += highestBid;
        }
        heighestBidder = msg.sender;
        highestBid = msg.value;
        emit HighestBidIncreased(msg.sender, msg.value);  // 发送一个消息 
    }

    // 还得主动取钱
    function withdraw() external returns (bool){   
        unit amount = pendingReturns[msg.sender];
        if(amount > 0){
            pendingReturns[msg.sender] = 0;
            if(!payable(msg.sender).send(amount)){  // 万一没成功 钱还是返回 那人家取钱 还是取不出来
               pendingReturns[msg.sender] = amount;
               return false;     
            }
        }
        return true;
    }

    function auctionEnd() external{   
        if(block.timestamp < auctionEndTime){
            revert AuctionNotYetEnded();
        }
        if(ended)
            revert AuctionAlreadyEnded();
        
        ended = true;
        emit AuctionEnded(heighestBidder, highestBid);

        beneficiary.transfer(highestBid);  //打钱到拍卖人账号上
    }
}