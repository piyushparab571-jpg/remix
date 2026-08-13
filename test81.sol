//SPDX-License-Identifier:MIT
pragma solidity ^0.8.20;
contract ReceiveETH {
    event Received(address sender, uint256 amount);
    receive() external payable {
        emit Received(msg.sender, msg.value);
    }
    function getBalance() external view returns (uint256) {
        return address(this).balance;
    }
}