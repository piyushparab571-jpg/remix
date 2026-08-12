// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract RestrictedFunction {
    address public owner;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner allowed");
        _;
    }

    uint public value;

    function setValue(uint _value) public onlyOwner {
        value = _value;
    }
}