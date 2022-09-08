import '@nomiclabs/hardhat-waffle'
import '@nomiclabs/hardhat-ethers'

// types
import type { HardhatUserConfig } from 'hardhat/config'

const config: HardhatUserConfig = {
  solidity: '0.8.9',
  defaultNetwork: "hardhat",
  networks: {
    hardhat: {
      
    }
  }
}

export default config

// npm install -D @nomiclabs/hardhat-waffle ethereum-waffle