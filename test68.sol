//SPDX-License-Identifier:MIT
pragma solidity ^0.8.20;
contract NestedStruct {
    struct AddressInfo {
        string city;
        uint pincode;
    }
    struct User {
        string name;
        uint age;
        AddressInfo addressInfo;
    }
    User public user;
    function setUser() public {
        user = User(
            "Piyush",
            18,
            AddressInfo("Sawantwadi", 400001)
        )
    

    }
}