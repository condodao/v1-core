// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Metadata} from "@condodao/v1-core/contracts/metadata/Metadata.sol";
import {CondoNFT} from "@condodao/v1-core/contracts/nft/CondoNFT.sol";

contract NewCondoNFT {
    event NewNFT(
        address indexed condoNFT,
        string indexed symbol,
        address indexed condoManager,
        uint256[][] apartments,
        string name,
        address metadata
    );

    constructor() {}

    function createNft(
        address condoManager,
        string memory name,
        string memory symbol,
        uint256[][] memory apartments
    ) public returns (address) {
        Metadata metadata = new Metadata();
        CondoNFT condoNFT = new CondoNFT(
            condoManager,
            name,
            symbol,
            address(metadata),
            apartments
        );

        emit NewNFT(
            address(condoNFT),
            symbol,
            condoManager,
            apartments,
            name,
            address(metadata)
        );

        return address(condoNFT);
    }
}
