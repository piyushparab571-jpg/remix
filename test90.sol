//SPDX-License-Identifier:MIT
pragma solidity ^0.8.20;
contract NonPayableFallback {
    event FallbackCalled(bytes data);
    fallback() external {
        emit FallbackCalled(msg.data);
    }
}