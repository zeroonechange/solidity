import { time, loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import { anyValue } from "@nomicfoundation/hardhat-chai-matchers/withArgs";
import { expect } from "chai";
import { ethers, upgrades } from "hardhat";

//  https://blog.csdn.net/bsn_yanxishe/article/details/124296667

// npm install --save-dev @openzeppelin/hardhat-upgrades
// npm install --save-dev @nomiclabs/hardhat-ethers ethers # peer dependencies
// at hardhat.config.ts:  import '@openzeppelin/hardhat-upgrades';

//  npm install -save @openzeppelin/contracts
//  npm install -save @openzeppelin/contracts-upgradeable

// 这种插件化方式 去掉了很多细节  并不知道做了具体的什么东西  
describe("Temp", function () {

    it('deploys', async function () {
        const MyLogicV1 = await ethers.getContractFactory('MyLogicV1');
        const myLogicV1 = (await upgrades.deployProxy(MyLogicV1, { kind: 'uups' }));
        console.log(myLogicV1.address);

        await myLogicV1.SetLogic("aa", 1);
        expect((await myLogicV1.GetLogic("aa")).toString()).to.equal('1');

        const MyLogicV2 = await ethers.getContractFactory('MyLogicV2');
        const myLogicV2 = (await upgrades.upgradeProxy(myLogicV1, MyLogicV2));
        console.log(myLogicV2.address);

        expect((await myLogicV2.GetLogic("aa")).toString()).to.equal('101');
    });
});