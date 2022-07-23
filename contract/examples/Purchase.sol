pragma solidity ^0.8.4;

contract Purchase{
    uint public value;
    address payable public seller;
    address payable public buyer;

    enum State{Created, Locked, Release, Inactive}

    State public state;

    modifier condition(bool condition_){
        require(condition_);
        _;
    }

    error OnlyBuyer();
    error OnlySeller();
    error InvalidState();
    error ValueNotEven();

    modifier onlyBuyer(){
        require(msg.sender == buyer, "only buyer can call this");
        _;
    }

    modifier onlySeller(){
        require(msg.sender == seller, "only seller can call this");
        _;
    }

    modifier inState(State _state){
        require(state == _state, "invalid state")
        _;
    }

    event Aborted();
    event PuchaseConfirmed();
    event ItemReceived();
    event SellerRefunded();

    //确保 `msg.value` 是一个偶数
    constructor() payable{
        seller = payable(msg.sender);
        value = msg.value /2;  // seller 锁定了 2倍 价值等价物
        if((2*value)!= msg.value)
            revert ValueNotEven();
    }

    //中止购买并回收以太币
    //只能在合约被锁定之前由卖家调用
    function abort()
        external
        onlySeller
        inState(State.Created)
    {
        emit Aborted();
        state = State.Inactive;
        seller.transfer(address(this).balance);
    }

    //买家确认购买   以太币会被锁定，直到 confirmReceived 被调用
    function confirmPurchase() 
        external
        inState(State.Created)
        condition(msg.value == (2*value))   //buyer 锁定了 2倍 价值等价物
        payable
    {
        emit PuchaseConfirmed();
        buyer = payable(msg.sender);
        state = State.Locked;
    }

    // 确认买家已经收到商品  这会释放被锁定的以太币
    function confirmReceive()
        external
        onlyBuyer
        inState(State.Locked)
    {
        emit ItemReceived();
        state = State.Release;
        buyer.transfer(value);
    }

    //pays back the locked funds of the seller
    function refundSeller()
        external
        onlySeller
        inState(State.Release)
    {
        emit SellerRefunded();
        state = State.Inactive;
        seller.transfer(3*value);
    }
}