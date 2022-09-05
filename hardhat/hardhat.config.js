/** @type import('hardhat/config').HardhatUserConfig */
require("@nomicfoundation/hardhat-toolbox");
require("@nomiclabs/hardhat-ethers");

const ALCHEMY_API_KEY = "fcvu1qm3Vc7yAxt53kZ_5H9cHuEe8vCE";
const GOERLI_PRIVATE_KEY = "a40f68e080b908bfe99210d483cf5aa53dd2bde380cfba94f3b2de4149e2a562";

module.exports = {
  solidity: "0.8.9",
  defaultNetwork: "goerli",
  networks: {
    hardhat: {
      allowUnlimitedContractSize: true
    },
    goerli: {
      url: `https://eth-goerli.alchemyapi.io/v2/${ALCHEMY_API_KEY}`,
      accounts: [GOERLI_PRIVATE_KEY],
      allowUnlimitedContractSize: true
    },
  }
};

