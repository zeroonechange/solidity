/** @type import('hardhat/config').HardhatUserConfig */

require("@nomicfoundation/hardhat-toolbox");
require("@nomiclabs/hardhat-ethers");

const ALCHEMY_API_KEY = "h0UgrsBVWA3cA6RuWVr8uecG8Cu3ror1";
const GOERLI_PRIVATE_KEY = "a4a86b2aeba73a66de902db46d9c7f353654bca222de7585a8f9547868e8e572";

module.exports = {
  solidity: "0.8.9",
  defaultNetwork: "hardhat",
  networks: {
    hardhat: {
      allowUnlimitedContractSize: true,
      // loggingEnabled: true
    },
    goerli: {
      url: `https://eth-goerli.g.alchemy.com/v2/${ALCHEMY_API_KEY}`,
      accounts: [GOERLI_PRIVATE_KEY],
      allowUnlimitedContractSize: true
    },
  }
};
