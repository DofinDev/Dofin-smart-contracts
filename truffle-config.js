const HDWalletProvider = require('@truffle/hdwallet-provider');
const env = require('./env.json');
const path = require("path");

module.exports = {
  compilers: {
    solc: {
      version: "pragma",
      docker: false,
      parser: "solcjs",
      settings: {
        optimizer: {
          enabled: true,
          runs: 200
        },
        evmVersion: "istanbul"
      },
    }
  },
  contracts_build_directory: path.join(__dirname, "client/src/contracts"),
  plugins: [
    'truffle-plugin-verify',
    'truffle-contract-size'
  ],
  api_keys: {
    bscscan: env.BSCSCANAPIKEY
  },
  networks: {
    develop: {
      host: "127.0.0.1",
      port: 7545,
      network_id: "*",
    },
    BSCTestnet: {
      // provider: () => new HDWalletProvider(env.BSCTestnet_mnemonic, 'https://data-seed-prebsc-1-s1.binance.org:8545'),
      host: "https://data-seed-prebsc-1-s1.binance.org",
      port: 8545,
      from: env.BSCTestnet_wallet,
      network_id: 97,
      confirmations: 0,
      networkCheckTimeout: 1000000,
      timeoutBlocks: 50000,
      skipDryRun: true
    },
    BSCMainnet: {
      // provider: () => new HDWalletProvider(env.BSCMainnet_mnemonic, 'wss://speedy-nodes-nyc.moralis.io/c0d694dd12278e2411cbe24c/bsc/mainnet/ws'),
      host: "https://bsc-dataseed.binance.org/",
      from: env.BSCMainnet_wallet,
      network_id: 56,
      confirmations: 0,
      networkCheckTimeout: 1000000,
      timeoutBlocks: 50000,
      skipDryRun: true
    },
    BSCForkMainnet: {
      // provider: () => new HDWalletProvider(env.BSCForkMainnet_mnemonic, 'http://127.0.0.1:7545'),
      host: "127.0.0.1",
      port: 7545,
      from: env.BSCForkMainnet_wallet,
      network_id: 80,
      networkCheckTimeout: 1000000,
      skipDryRun: true
    },
  },
  mocha: {
    reporter: 'eth-gas-reporter'
  }
};
