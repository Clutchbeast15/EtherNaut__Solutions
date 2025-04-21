// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Test} from "forge-std/Test.sol";
import {Privacy} from "../src/Privacy.sol";
import {console} from "forge-std/console.sol";

contract PrivacyTest is Test {
    Privacy privacyContract;

    function setUp() public {
        privacyContract = new Privacy([bytes32(0), bytes32(0), bytes32(0x1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef)]);
    }

    function testUnlock() public {

        // Read slot 5 (data[2])
        bytes32 slot5Value = vm.load(address(privacyContract), bytes32(uint256(5)));
        console.log("Slot 5 Value (hex): ", vm.toString(slot5Value));
        
        bytes16 key = bytes16(slot5Value); 
        console.log("Key (hex): ", vm.toString(key));
        

        // Unlock        
        privacyContract.unlock(key);
        console.log("Contract unlocked");

        // Verify
        assertFalse(privacyContract.locked(), "Contract should be unlocked");
    }
}
