// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {CondoEvents} from "@condodao/v1-core/contracts/condo/interfaces/CondoEvents.sol";
import {CondoStructs} from "@condodao/v1-core/contracts/condo/interfaces/CondoStructs.sol";
import {CondoErrors} from "@condodao/v1-core/contracts/condo/interfaces/CondoErrors.sol";

contract CondoUser is CondoEvents, CondoStructs, CondoErrors {
    uint256 public nextUserId;

    mapping(uint256 => User) private users;
    mapping(address userAddress => uint256 userId) public addressToId;

    function getUser(uint256 userId) public view returns (User memory) {
        return users[userId];
    }

    function getUserByAddress(
        address userAddress
    ) public view returns (User memory) {
        return users[addressToId[userAddress]];
    }

    function addUser(
        string memory name,
        string memory description,
        string memory image
    ) external returns (uint256) {
        return _addUser(msg.sender, name, description, image);
    }

    function updUser(
        string memory name,
        string memory description,
        string memory image
    ) external returns (uint256 userId) {
        userId = addressToId[msg.sender];

        if (userId == 0) {
            revert UserNotFound();
        }

        User storage user = users[userId];
        user.name = name;
        user.description = description;
        user.image = image;
        user.updatedAt = block.number;

        emit UserUpdated(userId, name, description, image);
    }

    function _ensureUserExists(address user) internal returns (uint256) {
        if (addressToId[user] == 0) {
            return _addUser(user, "", "", "");
        }
        return addressToId[user];
    }

    function _addUser(
        address user,
        string memory name,
        string memory description,
        string memory image
    ) internal returns (uint256 userId) {
        userId = ++nextUserId;

        users[userId] = User({
            wallet: user,
            name: name,
            description: description,
            image: image,
            createdAt: block.number,
            updatedAt: block.number
        });
        addressToId[user] = userId;

        emit UserAdded(userId, user, name, image, description);
    }
}
