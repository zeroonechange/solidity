pragma solidity ^0.8.9;

import "hardhat/console.sol";

contract Logic {
    
    mapping(string => uint256) private uint256Params;

    event Uint256ParamSetted(string indexed _key, uint256 _value);

    // SET a=4   cd4fe8cd0000000000000000000000000000000000000000000000000000000000000040000000000000000000000000000000000000000000000000000000000000000400000000000000000000000000000000000000000000000000000000000000016100000000000000000000000000000000000000000000000000000000000000
    function SetUint256Param(string memory _key, uint256 _value)  external{
        uint256Params[_key] = _value;
        console.log("---SetUint256Param--- key=%s, value=%s", _key, _value);
        emit Uint256ParamSetted(_key, _value);
    }

    // GET a    4e678e80000000000000000000000000000000000000000000000000000000000000002000000000000000000000000000000000000000000000000000000000000000016100000000000000000000000000000000000000000000000000000000000000
    function GetUint256Param(string memory _key) public view returns (uint256) {
        uint256 v = uint256Params[_key];
        console.log("---GetUint256Param--- key=%s, value=%s", _key, v);
        return v;
    }
}
