// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract SecurityGap {
    address public owner;
    uint public balance;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    function secureSet(uint _amount) public onlyOwner {
        balance = _amount;
    }

    // Modifier intentionally removed
    function insecureSet(uint _amount) public {
        balance = _amount;
    }
}