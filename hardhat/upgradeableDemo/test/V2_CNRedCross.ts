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

        /*  这种就是相当于构建一个新的合约  
         const fallbackProxy = await Logic.attach(proxy.address);
 
         const setResp = await fallbackProxy.SetParam('a', 4);
         expect(setResp).to.emit(proxy, "ParamSetEvent").withArgs('a', 4);
         const getResp = await fallbackProxy.GetParam('a');
         expect(getResp).to.emit(proxy, "ParamGetEvent").withArgs('a', 4); */

        // 下面的才是真的 fallback 方式调用 
        const setOld = await owner.sendTransaction({
            to: proxy.address,
            data: setA4
        });
        expect(setOld).to.emit(proxy, "ParamSetEvent")
            .withArgs('a', 4);

        const getOld = await owner.sendTransaction({
            to: proxy.address,
            data: getA
        });
        expect(getOld).to.emit(proxy, "ParamSetEvent")
            .withArgs('a', 4);

    });

    it("upgrade logic contract and set/get new value", async function () {
        const { Logic, logic, proxy, proxyAdmin, owner } = await loadFixture(deployTokenFixture);

        const LogicV2 = await ethers.getContractFactory("LogicV2");
        const logicV2 = await LogicV2.deploy();
        await logicV2.deployed();
        console.log("logicV2 contract deployed -> " + logicV2.address)

        // 醍醐灌顶 
        await proxyAdmin.upgrade(proxy.address, logicV2.address);   // 由于数据是保存在代理合约中，这份数据已经初始化过了，不需要再初始化，所以调用upgrade方法即可
        console.log(" -------------- after  upgradeAndCall -------------- ")
        expect(await proxyAdmin.getProxyImplementation(proxy.address)).to.equal(logicV2.address);
        expect(await proxyAdmin.getProxyAdmin(proxy.address)).to.equal(proxyAdmin.address);
        
        /*  const fallbackProxy = await LogicV2.attach(proxy.address);
         // 之前设置了 a=4  GetParam 新代码 返回 a+10 = 14 
         const getResp = await fallbackProxy.GetParam('a');
         expect(getResp).to.emit(proxy, "ParamGetEvent")
             .withArgs('a', 14);  // 这里接收不到之前的数据了  a=0   value=10   fallback不行 这种 attach 没用 
         // 重新设置 a=1   SetParam 代码没变  
         const setResp = await fallbackProxy.SetParam('a', 1);
         expect(setResp).to.emit(proxy, "ParamSetEvent")
             .withArgs('a', 1);
         // 再次获取 a 的值 应该是  1+10 = 11 
         const getResp2 = await fallbackProxy.GetParam('a');  // 跑的是里面的代码 
         expect(getResp2).to.emit(proxy, "ParamGetEvent")
             .withArgs('a', 11);    */
        
        // 真正的fallback 调用方式  
        const getOld2 = await owner.sendTransaction({
            to: proxy.address,
            data: getA
        });
        expect(getOld2).to.emit(proxy, "ParamSetEvent")
            .withArgs('a', 4);
    });
});
