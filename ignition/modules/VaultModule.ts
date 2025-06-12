import { buildModule } from '@nomicfoundation/hardhat-ignition/modules';

const VaultModule = buildModule('VaultModule', (m) => {
  // Deploy the stRIF token first
  const stRif = m.contract('stRIF');

  // Deploy the RootstockVault, passing the stRIF address as the asset
  const vault = m.contract('RootstockVault', [stRif]);

  return { stRif, vault };
});

export default VaultModule;
