// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract UserRecords {
    struct User {
        string name;
        uint age;
    }

    mapping(address => User) public users;

    function addUser(string memory _name, uint _age) public {
        users[msg.sender] = User(_name, _age);
    }
}