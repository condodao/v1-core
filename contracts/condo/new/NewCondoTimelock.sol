// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {CondoTimelock} from "@condodao/v1-core/contracts/dao/CondoTimelock.sol";

contract NewCondoTimelock {
    event NewTimelock(
        address indexed timelock,
        uint256 minDelay,
        address[] proposers,
        address[] executors,
        address indexed admin
    );

    // constructor() {}

    function createTimelock() public returns (address) {
        address admin = msg.sender;
        uint256 minDelay = 2 days; // 2 days
        address[] memory proposers = new address[](1);
        address[] memory executors = new address[](1);
        proposers[0] = msg.sender;
        executors[0] = msg.sender;

        CondoTimelock timelock = new CondoTimelock(
            minDelay,
            proposers,
            executors,
            admin
        );

        emit NewTimelock(
            address(timelock),
            minDelay,
            proposers,
            executors,
            admin
        );

        return address(timelock);
    }
}
