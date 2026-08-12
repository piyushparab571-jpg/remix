// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract ReplaceStruct {
    struct User {
        string name;
        uint age;
    }

    User public user;

    function setUser(string memory _name, uint _age) public {
        user = User(_name, _age);
    }
}