// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/*
=========================================================
PRACTICAL: Vulnerable Reentrancy Bank
CONCEPT: Root reentrancy logic
=========================================================

WARNING:
This contract is INTENTIONALLY VULNERABLE.

DO NOT use in production.
=========================================================
*/
/*
contract VulnerableBank {

    mapping(address => uint256) public balance;

    /*
    =====================================================
    DEPOSIT ETH
    =====================================================
    

    function deposit() external payable {
        balance[msg.sender] += msg.value;
    }

    /*
    =====================================================
    WITHDRAW ETH (VULNERABLE)
    =====================================================
    

    function withdraw(uint256 amount) external {

        /*
        STEP 1:
        Check balance
        
        require(balance[msg.sender] >= amount, "Not enough balance");

        /*
        STEP 2:
        EXTERNAL CALL FIRST ❌ (DANGER)
        
        (bool success, ) = msg.sender.call{value: amount}("");
        require(success, "Transfer failed");

        /*
        STEP 3:
        STATE UPDATE AFTER CALL ❌ (ROOT ISSUE)
        
        balance[msg.sender] -= amount;
    }

    /*
    =====================================================
    VIEW BALANCE
    =====================================================
    

    function getBalance(address user)
        external
        view
        returns (uint256)
    {
        return balance[user];
    }
}
*/
/*
Audit Report
Title
Reentrancy Vulnerability in withdraw() Function

Severity: High

Reason
The contract performs an external ETH transfer befor updating the user's balance.
An attacker can exploit this ordering to repeatedly re-enter the withdraw() function
and drain funds from the contract.

Location
Contract: VulnerableBamk
Function: withdraw(uint256 amount)

Vulnerability Description
The withdraw() function follows this sequence:
require(balance[msg.sender] >= amount);
(bool success, ) =
    msg.sender.call{value: amount}("");
require(success);
balance[msg.sender] -= amount;
The external cxall:
msg.sender.call{value: amount]("");
is executed before the user's balance is updated.
if msg.sender is a malicious contract, its receive() or fallback() function can call
withdraw() again before:
balance[msg.sender] -= amount;
is executed.
As a result, the attacker can withdraw funds multiple times using the same balance.

Impact
- Complete theft of ETH stored in the contract
- Drain of user deposits
- Loss of protocol funds
- Denial of service for legitimate users

Proof Of Concept
Step 1
Attacker deposits 1 ETH:
deposite{value: 1 ether}();
Balance:
balance[attacker] = 1 ether;

Step 2
Attacker calls:
withdraw(1 ether);

Step 3
Contract sends ETH:
msg.sender.call{value: 1 ether}("");

Step 4
Attackers receive() function executes and re-enters:
withdraw(1 ether);

Step 5
Balance has not yet been reduced:
balance[attacker] == 1 ether;
The check passes again and more ETH is withdrawn.

Result
The attacker repeatedly drains the contract until funds are exhausted.

Root Cause
Violation of the Checks-Effects-Interactions pattern.

Vulnerable ordering:
External call -> state update

Specifically
(bool success, ) =
    msg.sender.call{value: amount}("");
balance[msg.sender] -= amount;

Recommendation
Update state before making external calls.
Apply the Checks-Effects-interactions pattern:
require(balance[msg.sender] >= amount);
balance[msg.sender] -= amount;
(bool success, ) =
    msg.sender.call{value: amount}("");
require(success);
Consider adding a reentrancy guard.

Patched code
*/
contract SecureBank {

    mapping(address => uint256) public balance;

    function deposit()
        external
        payable
    {
        balance[msg.sender] += msg.value;
    }

    function withdraw(
        uint256 amount
    )
        external
    {
        require(
            balance[msg.sender] >= amount,
            "Not enough balance"
        );

        // EFFECTS FIRST
        balance[msg.sender] -= amount;

        // INTERACTION LAST
        (bool success, ) =
            msg.sender.call{
                value: amount
            }("");

        require(
            success,
            "Transfer failed"
        );
    }

    function getBalance(
        address user
    )
        external
        view
        returns (uint256)
    {
        return balance[user];
    }
}