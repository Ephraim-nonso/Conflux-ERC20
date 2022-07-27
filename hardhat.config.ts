import { HardhatUserConfig, task } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
import '@nomiclabs/hardhat-waffle'
import '@typechain/hardhat'
import * as dotenv from "dotenv"



dotenv.config()

task('accounts', 'Prints the list of accounts', async (taskArgs, hre) => {
  const accounts = await hre.ethers.getSigners()

  for (const account of accounts) {
    // console.log(account.address)
  }
})

const config: HardhatUserConfig = {
  solidity: {
    version: "0.8.7",
  },
  networks: {
    conflux: {
      url: process.env.CFX_URL || '',
      accounts:
        process.env.CONFLUX_PRIVATE_KEY !== undefined ? [process.env.CONFLUX_PRIVATE_KEY] : [],
    }
  }
};

export default config;
