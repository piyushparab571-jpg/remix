//SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
contract Practical93 {
    uint256 public counter;
    function increment() public {
        counter++;
    }
    function decrement() public {
        require(countr > 0, "Counter already zero");
        counter--;
    }
    function reset() public {
        counter = 0;
    }
}