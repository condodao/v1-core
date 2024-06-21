// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {SVGGeneration} from "@condodao/contracts/SVG/SVGGeneration.sol";
import {NFTUtils} from "@condodao/contracts/NFT/NFTUtils.sol";

library NFTGeneration {
    using SVGGeneration for uint256[][];

    function generateNFT(
        uint256 tokenId,
        string memory name,
        uint256 floor,
        uint256 apartment,
        uint256[][] memory apartments
    ) public pure returns (string memory) {
        string memory svg = apartments.generateSVG(name, floor, apartment);

        string memory image = string.concat(
            '"image":"data:image/svg+xml;base64,',
            NFTUtils.encode(bytes(svg)),
            '"'
        );

        string memory json = string.concat(
            '{"name":"Real estate contract #',
            NFTUtils.toString(tokenId),
            unicode'","description":"Real estate contract «',
            name,
            unicode'»",',
            NFTUtils.getTraitsAsJson(floor, apartment),
            ",",
            image,
            "}"
        );

        return
            string.concat(
                "data:application/json;base64,",
                NFTUtils.encode(bytes(json))
            );
    }
}
