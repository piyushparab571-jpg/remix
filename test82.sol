// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/*
=========================================================
PRACTICAL: Storage Collision Demo
CONCEPT: Upgrade/Proxy Risk (delegatecall mismatch)
=========================================================

OBJECTIVE

- Understand storage layout collision in proxy patterns
- See how delegatecall can corrupt state
- Learn why upgradeable contracts are dangerous if misaligned
- Observe proxy vs logic storage interaction

=========================================================
CORE IDEA
=========================================================

delegatecall uses CALLER STORAGE.

If storage layouts differ between:
- Proxy contract
- Logic contract

→ storage collision occurs ❌

=========================================================
VULNERABLE LOGIC CONTRACT (V1)
=========================================================
*/

contract LogicV1 {

    // SLOT 0
    uint256 public value;

    // SLOT 1
    address public owner;

    function setValue(uint256 _value) external {
        value = _value;
    }

    function setOwner(address _owner) external {
        owner = _owner;
    }
}

/*
=========================================================
PROXY CONTRACT (WRONG STORAGE LAYOUT)
=========================================================
*/

contract ProxyBad {

    /*
        ❌ STORAGE MISMATCH STARTS HERE
    */

    // SLOT 0 (EXPECTED: maybe admin)
    address public admin;

    // SLOT 1 (EXPECTED: implementation)
    address public implementation;

    /*
        BUT LogicV1 expects:
        slot0 = value
        slot1 = owner
    */

    constructor(address _impl) {
        admin = msg.sender;
        implementation = _impl;
    }

    /*
    =====================================================
    DELEGATECALL EXECUTION
    =====================================================
    */

    function setValue(uint256 _value) external {

        (bool success, ) = implementation.delegatecall(
            abi.encodeWithSignature(
                "setValue(uint256)",
                _value
            )
        );

        require(success, "delegatecall failed");
    }

    function setOwner(address _owner) external {

        (bool success, ) = implementation.delegatecall(
            abi.encodeWithSignature(
                "setOwner(address)",
                _owner
            )
        );

        require(success, "delegatecall failed");
    }
}

