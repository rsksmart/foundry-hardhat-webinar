// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC4626.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

/**
 * @title RootstockVaultV2 - Educational ERC4626 Vault
 * @author Rootstock Labs
 * @notice Simple ERC-4626 vault for educational purposes with core functionality only
 * @dev Minimal implementation focusing on the 4 critical vault operations: deposit, withdraw, mint, redeem
 */
contract RootstockVault is ERC4626 {
    using SafeERC20 for IERC20;

    /**
     * @notice Creates a new vault for the specified asset
     * @param asset_ The ERC20 token that users can deposit into this vault
     */
    constructor(IERC20 asset_)
        ERC20(
            string(bytes.concat(bytes(IERC20Metadata(address(asset_)).name()), bytes(" Vault"))),
            string(bytes.concat(bytes("v"), bytes(IERC20Metadata(address(asset_)).symbol())))
        )
        ERC4626(asset_)
    {}

    /*//////////////////////////////////////////////////////////////
                        CORE VAULT OPERATIONS
    //////////////////////////////////////////////////////////////*/

    /**
     * @notice Deposit assets and receive vault shares
     * @param assets Amount of underlying assets to deposit
     * @param receiver Who receives the vault shares
     * @return shares Amount of vault shares minted
     */
    function deposit(uint256 assets, address receiver) public override returns (uint256 shares) {
        require(assets > 0, "Cannot deposit zero");
        
        // Calculate how many shares to mint
        shares = previewDeposit(assets);
        require(shares > 0, "Would receive zero shares");

        // Transfer assets from user to vault
        IERC20(asset()).safeTransferFrom(msg.sender, address(this), assets);
        
        // Mint shares to receiver
        _mint(receiver, shares);

        emit Deposit(msg.sender, receiver, assets, shares);
    }

    /**
     * @notice Mint exact amount of shares by depositing assets
     * @param shares Amount of vault shares to mint
     * @param receiver Who receives the vault shares
     * @return assets Amount of underlying assets deposited
     */
    function mint(uint256 shares, address receiver) public override returns (uint256 assets) {
        require(shares > 0, "Cannot mint zero shares");
        
        // Calculate how many assets needed
        assets = previewMint(shares);
        require(assets > 0, "Would cost zero assets");

        // Transfer assets from user to vault
        IERC20(asset()).safeTransferFrom(msg.sender, address(this), assets);
        
        // Mint shares to receiver
        _mint(receiver, shares);

        emit Deposit(msg.sender, receiver, assets, shares);
    }

    /**
     * @notice Withdraw exact amount of assets by burning shares
     * @param assets Amount of underlying assets to withdraw
     * @param receiver Who receives the assets
     * @param owner Who owns the shares being burned
     * @return shares Amount of vault shares burned
     */
    function withdraw(uint256 assets, address receiver, address owner) public override returns (uint256 shares) {
        require(assets > 0, "Cannot withdraw zero");
        
        // Calculate how many shares to burn
        shares = previewWithdraw(assets);
        require(shares > 0, "Would burn zero shares");

        // Check if caller has permission to spend owner's shares
        if (msg.sender != owner) {
            _spendAllowance(owner, msg.sender, shares);
        }

        // Burn shares from owner
        _burn(owner, shares);
        
        // Transfer assets to receiver
        IERC20(asset()).safeTransfer(receiver, assets);

        emit Withdraw(msg.sender, receiver, owner, assets, shares);
    }

    /**
     * @notice Redeem shares for underlying assets
     * @param shares Amount of vault shares to redeem
     * @param receiver Who receives the assets
     * @param owner Who owns the shares being redeemed
     * @return assets Amount of underlying assets withdrawn
     */
    function redeem(uint256 shares, address receiver, address owner) public override returns (uint256 assets) {
        require(shares > 0, "Cannot redeem zero shares");
        
        // Calculate how many assets to withdraw
        assets = previewRedeem(shares);
        require(assets > 0, "Would receive zero assets");

        // Check if caller has permission to spend owner's shares
        if (msg.sender != owner) {
            _spendAllowance(owner, msg.sender, shares);
        }

        // Burn shares from owner
        _burn(owner, shares);
        
        // Transfer assets to receiver
        IERC20(asset()).safeTransfer(receiver, assets);

        emit Withdraw(msg.sender, receiver, owner, assets, shares);
    }

    /*//////////////////////////////////////////////////////////////
                        VIEW FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    /**
     * @notice Total amount of underlying assets held by the vault
     * @return Total assets in the vault
     */
    function totalAssets() public view override returns (uint256) {
        return IERC20(asset()).balanceOf(address(this));
    }

    /**
     * @notice Preview how many shares would be minted for an asset deposit
     * @param assets Amount of assets to deposit
     * @return shares Amount of shares that would be minted
     */
    function previewDeposit(uint256 assets) public view override returns (uint256 shares) {
        return convertToShares(assets);
    }

    /**
     * @notice Preview how many assets would be needed to mint shares
     * @param shares Amount of shares to mint
     * @return assets Amount of assets needed
     */
    function previewMint(uint256 shares) public view override returns (uint256 assets) {
        uint256 supply = totalSupply();
        return supply == 0 ? shares : (shares * totalAssets() + supply - 1) / supply; // Round up
    }

    /**
     * @notice Preview how many shares would be burned for an asset withdrawal
     * @param assets Amount of assets to withdraw
     * @return shares Amount of shares that would be burned
     */
    function previewWithdraw(uint256 assets) public view override returns (uint256 shares) {
        uint256 supply = totalSupply();
        return supply == 0 ? assets : (assets * supply + totalAssets() - 1) / totalAssets(); // Round up
    }

    /**
     * @notice Preview how many assets would be received for redeeming shares
     * @param shares Amount of shares to redeem
     * @return assets Amount of assets that would be received
     */
    function previewRedeem(uint256 shares) public view override returns (uint256 assets) {
        return convertToAssets(shares);
    }

    /*//////////////////////////////////////////////////////////////
                        CONVERSION FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    /**
     * @notice Convert assets to shares (rounded down)
     * @param assets Amount of assets to convert
     * @return shares Equivalent amount of shares
     */
    function convertToShares(uint256 assets) public view override returns (uint256 shares) {
        uint256 supply = totalSupply();
        return supply == 0 ? assets : assets * supply / totalAssets();
    }

    /**
     * @notice Convert shares to assets (rounded down)
     * @param shares Amount of shares to convert
     * @return assets Equivalent amount of assets
     */
    function convertToAssets(uint256 shares) public view override returns (uint256 assets) {
        uint256 supply = totalSupply();
        return supply == 0 ? shares : shares * totalAssets() / supply;
    }
}
