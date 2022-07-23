pragma solidity ^0.8.4

contract Coin{
    address public minter; //160位的值，且不允许任何算数操作   public关键字编译器已经帮你实现get
    mapping (address => uint) public balances; // 公共状态变量 哈希表  虚拟初始化 
    event Sent(address from, address to, uint amount); // 声明了一个事件 在send函数的最后一行被发出 用户界面监听区块链上的正在发送的事件 不会花费多少成本  
    constructor(){
        minter = msg.sender;  // 创建的时候调用 永久储存创建合约人的地址 
    }
    // 被用户调用  发行新币  只能由owner发行   随心所欲的铸币  可能会溢出 
    function mint(address receiver, uint amount) public{
        require(msg.sender == minter);
        balances[receiver]+=amount; // update balances table
    }

    //描述错误信息  类似自定义java的自定义exception 
    error InsuBa(uint requested, uint available); 

    // 被用户调用  转账   创建一个“区块链浏览器”来追踪交易和余额
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

/*  JavaScript 监听事件代码   为啥没有Java？ 
Coin.Sent().watch({}, '', function(error, result) {
    if (!error) {
        console.log("Coin transfer: " + result.args.amount +
            " coins were sent from " + result.args.from +
            " to " + result.args.to + ".");
        console.log("Balances now:\n" +
            "Sender: " + Coin.balances.call(result.args.from) +
            "Receiver: " + Coin.balances.call(result.args.to));
    }
})
*/