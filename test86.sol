//SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
contract FallbackEvent {
    event UnknownCall(
        address sender,
        uint256 value,
        bytes data
    );
    fallback() external payable {
        emit UnknownCall(msg.sender, msg.value, msg.data);
    }
}