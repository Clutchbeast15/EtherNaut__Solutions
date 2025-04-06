// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/Vault.sol";

contract VaultTest is Test {
    Vault public vault;
    bytes32 public password;

    function setUp() public {
        // Step 1: Deploy Vault with password 
        password = "mySecretPassword123!";
        vault = new Vault(password);
    }

    function testUnlockVault() public {
        //  Step 2: Read storage slot 1 (password)
        bytes32 slot1 = vm.load(address(vault), bytes32(uint256(1)));
        
        // Verification between steps
        assertEq(slot1, password, "Password mismatch");
        
        // Step 3: Unlock using the retrieved password
        vault.unlock(slot1);
        
        //  Step 4: Verify vault is now unlocked
        assertFalse(vault.locked(), "Vault should be unlocked");
        
     
    }
}