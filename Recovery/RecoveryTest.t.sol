// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import {Recovery, SimpleToken} from "../src/Recovery.sol";

contract RecoveryTest is Test {
    Recovery level;
    SimpleToken lostcontract;

    address player = makeAddr("player");
    address deployer = makeAddr("deployer");

    function setUp() public {
        level = new Recovery();

        vm.deal(player, 1 ether);
        vm.deal(deployer, 1 ether);
    }

    function test_recovery() public {
        vm.startPrank(deployer);

        // Step 1: create token (nonce = 1)
        level.generateToken("MyLostToken", 10000);

        // Step 2: compute address of deployed contract
        address lostAddress = computeAddress(address(level), 1);

        lostcontract = SimpleToken(payable(lostAddress));

        vm.stopPrank();

        // sanity check
        assertEq(address(lostcontract).balance, 0);

        // send ETH to lost contract
        vm.deal(address(lostcontract), 0.001 ether);

        vm.startPrank(player);

        // Step 3: destroy and recover funds
        lostcontract.destroy(payable(player));

        vm.stopPrank();

        // after selfdestruct → balance transferred
        assertEq(address(player).balance, 1 ether + 0.001 ether);
    }

    function computeAddress(address _creator, uint256 _nonce) internal pure returns (address) {
        return address(uint160(uint256(keccak256(abi.encodePacked(
            bytes1(0xd6),
            bytes1(0x94),
            _creator,
            bytes1(uint8(_nonce))
        )))));
    }
}
