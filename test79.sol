// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract ModifierFlow {
    uint public value;

    modifier addBefore() {
        value += 10;
        _;
    }

    function update() public addBefore {
        value += 20;
    }
}