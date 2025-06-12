// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import {Script} from "forge-std/Script.sol";  
import {RootstockVault} from "../../contracts/RootstockVault.sol";
import {stRIF} from "../../contracts/stRIF.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract DeployRootstockVault is Script {
    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        // Deploy stRIF token - this is the ASSET that users deposit
        stRIF stRifToken = new stRIF();
        
        // Deploy the vault with stRIF as the underlying asset
        // The vault will create shares named "stRIF Token Vault" with symbol "vstRIF"
        new RootstockVault(IERC20(address(stRifToken)));
      

        vm.stopBroadcast();
    }
}
