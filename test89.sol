//SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
contract PayableFallback{
    event ETHReceived(address sender, uint256 amount, bytes data);
    fallback() external payable {
        emit ETHReceived(msg.sender, msg.value, msg.data);
    }
}