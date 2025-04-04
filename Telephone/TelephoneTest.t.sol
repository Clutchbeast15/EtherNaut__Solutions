// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/Telephone.sol";
import "../src/TelephoneAttacker.sol"; // Now imported separately

contract TelephoneTest is Test {
        Telephone public telephone;
        TelephoneAttacker public attackerContract;
        address public  owner = address(1);
        address public attacker = address (2);


        function setUp() public {
                vm.prank(owner);
                telephone = new Telephone();
        }

        function testTelephoneHack() public {

        // ===== PHASE 1: Check original owner =====  
        assertEq(telephone.owner() , owner, "Owner should be the original owner");

        // ===== PHASE 2: Deploy the attacker contract =====
        vm.startPrank(attacker);
        attackerContract = new TelephoneAttacker(address(telephone));

        // ===== PHASE 3: Trigger the attack =====
        attackerContract.attack(attacker);

        vm.stopPrank();

        // ===== PHASE 4: Verify ownership takeover =====
        assertEq(telephone.owner() , attacker, "Attacker should be the owner");

        }
}