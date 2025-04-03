require("@nomicfoundation/hardhat-toolbox");
require("hardhat-contract-sizer");
require("dotenv").config();

const { PRIVATE_KEY } = process.env;

module.exports = {
  solidity: {
    version: "0.8.28", // Sesuai kontrak WaifuBattleArena
    settings: {
      optimizer: {
        enabled: true,
        runs: 200 // Dari config lu, optimize gas
      },
      viaIR: true, // Dari config lu, buat kontrak gede
      metadata: {
        bytecodeHash: "none", // Dari config pertama, cocok buat Monad Testnet
        useLiteralContent: true // Dari kedua config, Sourcify suka ini
      }
    }
  },
  networks: {
    monadTestnet: { // Nama dari config pertama, lebih jelas
      url: "https://testnet-rpc.monad.xyz", // Sama di kedua config
      chainId: 10143, // Sama di kedua config
      accounts: PRIVATE_KEY ? [PRIVATE_KEY] : [], // Dari config lu
      gas: 30000000, // Dari config lu, cukup buat kontrak gede
      gasPrice: "auto" // Dari config lu
    },
    hardhat: { // Dari config lu
      chainId: 31337,
      allowUnlimitedContractSize: true, // Biar kontrak gede bisa di-test lokal
      gas: 30000000
    }
  },
  sourcify: {
    enabled: true, // Dari kedua config
    apiUrl: "https://sourcify-api-monad.blockvision.org", // Dari config pertama, khusus Monad
    browserUrl: "https://testnet.monadexplorer.com" // Dari config pertama, cocok Monad Testnet
  },
  etherscan: {
    enabled: false // Dari config pertama, disable biar ga error di Monad
  },
  contractSizer: {
    alphaSort: true, // Dari config lu
    runOnCompile: false, // Dari config lu
    disambiguatePaths: false // Dari config lu
  }
};
