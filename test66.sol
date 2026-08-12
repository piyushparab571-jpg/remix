// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract DefaultStruct {
    struct User {
        string name;
        uint age;
        bool active;
    }

    User public user;

    function getUser()
        public
        view
        returns (string memory, uint, bool)
    {
        return (user.name, user.age, user.active);
    }
}