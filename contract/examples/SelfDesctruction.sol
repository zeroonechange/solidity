pragma solidity >=0.4.0 <0.9.0;

contract SelfDesctruction{
    public address owner;
    public string someValue;

    modifier ownerRestricted{
        require(msg.sender == owner);
        _;
    }

    function SelfDesctruction(){
        owner = msg.sender;
    }

    function setSomeValue(string value_){
        someValue = value_;
    }

    function destroyContract() ownerRestricted{
        suicide(owner);
    }
}