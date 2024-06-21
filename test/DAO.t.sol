// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import "@condao/contracts/NFT.sol";
import "@condao/contracts/CondoTimelock.sol";
import "@condao/contracts/CondoGovernor.sol";
import "@condao/contracts/CondoVault.sol";

contract DAOTest is Test {
    NFT nft;
    CondoTimelock timelock;
    CondoGovernor governor;
    CondoVault vault;

    address deployer = address(0x1234);
    address user1 = address(0x5678);
    address user2 = address(0x9ABC);

    function setUp() public {
        vm.startPrank(deployer);

        // Deploy the NFT contract
        uint256[][] memory apartments = new uint256[][](2);

        apartments[0] = new uint256[](3);
        apartments[0][0] = 1; // 1 floor
        apartments[0][1] = 1; // 1 apartment
        apartments[0][2] = 10; // 10 eth price

        apartments[1] = new uint256[](3);
        apartments[1][0] = 2; // 1 floor
        apartments[1][1] = 1; // 1 apartment
        apartments[1][2] = 20; // 10 eth price

        nft = new NFT("Test", "TST", apartments);

        // Mint NFTs to users
        nft.mint(user1, 1, 1); // Mint apartment 1 on floor 1
        nft.mint(user2, 2, 1); // Mint apartment 1 on floor 2

        // Deploy the Timelock contract
        uint256 minDelay = 2 days; // 2 days
        address[] memory proposers = new address[](1);
        address[] memory executors = new address[](1);
        proposers[0] = deployer;
        executors[0] = deployer;
        timelock = new CondoTimelock(minDelay, proposers, executors, deployer);

        // Deploy the Governor contract
        governor = new CondoGovernor(nft, timelock);

        // Deploy the Vault contract and transfer ownership to the Timelock contract
        vault = new CondoVault(address(timelock));

        // Set the Timelock contract as the executor of the Governor contract
        timelock.grantRole(timelock.EXECUTOR_ROLE(), address(governor));

        // Add Governor as a proposer to Timelock
        timelock.grantRole(timelock.PROPOSER_ROLE(), address(governor));

        vm.stopPrank();
    }

    function testPropose() public {
        vm.startPrank(deployer);

        // Ensure the Vault has sufficient funds
        vm.deal(address(vault), 1 ether);

        // Propose to withdraw some funds from the Vault
        address[] memory targets = new address[](1);
        uint256[] memory values = new uint256[](1);
        bytes[] memory calldatas = new bytes[](1);

        targets[0] = address(vault);
        values[0] = 0;
        calldatas[0] = abi.encodeWithSignature(
            "withdraw(address,uint256)",
            deployer,
            1 ether
        );

        console.log("Proposing...");
        uint256 proposalId = governor.propose(
            targets,
            values,
            calldatas,
            "Withdraw 1 ETH from Vault"
        );
        console.log("Proposal ID: ", proposalId);

        // Log voting power before voting
        console.log(
            "User1 votes before: ",
            nft.getPastVotes(user1, block.number - 1)
        );
        console.log(
            "User2 votes before: ",
            nft.getPastVotes(user2, block.number - 1)
        );

        // Move to the voting period
        vm.roll(block.number + governor.votingDelay() + 1);

        // Vote for the proposal
        vm.stopPrank();
        vm.prank(user1);
        console.log("User1 voting...");
        governor.castVote(proposalId, 1); // Vote in favor

        vm.prank(user2);
        console.log("User2 voting...");
        governor.castVote(proposalId, 1); // Vote in favor

        // Log voting power after voting
        console.log(
            "User1 votes after: ",
            nft.getPastVotes(user1, block.number - 1)
        );
        console.log(
            "User2 votes after: ",
            nft.getPastVotes(user2, block.number - 1)
        );

        // Move to the end of the voting period
        vm.startPrank(deployer);
        vm.roll(block.number + governor.votingPeriod() + 1);
        console.log("Queueing proposal...");
        governor.queue(
            targets,
            values,
            calldatas,
            keccak256(bytes("Withdraw 1 ETH from Vault"))
        );

        // Move past the timelock delay and execute the proposal
        vm.warp(block.timestamp + timelock.getMinDelay() + 1);
        console.log("Executing proposal...");
        governor.execute(
            targets,
            values,
            calldatas,
            keccak256(bytes("Withdraw 1 ETH from Vault"))
        );

        // Check the Vault balance
        console.log("Vault balance: ", address(vault).balance);
        assertEq(address(vault).balance, 0);

        vm.stopPrank();
    }

    function testDepositAndWithdraw() public {
        vm.deal(deployer, 1 ether); // Give deployer 1 ether
        vm.prank(deployer);
        vault.deposit{value: 1 ether}(); // Deposit 1 ether into the vault
        assertEq(address(vault).balance, 1 ether);

        // Propose to withdraw some funds from the Vault
        vm.startPrank(deployer);
        address[] memory targets = new address[](1);
        uint256[] memory values = new uint256[](1);
        bytes[] memory calldatas = new bytes[](1);

        targets[0] = address(vault);
        values[0] = 0;
        calldatas[0] = abi.encodeWithSignature(
            "withdraw(address,uint256)",
            deployer,
            1 ether
        );

        console.log("Proposing...");
        uint256 proposalId = governor.propose(
            targets,
            values,
            calldatas,
            "Withdraw 1 ETH from Vault"
        );
        console.log("Proposal ID: ", proposalId);

        // Log voting power before voting
        console.log(
            "User1 votes before: ",
            nft.getPastVotes(user1, block.number - 1)
        );
        console.log(
            "User2 votes before: ",
            nft.getPastVotes(user2, block.number - 1)
        );

        // Move to the voting period
        vm.roll(block.number + governor.votingDelay() + 1);

        // Vote for the proposal
        vm.stopPrank();
        vm.prank(user1);
        console.log("User1 voting...");
        governor.castVote(proposalId, 1); // Vote in favor

        vm.prank(user2);
        console.log("User2 voting...");
        governor.castVote(proposalId, 1); // Vote in favor

        // Log voting power after voting
        console.log(
            "User1 votes after: ",
            nft.getPastVotes(user1, block.number - 1)
        );
        console.log(
            "User2 votes after: ",
            nft.getPastVotes(user2, block.number - 1)
        );

        // Move to the end of the voting period
        vm.startPrank(deployer);
        vm.roll(block.number + governor.votingPeriod() + 1);
        console.log("Queueing proposal...");
        governor.queue(
            targets,
            values,
            calldatas,
            keccak256(bytes("Withdraw 1 ETH from Vault"))
        );

        // Move past the timelock delay and execute the proposal
        vm.warp(block.timestamp + timelock.getMinDelay() + 1);
        console.log("Executing proposal...");
        governor.execute(
            targets,
            values,
            calldatas,
            keccak256(bytes("Withdraw 1 ETH from Vault"))
        );

        // Check the Vault balance and deployer's balance
        console.log("Vault balance: ", address(vault).balance);
        console.log("Deployer balance: ", deployer.balance);
        assertEq(address(vault).balance, 0);
        assertEq(deployer.balance, 1 ether);

        vm.stopPrank();
    }
}
