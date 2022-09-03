/** @type import('hardhat/config').HardhatUserConfig */

// usePlugin("@nomiclabs/hardhat-web3");
require("@nomiclabs/hardhat-web3");
// import "@nomiclabs/hardhat-web3";

// task action function receives the Hardhat Runtime Environment as second argument
task("accounts", "Prints accounts", async (_, { web3 }) => {
  console.log(await web3.eth.getAccounts());
});

module.exports = {
  defaultNetwork: "rinkeby",
  networks: {
    hardhat: {
    },
    rinkeby: { 
      url: "https://rinkeby.infura.io/v3",
      accounts: ['a40f68e080b908bfe99210d483cf5aa53dd2bde380cfba94f3b2de4149e2a562']
    }
  },
  solidity: "0.8.9",
};