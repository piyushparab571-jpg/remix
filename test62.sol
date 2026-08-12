//Store a struct for msg.sender---- Structured state
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract SenderStruct {
    struct User {
        address wallet;
        uint balance;
        bool registered;
    }

    User public user;

    function register() public {
        user = User(msg.sender, msg.sender.balance, true);
    }
}