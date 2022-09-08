pragma solidity ^0.8.9;

import "hardhat/console.sol";


// This is the main building block for smart contracts.
contract Token {
    // Some string type variables to identify the token.
    string public name = "My Hardhat Token";
    string public symbol = "MHT";

    // The fixed amount of tokens, stored in an unsigned integer type variable.
    uint256 public totalSupply = 1000000;

    // An address type variable is used to store ethereum accounts.
    address public owner;

    address private implementation;

    // A mapping is a key/value map. Here we store each account's balance.
    mapping(address => uint256) balances;

    // The Transfer event helps off-chain applications understand
    // what happens within your contract.
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Fuck(string msg);

    /**
     * Contract initialization.
     */
    constructor() {
        // The totalSupply is assigned to the transaction sender, which is the
        // account that is deploying the contract.
        balances[msg.sender] = totalSupply;
        owner = msg.sender;
    }

    /**
     * A function to transfer tokens.
     *
     * The `external` modifier makes a function *only* callable from *outside*
     * the contract.
     */
    function transfer(address to, uint256 amount) external {
        // Check if the transaction sender has enough tokens.
        // If `require`'s first argument evaluates to `false` then the
        // transaction will revert.
        require(balances[msg.sender] >= amount, "Not enough tokens");

        // Transfer the amount.
        balances[msg.sender] -= amount;
        balances[to] += amount;

        // Notify off-chain applications of the transfer.
        emit Transfer(msg.sender, to, amount);
        emit Fuck("nothing");
    }

    /**
     * Read only function to retrieve the token balance of a given account.
     *
     * The `view` modifier indicates that it doesn't modify the contract's
     * state, which allows us to call it without executing a transaction.
     */
    function balanceOf(address account) external view returns (uint256) {
        return balances[account];
    }

    event Bro(string msg); 


    fallback() external payable {
        emit Bro("fallback");
        console.log("---fallback---  impl: %s ", implementation);
        delegate(implementation);
    }

   function delegate(address a) internal{
        assembly{
            calldatacopy(0, 0, calldatasize())

            let result := delegatecall(gas(), a, 0, calldatasize(), 0, 0)

            returndatacopy(0, 0, returndatasize())

            switch result
            case 0
            {
                revert(0, returndatasize())
            }
            default
            {
                return(0, returndatasize())
            }
        }
    }

    function test() public returns (uint256){
        console.log("---hello---");
        emit Bro("hello");
        return 4;
    }

    function setImplementation(address _impl) external {
        console.log("---setImpl---  impl: %s   contract address: %s ", _impl, address(this));
        implementation = _impl;
    }

    function getImplementation() public view returns (address){
        return implementation;
    }

}
