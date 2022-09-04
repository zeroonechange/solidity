const { expect } = require("chai");

describe("Token contract", function () {
  it("Deployment should assign the total supply of tokens to the owner", async function () {
    const [owner] = await ethers.getSigners();

    const Token = await ethers.getContractFactory("Token");

    const hardhatToken = await Token.deploy();

    const ownerBalance = await hardhatToken.balanceOf(owner.address);

    expect(await hardhatToken.totalSupply()).to.equal(ownerBalance);

  });
});


/**
 * 1.部署合约
 *    Params
 *    ProxyAdmin
 *    TransparentUpgradeableProxy
 * 
 * 2.通过 TransparentUpgradeableProxy.fallback  用 delegatecall 调用 Params 的 set 和 get 方法 
 * 
 * 3.修改 Params 合约   通过 ProxyAdmin 进行升级 
 * 
 * 4.重复2 过程   看返回是否是新逻辑 
 */
describe("可升级合约测试", function () {

  it("1.部署三个合约", async function () {

    const Params = await ethers.getContractFactory("Params");
    const paramsToken = await Params.deploy();
    
    const ProxyAdmin = await ethers.getContractFactory("ProxyAdmin");
    const proxyAdminToken = await ProxyAdmin.deploy();

    // address _logic, address admin_, bytes memory _data
    const TransparentUpgradeableProxy = await ethers.getContractFactory("TransparentUpgradeableProxy");
    const _logic = paramsToken.address;
    const admin_ = proxyAdminToken.address;
    const _data = "0x8129fc1c";   // kecca256("initialize()") = 0x8129fc1c
    const transparentUpgradeableProxyToken = await TransparentUpgradeableProxy.deploy(_logic, admin_, _data);  

    const implementation = paramsToken.address;
    const adminProxyAddress = proxyAdminToken.address;
    const proxyAddress = transparentUpgradeableProxyToken.address;

    expect(await proxyAdminToken.getProxyImplementation(proxyAddress)).to.equal(implementation)
    expect(await proxyAdminToken.getProxyAdmin(proxyAddress)).to.equal(adminProxyAddress)

  });

  it("2.通过 fallback 调用 set / get 方法 ", async function() {

  });

});