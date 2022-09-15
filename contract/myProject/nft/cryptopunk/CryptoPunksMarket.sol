pragma solidity ^0.4.8;

library ConvertLib{
	function convert(uint amount,uint conversionRate) returns (uint convertedAmount)
	{
		return amount * conversionRate;
	}
}

contract Migrations {
  address public owner;
  uint public last_completed_migration;

  modifier restricted() {
    if (msg.sender == owner) _;
  }

  function Migrations() {
    owner = msg.sender;
  }

  function setCompleted(uint completed) restricted {
    last_completed_migration = completed;
  }

  function upgrade(address new_address) restricted {
    Migrations upgraded = Migrations(new_address);
    upgraded.setCompleted(last_completed_migration);
  }
}


contract CryptoPunksMarket {

    // You can use this hash to verify the image file containing all the punks
    string public imageHash = "ac39af4793119ee46bbff351d8cb6b5f23da60222126add4268e261199a2921b";

    address owner;

    string public standard = 'CryptoPunks';
    string public name;
    string public symbol;
    uint8 public decimals;
    uint256 public totalSupply;

    uint public nextPunkIndexToAssign = 0;

    bool public allPunksAssigned = false;  // assign 分配 
    uint public punksRemainingToAssign = 0;

    //mapping (address => uint) public addressToPunkIndex;
    mapping (uint => address) public punkIndexToAddress; // 拥有表 

    /* This creates an array with all balances */
    mapping (address => uint256) public balanceOf; // 余额表 

    struct Offer {
        bool isForSale;  
        uint punkIndex;
        address seller;
        uint minValue;          // in ether
        address onlySellTo;     // specify to sell only to a specific person
    }

    struct Bid {
        bool hasBid;
        uint punkIndex;
        address bidder;
        uint value;
    }

    // A record of punks that are offered for sale at a specific minimum value, and perhaps to a specific person
    mapping (uint => Offer) public punksOfferedForSale; // 待售记录

    // A record of the highest punk bid
    mapping (uint => Bid) public punkBids;  // 高价竞卖记录  

    mapping (address => uint) public pendingWithdrawals; // 等待取钱

    event Assign(address indexed to, uint256 punkIndex);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event PunkTransfer(address indexed from, address indexed to, uint256 punkIndex);
    event PunkOffered(uint indexed punkIndex, uint minValue, address indexed toAddress);
    event PunkBidEntered(uint indexed punkIndex, uint value, address indexed fromAddress);
    event PunkBidWithdrawn(uint indexed punkIndex, uint value, address indexed fromAddress);
    event PunkBought(uint indexed punkIndex, uint value, address indexed fromAddress, address indexed toAddress);
    event PunkNoLongerForSale(uint indexed punkIndex);

    /* Initializes contract with initial supply tokens to the creator of the contract */
    function CryptoPunksMarket() payable {
        //        balanceOf[msg.sender] = initialSupply;              // Give the creator all initial tokens
        owner = msg.sender;
        totalSupply = 10000;                        // Update total supply
        punksRemainingToAssign = totalSupply;
        name = "CRYPTOPUNKS";                                   // Set the name for display purposes
        symbol = "Ͼ";                               // Set the symbol for display purposes
        decimals = 0;                                       // Amount of decimals for display purposes
    }

    // 给 token 分配最初的拥有者   必须是 owner 
    function setInitialOwner(address to, uint punkIndex) {
        if (msg.sender != owner) throw; // 很粗糙 没用框架
        if (allPunksAssigned) throw;   // 所有都分配了
        if (punkIndex >= 10000) throw; // 已经超过最大发售数量
        if (punkIndexToAddress[punkIndex] != to) {
            if (punkIndexToAddress[punkIndex] != 0x0) {
                balanceOf[punkIndexToAddress[punkIndex]]--;
            } else {
                punksRemainingToAssign--; // 地址为0 就是销毁了 
            }
            punkIndexToAddress[punkIndex] = to; // 更新拥有者表
            balanceOf[to]++;        // 更新余额表 
            Assign(to, punkIndex);  // 发出事件  低版本没 emit 语法 
        }
    }

    // 批量分配 token 拥有者   必须是 owner 权限 
    function setInitialOwners(address[] addresses, uint[] indices) {
        if (msg.sender != owner) throw;
        uint n = addresses.length;
        for (uint i = 0; i < n; i++) {
            setInitialOwner(addresses[i], indices[i]);
        }
    }

    // 所有的 token 都被分配了
    function allInitialOwnersAssigned() {
        if (msg.sender != owner) throw;
        allPunksAssigned = true;
    }

    // 获得 token 
    function getPunk(uint punkIndex) {
        if (!allPunksAssigned) throw;  // 所有的token必须全部被分配了
        if (punksRemainingToAssign == 0) throw; // 还有剩下的token  这和上面不矛盾吗?
        if (punkIndexToAddress[punkIndex] != 0x0) throw; // 持有者的地址为 0  还没人持有
        if (punkIndex >= 10000) throw;  // 不能大于10000
        punkIndexToAddress[punkIndex] = msg.sender; // 更新持有表 
        balanceOf[msg.sender]++;   // 更新余额表
        punksRemainingToAssign--; // 剩余分配
        Assign(msg.sender, punkIndex);
    }

    // Transfer ownership of a punk to another user without requiring payment
    // 直接转给一个人  即便有最高竞价  
    function transferPunk(address to, uint punkIndex) {
        if (!allPunksAssigned) throw;  // 控制所有操作  必须 allPunksAssigned = true 
        if (punkIndexToAddress[punkIndex] != msg.sender) throw; // 是拥有者才能调用这个方法
        if (punkIndex >= 10000) throw; // 超出了
        if (punksOfferedForSale[punkIndex].isForSale) { // 待售状态 
            punkNoLongerForSale(punkIndex);        // 修改待售状态
        }
        punkIndexToAddress[punkIndex] = to; // 更新 持有表 
        balanceOf[msg.sender]--;      // 更新余额
        balanceOf[to]++;              
        Transfer(msg.sender, to, 1);     
        PunkTransfer(msg.sender, to, punkIndex);    
        // Check for the case where there is a bid from the new owner and refund it.
        // Any other bid can stay in place.
        Bid bid = punkBids[punkIndex];     // 竞价的 不处理? 
        if (bid.bidder == to) {            // 竞价者
            // Kill bid and refund value
            pendingWithdrawals[to] += bid.value; // 余额表
            punkBids[punkIndex] = Bid(false, punkIndex, 0x0, 0); // 更新竞价表
        }
    }
    // 待售  高低贵贱不卖   修改待售状态  不卖了 
    function punkNoLongerForSale(uint punkIndex) {
        if (!allPunksAssigned) throw;
        if (punkIndexToAddress[punkIndex] != msg.sender) throw;
        if (punkIndex >= 10000) throw;
        punksOfferedForSale[punkIndex] = Offer(false, punkIndex, msg.sender, 0, 0x0);
        PunkNoLongerForSale(punkIndex);
    }

    // 修改待售状态  最低价 开卖 
    function offerPunkForSale(uint punkIndex, uint minSalePriceInWei) {
        if (!allPunksAssigned) throw;
        if (punkIndexToAddress[punkIndex] != msg.sender) throw;
        if (punkIndex >= 10000) throw;
        punksOfferedForSale[punkIndex] = Offer(true, punkIndex, msg.sender, minSalePriceInWei, 0x0);
        PunkOffered(punkIndex, minSalePriceInWei, 0x0);
    }

    // 修改待售数据  只卖给那一个人 以特定的价钱 
    function offerPunkForSaleToAddress(uint punkIndex, uint minSalePriceInWei, address toAddress) {
        if (!allPunksAssigned) throw;
        if (punkIndexToAddress[punkIndex] != msg.sender) throw;
        if (punkIndex >= 10000) throw;
        punksOfferedForSale[punkIndex] = Offer(true, punkIndex, msg.sender, minSalePriceInWei, toAddress);
        PunkOffered(punkIndex, minSalePriceInWei, toAddress);
    }

    // 买一个 token  
    function buyPunk(uint punkIndex) payable {
        if (!allPunksAssigned) throw;
        Offer offer = punksOfferedForSale[punkIndex];
        if (punkIndex >= 10000) throw;
        if (!offer.isForSale) throw;  //人家卖才能买啊              // punk not actually for sale
        if (offer.onlySellTo != 0x0 && offer.onlySellTo != msg.sender) throw;  // punk not supposed to be sold to this user
        if (msg.value < offer.minValue) throw;  // 小于最低价别来凑热闹了     // Didn't send enough ETH
        // 这是为啥? 
        if (offer.seller != punkIndexToAddress[punkIndex]) throw; // Seller no longer owner of punk

        address seller = offer.seller;

        punkIndexToAddress[punkIndex] = msg.sender;  // 更新拥有表
        balanceOf[seller]--; // 更新余额表
        balanceOf[msg.sender]++;
        Transfer(seller, msg.sender, 1);

        punkNoLongerForSale(punkIndex);  // 修改 token 状态  不卖了 
        pendingWithdrawals[seller] += msg.value;   // 修改取钱表 可以到时候套现
        PunkBought(punkIndex, msg.value, seller, msg.sender);

        // Check for the case where there is a bid from the new owner and refund it.
        // Any other bid can stay in place.
        Bid bid = punkBids[punkIndex];  // 竞价表  如果之前有竞价 锁住了一部分的eth吗？
        if (bid.bidder == msg.sender) {
            // Kill bid and refund value
            pendingWithdrawals[msg.sender] += bid.value;  
            punkBids[punkIndex] = Bid(false, punkIndex, 0x0, 0);
        }
    }

    // 取钱
    function withdraw() {
        if (!allPunksAssigned) throw;
        uint amount = pendingWithdrawals[msg.sender];   
        // Remember to zero the pending refund before
        // sending to prevent re-entrancy attacks
        pendingWithdrawals[msg.sender] = 0;   
        msg.sender.transfer(amount); // 转账 
    }

    // 价高者得  重新竞价
    function enterBidForPunk(uint punkIndex) payable {
        if (punkIndex >= 10000) throw;
        if (!allPunksAssigned) throw;                
        if (punkIndexToAddress[punkIndex] == 0x0) throw;
        if (punkIndexToAddress[punkIndex] == msg.sender) throw;
        if (msg.value == 0) throw;
        Bid existing = punkBids[punkIndex]; // 竞价信息 
        if (msg.value <= existing.value) throw;
        if (existing.value > 0) {
            // Refund the failing bid
            pendingWithdrawals[existing.bidder] += existing.value; //退款给之前竞价人
        }
        // 重新构建 bid  出价比之前的高 
        punkBids[punkIndex] = Bid(true, punkIndex, msg.sender, msg.value);
        PunkBidEntered(punkIndex, msg.value, msg.sender); // 事件
    }

    // 卖家接受竞价  完成交易
    function acceptBidForPunk(uint punkIndex, uint minPrice) {
        if (punkIndex >= 10000) throw;
        if (!allPunksAssigned) throw;                
        if (punkIndexToAddress[punkIndex] != msg.sender) throw;
        address seller = msg.sender;
        Bid bid = punkBids[punkIndex];
        if (bid.value == 0) throw;
        if (bid.value < minPrice) throw;

        punkIndexToAddress[punkIndex] = bid.bidder; // 更新持有表
        balanceOf[seller]--;   // 余额表
        balanceOf[bid.bidder]++;
        Transfer(seller, bid.bidder, 1);
        // 更新待售表 
        punksOfferedForSale[punkIndex] = Offer(false, punkIndex, bid.bidder, 0, 0x0);
        uint amount = bid.value; // 最高竞价
        punkBids[punkIndex] = Bid(false, punkIndex, 0x0, 0); // 更新竞价表  不再竞价了
        pendingWithdrawals[seller] += amount; // 给卖家打钱
        PunkBought(punkIndex, bid.value, seller, bid.bidder);
    }

    // 不再参与竞价
    function withdrawBidForPunk(uint punkIndex) {
        if (punkIndex >= 10000) throw;
        if (!allPunksAssigned) throw;                
        if (punkIndexToAddress[punkIndex] == 0x0) throw;
        if (punkIndexToAddress[punkIndex] == msg.sender) throw;
        Bid bid = punkBids[punkIndex];  // 竞价表
        if (bid.bidder != msg.sender) throw; // 自己就是最高竞价人
        PunkBidWithdrawn(punkIndex, bid.value, msg.sender);
        uint amount = bid.value; // 最高竞价价格
        punkBids[punkIndex] = Bid(false, punkIndex, 0x0, 0); // 不再竞价了
        // Refund the bid money
        msg.sender.transfer(amount); // 直接把钱要回来 
    }

}

