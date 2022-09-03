/** @type import('hardhat/config').HardhatUserConfig */

// usePlugin("@nomiclabs/hardhat-web3");
require("@nomiclabs/hardhat-web3");
// import "@nomiclabs/hardhat-web3";

// task action function receives the Hardhat Runtime Environment as second argument
task("accounts", "Prints accounts", async (_, { web3 }) => {
  console.log(await web3.eth.getAccounts());
});

module.exports = {
  solidity: "0.8.9",
};