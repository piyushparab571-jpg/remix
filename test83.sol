// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract ReceiveAndFallback {
    event Received(uint256 amount);
    event FallbackCalled(bytes data);

    receive() external payable {
        emit Received(msg.value);
    }

    fallback() external payable {
        emit FallbackCalled(msg.data);
    }
}