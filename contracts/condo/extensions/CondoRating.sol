// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {CondoUser} from "@condodao/v1-core/contracts/condo/extensions/CondoUser.sol";

contract CondoRating is CondoUser {
    uint256 public nextRatingId;

    mapping(uint256 => Rating) private ratings;

    function getRating(uint256 ratingId) public view returns (Rating memory) {
        return ratings[ratingId];
    }

    function addRating(
        uint256 ratedUserId,
        bool isPositive,
        string memory comment
    ) external returns (uint256 ratingId) {
        uint256 raterUserId = _ensureUserExists(msg.sender);

        ratingId = ++nextRatingId;

        ratings[ratingId] = Rating({
            ratedUserId: ratedUserId,
            raterUserId: raterUserId,
            isPositive: isPositive,
            comment: comment,
            createdAt: block.number,
            updatedAt: block.number
        });

        emit RatingAdded(
            ratingId,
            ratedUserId,
            raterUserId,
            isPositive,
            comment
        );
    }

    function updRating(
        uint256 ratingId,
        bool isPositive,
        string memory comment
    ) external {
        Rating storage rating = ratings[ratingId];

        if (rating.raterUserId != addressToId[msg.sender]) {
            revert UnauthorizedAccess();
        }

        rating.isPositive = isPositive;
        rating.comment = comment;
        rating.updatedAt = block.number;

        emit RatingUpdated(ratingId, isPositive, comment);
    }
}
