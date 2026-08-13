//SPDX-License-Identifier:MIT
pragma solidity ^0.8.20;
contract EmptyCalldata{
    event ReceiveTriggered(address sender, uint256 amount);
    receive() external payable {
        emit ReceiveTriggered(msg.sender, msg.value);
     }
}