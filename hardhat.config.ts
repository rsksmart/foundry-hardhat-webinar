import 'dotenv/config';
import '@nomicfoundation/hardhat-toolbox';
import '@nomicfoundation/hardhat-foundry';
import '@nomicfoundation/hardhat-verify';
import { HardhatUserConfig } from 'hardhat/config';
import chalk from 'chalk';
import console from 'console';
import process from 'process';

const config: HardhatUserConfig = {
  solidity: {
    compilers: [
      {
        version: '0.8.25',
        settings: {
          optimizer: {
            evmVersion: 'cancun',
            enabled: true,
            runs: 10000
          }
        }
      }
    ]
  },
  paths: {
    sources: './contracts',
    tests: './test',
    cache: './build/cache',
    artifacts: './build/artifacts'
  },
  gasReporter: {
    enabled: true,
    outputFile: './test/gas-report.txt',
    noColors: true
  },
  networks: {
    localhost: {
      chainId: 31337,
      url: 'http://localhost:8545'
    },
    'rootstock-testnet': {
      url: 'https://public-node.testnet.rsk.co',
      chainId: 31,
      accounts: getRootstockPrivateKeys()
    }
  },
  etherscan: {
    apiKey: {
      // Is not required by blockscout. Can be any non-empty string
      'rootstock-testnet': ' '
    },
    customChains: [
      {
        network: 'rootstock-testnet',
        chainId: 31,
        urls: {
          apiURL: 'https://rootstock-testnet.blockscout.com/api/',
          browserURL: 'https://rootstock-testnet.blockscout.com/'
        }
      }
    ]
  },
  sourcify: {
    enabled: false
  }
};

function getRootstockPrivateKeys(): string[] {
  const rootstockPrivateKeysEnv = process.env.PRIVATE_KEY;
  if (rootstockPrivateKeysEnv === undefined) {
    console.log(chalk.red('Env variable PRIVATE_KEY is not set'));
    process.exit();
  }
  const rootstockPrivateKeys = rootstockPrivateKeysEnv.split(',');
  return rootstockPrivateKeys;
}

export default config;
