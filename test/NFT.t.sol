// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Test.sol";
import {Metadata} from "@condodao/v1-core/contracts/metadata/Metadata.sol";
import {CondoNFT} from "@condodao/v1-core/contracts/nft/CondoNFT.sol";

contract NFTTest is Test {
    Metadata metadata;
    CondoNFT nft;

    function setUp() public {
        // Deploy the NFT contract
        uint256[][] memory apartments = new uint256[][](6);

        apartments[0] = new uint256[](3);
        apartments[0][0] = 1; // floor number
        apartments[0][1] = 1; // apart number
        apartments[0][2] = 1000; // apart price
        apartments[1] = new uint256[](3);
        apartments[1][0] = 1; // floor number
        apartments[1][1] = 2; // apart number
        apartments[1][2] = 1500; // apart price
        apartments[2] = new uint256[](3);
        apartments[2][0] = 2; // floor number
        apartments[2][1] = 1; // apart number
        apartments[2][2] = 1500; // apart price
        apartments[3] = new uint256[](3);
        apartments[3][0] = 2; // floor number
        apartments[3][1] = 2; // apart number
        apartments[3][2] = 1500; // apart price
        apartments[4] = new uint256[](3);
        apartments[4][0] = 3; // floor number
        apartments[4][1] = 1; // apart number
        apartments[4][2] = 3500; // apart price
        apartments[5] = new uint256[](3);
        apartments[5][0] = 3; // floor number
        apartments[5][1] = 2; // apart number
        apartments[5][2] = 2500; // apart price

        metadata = new Metadata();
        nft = new CondoNFT(
            address(this),
            "Test",
            "TST",
            address(metadata),
            apartments
        );
    }

    function testNFT() public {
        uint256 tokenId = nft.mintByIndex(msg.sender, 3);
        string memory tokenURI = nft.tokenURI(tokenId);
        console.log(tokenURI);
        assertTrue(bytes(tokenURI).length > 0);
    }
}
