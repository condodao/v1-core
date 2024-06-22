// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {CondoUser} from "@condodao/v1-core/contracts/condo/extensions/CondoUser.sol";
import {CondoShare} from "@condodao/v1-core/contracts/condo/extensions/CondoShare.sol";

contract CondoRent is CondoUser, CondoShare {
    uint256 public nextRentId;

    mapping(uint256 => Rent) private rents;

    function getRent(uint256 rentId) public view returns (Rent memory) {
        return rents[rentId];
    }

    function addRent(
        uint256 shareId
    ) external payable returns (uint256 rentId) {
        Share memory share = getShare(shareId);

        if (msg.value < share.pricePerBlock * 8640 || !share.isActive) {
            revert InsufficientPayment();
        }

        uint256 userId = _ensureUserExists(msg.sender);

        rentId = ++nextRentId;

        rents[rentId] = Rent({
            userId: userId,
            shareId: shareId,
            balance: msg.value,
            createdAt: block.number,
            updatedAt: block.number
        });

        emit RentAdded(userId, shareId, userId, msg.value);
    }

    function updRent(uint256 rentId) external payable {
        Rent storage rent = rents[rentId];

        if (rent.userId != addressToId[msg.sender]) {
            revert UnauthorizedAccess();
        }

        rent.balance += msg.value;
        rent.updatedAt = block.number;

        emit RentUpdated(rentId, rent.balance);
    }
}