/*
=========================================================
ATTACK / COLLISION RESULT
=========================================================

CALL:
setValue(100)

=========================================================

LogicV1 executes:

value = 100

BUT STORAGE ACTUALLY WRITES INTO PROXY:

slot0 → admin ❌ overwritten

=========================================================

CALL:
setOwner(attacker)

=========================================================

LogicV1 executes:

owner = attacker

BUT STORAGE WRITES INTO:

slot1 → implementation ❌ overwritten

=========================================================
FINAL BROKEN STATE IN PROXY
=========================================================

admin         = 100 (CORRUPTED)
implementation = attacker address (BROKEN)
value         = NOT stored correctly
owner         = attacker (misplaced slot)

=========================================================
💥 THIS IS STORAGE COLLISION
=========================================================

Logic assumes one layout
Proxy has another layout

→ delegatecall causes memory mismatch

=========================================================
WHY THIS IS CRITICAL
=========================================================

This leads to:

- admin takeover
- implementation hijack
- proxy corruption
- full protocol compromise

=========================================================
SECURE PATTERN (FIX IDEA)
=========================================================

Use consistent storage layout:

---------------------------------------------------------
Proxy:
slot0 = implementation
slot1 = admin
---------------------------------------------------------

OR use OpenZeppelin standard proxies:
- Transparent Proxy
- UUPS Proxy

=========================================================
SAFE PROXY EXAMPLE (CONCEPT ONLY)
=========================================================
*/
/*
contract ProxySafe {

    // MUST MATCH expected layout carefully
    address public implementation;
    address public admin;

    constructor(address _impl) {
        implementation = _impl;
        admin = msg.sender;
    }

    function setValue(uint256 _value) external {
        (bool success, ) = implementation.delegatecall(
            abi.encodeWithSignature("setValue(uint256)", _value)
        );
        require(success);
    }
}
*/
/*
=========================================================
KEY SECURITY INSIGHTS
=========================================================

- delegatecall shares storage with proxy
- storage slot order MUST match exactly
- mismatch = silent corruption (very dangerous)
- upgradeable contracts require strict layout control

=========================================================
AUDITOR CHECKLIST
=========================================================

✔ Does proxy and logic share identical storage layout?
✔ Are new variables appended safely?
✔ Is upgrade mechanism controlled?
✔ Is implementation address protected?
✔ Is storage collision possible via delegatecall?

=========================================================
REAL-WORLD IMPACT
=========================================================

Many DeFi hacks come from:

- broken upgradeable proxies
- storage slot mismatch
- unsafe delegatecall usage
- logic contract upgrades without layout checks

=========================================================
KEY TAKEAWAYS
=========================================================

- delegatecall = shared storage execution
- storage order matters more than logic
- mismatch causes silent corruption
- proxy patterns must be strictly standardized

=========================================================
*/
/*
Audit Report

Title: Storage Collision via delegatecall in Proxy Pattern

Severity: Critical

Reason

The ProxyBad contract uses delegatecall to execute logic from LogicV1, but their storage layouts do not match.

Since delegatecall executes code in the context of the caller's storage, variables from LogicV1 overwrite unrelated storage slots in ProxyBad.

This results in storage collision, allowing critical proxy variables such as admin and implementation to be corrupted.

Location

Contract: ProxyBad

Functions:

setValue(uint256)
setOwner(address)

External Logic Contract: LogicV1

Vulnerability Description

LogicV1 expects:

Slot	Variable
0	value
1	owner

However ProxyBad stores:

Slot	Variable
0	admin
1	implementation

When delegatecall executes:

value = _value;

the write occurs in Proxy storage slot 0:

admin = address(uint160(_value));

Similarly:

owner = _owner;

writes into slot 1:

implementation = _owner;

This corrupts proxy state.

Impact

An attacker can:

Overwrite proxy admin
Replace implementation address
Hijack upgrade mechanism
Redirect delegatecalls to malicious contracts
Gain full control of protocol logic
Cause permanent protocol compromise
Proof of Concept
Step 1

Deploy:

LogicV1

Deploy:

ProxyBad(logicAddress)

Initial state:

admin = deployer
implementation = LogicV1
Step 2

Call:

ProxyBad.setValue(100);

Delegatecall executes:

LogicV1.value = 100;

Actual result:

admin = address(100);

Proxy admin becomes corrupted.

Step 3

Call:

ProxyBad.setOwner(attacker);

Delegatecall executes:

LogicV1.owner = attacker;

Actual result:

implementation = attacker;

Implementation address is replaced.

Step 4

Attacker deploys malicious implementation:

contract EvilLogic {
    function pwn() external {
        selfdestruct(payable(msg.sender));
    }
}

Future delegatecalls execute attacker-controlled code.

Root Cause

delegatecall shares the caller's storage.

The storage layout of:

LogicV1

does not match:

ProxyBad

Storage slots are interpreted differently by each contract.

No storage layout compatibility checks exist.

Recommendation

Use identical storage layouts between proxy and implementation.

Example:

contract ProxySafe {

    uint256 public value;
    address public owner;

    address public implementation;
    address public admin;
}

Or use standardized proxy patterns:

OpenZeppelin Contracts Transparent Proxy
OpenZeppelin Contracts UUPS Proxy
EIP-1967 storage slots

Always append new variables to the end of storage layouts during upgrades.

Patched Code
*/
contract ProxySafe {

    // Match LogicV1 storage layout
    uint256 public value;      // slot 0
    address public owner;      // slot 1

    // Additional proxy variables
    address public implementation; // slot 2
    address public admin;          // slot 3

    constructor(address _impl) {
        implementation = _impl;
        admin = msg.sender;
    }

    function setValue(uint256 _value) external {
        (bool success, ) =
            implementation.delegatecall(
                abi.encodeWithSignature(
                    "setValue(uint256)",
                    _value
                )
            );

        require(success, "delegatecall failed");
    }

    function setOwner(address _owner) external {
        (bool success, ) =
            implementation.delegatecall(
                abi.encodeWithSignature(
                    "setOwner(address)",
                    _owner
                )
            );

        require(success, "delegatecall failed");
    }
}