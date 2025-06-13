[![OpenSSF Scorecard](https://api.scorecard.dev/projects/github.com/rsksmart/foundry-hardhat-webinar/badge)](https://scorecard.dev/viewer/?uri=github.com/rsksmart/foundry-hardhat-webinar)
[![CodeQL](https://github.com/rsksmart/foundry-hardhat-webinar/workflows/CodeQL/badge.svg)](https://github.com/rsksmart/foundry-hardhat-webinar/actions?query=workflow%3ACodeQL)

# Hardhat & Foundry Starter Kit

A modern template repository for developing smart contracts using **Foundry**, **Hardhat**, and **Rootstock**.

---

## Quick Start

### Compile Contracts

**With Hardhat:**

```bash
bunx hardhat compile
```

**With Foundry:**

```bash
forge build
```

---

### Run Tests

**With Hardhat:**

```bash
bunx hardhat test
```

**With Coverage Table:**

```bash
bunx hardhat coverage
```

**With Foundry (Gas Report):**

```bash
forge test --gas-report
```

**With Foundry (Coverage):**

```bash
forge coverage
```

---

### Deploy to Rootstock Testnet

**With Hardhat Ignition:**

```bash
bunx hardhat ignition deploy ignition/modules/VaultModule.ts --network rootstock-testnet
```

**With Foundry Script:**

```bash
forge script ./foundry/script/RootstockVault.s.sol --rpc-url https://public-node.testnet.rsk.co --broadcast 
```

### Verify to Rootstock Testnet

**stRIF**

```bash
bunx hardhat verify --network rootstock-testnet <stRifAddress>
```

**Rootstock Vault**

```bash
bunx hardhat verify --network rootstock-testnet <RootstockVaultAddress> <stRifAddress>
```

---

## Support

For any questions or support, please open an issue on the repository or reach out to the maintainers.

## Disclaimer

The software provided in this GitHub repository is offered "as is," without warranty of any kind, express or implied, including but not limited to the warranties of merchantability, fitness for a particular purpose, and non-infringement.

- **Testing:** The software has not undergone testing of any kind, and its functionality, accuracy, reliability, and suitability for any purpose are not guaranteed.
- **Use at Your Own Risk:** The user assumes all risks associated with the use of this software. The author(s) of this software shall not be held liable for any damages, including but not limited to direct, indirect, incidental, special, consequential, or punitive damages arising out of the use of or inability to use this software, even if advised of the possibility of such damages.
- **No Liability:** The author(s) of this software are not liable for any loss or damage, including without limitation, any loss of profits, business interruption, loss of information or data, or other pecuniary loss arising out of the use of or inability to use this software.
- **Sole Responsibility:** The user acknowledges that they are solely responsible for the outcome of the use of this software, including any decisions made or actions taken based on the software's output or functionality.
- **No Endorsement:** Mention of any specific product, service, or organization does not constitute or imply endorsement by the author(s) of this software.
- **Modification and Distribution:** This software may be modified and distributed under the terms of the license provided with the software. By modifying or distributing this software, you agree to be bound by the terms of the license.
- **Assumption of Risk:** By using this software, the user acknowledges and agrees that they have read, understood, and accepted the terms of this disclaimer and assumes all risks associated with the use of this software.

---
