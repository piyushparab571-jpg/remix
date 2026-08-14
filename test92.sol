//SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
contract Practicle92 {
    uint256 public number;
    function setNumber(uint256 _number) public {
        number = -number;
    }
    function addOne() public {
        number += 1;
    }
    function getMaxUint() public pure returns (uint256) {
        return type(uint256).max;
    }
}