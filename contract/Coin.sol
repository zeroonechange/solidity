pragma solidity ^0.8.4

contract Coin{
    address public minter; //160位的值，且不允许任何算数操作  编译器已经帮你实现get
    mapping (address => uint) public balances;
    event Sent(address from, address to, uint amount);
    constructor(){
        minter = msg.sender;
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