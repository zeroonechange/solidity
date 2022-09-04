const { loadFixture } = require("@nomicfoundation/hardhat-network-helpers");
const { expect } = require("chai");

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

  async function deployTokenFixture(){
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

    const implementationAddress = paramsToken.address;
    const adminProxyAddress = proxyAdminToken.address;
    const proxyAddress = transparentUpgradeableProxyToken.address;
    console.log("逻辑合约:" + implementationAddress)
    console.log("管理合约:" + adminProxyAddress)
    console.log("代理合约:" + proxyAddress)
    return {proxyAdminToken, implementationAddress, adminProxyAddress, proxyAddress };
  }

  it("1.部署三个合约", async function(){
    const { proxyAdminToken, implementationAddress, adminProxyAddress, proxyAddress } = await loadFixture(deployTokenFixture);
    expect(await proxyAdminToken.getProxyImplementation(proxyAddress)).to.equal(implementationAddress)
    expect(await proxyAdminToken.getProxyAdmin(proxyAddress)).to.equal(adminProxyAddress)
  });

  it("2.通过 fallback 调用 set / get 方法 ", async function() {
    const { proxyAdminToken, implementationAddress, adminProxyAddress, proxyAddress } = await loadFixture(deployTokenFixture);
    const signer = await ethers.getSigner()
    // SetUint256Param(_key=a, _value=10) 
    const setAbiData = '0xcd4fe8cd0000000000000000000000000000000000000000000000000000000000000040000000000000000000000000000000000000000000000000000000000000000a00000000000000000000000000000000000000000000000000000000000000016100000000000000000000000000000000000000000000000000000000000000';
    await signer.sendTransaction({
      to: proxyAddress,
      data: setAbiData
    });

    // SetUint256Param(_key=a) 
    const getAbiData = '0x4e678e80000000000000000000000000000000000000000000000000000000000000002000000000000000000000000000000000000000000000000000000000000000016100000000000000000000000000000000000000000000000000000000000000';
    const txGet = await signer.sendTransaction({
      to: proxyAddress,
      data: getAbiData
    });
    
    const filter = {
                address: proxyAddress,
                topics: [
                    utils.id("Transfer(address,address,uint256)")
                ]
            }
    provider.on(filter, (log, event) => {
        // Emitted whenever a DAI token transfer occurs
    })

    console.log("callback 返回的数据 : " + txGet.blockHash )
    console.log("callback 返回的数据 : " + txGet.raw )

    expect(txGet).to.equal(10);

    
  });
});