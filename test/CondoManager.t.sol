// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "@condao/contracts/DAO/CondoManager.sol";
import "@condao/contracts/NFT.sol";
import "@condao/contracts/CondoTimelock.sol";
import "@condao/contracts/CondoGovernor.sol";
import "@condao/contracts/CondoVault.sol";
import "@condao/contracts/DAO/CondoEnums.sol";
import "@condao/contracts/DAO/CondoStructs.sol";
import "@condao/contracts/DAO/CondoEvents.sol";
import "@condao/contracts/DAO/CondoErrors.sol";

contract CondoManagerTest is Test, CondoEnums, CondoEvents, CondoErrors {
    CondoManager condoManager;
    uint256[][] apartments = new uint256[][](5);

    function setUp() public {
        condoManager = new CondoManager();

        apartments[0] = new uint256[](3);
        apartments[0][0] = 1; // floor number
        apartments[0][1] = 1; // apart number
        apartments[0][2] = 1000;
        apartments[1] = new uint256[](3);
        apartments[1][0] = 1; // floor number
        apartments[1][1] = 2; // apart number
        apartments[1][2] = 1500;
        apartments[2] = new uint256[](3);
        apartments[2][0] = 2; // floor number
        apartments[2][1] = 1; // apart number
        apartments[2][2] = 1500;
        apartments[3] = new uint256[](3);
        apartments[3][0] = 3; // floor number
        apartments[3][1] = 1; // apart number
        apartments[3][2] = 3500;
        apartments[4] = new uint256[](3);
        apartments[4][0] = 3; // floor number
        apartments[4][1] = 2; // apart number
        apartments[4][2] = 2500;
    }

    function testAddCondo() public {
        uint256 condoId = condoManager.addCondo("Condo1", "CD1", apartments);

        CondoStructs.Condo memory condo = condoManager.getCondo(condoId);

        assertEq(condo.apartments.length, 5);
        assertEq(uint256(condo.status), uint256(Status.Suspended));
    }

    function testUpdCondo() public {
        uint256 condoId = condoManager.addCondo("Condo1", "CD1", apartments);

        vm.prank(address(this)); // Set the caller to this contract
        condoManager.updCondo(condoId, Status.Active);

        CondoStructs.Condo memory condo = condoManager.getCondo(condoId);

        assertEq(uint256(condo.status), uint256(Status.Active));
    }

    function testAddCondoUnauthorized() public {
        uint256 condoId = condoManager.addCondo("Condo1", "CD1", apartments);
        uint256 userId = condoManager.addressToId(address(this));

        assertEq(userId, 1);
        vm.startPrank(address(0x1234)); // Set the caller to an unauthorized address
        vm.expectRevert(UnauthorizedAccess.selector);
        condoManager.updCondo(condoId, Status.Active);
        vm.stopPrank();
    }

    function testAddApart() public {
        uint256 condoId = condoManager.addCondo("Condo1", "CD1", apartments);

        address buyer = address(0x1234); // A separate address for the buyer

        vm.deal(buyer, 1 ether); // Fund the buyer address with sufficient ETH
        vm.prank(buyer); // Set the caller to the buyer address
        uint256 apartId = condoManager.addApart{value: 1000}(condoId, 1, 1);

        CondoStructs.Apart memory apart = condoManager.getApart(apartId);

        assertEq(apart.floorNumber, 1);
        assertEq(apart.apartmentNumber, 1);
        assertEq(apart.price, 1000);
    }

    function testAddRating() public {
        uint256 ratingId = condoManager.addRating(1, true, "Great user");

        CondoStructs.Rating memory rating = condoManager.getRating(ratingId);

        assertEq(rating.ratedUserId, 1);
        assertEq(rating.isPositive, true);
        assertEq(rating.comment, "Great user");
    }

    function testUpdRating() public {
        uint256 ratingId = condoManager.addRating(1, true, "Great user");

        vm.prank(address(this)); // Set the caller to this contract
        condoManager.updRating(ratingId, false, "Changed my mind");

        CondoStructs.Rating memory rating = condoManager.getRating(ratingId);

        assertEq(rating.isPositive, false);
        assertEq(rating.comment, "Changed my mind");
    }

    function testAddShare() public {
        uint256 shareId = condoManager.addShare(10, 1);

        CondoStructs.Share memory share = condoManager.getShare(shareId);

        assertEq(share.pricePerBlock, 10);
        assertEq(share.tokenId, 1);
        assertEq(share.isActive, true);
    }

    function testUpdShare() public {
        uint256 shareId = condoManager.addShare(10, 1);

        vm.prank(address(this)); // Set the caller to this contract
        condoManager.updShare(shareId, 20, false);

        CondoStructs.Share memory share = condoManager.getShare(shareId);

        assertEq(share.pricePerBlock, 20);
        assertEq(share.isActive, false);
    }

    function testAddRent() public {
        uint256 shareId = condoManager.addShare(10, 1);

        uint256 rentId = condoManager.addRent{value: 86400}(shareId);

        CondoStructs.Rent memory rent = condoManager.getRent(rentId);

        assertEq(rent.balance, 86400);
        assertEq(rent.shareId, shareId);
    }

    function testUpdRent() public {
        uint256 shareId = condoManager.addShare(10, 1);

        uint256 rentId = condoManager.addRent{value: 86400}(shareId);

        vm.prank(address(this)); // Set the caller to this contract
        condoManager.updRent{value: 43200}(rentId);

        CondoStructs.Rent memory rent = condoManager.getRent(rentId);

        assertEq(rent.balance, 129600);
    }

    function testAddUser() public {
        uint256 userId = condoManager.addUser("Alice", "Test user", "image1");

        CondoStructs.User memory user = condoManager.getUser(userId);

        assertEq(user.name, "Alice");
        assertEq(user.description, "Test user");
        assertEq(user.image, "image1");
    }

    function testUpdUser() public {
        uint256 userId = condoManager.addUser("Alice", "Test user", "image1");

        vm.prank(address(this)); // Set the caller to this contract
        condoManager.updUser("Alice Updated", "Updated user", "image2");

        CondoStructs.User memory user = condoManager.getUser(userId);

        assertEq(user.name, "Alice Updated");
        assertEq(user.description, "Updated user");
        assertEq(user.image, "image2");
    }
}
