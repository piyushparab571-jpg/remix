// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract OnlyOwner {
    address public owner;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not the owner");
        _;
    }

    function secretFunction() public onlyOwner {
        // Only owner can execute this
    }
}