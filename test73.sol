// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract MultipleModifiers {
    address public owner;
    bool public active = true;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    modifier whenActive() {
        require(active == true, "Contract inactive");
        _;
    }

    function setValue(uint _value)
        public
        onlyOwner
        whenActive
    {
        // Function body
    }
}