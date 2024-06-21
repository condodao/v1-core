// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "@condao/contracts/NFT.sol";
import "@condao/contracts/CondoTimelock.sol";
import "@condao/contracts/CondoGovernor.sol";
import "@condao/contracts/CondoVault.sol";

contract Deploy is Script {
    function run() external {
        address deployer = msg.sender;

        vm.startBroadcast(deployer);

        uint256[][] memory apartments = new uint256[][](0);
        NFT condoNFT = new NFT("Test", "TST", apartments);

        // Deploy the Timelock contract
        uint256 minDelay = 60 * 60 * 24 * 2; // 2 days
        address[] memory proposers = new address[](1);
        address[] memory executors = new address[](1);
        proposers[0] = deployer;
        executors[0] = deployer;
        CondoTimelock condoTimelock = new CondoTimelock(
            minDelay,
            proposers,
            executors,
            deployer
        );

        // Deploy the Governor contract
        CondoGovernor condoGovernor = new CondoGovernor(
            condoNFT,
            condoTimelock
        );

        // Deploy the Vault contract and transfer ownership to the Timelock contract
        new CondoVault(address(condoTimelock));

        // Set the Timelock contract as the executor of the Governor contract
        condoTimelock.grantRole(
            condoTimelock.EXECUTOR_ROLE(),
            address(condoGovernor)
        );

        // Add Governor as a proposer to Timelock
        condoTimelock.grantRole(
            condoTimelock.PROPOSER_ROLE(),
            address(condoGovernor)
        );

        vm.stopBroadcast();
    }
}
