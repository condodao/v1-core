// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.20;

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {ERC721Enumerable} from "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {EIP712} from "@openzeppelin/contracts/utils/cryptography/EIP712.sol";
import {ERC721Votes} from "@openzeppelin/contracts/token/ERC721/extensions/ERC721Votes.sol";
import {IMetadata} from "@condodao/v1-core/contracts/metadata/Metadata.sol";

interface ICondoNFT {
    function mintByIndex(
        address to,
        uint256 apartmentIndex
    ) external returns (uint256 tokenId);

    function mintByApartment(
        address to,
        uint256 floor,
        uint256 apartment
    ) external returns (uint256 tokenId);

    function getMetadata() external view returns (address);

    function getApartments() external view returns (uint256[][] memory);

    function getTokenInfo(
        uint256 tokenId_
    )
        external
        view
        returns (
            uint256 apartmentIndex,
            uint256 floorNumber,
            uint256 apartmentNumber,
            uint256 apartmentPrice,
            bool apartmentFree
        );

    function getApartmentInfo(
        uint256 floorNumber_,
        uint256 apartmentNumber_
    )
        external
        view
        returns (
            uint256 apartmentIndex,
            uint256 floorNumber,
            uint256 apartmentNumber,
            uint256 apartmentPrice,
            bool apartmentFree
        );
}

contract CondoNFT is ERC721, ERC721Enumerable, Ownable, EIP712, ERC721Votes {
    uint256[][] private _apartments; // [[floor number, apartment number, apartment price]]
    address private _metadata; // Generate NFT
    uint256 private _nextTokenId; // Start from 1

    mapping(uint256 floorNumber => mapping(uint256 apartmentNumber => uint256 tokenId))
        private _tokenId;
    mapping(uint256 tokenId => uint256 apartmentIndex) private _tokenIndex;

    constructor(
        address manager_,
        string memory name_,
        string memory symbol_,
        address metadata_,
        uint256[][] memory apartments_
    ) ERC721(name_, symbol_) Ownable(manager_) EIP712(name_, "1") {
        _metadata = metadata_;
        _apartments = apartments_;
    }

    function mintByIndex(
        address to,
        uint256 apartmentIndex
    ) public onlyOwner returns (uint256 tokenId) {
        tokenId = _mintApartment(to, apartmentIndex);
    }

    function mintByApartment(
        address to,
        uint256 floor,
        uint256 apartment
    ) public onlyOwner returns (uint256 tokenId) {
        (uint256 apartmentIndex, , , , ) = getApartmentInfo(floor, apartment);
        tokenId = _mintApartment(to, apartmentIndex);
    }

    function _mintApartment(
        address to,
        uint256 apartmentIndex
    ) internal returns (uint256 tokenId) {
        uint256[] memory apart = _apartments[apartmentIndex];

        require(_tokenId[apart[0]][apart[1]] == 0);

        tokenId = ++_nextTokenId;
        _tokenId[apart[0]][apart[1]] = tokenId;
        _tokenIndex[tokenId] = apartmentIndex;

        _safeMint(to, tokenId);
        _delegate(to, to);
    }

    function tokenURI(
        uint256 tokenId
    ) public view override returns (string memory) {
        return
            IMetadata(_metadata).tokenURI(
                tokenId,
                name(),
                _apartments[_tokenIndex[tokenId]][0],
                _apartments[_tokenIndex[tokenId]][1],
                _apartments
            );
    }

    function getMetadata() public view returns (address) {
        return _metadata;
    }

    function getApartments() public view returns (uint256[][] memory) {
        return _apartments;
    }

    function getTokenInfo(
        uint256 tokenId_
    )
        public
        view
        returns (
            uint256 apartmentIndex,
            uint256 floorNumber,
            uint256 apartmentNumber,
            uint256 apartmentPrice,
            bool apartmentFree
        )
    {
        apartmentIndex = _tokenIndex[tokenId_];
        floorNumber = _apartments[apartmentIndex][0];
        apartmentNumber = _apartments[apartmentIndex][1];
        apartmentPrice = _apartments[apartmentIndex][2];
        apartmentFree = _tokenId[floorNumber][apartmentNumber] == 0;
    }

    function getApartmentInfo(
        uint256 floorNumber_,
        uint256 apartmentNumber_
    )
        public
        view
        returns (
            uint256 apartmentIndex,
            uint256 floorNumber,
            uint256 apartmentNumber,
            uint256 apartmentPrice,
            bool apartmentFree
        )
    {
        for (uint256 i = 0; i < _apartments.length; i++) {
            if (
                _apartments[i][0] == floorNumber_ &&
                _apartments[i][1] == apartmentNumber_
            ) {
                return (
                    i,
                    floorNumber_,
                    apartmentNumber_,
                    _apartments[i][2],
                    _tokenId[floorNumber_][apartmentNumber_] == 0
                );
            }
        }
    }

    function _update(
        address to,
        uint256 tokenId,
        address auth
    )
        internal
        override(ERC721, ERC721Enumerable, ERC721Votes)
        returns (address)
    {
        return super._update(to, tokenId, auth);
    }

    function _increaseBalance(
        address account,
        uint128 value
    ) internal override(ERC721, ERC721Enumerable, ERC721Votes) {
        super._increaseBalance(account, value);
    }

    function supportsInterface(
        bytes4 interfaceId
    ) public view override(ERC721, ERC721Enumerable) returns (bool) {
        return super.supportsInterface(interfaceId);
    }
}
