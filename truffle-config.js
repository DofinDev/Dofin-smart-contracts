const HDWalletProvider = require('@truffle/hdwallet-provider');
const env = require('./env.json');
const path = require("path");

module.exports = {
  // See <http://truffleframework.com/docs/advanced/configuration>
  // to customize your Truffle configuration!
  compilers: {
    solc: {
      version: "pragma", // A version or constraint - Ex. "^0.5.0"
                         // Can be set to "native" to use a native solc or
                         // "pragma" which attempts to autodetect compiler versions
      docker: false, // Use a version obtained through docker
      parser: "solcjs",  // Leverages solc-js purely for speedy parsing
      settings: {
        optimizer: {
          enabled: true,
          runs: 1   // Optimize for how many times you intend to run the code
        },
        evmVersion: "istanbul" // Default: "istanbul"
      },
      // modelCheckerSettings: {
      //   // contains options for SMTChecker
      // }
    }
  },
  contracts_build_directory: path.join(__dirname, "client/src/contracts"),
  plugins: [
    'truffle-plugin-verify'
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
      provider: () => new HDWalletProvider(env.BSCTestnet_mnemonic, `https://data-seed-prebsc-1-s1.binance.org:8545`),
      network_id: 97,
      confirmations: 10,
      timeoutBlocks: 200,
      skipDryRun: true
    },
    BSCMainnet: {
      provider: () => new HDWalletProvider(env.BSCMainnet_mnemonic, `https://bsc-dataseed1.binance.org`),
      network_id: 56,
      confirmations: 10,
      timeoutBlocks: 200,
      skipDryRun: true
    }
  }
};
