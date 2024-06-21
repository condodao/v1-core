// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@condodao/contracts/SVG/SVGUtils.sol";

library SVGGeneration {
    function generateSVG(
        uint256[] memory apartments,
        string memory name,
        uint256 floor,
        uint256 apartment
    ) internal pure returns (string memory) {
        uint256 maxApartmentsPerFloor = getMaxApartmentsPerFloor(apartments);
        uint256 rectWidth = (600 - (maxApartmentsPerFloor - 1) * 2) /
            maxApartmentsPerFloor;
        uint256 rectHeight = (600 - (apartments.length - 1) * 2) /
            apartments.length;

        string memory gradient = generateGradient(floor, apartment);
        string memory svgStart = string(
            abi.encodePacked(
                '<svg width="800" height="800" xmlns="http://www.w3.org/2000/svg">',
                gradient,
                '<rect width="100%" height="100%" fill="url(#bgGradient)"/>',
                "<style>",
                ".pulse { animation: pulse 1s infinite; }",
                "@keyframes pulse { 0% { r: 0; } 50% { r: 10; opacity: 0.5; } 100% { r: 0; opacity: 1; } }",
                "</style>",
                '<text x="50%" y="50" font-family="Arial" font-size="24" font-weight="bold" text-anchor="middle">',
                name,
                "</text>",
                '<g id="grid" transform="translate(100, 100)">'
            )
        );
        string memory svgEnd = "</g></svg>";
        string memory grid = generateGrid(
            apartments,
            floor,
            apartment,
            rectWidth,
            rectHeight,
            2
        );

        return string(abi.encodePacked(svgStart, grid, svgEnd));
    }

    function generateGrid(
        uint256[] memory apartments,
        uint256 floor,
        uint256 apartment,
        uint256 rectWidth,
        uint256 rectHeight,
        uint256 spacing
    ) internal pure returns (string memory) {
        string memory grid = "";
        uint256 totalFloors = apartments.length;

        for (uint256 y = 0; y < totalFloors; y++) {
            grid = string(
                abi.encodePacked(
                    grid,
                    generateFloor(
                        apartments,
                        y,
                        floor,
                        apartment,
                        rectWidth,
                        rectHeight,
                        spacing,
                        totalFloors
                    )
                )
            );
        }

        return grid;
    }

    function generateFloor(
        uint256[] memory apartments,
        uint256 y,
        uint256 floor,
        uint256 apartment,
        uint256 rectWidth,
        uint256 rectHeight,
        uint256 spacing,
        uint256 totalFloors
    ) internal pure returns (string memory) {
        string memory floorGrid = "";
        uint256 apartmentsOnFloor = apartments[totalFloors - 1 - y];

        for (uint256 x = 0; x < apartmentsOnFloor; x++) {
            floorGrid = string(
                abi.encodePacked(
                    floorGrid,
                    generateRect(
                        x,
                        totalFloors - 1 - y,
                        floor,
                        apartment,
                        rectWidth,
                        rectHeight,
                        spacing,
                        totalFloors
                    )
                )
            );
        }

        return floorGrid;
    }

    function generateRect(
        uint256 x,
        uint256 y,
        uint256 floor,
        uint256 apartment,
        uint256 rectWidth,
        uint256 rectHeight,
        uint256 spacing,
        uint256 totalFloors
    ) internal pure returns (string memory) {
        uint256 xOffset = x * (rectWidth + spacing);
        uint256 yOffset = (totalFloors - 1 - y) * (rectHeight + spacing);

        if (y == floor - 1 && x == apartment - 1) {
            return
                generateCyanRect(
                    xOffset,
                    yOffset,
                    rectWidth,
                    rectHeight,
                    floor,
                    apartment
                );
        } else {
            return generateGrayRect(xOffset, yOffset, rectWidth, rectHeight);
        }
    }

    function generateCyanRect(
        uint256 xOffset,
        uint256 yOffset,
        uint256 rectWidth,
        uint256 rectHeight,
        uint256 floor,
        uint256 apartment
    ) internal pure returns (string memory) {
        string memory link = string(
            abi.encodePacked(
                "http://localhost:3000/cond?floor=",
                SVGUtils.uint2str(floor),
                "&amp;appartment=",
                SVGUtils.uint2str(apartment)
            )
        );
        return
            string(
                abi.encodePacked(
                    '<a href="',
                    link,
                    '">',
                    '<rect x="',
                    SVGUtils.uint2str(xOffset),
                    '" y="',
                    SVGUtils.uint2str(yOffset),
                    '" width="',
                    SVGUtils.uint2str(rectWidth),
                    '" height="',
                    SVGUtils.uint2str(rectHeight),
                    '" rx="5" ry="5" fill="cyan" class="pulse"/>',
                    SVGUtils.generateText(
                        xOffset,
                        yOffset,
                        rectWidth,
                        rectHeight,
                        floor,
                        apartment
                    ),
                    "</a>"
                )
            );
    }

    function generateGrayRect(
        uint256 xOffset,
        uint256 yOffset,
        uint256 rectWidth,
        uint256 rectHeight
    ) internal pure returns (string memory) {
        return
            string(
                abi.encodePacked(
                    '<rect x="',
                    SVGUtils.uint2str(xOffset),
                    '" y="',
                    SVGUtils.uint2str(yOffset),
                    '" width="',
                    SVGUtils.uint2str(rectWidth),
                    '" height="',
                    SVGUtils.uint2str(rectHeight),
                    '" rx="5" ry="5" fill="black"/>'
                )
            );
    }

    function generateGradient(
        uint256 floor,
        uint256 apartment
    ) internal pure returns (string memory) {
        bytes32 hash = keccak256(abi.encodePacked(floor, apartment));
        string memory color1 = SVGUtils.colorFromHash(hash, 0);
        string memory color2 = SVGUtils.colorFromHash(hash, 16);
        string memory color3 = SVGUtils.colorFromHash(hash, 32);

        return
            string(
                abi.encodePacked(
                    "<defs>",
                    '<linearGradient id="bgGradient" x1="0%" y1="0%" x2="100%" y2="100%">',
                    '<stop offset="0%" style="stop-color:',
                    color1,
                    ';stop-opacity:1" />',
                    '<stop offset="50%" style="stop-color:',
                    color2,
                    ';stop-opacity:1" />',
                    '<stop offset="100%" style="stop-color:',
                    color3,
                    ';stop-opacity:1" />',
                    "</linearGradient>",
                    "</defs>"
                )
            );
    }

    function getMaxApartmentsPerFloor(
        uint256[] memory apartments
    ) internal pure returns (uint256) {
        uint256 max = 0;
        for (uint256 i = 0; i < apartments.length; i++) {
            if (apartments[i] > max) {
                max = apartments[i];
            }
        }
        return max;
    }
}
