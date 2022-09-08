const { expect } = require("chai");
const { ethers } = require("hardhat");

// from  https://ethereum.stackexchange.com/questions/128321/fallback-not-executing
describe("Storage", function () {

    it("delegatecall test", async function () {

        const StorageContract = await ethers.getContractFactory("StorageContract");
        const storage = await StorageContract.deploy();
        await storage.deployed();

        const StorageImplementation = await ethers.getContractFactory("StorageImplementation");
        const storageImpl = await StorageImplementation.deploy();
        await storageImpl.deployed();

        storage.setImplementation(storageImpl.address);

        let impl = await storage.getImplementation();
        console.log("impl:" + impl);

        // Proxy handle : StorageImplementation attached to storage address
        // Trough proxy, you can interact with storage as if it was an instance
        // of StorageImplementation.
        const proxy = await StorageImplementation.attach(storage.address);
        let helloResp = await proxy.hello();

        expect(helloResp).to.equal("hello");
    });
});
