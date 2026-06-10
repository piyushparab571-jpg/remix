// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/*
=========================================================
PRACTICAL: delegatecall Demo
CONCEPT: Context execution (storage of caller contract)
=========================================================

OBJECTIVE

- Understand delegatecall execution model
- See how storage of caller contract is modified
- Learn why delegatecall is powerful AND dangerous
- Observe context (msg.sender, msg.value, storage)

=========================================================
CORE IDEA
=========================================================

delegatecall:

- runs code from another contract
- BUT uses caller’s storage, msg.sender, msg.value

=========================================================
KEY DIFFERENCE

call        → changes callee storage
delegatecall → changes caller storage ❗

=========================================================
LIBRARY CONTRACT (LOGIC ONLY)
=========================================================
*/
/*
contract LogicContract {

    // NOTE: storage layout MUST match caller
    uint256 public num;
    address public sender;

    /*
    =====================================================
    SET FUNCTION (RUNS IN CALLER CONTEXT)
    =====================================================
    

    function set(uint256 _num) external payable {

        /*
            These variables actually belong to CALLER
            when used via delegatecall
        

        num = _num;
        sender = msg.sender;
    }
}

/*
=========================================================
CALLER CONTRACT (STATE HOLDER)
=========================================================


contract ProxyContract {

    uint256 public num;
    address public sender;

    /*
        Address of logic contract
    
    address public logic;

    constructor(address _logic) {
        logic = _logic;
    }

    /*
    =====================================================
    DELEGATECALL EXECUTION
    =====================================================
    

    function setViaDelegate(uint256 _num) external payable {

        (bool success, ) = logic.delegatecall(
            abi.encodeWithSignature(
                "set(uint256)",
                _num
            )
        );

        require(success, "delegatecall failed");
    }
}
*/
/*
Audit Report
Title

Unsafe Use of delegatecall Can Modify Caller Storage

Severity

High

Reason

The contract uses delegatecall, which executes external code in the storage context of the calling contract. If the logic contract is malicious, compromised, or upgraded incorrectly, it can overwrite critical storage variables in the proxy contract.

Location

Contract: ProxyContract
Function: setViaDelegate(uint256 _num)

Vulnerability Description

The function performs a delegatecall to an external logic contract:

(bool success, ) = logic.delegatecall(
    abi.encodeWithSignature(
        "set(uint256)",
        _num
    )
);

Unlike a normal call(), delegatecall() executes the target contract's code while preserving:

msg.sender
msg.value
Storage of the caller contract

As a result, any storage writes performed inside LogicContract will modify the storage of ProxyContract.

Impact

A malicious or compromised logic contract can:

Overwrite storage variables
Change ownership variables
Corrupt balances
Brick the proxy contract
Take full control of protocol state

Potential consequences:

Unauthorized storage modification
Privilege escalation
Loss of funds
Protocol takeover
Proof of Concept
Initial State
ProxyContract.num = 0;
ProxyContract.sender = address(0);

User calls:

setViaDelegate(100);
Execution Flow
User
 ↓
ProxyContract
 ↓ delegatecall
LogicContract.set(100)

Inside LogicContract:

num = _num;
sender = msg.sender;

Because of delegatecall:

ProxyContract.num = 100
ProxyContract.sender = User

Storage in LogicContract is NOT modified.

Root Cause

Use of:

logic.delegatecall(...)

Delegatecall executes external code using the caller's storage layout.

Security depends entirely on:

Correct storage alignment
Trusted logic contract
Safe upgrade mechanisms
Recommendation
Option 1: Use call Instead

If storage sharing is not required:

(bool success, ) =
    logic.call(
        abi.encodeWithSignature(
            "set(uint256)",
            _num
        )
    );

This updates storage in the logic contract rather than the proxy.

Option 2: Restrict Logic Upgrades

If using a proxy pattern:

require(
    msg.sender == owner,
    "Not owner"
);

for logic updates.

Option 3: Validate Logic Address
require(
    logic != address(0),
    "Invalid logic"
);
Patched Code
*/
contract LogicContract {

    uint256 public num;
    address public sender;

    function set(uint256 _num)
        external
    {
        num = _num;
        sender = msg.sender;
    }
}

contract ProxyContract {

    address public logic;

    constructor(address _logic) {
        require(
            _logic != address(0),
            "Invalid logic"
        );
        logic = _logic;
    }

    function setViaCall(
        uint256 _num
    )
        external
    {
        (bool success, ) =
            logic.call(
                abi.encodeWithSignature(
                    "set(uint256)",
                    _num
                )
            );

        require(
            success,
            "call failed"
        );
    }
}