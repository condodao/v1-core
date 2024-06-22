// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {CondoEnums} from "@condodao/v1-core/contracts/condo/interfaces/CondoEnums.sol";

interface CondoStructs is CondoEnums {
    struct Condo {
        uint256 userId; // Creator
        address tokenAddress; // NFT collection representing the condominium
        address timelock; // Timelock for the condominium's DAO
        address governor; // Governor contract for the condominium's DAO
        address vault; // Vault for accumulating sales from apartments
        Status status; // Current status of the condo
        uint256 createdAt; // Block number when created
        uint256 updatedAt; // Block number when last updated
    }

    struct Apart {
        uint256 userId; // Buyer
        uint256 tokenId;
        uint256 floorNumber;
        uint256 apartmentNumber;
        uint256 price;
        uint256 createdAt; // Block number when created
        uint256 updatedAt; // Block number when last updated
    }

    struct User {
        address wallet; // User's wallet address
        string name;
        string description;
        string image;
        uint256 createdAt; // Block number when created
        uint256 updatedAt; // Block number when last updated
    }

    struct Rating {
        uint256 ratedUserId;
        uint256 raterUserId;
        bool isPositive;
        string comment;
        uint256 createdAt; // Block number when created
        uint256 updatedAt; // Block number when last updated
    }

    struct Share {
        uint256 tokenId;
        uint256 userId; // Renter
        uint256 pricePerBlock; // Price per block for renting
        bool isActive; // Owner shared your apart for renting or not
        uint256 createdAt; // Block number when created
        uint256 updatedAt; // Block number when last updated
    }

    struct Rent {
        uint256 userId; // Renter
        uint256 shareId;
        uint256 balance; // Balance of the user renting the apartment
        uint256 createdAt; // Block number when created
        uint256 updatedAt; // Block number when last updated
    }
}
