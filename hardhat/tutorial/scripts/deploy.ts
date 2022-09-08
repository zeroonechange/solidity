import { ethers } from "hardhat";

async function main() {
  const currentTimestampInSeconds = Math.round(Date.now() / 1000);
  const ONE_YEAR_IN_SECS = 365 * 24 * 60 * 60;
  const unlockTime = currentTimestampInSeconds + ONE_YEAR_IN_SECS;

  const lockedAmount = ethers.utils.parseEther("1");

  const Lock = await ethers.getContractFactory("Lock");
  const lock = await Lock.deploy(unlockTime, { value: lockedAmount });

  await lock.deployed();

  console.log(`Lock with 1 ETH and unlock timestamp ${unlockTime} deployed to ${lock.address}`);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });


//  npx hardhat node
//  npx hardhat run --network localhost scripts/deploy.ts

/**
 * ethers.js + hardhat  能做俩个事情
 * 1. 测试脚本   部署在本地网络节点  0等待   部署  普通调用  fallback调用方式有点不太一样  
 * 2. 部署脚本   或者搞一些有意思的实验  可以远程弄到 rinkeby  或者  geroli 上面去  
 * 
 * 基本上看这个项目的代码  结合官网doc英文文档 可以弄懂 80%的流程了   感觉功能不够强大  ethers.js 的官网文档写的很拉跨 
 * 
 */