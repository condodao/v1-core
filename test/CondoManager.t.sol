// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import {CondoManager} from "@condodao/v1-core/contracts/condo/CondoManager.sol";
import {CondoNFT} from "@condodao/v1-core/contracts/nft/CondoNFT.sol";
import {Metadata} from "@condodao/v1-core/contracts/metadata/Metadata.sol";
import {CondoVault} from "@condodao/v1-core/contracts/dao/CondoVault.sol";
import {CondoEnums} from "@condodao/v1-core/contracts/condo/interfaces/CondoEnums.sol";
import {CondoEvents} from "@condodao/v1-core/contracts/condo/interfaces/CondoEvents.sol";
import {CondoErrors} from "@condodao/v1-core/contracts/condo/interfaces/CondoErrors.sol";
import {CondoStructs} from "@condodao/v1-core/contracts/condo/interfaces/CondoStructs.sol";

contract CondoManagerTest is
    Test,
    CondoEnums,
    CondoEvents,
    CondoErrors,
    CondoStructs
{
    CondoManager condoManager;
    CondoNFT condoNFT;
    Metadata metadata;
    CondoVault vault;
    uint256[][] apartments = new uint256[][](5);

    address getNftUser = address(0x5678);

    function setUp() public {
        condoManager = new CondoManager();

        apartments[0] = new uint256[](3);
        apartments[0][0] = 1; // floor number
        apartments[0][1] = 1; // apart number
        apartments[0][2] = 1000; // apart price
        apartments[1] = new uint256[](3);
        apartments[1][0] = 1; // floor number
        apartments[1][1] = 2; // apart number
        apartments[1][2] = 1500; // apart price
        apartments[2] = new uint256[](3);
        apartments[2][0] = 2; // floor number
        apartments[2][1] = 1; // apart number
        apartments[2][2] = 1500; // apart price
        apartments[3] = new uint256[](3);
        apartments[3][0] = 3; // floor number
        apartments[3][1] = 1; // apart number
        apartments[3][2] = 3500; // apart price
        apartments[4] = new uint256[](3);
        apartments[4][0] = 3; // floor number
        apartments[4][1] = 2; // apart number
        apartments[4][2] = 2500; // apart price

        metadata = new Metadata();
        condoNFT = new CondoNFT(
            address(condoManager),
            "CondoToken",
            "CNT",
            address(metadata),
            apartments
        );

        vault = new CondoVault(address(1));
    }

    function testAddGetCondo() public {
        uint256 condoId = condoManager.addCondo(
            address(this),
            address(this),
            address(this),
            address(this)
        );

        Condo memory condo = condoManager.getCondo(condoId);

        assertEq(condo.userId, 1);
        assertEq(condo.tokenAddress, address(this));
        assertEq(condo.timelock, address(this));
        assertEq(condo.governor, address(this));
        assertEq(condo.vault, address(this));
        assertEq(uint(condo.status), uint(Status.Investing));
    }

    function testUpdateCondoStatus() public {
        uint256 condoId = condoManager.addCondo(
            address(this),
            address(this),
            address(this),
            address(this)
        );

        condoManager.updCondo(condoId, Status.Completed);

        Condo memory condo = condoManager.getCondo(condoId);

        assertEq(uint(condo.status), uint(Status.Completed));
    }

    function testAddGetUser() public {
        uint256 userId = condoManager.addUser(
            "TestUser",
            "Description",
            "image"
        );

        User memory user = condoManager.getUser(userId);

        assertEq(user.wallet, address(this));
        assertEq(user.name, "TestUser");
        assertEq(user.description, "Description");
        assertEq(user.image, "image");
    }

    function testUpdateUser() public {
        uint256 userId = condoManager.addUser(
            "TestUser",
            "Description",
            "image"
        );

        condoManager.updUser("UpdatedUser", "NewDescription", "newImage");

        User memory user = condoManager.getUser(userId);

        assertEq(user.name, "UpdatedUser");
        assertEq(user.description, "NewDescription");
        assertEq(user.image, "newImage");
    }

    function testAddGetRating() public {
        uint256 userId = condoManager.addUser(
            "TestUser",
            "Description",
            "image"
        );
        uint256 ratingId = condoManager.addRating(userId, true, "Good");

        Rating memory rating = condoManager.getRating(ratingId);

        assertEq(rating.ratedUserId, userId);
        assertEq(rating.isPositive, true);
        assertEq(rating.comment, "Good");
    }

    function testUpdateRating() public {
        uint256 userId = condoManager.addUser(
            "TestUser",
            "Description",
            "image"
        );
        uint256 ratingId = condoManager.addRating(userId, true, "Good");

        condoManager.updRating(ratingId, false, "Bad");

        Rating memory rating = condoManager.getRating(ratingId);

        assertEq(rating.isPositive, false);
        assertEq(rating.comment, "Bad");
    }

    function testAddGetShare() public {
        uint256 shareId = condoManager.addShare(100, 1);

        Share memory share = condoManager.getShare(shareId);

        assertEq(share.userId, 1);
        assertEq(share.pricePerBlock, 100);
        assertEq(share.tokenId, 1);
        assertEq(share.isActive, true);
    }

    function testUpdateShare() public {
        uint256 shareId = condoManager.addShare(100, 1);

        condoManager.updShare(shareId, 200, false);

        Share memory share = condoManager.getShare(shareId);

        assertEq(share.pricePerBlock, 200);
        assertEq(share.isActive, false);
    }

    function testAddGetRent() public {
        uint256 shareId = condoManager.addShare(100, 1);
        uint256 rentId = condoManager.addRent{value: 8640 * 100}(shareId);

        Rent memory rent = condoManager.getRent(rentId);

        assertEq(rent.userId, 1);
        assertEq(rent.shareId, shareId);
        assertEq(rent.balance, 8640 * 100);
    }

    function testUpdateRent() public {
        uint256 shareId = condoManager.addShare(100, 1);
        uint256 rentId = condoManager.addRent{value: 8640 * 100}(shareId);

        condoManager.updRent{value: 1000}(rentId);

        Rent memory rent = condoManager.getRent(rentId);

        assertEq(rent.balance, 8640 * 100 + 1000);
    }

    function testAddGetApart() public {
        vm.startPrank(getNftUser);
        vm.deal(address(getNftUser), 1 ether);

        uint256 condoId = condoManager.addCondo(
            address(condoNFT),
            address(this),
            address(this),
            address(vault)
        );

        // Add an apartment
        uint256 apartId = condoManager.addApart{value: 1500}(
            condoId,
            1, // floorNumber
            2 // apartmentNumber
        );

        // Retrieve the apartment
        Apart memory apart = condoManager.getApart(apartId);

        assertEq(apart.floorNumber, 1);
        assertEq(apart.apartmentNumber, 2);
        assertEq(apart.price, 1500);
        assertEq(address(vault).balance, 1500);
    }
}
