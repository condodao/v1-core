// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {CondoVault} from "@condodao/v1-core/contracts/dao/CondoVault.sol";

contract NewCondoVault {
    event NewVault(address indexed condoTimelock, address indexed vault);

    // constructor() {}

    function createVault(address condoTimelock) public returns (address) {
        CondoVault vault = new CondoVault(condoTimelock);

        emit NewVault(address(vault), condoTimelock);

        return address(vault);
    }
}
