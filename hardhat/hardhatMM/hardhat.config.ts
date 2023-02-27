import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";

// 尽管报错 实际上是可以执行的
task("accounts", "Prints the list of accounts", async (taskArgs, hre) => {
  const accounts = await hre.ethers.getSigners();

  for (const account of accounts) {
    console.log(account.address);
  }
});


const config: HardhatUserConfig = {
  solidity: "0.8.17",
  gasReporter: {
    enabled: true,
    currency: 'USD',
    gasPrice: 20,
  },
};

export default config;