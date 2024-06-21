// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

contract CondoVault is Ownable, ReentrancyGuard {
    event Deposit(address indexed user, uint256 amount);
    event Withdraw(address indexed to, uint256 amount);

    constructor(address timelock) Ownable(timelock) {}

    function deposit() external payable nonReentrant {
        require(msg.value > 0, "Must send ETH");
        emit Deposit(msg.sender, msg.value);
    }

    function withdraw(
        address payable to,
        uint256 amount
    ) external onlyOwner nonReentrant {
        require(amount <= address(this).balance, "Insufficient funds");
        to.transfer(amount);
        emit Withdraw(to, amount);
    }

    receive() external payable {
        emit Deposit(msg.sender, msg.value);
    }
}
