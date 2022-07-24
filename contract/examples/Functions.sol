// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.6.4  <0.9.0;

contract Example {
  function f() public payable returns (bytes4) {
    assert(this.f.address == address(this));
    return this.f.selector;
  }
  function g() public {
    this.f{gas: 10, value: 800}();
  }
}


//--------------------------------------------------------------
pragma solidity >=0.4.16  <0.9.0;

library ArrayUtils {
  // 内部函数可以在内部库函数中使用，
  // 因为它们会成为同一代码上下文的一部分
  function map(uint[] memory self, function (uint) pure returns (uint) f)
    internal
    pure
    returns (uint[] memory r)
  {
    r = new uint[](self.length);
    for (uint i = 0; i < self.length; i++) {
      r[i] = f(self[i]);
    }
  }
  function reduce(
    uint[] memory self,
    function (uint, uint) pure returns (uint) f
  )
    internal
    pure
    returns (uint r)
  {
    r = self[0];
    for (uint i = 1; i < self.length; i++) {
      r = f(r, self[i]);
    }
  }
  function range(uint length) internal pure returns (uint[] memory r) {
    r = new uint[](length);
    for (uint i = 0; i < r.length; i++) {
      r[i] = i;
    }
  }
}

contract Pyramid {
  using ArrayUtils for *;
  function pyramid(uint l) public pure returns (uint) {
    return ArrayUtils.range(l).map(square).reduce(sum);
  }
  function square(uint x) internal pure returns (uint) {
    return x * x;
  }
  function sum(uint x, uint y) internal pure returns (uint) {
    return x + y;
  }
}


//--------------------------------------------------------------
pragma solidity >=0.4.22  <0.9.0;

contract Oracle {
  struct Request {
    bytes data;
    function(uint) external callback;
  }
  Request[] private requests;
  event NewRequest(uint);
  function query(bytes memory data, function(uint) external callback) public {
    requests.push(Request(data, callback));
    emit NewRequest(requests.length - 1);
  }
  function reply(uint requestID, uint response) public {
    // 这里检查回复来自可信来源
    requests[requestID].callback(response);
  }
}

contract OracleUser {
  Oracle constant private ORACLE_CONST = Oracle(address(0x00000000219ab540356cBB839Cbe05303d7705Fa)); // known contract
  uint private exchangeRate;
  function buySomething() public {
    ORACLE_CONST.query("USD", this.oracleResponse);
  }
  function oracleResponse(uint response) public {
    require(
        msg.sender == address(ORACLE_CONST),
        "Only oracle can call this."
    );
    exchangeRate = response;
  }
}