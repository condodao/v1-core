// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {CondoUser} from "@condodao/v1-core/contracts/condo/extensions/CondoUser.sol";

contract CondoCondo is CondoUser {
    uint256 public nextCondoId;

    mapping(uint256 => Condo) private condos;

    mapping(uint256 tokenId => uint256 condoId) private tokenToCondo;

    function getCondo(uint256 condoId) public view returns (Condo memory) {
        return condos[condoId];
    }

    function getCondoByToken(
        uint256 tokenId
    ) public view returns (Condo memory) {
        return condos[tokenToCondo[tokenId]];
    }

    function addCondo(
        address tokenAddress, // CondoNFT token address
        address timelock,
        address governor,
        address valut
    ) external returns (uint256 condoId) {
        uint256 userId = _ensureUserExists(msg.sender);

        condoId = ++nextCondoId;

        condos[condoId] = Condo({
            userId: userId,
            tokenAddress: tokenAddress,
            timelock: timelock,
            governor: governor,
            vault: valut,
            status: Status.Investing,
            createdAt: block.number,
            updatedAt: block.number
        });

        emit CondoAdded(
            condoId,
            userId,
            tokenAddress,
            timelock,
            governor,
            valut
        );
    }

    function updCondo(uint256 condoId, Status status) public {
        Condo storage condo = condos[condoId];

        if (condo.userId != addressToId[msg.sender]) {
            revert UnauthorizedAccess();
        }

        condo.status = status;
        condo.updatedAt = block.number;

        emit CondoUpdated(condoId, status);
    }
}
