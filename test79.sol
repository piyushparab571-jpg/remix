// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/*
=========================================================
PRACTICAL: tx.origin Authentication Contract
CONCEPT: Dangerous authentication pattern
=========================================================

WARNING:
This contract demonstrates a BAD PRACTICE.

DO NOT use tx.origin for authentication in production.
=========================================================
*/
/*
contract TxOriginAuth {

    address public owner;

    constructor() {
        owner = msg.sender;
    }

    /*
    =====================================================
    DANGEROUS AUTH CHECK
    =====================================================
    

    function withdrawAll() external {

        /*
        ❌ BAD PRACTICE:
        using tx.origin for authentication
        

        require(tx.origin == owner, "Not owner");

        payable(owner).transfer(address(this).balance);
    }

    /*
    =====================================================
    NORMAL DEPOSIT
    =====================================================
    

    function deposit() external payable {}
}
*/
/*
Audit Report
Title

Use of tx.origin for Authentication

Severity

High

Reason

The contract uses tx.origin for authorization checks, which can be bypassed through phishing contracts and intermediary contract calls.

Location

Contract: TxOriginAuth
Function: withdrawAll()

Vulnerability Description

The withdrawAll() function authenticates the caller using:

require(tx.origin == owner, "Not owner");

tx.origin returns the original externally owned account (EOA) that initiated the transaction.

If the owner is tricked into interacting with a malicious contract, that malicious contract can call withdrawAll() on behalf of the owner while tx.origin still equals the owner's address.

As a result, unauthorized withdrawals can occur.

Impact

An attacker can steal all ETH stored in the contract if:

The owner interacts with a malicious contract.
The malicious contract calls withdrawAll().
The authentication check passes because tx.origin remains the owner's address.

Potential consequences:

Complete loss of contract funds.
Unauthorized privileged actions.
Phishing-based account compromise.
Proof of Concept
Owner
Owner = 0x123...
Attacker Deploys
contract Attack {
    TxOriginAuth target;

    constructor(address _target) {
        target = TxOriginAuth(_target);
    }

    function attack() external {
        target.withdrawAll();
    }
}
Attack Flow
Owner
  ↓
Attack Contract
  ↓
TxOriginAuth.withdrawAll()

Values inside withdrawAll():

tx.origin = Owner
msg.sender = Attack Contract

Check:

require(tx.origin == owner);

Result:

TRUE

Funds are transferred.

Root Cause

Authentication relies on:

tx.origin

instead of:

msg.sender

tx.origin tracks the original transaction initiator, not the immediate caller.

Recommendation

Use msg.sender for authorization.

Replace:

require(tx.origin == owner, "Not owner");

with:

require(msg.sender == owner, "Not owner");
Patched Code
*/
contract TxOriginAuthFixed {

    address public owner;

    constructor() {
        owner = msg.sender;
    }

    /*
    =====================================================
    SECURE AUTH CHECK
    =====================================================
    */

    function withdrawAll() external {

        /*
            Use msg.sender instead of tx.origin
        */
        require(
            msg.sender == owner,
            "Not owner"
        );

        payable(owner).transfer(
            address(this).balance
        );
    }

    /*
    =====================================================
    NORMAL DEPOSIT
    =====================================================
    */

    function deposit()
        external
        payable
    {}
}