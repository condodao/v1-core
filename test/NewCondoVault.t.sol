// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import {NewCondoVault} from "@condodao/v1-core/contracts/condo/new/NewCondoVault.sol";
import {CondoVault} from "@condodao/v1-core/contracts/dao/CondoVault.sol";

contract NewCondoVaultTest is Test {
    NewCondoVault newCondoVault;

    function setUp() public {
        newCondoVault = new NewCondoVault();
    }

    function testCreateVault() public {
        address condoTimelock = address(0x1234);
        address vaultAddress = newCondoVault.createVault(condoTimelock);

        assertTrue(vaultAddress != address(0));
    }
}
