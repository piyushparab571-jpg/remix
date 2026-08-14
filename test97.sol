// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract Practical97 {
    address public owner;

    constructor() payable {
        owner = msg.sender;
    }

    function deposit() public payable {}

    // INTENTIONALLY VULNERABLE
    function withdraw() public {
        payable(msg.sender).transfer(address(this).balance);
    }

    receive() external payable {}
}