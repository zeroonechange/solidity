// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

contract Owned {
    constructor() public { owner = payable(msg.sender); }
    address payable owner;
}

// 使用 is 从另一个合约派生。派生合约可以访问所有非私有成员，包括内部（internal）函数和状态变量，
// 但无法通过 this 来外部访问。
contract Destructible is Owned {

// 关键字`virtual`表示该函数可以在派生类中“overriding”。

    function destroy() virtual public {
        if (msg.sender == owner) selfdestruct(owner);
    }
}

// 这些抽象合约仅用于给编译器提供接口。
// 注意函数没有函数体。
// 如果一个合约没有实现所有函数，则只能用作接口。
abstract contract Config {
    function lookup(uint id) public virtual returns (address adr);
}

abstract contract NameReg {
    function register(bytes32 name) public virtual;
    function unregister() public virtual;
}

// 可以多重继承。请注意，owned 也是 Destructible 的基类，
// 但只有一个 owned 实例（就像 C++ 中的虚拟继承）。
contract Named is Owned, Destructible {
    constructor(bytes32 name) {
        Config config = Config(0xD5f9D8D94886E70b06E474c3fB14Fd43E2f23970);
        NameReg(config.lookup(1)).register(name);
    }

    // 函数可以被另一个具有相同名称和相同数量/类型输入的函数重载。
    // 如果重载函数有不同类型的输出参数，会导致错误。
    // 本地和基于消息的函数调用都会考虑这些重载。

//如果要覆盖函数，则需要使用 `override` 关键字。 如果您想再次覆盖此函数，则需要再次指定`virtual`关键字。

    function destroy() public virtual override {
        if (msg.sender == owner) {
            Config config = Config(0xD5f9D8D94886E70b06E474c3fB14Fd43E2f23970);
            NameReg(config.lookup(1)).unregister();
            // 仍然可以调用特定的重载函数。
            Destructible.destroy();
        }
    }
}

// 如果构造函数接受参数，
// 则需要在声明（合约的构造函数）时提供，
// 或在派生合约的构造函数位置以修改器调用风格提供（见下文）。
contract PriceFeed is Owned, Destructible, Named("GoldFeed") {
    function updateInfo(uint newInfo) public {
        if (msg.sender == owner) info = newInfo;
    }

    // Here, we only specify `override` and not `virtual`.
    // This means that contracts deriving from `PriceFeed`
    // cannot change the behaviour of `destroy` anymore.
    function destroy() public override(Destructible, Named) { Named.destroy(); }

    function get() public view returns(uint r) { return info; }

    uint info;
}