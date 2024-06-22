// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {SVGGeneration} from "@condodao/v1-core/contracts/metadata/svg/SVGGeneration.sol";
import {Utils} from "@condodao/v1-core/contracts/metadata/Utils.sol";

interface IMetadata {
    function tokenURI(
        uint256 tokenId,
        string memory name,
        uint256 floor,
        uint256 apartment,
        uint256[][] memory apartments
    ) external pure returns (string memory);
}

contract Metadata is IMetadata {
    using SVGGeneration for uint256[][];

    constructor() {}

    function tokenURI(
        uint256 tokenId,
        string memory name,
        uint256 floor,
        uint256 apartment,
        uint256[][] memory apartments
    ) public pure returns (string memory) {
        string memory svg = apartments.generateSVG(name, floor, apartment);

        string memory image = string.concat(
            '"image":"data:image/svg+xml;base64,',
            Utils.encode(bytes(svg)),
            '"'
        );

        string memory json = string.concat(
            '{"name":"Real estate contract #',
            Utils.toString(tokenId),
            unicode'","description":"Real estate contract «',
            name,
            unicode'»",',
            Utils.getTraitsAsJson(floor, apartment),
            ",",
            image,
            "}"
        );

        return
            string.concat(
                "data:application/json;base64,",
                Utils.encode(bytes(json))
            );
    }
}
