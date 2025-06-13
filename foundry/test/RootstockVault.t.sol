// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import "forge-std/Test.sol";
import "../../contracts/RootstockVault.sol";
import "../../contracts/stRIF.sol";

contract RootstockVaultTest is Test {
    RootstockVault vault;
    stRIF stRifToken;
    address user1;
    address user2;

    function setUp() public {
        user1 = address(0x1);
        user2 = address(0x2);

        // Deploy stRIF token and vault
        stRifToken = new stRIF();
        vault = new RootstockVault(IERC20(address(stRifToken)));

        // Mint tokens to users
        stRifToken.mint(user1, 1000 ether);
        stRifToken.mint(user2, 1000 ether);

        // Users approve vault
        vm.prank(user1);
        stRifToken.approve(address(vault), type(uint256).max);
        vm.prank(user2);
        stRifToken.approve(address(vault), type(uint256).max);
    }

    function testDeployment() public view {
        assertEq(vault.asset(), address(stRifToken));
        assertEq(vault.name(), "Staked RIF Vault");
        assertEq(vault.symbol(), "vRIF");
        assertEq(vault.decimals(), stRifToken.decimals());
    }

    function testDeposit() public {
        vm.prank(user1);
        vault.deposit(100 ether, user1);

        assertEq(vault.balanceOf(user1), 100 ether);
        assertEq(vault.totalAssets(), 100 ether);
        assertEq(stRifToken.balanceOf(user1), 900 ether);
    }

    function testDepositZeroReverts() public {
        vm.prank(user1);
        vm.expectRevert("Cannot deposit zero");
        vault.deposit(0, user1);
    }

    function testMint() public {
        vm.prank(user1);
        vault.mint(75 ether, user1);

        assertEq(vault.balanceOf(user1), 75 ether);
        assertEq(vault.totalAssets(), 75 ether);
    }

    function testMintZeroReverts() public {
        vm.prank(user1);
        vm.expectRevert("Cannot mint zero shares");
        vault.mint(0, user1);
    }

    function testWithdraw() public {
        vm.startPrank(user1);
        vault.deposit(200 ether, user1);
        vault.withdraw(50 ether, user1, user1);
        assertEq(vault.balanceOf(user1), 150 ether);
        assertEq(stRifToken.balanceOf(user1), 850 ether);
        vm.stopPrank();
    }

    function testWithdrawZeroReverts() public {
        vm.startPrank(user1);
        vault.deposit(200 ether, user1);
        vm.expectRevert("Cannot withdraw zero");
        vault.withdraw(0, user1, user1);
        vm.stopPrank();
    }

    function testWithdrawWithAllowance() public {
        vm.startPrank(user1);
        vault.deposit(200 ether, user1);
        vault.approve(user2, 100 ether);
        vm.stopPrank();

        vm.prank(user2);
        vault.withdraw(30 ether, user2, user1);

        assertEq(stRifToken.balanceOf(user2), 1030 ether);
    }

    function testRedeem() public {
        vm.startPrank(user1);
        vault.deposit(300 ether, user1);
        vault.redeem(100 ether, user1, user1);
        assertEq(vault.balanceOf(user1), 200 ether);
        assertEq(stRifToken.balanceOf(user1), 800 ether);
        vm.stopPrank();
    }

    function testRedeemZeroReverts() public {
        vm.startPrank(user1);
        vault.deposit(300 ether, user1);
        vm.expectRevert("Cannot redeem zero shares");
        vault.redeem(0, user1, user1);
        vm.stopPrank();
    }

    function testPreviewDeposit() public view {
        uint256 assets = 100 ether;
        assertEq(vault.previewDeposit(assets), vault.convertToShares(assets));
    }

    function testPreviewMint() public {
        vm.prank(user1);
        vault.deposit(500 ether, user1);

        uint256 shares = 50 ether;
        uint256 previewAssets = vault.previewMint(shares);
        assertGe(previewAssets, vault.convertToAssets(shares));
    }

    function testPreviewWithdraw() public {
        vm.prank(user1);
        vault.deposit(500 ether, user1);

        uint256 assets = 100 ether;
        uint256 previewShares = vault.previewWithdraw(assets);
        assertGe(previewShares, vault.convertToShares(assets));
    }

    function testPreviewRedeem() public {
        vm.prank(user1);
        vault.deposit(500 ether, user1);

        uint256 shares = 50 ether;
        assertEq(vault.previewRedeem(shares), vault.convertToAssets(shares));
    }

    function testConversionFunctions() public {
        assertEq(vault.convertToShares(100 ether), 100 ether);
        assertEq(vault.convertToAssets(100 ether), 100 ether);

        vm.prank(user1);
        vault.deposit(200 ether, user1);

        uint256 totalAssets = vault.totalAssets();
        uint256 totalSupply = vault.totalSupply();
        uint256 testAssets = 50 ether;
        uint256 convertedShares = vault.convertToShares(testAssets);
        uint256 expectedShares = (testAssets * totalSupply) / totalAssets;
        assertEq(convertedShares, expectedShares);
    }

    function testMultipleUsers() public {
        // First round of deposits
        vm.prank(user1);
        vault.deposit(100 ether, user1);

        vm.prank(user2);
        vault.deposit(200 ether, user2);

        assertEq(vault.balanceOf(user1), 100 ether);
        assertEq(vault.balanceOf(user2), 200 ether);
        assertEq(vault.totalAssets(), 300 ether);
        assertEq(vault.totalSupply(), 300 ether);

        // User1 should own 1/3, user2 should own 2/3
        assertEq(vault.balanceOf(user1) * 3, vault.totalSupply());
        assertEq(vault.balanceOf(user2) * 3, vault.totalSupply() * 2);

        // Second round of deposits
        vm.prank(user1);
        vault.deposit(100 ether, user1);
        vm.prank(user2);
        vault.deposit(300 ether, user2);

        // After second round, just check sum
        uint256 user1Balance = vault.balanceOf(user1);
        uint256 user2Balance = vault.balanceOf(user2);
        uint256 totalSupply = vault.totalSupply();
        assertEq(user1Balance + user2Balance, totalSupply);
    }
} 
