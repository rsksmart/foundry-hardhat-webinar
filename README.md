# hardhat-foundry-starter-kit

This is an up-to-date template repository to develop using Foundry, Hardhat and Rootstock.

## General commands

## Setup Foundry for Rootstock

To set up the Foundry version that works with Rootstock run

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

## Basic Hardhat commands

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

## Basic Foundry commands

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
## Support

For any questions or support, please open an issue on the repository or reach out to the maintainers.

# Disclaimer

The software provided in this GitHub repository is offered "as is," without warranty of any kind, express or implied, including but not limited to the warranties of merchantability, fitness for a particular purpose, and non-infringement.

- **Testing:** The software has not undergone testing of any kind, and its functionality, accuracy, reliability, and suitability for any purpose are not guaranteed.
- **Use at Your Own Risk:** The user assumes all risks associated with the use of this software. The author(s) of this software shall not be held liable for any damages, including but not limited to direct, indirect, incidental, special, consequential, or punitive damages arising out of the use of or inability to use this software, even if advised of the possibility of such damages.
- **No Liability:** The author(s) of this software are not liable for any loss or damage, including without limitation, any loss of profits, business interruption, loss of information or data, or other pecuniary loss arising out of the use of or inability to use this software.
- **Sole Responsibility:** The user acknowledges that they are solely responsible for the outcome of the use of this software, including any decisions made or actions taken based on the software's output or functionality.
- **No Endorsement:** Mention of any specific product, service, or organization does not constitute or imply endorsement by the author(s) of this software.
- **Modification and Distribution:** This software may be modified and distributed under the terms of the license provided with the software. By modifying or distributing this software, you agree to be bound by the terms of the license.
- **Assumption of Risk:** By using this software, the user acknowledges and agrees that they have read, understood, and accepted the terms of this disclaimer and assumes all risks associated with the use of this software.

