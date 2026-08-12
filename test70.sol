// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract FieldAccess {
    struct Student {
        string name;
        uint age;
        uint marks;
    }

    Student public student = Student("Piyush", 18, 85);

    function getName() public view returns (string memory) {
        return student.name;
    }

    function getAge() public view returns (uint) {
        return student.age;
    }

    function getMarks() public view returns (uint) {
        return student.marks;
    }
}