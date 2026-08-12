//SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
contract UpdateStruct {
    struct Student {
        string name;
        uint age;
        uint marks;
    }
    Student public student = Student("Piyush", 18, 70);
    function updateMarks(uint _marks) public {
        student.marks = _marks;
    }
}