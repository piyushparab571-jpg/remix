//SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
contract Practicle955Secure {
    address public owner;
    constructor() {
        owner = msg.sender;
    }
    function withdraw() public {
        require(msg.sender == owner, "Unauthorized");
        payable(msg.sender).transfer(address(this).balance);
    }
    receive() external payable {}
}