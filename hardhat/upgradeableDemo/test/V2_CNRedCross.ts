import { time, loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import { anyValue } from "@nomicfoundation/hardhat-chai-matchers/withArgs";
import { expect } from "chai";
import { ethers } from "hardhat";

/**
 * logic = Params    proxy = TransparentUpgradeableProxy
 * 1.分别部署 {实现合约 logic} {代理管理合约 ProxyAdmin}  {代理合约 proxy }
 * 2.通过 ProxyAdmin 设置 proxy 和 implementation
 * 3.通过 proxy 的fallback 方法 调用 logic 里面的方法  加上日志和事件  方便调试
 * 4.再部署一个新的 logicV2  具体逻辑做点修改 
 * 5.通过 ProxyAdmin 进行升级  调用方法  看是否生效 
 */
describe("V2_CNRedCross Test", function () {

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

        const fallbackProxy = await Logic.attach(proxy.address);

        const setResp = await fallbackProxy.SetParam('a', 4);
        expect(setResp).to.emit(proxy, "ParamSetEvent").withArgs('a', 4);
        const getResp = await fallbackProxy.GetParam('a');
        expect(getResp).to.emit(proxy, "ParamGetEvent").withArgs('a', 4);
    });

    it("upgrade logic contract and set/get new value", async function () {
        const { Logic, logic, proxy, proxyAdmin, owner } = await loadFixture(deployTokenFixture);

        const LogicV2 = await ethers.getContractFactory("LogicV2");
        const logicV2 = await LogicV2.deploy();
        await logicV2.deployed();
        console.log("logicV2 contract deployed -> " + logicV2.address)

        await proxyAdmin.upgradeAndCall(proxy.address, logicV2.address, '0x8129fc1c');
        // await proxyAdmin.upgrade(proxy.address, logicV2.address);
        console.log(" -------------- after  upgradeAndCall -------------- ")
        expect(await proxyAdmin.getProxyImplementation(proxy.address)).to.equal(logicV2.address);
        expect(await proxyAdmin.getProxyAdmin(proxy.address)).to.equal(proxyAdmin.address);

        const fallbackProxy = await LogicV2.attach(proxy.address);

        // 之前设置了 a=4  GetParam 新代码 返回 a+10 = 14 
        const getResp = await fallbackProxy.GetParam('a');
        expect(getResp).to.emit(proxy, "ParamGetEvent")
            .withArgs('a', 14);

        console.log(" -------------- get  old -------------- ")

        // 重新设置 a=1   SetParam 代码没变  
        const setResp = await fallbackProxy.SetParam('a', 1);
        expect(setResp).to.emit(proxy, "ParamSetEvent")
            .withArgs('a', 1);
        // 再次获取 a 的值 应该是  1+10 = 11 
        console.log(" -------------- set  new -------------- ")

        expect(getResp).to.emit(proxy, "ParamGetEvent")
            .withArgs('a', 11);

        console.log(" -------------- get  new -------------- ")
    });
});
