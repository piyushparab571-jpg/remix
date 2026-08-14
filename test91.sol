//SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
contract Practical91 {
    uint256 public balance;
    function deposite(uint256 amount) public {
        balance += amount;
    }
    function withdraw(uint256 amount) public {
        require(amount > 0, "Amount must be greater than zero");
        require(amount <= balance, "Insufficient balance");

        balance -= amount;
    }
    function setValue(uint256 value) public {
        balance = value;
    }
}