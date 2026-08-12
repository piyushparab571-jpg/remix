// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract MultipleUsers {
    struct User {
        string name;
        uint age;
        bool registered;
    }

    mapping(address => User) public users;

    function register(string memory _name, uint _age) public {
        users[msg.sender] = User(_name, _age, true);
    }
}