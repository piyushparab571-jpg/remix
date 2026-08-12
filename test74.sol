// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract ModifierOrder {
    address public owner;
    bool public active = true;

    constructor() {
        owner = msg.sender;
    }

    modifier first() {
        require(msg.sender == owner, "First modifier failed");
        _;
    }

    modifier second() {
        require(active, "Second modifier failed");
        _;
    }

    function test()
        public
        first
        second
    {
    }
}