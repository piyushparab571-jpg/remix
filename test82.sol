//SPDX-License-identifier:MIT
pragma solidity ^0.8.20;
contract UnknownFunction {
    event FallbackCalled(bytes data);
    fallback() external {
        emit FallbackCalled(msg.data);
    }
}