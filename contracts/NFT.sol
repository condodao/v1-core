// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.20;

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {ERC721Enumerable} from "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {EIP712} from "@openzeppelin/contracts/utils/cryptography/EIP712.sol";
import {ERC721Votes} from "@openzeppelin/contracts/token/ERC721/extensions/ERC721Votes.sol";
import {NFTGeneration} from "@condodao/contracts/NFT/NFTGeneration.sol";

contract NFT is ERC721, ERC721Enumerable, Ownable, EIP712, ERC721Votes {
    uint256[][] public apartments;
    uint256 private _nextTokenId;

    struct Info {
        uint256 floor;
        uint256 apartment;
    }

    mapping(uint256 tokenId => Info) public info;

    constructor(
        string memory _name,
        string memory _symbol,
        uint256[][] memory _apartments
    ) ERC721(_name, _symbol) Ownable(msg.sender) EIP712(_name, "1") {
        apartments = _apartments;
    }

    function mint(
        address to,
        uint256 floor,
        uint256 apartment
    ) public onlyOwner returns (uint256) {
        // require(!apartmentExists(floor, apartment), "Apartment exist");
        uint256 tokenId = _nextTokenId++;
        info[tokenId] = Info(floor, apartment);
        _safeMint(to, tokenId);
        _delegate(to, to);
        return tokenId;
    }

    function tokenURI(
        uint256 tokenId
    ) public view override returns (string memory) {
        return
            NFTGeneration.generateNFT(
                tokenId,
                name(),
                info[tokenId].floor,
                info[tokenId].apartment,
                apartments
            );
    }

    function getInfo(
        uint256 tokenId
    ) public view returns (uint256 floor, uint256 apartment) {
        floor = info[tokenId].floor;
        apartment = info[tokenId].apartment;
    }

    function apartmentExists(
        uint256 floor,
        uint256 apartment
    ) internal view returns (bool) {
        for (uint256 i = 0; i < apartments.length; i++) {
            if (apartments[i][0] == floor && apartments[i][1] == apartment) {
                return true;
            }
        }
        return false;
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
