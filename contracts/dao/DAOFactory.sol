// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {CondoNFT} from "@condodao/v1-core/contracts/nft/CondoNFT.sol";
import {CondoTimelock} from "@condodao/v1-core/contracts/dao/CondoTimelock.sol";
import {CondoGovernor} from "@condodao/v1-core/contracts/dao/CondoGovernor.sol";
import {CondoVault} from "@condodao/v1-core/contracts/dao/CondoVault.sol";

contract DAOFactory {
    CondoNFT public condoNft;
    CondoTimelock public condoTimelock;
    CondoGovernor public condoGovernor;
    CondoVault public condoVault;

    constructor() {}

    // function newCondoNFT(
    //     string memory name,
    //     string memory symbol,
    //     uint256[][] memory apartments,
    //     address gen
    // ) external returns (address) {
    //     condoNft = new CondoNFT(name, symbol, apartments, gen);
    //     return (address(condoNft));
    // }

    function newCondoTimelock(address owner) external returns (address) {
        address[] memory proposers = new address[](1);
        address[] memory executors = new address[](1);
        proposers[0] = owner;
        executors[0] = owner;
        condoTimelock = new CondoTimelock(2 days, proposers, executors, owner);
        return address(condoTimelock);
    }

    function newCondoGovernor() external returns (address) {
        condoGovernor = new CondoGovernor(condoNft, condoTimelock);
        return address(condoGovernor);
    }

    function newCondoVault() external returns (address) {
        condoVault = new CondoVault(address(condoTimelock));
        return address(condoVault);
    }

    // function mint(
    //     address owner,
    //     uint256 floorNumber,
    //     uint256 apartmentNumber
    // ) external returns (uint256 tokenId) {
    //     tokenId = condoNft.mint(owner, floorNumber, apartmentNumber);
    // }
}
