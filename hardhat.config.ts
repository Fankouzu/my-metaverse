import "hardhat-typechain";
import "@nomiclabs/hardhat-ethers";
import "@nomiclabs/hardhat-waffle";
import "@nomiclabs/hardhat-etherscan";
import { task } from "hardhat/config";
import { compileSetting } from "./scripts/deployTool";
import { RPCS } from "./scripts/network";
const dotenv = require('dotenv')
dotenv.config();

task("accounts", "Prints the list of accounts", async (taskArgs, bre) => {
  const accounts = await bre.ethers.getSigners();

  for (const account of accounts) {
    let address = await account.getAddress();
    console.log(
      address,
      (await bre.ethers.provider.getBalance(address)).toString()
    );
  }
});

export default {
  networks: RPCS,
  etherscan: {
    apiKey: process.env.ETHERSCAN_APIKEY,
  },
  solidity: {
    compilers: [compileSetting("0.8.3", 200)],
    overrides: {
      "contracts/samples/Loot.sol": compileSetting("0.6.6", 200),
    },
  },
};
