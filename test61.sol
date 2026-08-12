// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract StructExample {
    struct Student {
        string name;
        uint age;
        uint marks;
        bool passed;
    }

    Student public student;
}