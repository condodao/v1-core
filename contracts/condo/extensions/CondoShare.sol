// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {CondoUser} from "@condodao/v1-core/contracts/condo/extensions/CondoUser.sol";

contract CondoShare is CondoUser {
    uint256 public nextShareId;

    mapping(uint256 => Share) private shares;

    function getShare(uint256 shareId) public view returns (Share memory) {
        return shares[shareId];
    }

    function addShare(
        uint256 pricePerBlock,
        uint256 tokenId
    ) external returns (uint256 shareId) {
        uint256 userId = _ensureUserExists(msg.sender);

        shareId = ++nextShareId;

        shares[shareId] = Share({
            userId: userId,
            pricePerBlock: pricePerBlock,
            tokenId: tokenId,
            isActive: true,
            createdAt: block.number,
            updatedAt: block.number
        });

        emit ShareAdded(shareId, tokenId, userId, pricePerBlock);
    }

    function updShare(
        uint256 shareId,
        uint256 pricePerBlock,
        bool isActive
    ) external {
        Share storage share = shares[shareId];

        if (share.userId != addressToId[msg.sender]) {
            revert UnauthorizedAccess();
        }

        share.pricePerBlock = pricePerBlock;
        share.isActive = isActive;
        share.updatedAt = block.number;

        emit ShareUpdated(shareId, pricePerBlock, isActive);
    }
}
