import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
import { config as dotenvConfig } from "dotenv";

dotenvConfig();

const { SECRET_KEY, SEPOLIA_URL } = process.env;

const config: HardhatUserConfig = {
  solidity: "0.8.28",
  networks: {
    sepolia: {
      url: SEPOLIA_URL || "",
      accounts: SECRET_KEY !== undefined ? [SECRET_KEY] : [],
    },
  },
};

export default config;