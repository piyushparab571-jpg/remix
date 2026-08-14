// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract Practical96 {
    mapping(address => uint256) public balances;

    function deposit() public payable {
        balances[msg.sender] += msg.value;
    }

    function withdraw() public {
        uint256 amount = balances[msg.sender];

        require(amount > 0, "No balance");

        // Interaction happens BEFORE state update
        (bool success, ) = payable(msg.sender).call{value: amount}("");
        require(success, "Transfer failed");

        // State update happens too late
        balances[msg.sender] = 0;
    }

    receive() external payable {}
}