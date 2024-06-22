// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {CondoNFT} from "@condodao/v1-core/contracts/nft/CondoNFT.sol";
import {CondoTimelock} from "@condodao/v1-core/contracts/dao/CondoTimelock.sol";
import {CondoGovernor} from "@condodao/v1-core/contracts/dao/CondoGovernor.sol";

contract NewCondoGovernor {
    event NewGovernor(
        address indexed condoNft,
        address indexed condoTimelock,
        address indexed governor
    );

    // constructor() {}

    function createGovernor(
        address condoNft,
        address condoTimelock
    ) public returns (address) {
        CondoGovernor governor = new CondoGovernor(
            CondoNFT(condoNft),
            CondoTimelock(payable(condoTimelock))
        );

        emit NewGovernor(condoNft, condoTimelock, address(governor));

        return address(governor);
    }
}
