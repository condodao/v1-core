// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {CondoCondo} from "@condodao/v1-core/contracts/condo/extensions/CondoCondo.sol";
import {ICondoNFT} from "@condodao/v1-core/contracts/nft/CondoNFT.sol";

contract CondoApart is CondoCondo {
    uint256 public nextApartId;

    mapping(uint256 => Apart) private aparts;

    mapping(uint256 tokenId => uint256 apartId) private tokenToApart;

    function getApart(uint256 apartId) external view returns (Apart memory) {
        return aparts[apartId];
    }

    function getApartByToken(
        uint256 tokenId
    ) external view returns (Apart memory) {
        return aparts[tokenToApart[tokenId]];
    }

    function addApart(
        uint256 condoId,
        uint256 floorNumber,
        uint256 apartmentNumber
    ) external payable returns (uint256 apartId) {
        uint256 userId = _ensureUserExists(msg.sender);

        apartId = ++nextApartId;

        Condo memory condo = getCondo(condoId);
        ICondoNFT token = ICondoNFT(condo.tokenAddress);

        (, , , uint256 price, ) = token.getApartmentInfo(
            floorNumber,
            apartmentNumber
        );
        if (msg.value < price) revert InsufficientPayment();

        uint256 tokenId = token.mintByApartment(
            msg.sender,
            floorNumber,
            apartmentNumber
        );
        (bool sent, ) = payable(condo.vault).call{value: msg.value}("");
        require(sent, "Payment transfer failed");

        tokenToApart[tokenId] = apartId;

        aparts[apartId] = Apart({
            userId: userId,
            tokenId: tokenId,
            floorNumber: floorNumber,
            apartmentNumber: apartmentNumber,
            price: price,
            createdAt: block.number,
            updatedAt: block.number
        });

        emit ApartAdded(
            apartId,
            userId,
            condoId,
            tokenId,
            floorNumber,
            apartmentNumber,
            price
        );
    }
}
