//SPDX-License-Identifier:MIT
pragma solidity ^0.8.20;
contract NoFallback{
    function hello() external pure returns (string memory) {
        return "Hello";
    }
}