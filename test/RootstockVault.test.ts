import { expect } from 'chai';
import hre from 'hardhat';
import { HardhatEthersSigner } from '@nomicfoundation/hardhat-ethers/signers';
import { contracts } from '../typechain-types';

describe('RootstockVault', function () {
  let vault: contracts.RootstockVault;
  let stRifToken: contracts.StRIF;
  let user1: HardhatEthersSigner;
  let user2: HardhatEthersSigner;

  beforeEach(async function () {
    [user1, user2] = await hre.ethers.getSigners();

    // Deploy stRIF token (underlying asset)
    const StRIFFactory = await hre.ethers.getContractFactory('stRIF');
    stRifToken = (await StRIFFactory.deploy()) as contracts.StRIF;

    // Deploy RootstockVault
    const VaultFactory = await hre.ethers.getContractFactory('RootstockVault');
    vault = (await VaultFactory.deploy(await stRifToken.getAddress())) as contracts.RootstockVault;
    await vault.waitForDeployment();

    // Mint some stRIF tokens to users for testing
    await stRifToken.mint(user1.address, hre.ethers.parseEther('1000'));
    await stRifToken.mint(user2.address, hre.ethers.parseEther('1000'));
  });

  describe('Deployment', function () {
    it('Should set the correct underlying asset', async function () {
      expect(await vault.asset()).to.equal(await stRifToken.getAddress());
    });

    it('Should have correct vault token name and symbol', async function () {
      expect(await vault.name()).to.equal('Staked RIF Vault');
      expect(await vault.symbol()).to.equal('vRIF');
    });

    it('Should have same decimals as underlying asset', async function () {
      expect(await vault.decimals()).to.equal(await stRifToken.decimals());
    });
  });

  describe('Deposit Operations', function () {
    beforeEach(async function () {
      // Approve vault to spend user's stRIF tokens
      await stRifToken
        .connect(user1)
        .approve(await vault.getAddress(), hre.ethers.parseEther('1000'));
    });

    it('Should deposit assets and receive shares', async function () {
      const depositAmount = hre.ethers.parseEther('100');

      await expect(vault.connect(user1).deposit(depositAmount, user1.address))
        .to.emit(vault, 'Deposit')
        .withArgs(user1.address, user1.address, depositAmount, depositAmount);

      expect(await vault.balanceOf(user1.address)).to.equal(depositAmount);
      expect(await vault.totalAssets()).to.equal(depositAmount);
      expect(await stRifToken.balanceOf(user1.address)).to.equal(hre.ethers.parseEther('900'));
    });

    it('Should revert when depositing zero assets', async function () {
      await expect(vault.connect(user1).deposit(0, user1.address)).to.be.revertedWith(
        'Cannot deposit zero'
      );
    });

    it('Should handle deposits with 1:1 ratio when vault is empty', async function () {
      const depositAmount = hre.ethers.parseEther('50');

      const expectedShares = await vault.previewDeposit(depositAmount);
      expect(expectedShares).to.equal(depositAmount);
    });
  });

  describe('Mint Operations', function () {
    beforeEach(async function () {
      await stRifToken
        .connect(user1)
        .approve(await vault.getAddress(), hre.ethers.parseEther('1000'));
    });

    it('Should mint exact shares by depositing assets', async function () {
      const sharesToMint = hre.ethers.parseEther('75');
      const expectedAssets = await vault.previewMint(sharesToMint);

      await expect(vault.connect(user1).mint(sharesToMint, user1.address))
        .to.emit(vault, 'Deposit')
        .withArgs(user1.address, user1.address, expectedAssets, sharesToMint);

      expect(await vault.balanceOf(user1.address)).to.equal(sharesToMint);
      expect(await vault.totalAssets()).to.equal(expectedAssets);
    });

    it('Should revert when minting zero shares', async function () {
      await expect(vault.connect(user1).mint(0, user1.address)).to.be.revertedWith(
        'Cannot mint zero shares'
      );
    });
  });

  describe('Withdraw Operations', function () {
    beforeEach(async function () {
      // Setup: user1 deposits 200 stRIF tokens
      await stRifToken
        .connect(user1)
        .approve(await vault.getAddress(), hre.ethers.parseEther('1000'));
      await vault.connect(user1).deposit(hre.ethers.parseEther('200'), user1.address);
    });

    it('Should withdraw exact assets by burning shares', async function () {
      const withdrawAmount = hre.ethers.parseEther('50');
      const expectedShares = await vault.previewWithdraw(withdrawAmount);

      await expect(vault.connect(user1).withdraw(withdrawAmount, user1.address, user1.address))
        .to.emit(vault, 'Withdraw')
        .withArgs(user1.address, user1.address, user1.address, withdrawAmount, expectedShares);

      expect(await vault.balanceOf(user1.address)).to.equal(hre.ethers.parseEther('150'));
      expect(await stRifToken.balanceOf(user1.address)).to.equal(hre.ethers.parseEther('850'));
    });

    it('Should revert when withdrawing zero assets', async function () {
      await expect(
        vault.connect(user1).withdraw(0, user1.address, user1.address)
      ).to.be.revertedWith('Cannot withdraw zero');
    });

    it('Should allow approved spender to withdraw', async function () {
      const withdrawAmount = hre.ethers.parseEther('30');

      // user1 approves user2 to spend their shares
      await vault.connect(user1).approve(user2.address, hre.ethers.parseEther('100'));

      await expect(
        vault.connect(user2).withdraw(withdrawAmount, user2.address, user1.address)
      ).to.emit(vault, 'Withdraw');

      expect(await stRifToken.balanceOf(user2.address)).to.equal(hre.ethers.parseEther('1030'));
    });
  });

  describe('Redeem Operations', function () {
    beforeEach(async function () {
      // Setup: user1 deposits 300 stRIF tokens
      await stRifToken
        .connect(user1)
        .approve(await vault.getAddress(), hre.ethers.parseEther('1000'));
      await vault.connect(user1).deposit(hre.ethers.parseEther('300'), user1.address);
    });

    it('Should redeem shares for underlying assets', async function () {
      const sharesToRedeem = hre.ethers.parseEther('100');
      const expectedAssets = await vault.previewRedeem(sharesToRedeem);

      await expect(vault.connect(user1).redeem(sharesToRedeem, user1.address, user1.address))
        .to.emit(vault, 'Withdraw')
        .withArgs(user1.address, user1.address, user1.address, expectedAssets, sharesToRedeem);

      expect(await vault.balanceOf(user1.address)).to.equal(hre.ethers.parseEther('200'));
      expect(await stRifToken.balanceOf(user1.address)).to.equal(hre.ethers.parseEther('800'));
    });

    it('Should revert when redeeming zero shares', async function () {
      await expect(vault.connect(user1).redeem(0, user1.address, user1.address)).to.be.revertedWith(
        'Cannot redeem zero shares'
      );
    });
  });

  describe('Preview Functions', function () {
    beforeEach(async function () {
      // Add some assets to the vault for more interesting math
      await stRifToken
        .connect(user1)
        .approve(await vault.getAddress(), hre.ethers.parseEther('1000'));
      await vault.connect(user1).deposit(hre.ethers.parseEther('500'), user1.address);
    });

    it('Should preview deposit correctly', async function () {
      const assets = hre.ethers.parseEther('100');
      const expectedShares = await vault.convertToShares(assets);

      expect(await vault.previewDeposit(assets)).to.equal(expectedShares);
    });

    it('Should preview mint correctly', async function () {
      const shares = hre.ethers.parseEther('50');
      const previewAssets = await vault.previewMint(shares);

      // Should round up for minting
      expect(previewAssets).to.be.gte(await vault.convertToAssets(shares));
    });

    it('Should preview withdraw correctly', async function () {
      const assets = hre.ethers.parseEther('100');
      const previewShares = await vault.previewWithdraw(assets);

      // Should round up for withdrawal
      expect(previewShares).to.be.gte(await vault.convertToShares(assets));
    });

    it('Should preview redeem correctly', async function () {
      const shares = hre.ethers.parseEther('50');
      const expectedAssets = await vault.convertToAssets(shares);

      expect(await vault.previewRedeem(shares)).to.equal(expectedAssets);
    });
  });

  describe('Conversion Functions', function () {
    it('Should convert assets to shares (1:1 when empty)', async function () {
      const assets = hre.ethers.parseEther('100');
      expect(await vault.convertToShares(assets)).to.equal(assets);
    });

    it('Should convert shares to assets (1:1 when empty)', async function () {
      const shares = hre.ethers.parseEther('100');
      expect(await vault.convertToAssets(shares)).to.equal(shares);
    });

    it('Should maintain correct ratios after deposits', async function () {
      // Setup vault with some assets
      await stRifToken
        .connect(user1)
        .approve(await vault.getAddress(), hre.ethers.parseEther('1000'));
      await vault.connect(user1).deposit(hre.ethers.parseEther('200'), user1.address);

      const totalAssets = await vault.totalAssets();
      const totalSupply = await vault.totalSupply();

      // Test conversion maintains ratio
      const testAssets = hre.ethers.parseEther('50');
      const convertedShares = await vault.convertToShares(testAssets);
      const expectedShares = (testAssets * totalSupply) / totalAssets;

      expect(convertedShares).to.equal(expectedShares);
    });
  });

  describe('Multiple Users', function () {
    beforeEach(async function () {
      // Both users approve vault
      await stRifToken
        .connect(user1)
        .approve(await vault.getAddress(), hre.ethers.parseEther('1000'));
      await stRifToken
        .connect(user2)
        .approve(await vault.getAddress(), hre.ethers.parseEther('1000'));
    });

    it('Should handle deposits from multiple users', async function () {
      // User1 deposits first
      await vault.connect(user1).deposit(hre.ethers.parseEther('100'), user1.address);

      // User2 deposits after
      await vault.connect(user2).deposit(hre.ethers.parseEther('200'), user2.address);

      expect(await vault.balanceOf(user1.address)).to.equal(hre.ethers.parseEther('100'));
      expect(await vault.balanceOf(user2.address)).to.equal(hre.ethers.parseEther('200'));
      expect(await vault.totalAssets()).to.equal(hre.ethers.parseEther('300'));
      expect(await vault.totalSupply()).to.equal(hre.ethers.parseEther('300'));
    });

    it('Should maintain correct share ratios between users', async function () {
      // User1 deposits 100
      await vault.connect(user1).deposit(hre.ethers.parseEther('100'), user1.address);

      // User2 deposits 300
      await vault.connect(user2).deposit(hre.ethers.parseEther('300'), user2.address);

      // After first round
      const user1Balance = await vault.balanceOf(user1.address);
      const user2Balance = await vault.balanceOf(user2.address);
      const totalSupply = await vault.totalSupply();
      expect(user1Balance + user2Balance).to.equal(totalSupply);
    });
  });
});
