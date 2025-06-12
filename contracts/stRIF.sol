// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity 0.8.25;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

/**
 * @title USDRIF Token
 * @notice A simple ERC20 token representing USDRIF for educational purposes
 * @dev This is the ASSET that users deposit into the vault (not the vault shares)
 */
contract stRIF is ERC20 {
    /**
     * @notice Deploy USDRIF token with initial supply
     */
    constructor() ERC20("Staked RIF", "RIF") {}
    
    /**
     * @notice Allow anyone to mint tokens for testing purposes
     * @dev In production, this would have access controls
     */
    function mint(address to, uint256 amount) external {
        _mint(to, amount);
    }
}
