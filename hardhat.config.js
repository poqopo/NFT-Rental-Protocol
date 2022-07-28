require("@nomiclabs/hardhat-waffle");
require("hardhat-deploy");
require("solidity-coverage");
require("hardhat-gas-reporter");
require("dotenv").config();

module.exports = {
  solidity: {
    compilers: [
      {
        version: "0.8.5",
        settings: {
          evmVersion: "constantinople",
          optimizer: {
            enabled: true,
            runs: 200,
          },
          outputSelection: {
            "*": {
              "*": ["storageLayout"],
            },
          },
        },
      },
    ],
  },
  networks: {
    localhost: {
      live: false,
      saveDeployments: true,
      tags: ["test", "local"],
    },
    hardhat: {
    },
    cypress: {
      url: "https://public-node-api.klaytnapi.com/v1/cypress",
      chainId: 8217,
      gas: 20000000,
      gasPrice: 250000000000,
      accounts: [process.env.PRIVATE_KEY],
      live: true,
      saveDeployments: true,
      tags: ["mainnet"],
    },
    baobab: {
      url: "https://kaikas.baobab.klaytn.net:8651",
      chainId: 1001,
      gas: 20000000,
      gasPrice: 250000000000,
      accounts: [process.env.PRIVATE_KEY],
      live: true,
      saveDeployments: true,
      tags: ["test", "testnet"],
    },
    coverage: {
      url: "http://localhost:8555",
    },
  },
  namedAccounts: {
    deployer: {
      default: 0,
    },
  },
};