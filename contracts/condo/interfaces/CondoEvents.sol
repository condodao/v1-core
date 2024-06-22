// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {CondoEnums} from "@condodao/v1-core/contracts/condo/interfaces/CondoEnums.sol";

interface CondoEvents is CondoEnums {
    event CondoAdded(
        uint256 indexed condoId,
        uint256 indexed creatorId,
        address indexed tokenAddress,
        address timelock,
        address governor,
        address vault
    );

    event CondoUpdated(uint256 indexed condoId, Status indexed status);

    event ApartAdded(
        uint256 indexed apartId,
        uint256 indexed buyerId,
        uint256 indexed condoId,
        uint256 tokenId,
        uint256 floorNumber,
        uint256 apartmentNumber,
        uint256 price
    );

    event UserAdded(
        uint256 indexed userId,
        address indexed wallet,
        string name,
        string description,
        string image
    );

    event UserUpdated(
        uint256 indexed userId,
        string name,
        string description,
        string image
    );

    event RatingAdded(
        uint256 indexed ratingId,
        uint256 indexed ratedUserId,
        uint256 indexed raterUserId,
        bool isPositive,
        string comment
    );

    event RatingUpdated(
        uint256 indexed ratingId,
        bool isPositive,
        string comment
    );

    event ShareAdded(
        uint256 indexed shareId,
        uint256 indexed tokenId,
        uint256 indexed renterId,
        uint256 pricePerBlock
    );

    event ShareUpdated(
        uint256 indexed shareId,
        uint256 pricePerBlock,
        bool isActive
    );

    event RentAdded(
        uint256 indexed rentId,
        uint256 indexed shareId,
        uint256 indexed renterId,
        uint256 balance
    );

    event RentUpdated(uint256 indexed rentId, uint256 indexed balance);
}
