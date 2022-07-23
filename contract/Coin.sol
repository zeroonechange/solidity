pragma solidity ^0.8.4

contract Coin{
    address public minter; //160位的值，且不允许任何算数操作   public关键字编译器已经帮你实现get
    mapping (address => uint) public balances; // 公共状态变量 哈希表  虚拟初始化 
    event Sent(address from, address to, uint amount); // 声明了一个事件 在send函数的最后一行被发出 用户界面监听区块链上的正在发送的事件 不会花费多少成本  javascript代码  为啥没有Java？ 
    constructor(){
        minter = msg.sender;  // 创建的时候调用 永久储存创建合约人的地址 
    }
    function mint(address receiver, uint amount) public{
        require(msg.sender == minter);
        balances[receiver]+=amount; // update balances table
    }
    error InsuBa(uint requested, uint available);
    function send(address receiver, uint amount) public{
        if(amount > balances[msg.sender]){
            revert InsuBa({
                requested: amount,
                available : balances[msg.sender]
            });
        }
        balances[msg.sender]-=amount;
        balances[receiver]+=amount;
        emit Sent(msg.sender, receiver, amount);
    }
}