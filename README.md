# hardhat-foundry-starter-kit

This is an up-to-date template repository to develop using foudry, hardhat and rootstock.

## General commands

## Setup foudnry for rootstock

To set up the foundry version that works with rootstock run

```bash
chmod +x check_rust.sh
```

and then

```bash
./rootstock-setup.sh
```

## Start local devnet

- with hardhat: `npx hardhat node`
- with foundry: `anvil`

## Basic hardhat commands

1. Compile contract

   ```bash
   npx hardhat compile
   ```

1. Test contract

   ```bash
   npx hardhat test

   # Test with coverage table
   npx hardhat coverage
   ```

1. Deploy contract to local testnet

   ```bash
   npx hardhat ignition deploy ignition/modules/* --network localhost
   ```

## Basic foundry commands

1. Compile contract

   ```bash
   forge build
   ```

1. Test contract

   ```bash
   # Test with gas-report output
   forge test --gas-report
   ```

1. Get coverage table

   ```bash
   forge coverage
   ```

1. Deploy contract to local testnet

   ```bash
   forge script ./foundry/script/Faucet.s.sol:FaucetDeploymentScript --rpc-url localhost --broadcast
   ```
