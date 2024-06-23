// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import {NewCondoGovernor} from "@condodao/v1-core/contracts/condo/new/NewCondoGovernor.sol";
import {CondoNFT} from "@condodao/v1-core/contracts/nft/CondoNFT.sol";
import {CondoTimelock} from "@condodao/v1-core/contracts/dao/CondoTimelock.sol";
import {CondoGovernor} from "@condodao/v1-core/contracts/dao/CondoGovernor.sol";
import {Metadata} from "@condodao/v1-core/contracts/metadata/Metadata.sol";

contract NewCondoGovernorTest is Test {
    NewCondoGovernor newCondoGovernor;
    Metadata metadata;
    CondoNFT condoNFT;
    CondoTimelock condoTimelock;

    function setUp() public {
        newCondoGovernor = new NewCondoGovernor();
        metadata = new Metadata();

        uint256[][] memory apartments = new uint256[][](1);
        apartments[0] = new uint256[](3);
        apartments[0][0] = 1; // floor number
        apartments[0][1] = 1; // apart number
        apartments[0][2] = 1000; // apart price

        condoNFT = new CondoNFT(
            address(this),
            "CondoToken",
            "CNT",
            address(metadata),
            apartments
        );

        address[] memory proposers = new address[](1);
        address[] memory executors = new address[](1);
        proposers[0] = address(this);
        executors[0] = address(this);

        condoTimelock = new CondoTimelock(
            2 days,
            proposers,
            executors,
            address(this)
        );
    }

    function testCreateGovernor() public {
        address governorAddress = newCondoGovernor.createGovernor(
            address(condoNFT),
            address(condoTimelock)
        );

        assertTrue(governorAddress != address(0));
    }
}
