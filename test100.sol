// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract Practical100 {
    address public owner;
    mapping(address => uint256) public balances;

    constructor() {
        owner = msg.sender;
    }

    function deposit() public payable {
        balances[msg.sender] += msg.value;
    }

    function withdraw(uint256 amount) public {
        require(amount > 0, "Zero amount");
        require(amount <= balances[msg.sender], "Insufficient balance");

        balances[msg.sender] -= amount;

        payable(msg.sender).transfer(amount);
    }

    function changeOwner(address newOwner) public {
        require(msg.sender == owner, "Not owner");
        require(newOwner != address(0), "Invalid owner");

        owner = newOwner;
    }

    function emergencyWithdraw() public {
        require(msg.sender == owner, "Not owner");

        payable(owner).transfer(address(this).balance);
    }

    receive() external payable {}
}