require("@nomicfoundation/hardhat-toolbox");
require("@chainlink/env-enc").config();
require("./tasks/index")

const SEPOLIA_URL = process.env.SEPOLIA_URL;
const PRIVATE_KEY = process.env.PRIVATE_KEY;
const PRIVATE_KEY2 = process.env.PRIVATE_KEY2;
const ETHERSCAN_API_KEY = process.env.ETHERSCAN_API_KEY;

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: "0.8.24",
  networks: {
    sepolia: {
      url: SEPOLIA_URL,
      accounts: [PRIVATE_KEY, PRIVATE_KEY2],
      chainId: 11155111,
    },
  },
  etherscan: {
    apiKey: {
      sepolia: ETHERSCAN_API_KEY,
    },
  },
};
