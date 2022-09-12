import { time, loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import { anyValue } from "@nomicfoundation/hardhat-chai-matchers/withArgs";
import { expect } from "chai";
import { ethers } from "hardhat";

 
/* describe("V2_CNRedCross Test", function () {

    const setA4 = '0xef6f2e050000000000000000000000000000000000000000000000000000000000000040000000000000000000000000000000000000000000000000000000000000000400000000000000000000000000000000000000000000000000000000000000016100000000000000000000000000000000000000000000000000000000000000';
    const getA = '0x70e03cb3000000000000000000000000000000000000000000000000000000000000002000000000000000000000000000000000000000000000000000000000000000016100000000000000000000000000000000000000000000000000000000000000';

    async function deployTokenFixture() {
        const [owner] = await ethers.getSigners();
        console.log("owner -> " + owner.address)

        const Logic = await ethers.getContractFactory("Logic");
        const logic = await Logic.deploy();
        await logic.deployed();

        console.log("logic contract deployed -> " + logic.address)

        const ProxyAdmin = await ethers.getContractFactory("ProxyAdmin");
        const proxyAdmin = await ProxyAdmin.deploy();
        await proxyAdmin.deployed();

        console.log("proxyAdmin contract deployed -> " + proxyAdmin.address)

        const TransparentUpgradeableProxy = await ethers.getContractFactory("TransparentUpgradeableProxy");
        const proxy = await TransparentUpgradeableProxy.deploy(logic.address, proxyAdmin.address, "0x8129fc1c");
        await proxy.deployed();

        console.log("proxy contract deployed -> " + proxy.address)

        return { Logic, logic, proxy, proxyAdmin, owner };
    }

    it("proxy Should set the right logic", async function () {
        const { logic, proxy, proxyAdmin, owner } = await loadFixture(deployTokenFixture);
        expect(await proxyAdmin.getProxyImplementation(proxy.address)).to.equal(logic.address)
        expect(await proxyAdmin.getProxyAdmin(proxy.address)).to.equal(proxyAdmin.address)
    });

    it("call logic via proxy.fallback()", async function () {
        const { Logic, logic, proxy, proxyAdmin, owner } = await loadFixture(deployTokenFixture);

    });

    it("upgrade logic contract and set/get new value", async function () {
        const { Logic, logic, proxy, proxyAdmin, owner } = await loadFixture(deployTokenFixture);
        
    });
}); */
