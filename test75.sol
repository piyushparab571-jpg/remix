// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract BeforeModifier {
    uint public value;

    modifier beforeFunction() {
        value = 10;
        _;
    }

    function test() public beforeFunction {
        value = 20;
    }
}