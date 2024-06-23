// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import {NewCondoTimelock} from "@condodao/v1-core/contracts/condo/new/NewCondoTimelock.sol";
import {CondoTimelock} from "@condodao/v1-core/contracts/dao/CondoTimelock.sol";

contract NewCondoTimelockTest is Test {
    NewCondoTimelock newCondoTimelock;

    function setUp() public {
        newCondoTimelock = new NewCondoTimelock();
    }

    function testCreateTimelock() public {
        address timelockAddress = newCondoTimelock.createTimelock();

        assertTrue(timelockAddress != address(0));
    }
}
