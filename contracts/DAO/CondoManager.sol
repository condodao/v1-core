// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {NFT} from "@condodao/contracts/NFT.sol";
import {CondoTimelock} from "@condodao/contracts/CondoTimelock.sol";
import {CondoGovernor} from "@condodao/contracts/CondoGovernor.sol";
import {CondoVault} from "@condodao/contracts/CondoVault.sol";

import {CondoEnums} from "@condodao/contracts/DAO/CondoEnums.sol";
import {CondoEvents} from "@condodao/contracts/DAO/CondoEvents.sol";
import {CondoStructs} from "@condodao/contracts/DAO/CondoStructs.sol";
import {CondoErrors} from "@condodao/contracts/DAO/CondoErrors.sol";

contract CondoManager is CondoEvents, CondoStructs, CondoErrors {
    uint256 public nextCondoId;
    uint256 public nextApartId;
    uint256 public nextUserId;
    uint256 public nextRatingId;
    uint256 public nextShareId;
    uint256 public nextRentId;

    mapping(uint256 => Condo) private condos;
    mapping(uint256 => Apart) private aparts;
    mapping(uint256 => User) private users;
    mapping(uint256 => Rating) private ratings;
    mapping(uint256 => Share) private shares;
    mapping(uint256 => Rent) private rents;

    mapping(uint256 tokenId => uint256 condoId) public tokenToCondo;
    mapping(address userAddress => uint256 userId) public addressToId;

    constructor() {}

    function getCondo(uint256 condoId) public view returns (Condo memory) {
        return condos[condoId];
    }

    function getCondoByToken(
        uint256 tokenId
    ) public view returns (Condo memory) {
        return condos[tokenToCondo[tokenId]];
    }

    function getApart(uint256 apartId) public view returns (Apart memory) {
        return aparts[apartId];
    }

    function getUser(uint256 userId) public view returns (User memory) {
        return users[userId];
    }

    function getUserByAddress(
        address userAddress
    ) public view returns (User memory) {
        return users[addressToId[userAddress]];
    }

    function getRating(uint256 ratingId) public view returns (Rating memory) {
        return ratings[ratingId];
    }

    function getShare(uint256 shareId) public view returns (Share memory) {
        return shares[shareId];
    }

    function getRent(uint256 rentId) public view returns (Rent memory) {
        return rents[rentId];
    }

    function addCondo(
        string memory name,
        string memory symbol,
        uint256[][] memory apartments
    ) public returns (uint256 condoId) {
        condoId = ++nextCondoId;

        NFT token = new NFT(name, symbol, apartments);
        CondoTimelock timelock = condoTimelock();
        CondoGovernor governor = new CondoGovernor(token, timelock);
        CondoVault valut = new CondoVault(address(timelock));

        condos[condoId] = Condo({
            userId: _ensureUserExists(msg.sender),
            tokenAddress: address(token),
            timelock: address(timelock),
            governor: address(governor),
            vault: address(valut),
            apartments: apartments,
            status: Status.Suspended,
            createdAt: block.number,
            updatedAt: block.number
        });

        emit CondoAdded(
            _ensureUserExists(msg.sender),
            condoId,
            address(token),
            address(timelock),
            address(governor),
            address(valut),
            apartments.length,
            name,
            symbol
        );
    }

    function condoTimelock() internal returns (CondoTimelock timelock) {
        address[] memory proposers = new address[](1);
        address[] memory executors = new address[](1);
        proposers[0] = msg.sender;
        executors[0] = msg.sender;
        timelock = new CondoTimelock(2 days, proposers, executors, msg.sender);
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

    function addApart(
        uint256 condoId,
        uint256 floorNumber,
        uint256 apartmentNumber
    ) public payable returns (uint256 apartId) {
        uint256 userId = _ensureUserExists(msg.sender);

        apartId = ++nextApartId;

        uint256 price = getApartmentPrice(
            condoId,
            floorNumber,
            apartmentNumber
        );
        if (msg.value < price) revert InsufficientPayment();

        Condo memory condo = condos[condoId];

        uint256 tokenId = NFT(condo.tokenAddress).mint(
            msg.sender,
            floorNumber,
            apartmentNumber
        );
        (bool sent, ) = payable(condo.vault).call{value: msg.value}("");
        require(sent, "Payment transfer failed");

        if (condo.apartments.length == tokenId) {
            updCondo(condoId, Status.Active);
        }

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

    function addRating(
        uint256 ratedUserId,
        bool isPositive,
        string memory comment
    ) public returns (uint256 ratingId) {
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
    ) public {
        Rating storage rating = ratings[ratingId];

        if (rating.raterUserId != addressToId[msg.sender]) {
            revert UnauthorizedAccess();
        }

        rating.isPositive = isPositive;
        rating.comment = comment;
        rating.updatedAt = block.number;

        emit RatingUpdated(ratingId, isPositive, comment);
    }

    function addShare(
        uint256 pricePerBlock,
        uint256 tokenId
    ) public returns (uint256 shareId) {
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
    ) public {
        Share storage share = shares[shareId];

        if (share.userId != addressToId[msg.sender]) {
            revert UnauthorizedAccess();
        }

        share.pricePerBlock = pricePerBlock;
        share.isActive = isActive;
        share.updatedAt = block.number;

        emit ShareUpdated(shareId, pricePerBlock, isActive);
    }

    function addRent(uint256 shareId) public payable returns (uint256 rentId) {
        Share storage share = shares[shareId];

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

    function updRent(uint256 rentId) public payable {
        Rent storage rent = rents[rentId];

        if (rent.userId != addressToId[msg.sender]) {
            revert UnauthorizedAccess();
        }

        rent.balance += msg.value;
        rent.updatedAt = block.number;

        emit RentUpdated(rentId, rent.balance);
    }

    function addUser(
        string memory name,
        string memory description,
        string memory image
    ) public returns (uint256) {
        return _addUser(msg.sender, name, description, image);
    }

    function updUser(
        string memory name,
        string memory description,
        string memory image
    ) public returns (uint256 userId) {
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

    function updateRent(uint256 rentId) public payable returns (uint256) {
        if (rents[rentId].userId != addressToId[msg.sender]) {
            revert UnauthorizedAccess();
        }

        rents[rentId].balance += msg.value;
        rents[rentId].updatedAt = block.number;

        emit RentUpdated(rentId, msg.value);
        return msg.value / shares[rents[rentId].shareId].pricePerBlock;
    }

    function getApartmentDetails(
        uint256 tokenId
    ) public view returns (uint256 floorNumber, uint256 apartmentNumber) {
        address nftAddress = condos[tokenToCondo[tokenId]].tokenAddress;
        (floorNumber, apartmentNumber) = NFT(nftAddress).getInfo(tokenId);
    }

    function isApartmentAvailable(
        uint256 condoId,
        uint256 floorNumber,
        uint256 apartmentNumber
    ) internal view returns (bool) {
        for (uint256 i = 0; i < condos[condoId].apartments.length; i++) {
            if (
                condos[condoId].apartments[i][0] == floorNumber &&
                condos[condoId].apartments[i][1] == apartmentNumber
            ) {
                return true;
            }
        }
        return false;
    }

    function getApartmentPrice(
        uint256 condoId,
        uint256 floorNumber,
        uint256 apartmentNumber
    ) internal view returns (uint256) {
        for (uint256 i = 0; i < condos[condoId].apartments.length; i++) {
            if (
                condos[condoId].apartments[i][0] == floorNumber &&
                condos[condoId].apartments[i][1] == apartmentNumber
            ) {
                return condos[condoId].apartments[i][2];
            }
        }
        revert ApartmentNotFound();
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
