//SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
contract ContractA {
    address public lastCaller;
    function recordCaller() publc {
        lastCaller = msg.sender; 
    }
    function getCaller() public view returns (address) {
        return lastCaller;
    }
}
interface IContractA {
    function recordCaller() external;
}

contract ContractB {
    function callContractA(address contractA) public {
        IContractA(contractA).recordCaller();
    }
}