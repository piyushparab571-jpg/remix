//SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
contract RandomCalldata{
    event DataReceived(bytes data);
    fallback() external{
        emit DataReceived(msg.data);
    }
}