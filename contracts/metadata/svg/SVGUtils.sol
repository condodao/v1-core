// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

library SVGUtils {
    function uint2str(uint256 _i) internal pure returns (string memory) {
        if (_i == 0) {
            return "0";
        }
        uint256 j = _i;
        uint256 length;
        while (j != 0) {
            length++;
            j /= 10;
        }
        bytes memory bstr = new bytes(length);
        uint256 k = length;
        while (_i != 0) {
            k = k - 1;
            uint8 temp = (48 + uint8(_i - (_i / 10) * 10));
            bstr[k] = bytes1(temp);
            _i /= 10;
        }
        return string(bstr);
    }

    function colorFromHash(
        bytes32 hash,
        uint256 offset
    ) internal pure returns (string memory) {
        bytes3 color = bytes3(hash << (offset * 8));
        return
            string(
                abi.encodePacked(
                    "#",
                    toHexChar(uint8(color[0]) >> 4),
                    toHexChar(uint8(color[0]) & 0x0f),
                    toHexChar(uint8(color[1]) >> 4),
                    toHexChar(uint8(color[1]) & 0x0f),
                    toHexChar(uint8(color[2]) >> 4),
                    toHexChar(uint8(color[2]) & 0x0f)
                )
            );
    }

    function toHexChar(uint8 c) internal pure returns (bytes1) {
        return bytes1(c < 10 ? c + 0x30 : c + 0x57);
    }

    function generateText(
        uint256 xOffset,
        uint256 yOffset,
        uint256 rectWidth,
        uint256 rectHeight,
        uint256 floor,
        uint256 apartment
    ) internal pure returns (string memory) {
        return
            string(
                abi.encodePacked(
                    '<text x="',
                    uint2str(xOffset + rectWidth / 2),
                    '" y="',
                    uint2str(yOffset + rectHeight / 2 - 2),
                    '" font-family="Arial" font-size="10" fill="black" text-anchor="middle" dominant-baseline="middle">Floor: ',
                    uint2str(floor),
                    "</text>",
                    '<text x="',
                    uint2str(xOffset + rectWidth / 2),
                    '" y="',
                    uint2str(yOffset + rectHeight / 2 + 10),
                    '" font-family="Arial" font-size="10" fill="black" text-anchor="middle" dominant-baseline="middle">Apartment: ',
                    uint2str(apartment),
                    "</text>"
                )
            );
    }
}
