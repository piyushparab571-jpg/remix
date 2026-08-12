// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract MisusedModifier {
    address public owner;
    uint public balance;

    constructor() {
        owner = msg.sender;
    }

    // Incorrect modifier
    modifier onlyOwner() {
        if (msg.sender != owner) {
            _;
        }
    }

    function withdraw() public onlyOwner {
        balance = 0;
    }
}