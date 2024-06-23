// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import {NewCondoNFT} from "@condodao/v1-core/contracts/condo/new/NewCondoNFT.sol";
import {Metadata} from "@condodao/v1-core/contracts/metadata/Metadata.sol";
import {CondoNFT} from "@condodao/v1-core/contracts/nft/CondoNFT.sol";

contract NewCondoNFTTest is Test {
    NewCondoNFT newCondoNFT;
    Metadata metadata;

    function setUp() public {
        newCondoNFT = new NewCondoNFT();
    }

    function testCreateNFT() public {
        uint256[][] memory apartments = new uint256[][](1);
        apartments[0] = new uint256[](3);
        apartments[0][0] = 1; // floor number
        apartments[0][1] = 1; // apart number
        apartments[0][2] = 1000; // apart price

        address condoNFTAddress = newCondoNFT.createNft(
            address(this),
            "CondoToken",
            "CNT",
            apartments
        );

        assertTrue(condoNFTAddress != address(0));
    }
}
