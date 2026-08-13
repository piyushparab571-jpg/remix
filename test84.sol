//SPDX-License-Identifier:MIT
pragma solidity ^0.8.20;
contract OnlyFallback {
    event FallbackCalled(bytes data);

    fallback() external payable {
        emit FallbackCalled(msg.data);
    }
}