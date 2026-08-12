// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract ParameterModifier {
    modifier minimum(uint _amount) {
        require(msg.value >= _amount, "Insufficient ETH");
        _;
    }

    function deposit()
        public
        payable
        minimum(1 ether)
    {
    }
}