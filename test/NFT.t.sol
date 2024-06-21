// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Test.sol";
import "@condodao/contracts/NFT.sol";

contract NFTTest is Test {
    NFT nft;

    function setUp() public {
        // Deploy the NFT contract
        uint256[][] memory apartments = new uint256[][](4);

        apartments[0] = new uint256[](3);
        apartments[0][0] = 1; // 1 floor
        apartments[0][1] = 1; // 1 apartment
        apartments[0][2] = 10; // apartment price 10 eth

        apartments[1] = new uint256[](3);
        apartments[1][0] = 2; // 2 floor
        apartments[1][1] = 1; // 1 apartment
        apartments[1][2] = 20; // apartment price 20 eth

        apartments[2] = new uint256[](3);
        apartments[2][0] = 2; // 2 floor
        apartments[2][1] = 2; // 2 apartment
        apartments[2][2] = 20; // apartment price 20 eth

        apartments[3] = new uint256[](3);
        apartments[3][0] = 3; // 2 floor
        apartments[3][1] = 1; // 1 apartment
        apartments[3][2] = 30; // apartment price 20 eth

        nft = new NFT("Test", "TST", apartments);
    }

    function testNFT() public {
        uint256 tokenId = nft.mint(msg.sender, 3, 1);
        string memory tokenURI = nft.tokenURI(tokenId);
        console.log(tokenURI);
        assertTrue(bytes(tokenURI).length > 0);
    }
}
