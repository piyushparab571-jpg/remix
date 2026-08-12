// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract DeleteStruct {
    struct User {
        string name;
        uint age;
        bool active;
    }

    User public user = User("Piyush", 18, true);

    function resetUser() public {
        delete user;
    }
}