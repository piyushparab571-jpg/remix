//SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
contract Practicle94 {
    address public owner;
    uint256 public balance;
    constructor() {
        owner = msg.sender;
    }
    modifier onlyOwner(){
        require(msg.sender == owner, "Not the owner");
        _;
    }
    function deposit() public payable {
        balance += msg.value;
    }
    function withdraw() public onlyOwner {
        payable(owner).transfer(address(this).balance);
        balance = 0;
    }
}