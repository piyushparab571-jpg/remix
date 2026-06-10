// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/*
=========================================================
PRACTICAL: selfdestruct forces ETH into contract
CONCEPT: Forced balance behavior
=========================================================

OBJECTIVE

- Understand how selfdestruct can send ETH to any address
- Learn that ETH can be forced into contracts without payable functions
- Observe balance change without fallback/receive
- Learn historical + modern Ethereum behavior

=========================================================
CORE IDEA
=========================================================

selfdestruct(target) → sends ALL contract ETH to target

IMPORTANT:
No fallback() or receive() is required.

=========================================================
FORCED ETH CONTRACT (TARGET)
=========================================================
*/
/*
contract VictimContract {

    /*
        This contract CANNOT reject ETH sent via selfdestruct
    

    uint256 public balanceTracker;

    function update() external payable {
        balanceTracker += msg.value;
    }

    function getBalance() external view returns (uint256) {
        return address(this).balance;
    }
}

/*
=========================================================
ATTACK CONTRACT USING selfdestruct
=========================================================


contract ForceEtherSender {

    /*
    =====================================================
    FORCE ETH INTO TARGET
    =====================================================
    

    function forceSend(address payable target) external payable {

        /*
            Step 1:
            Contract receives ETH
        

        /*
            Step 2:
            selfdestruct sends ETH to target
        

        selfdestruct(target);
    }
}
*/
/*
=========================================================
EXECUTION FLOW
=========================================================

STEP 1:
Deploy VictimContract

STEP 2:
Deploy ForceEtherSender

STEP 3:
Call:

forceSend(VictimContract, 5 ether)

=========================================================

STEP-BY-STEP RESULT
=========================================================

1. ForceEtherSender holds 5 ETH
2. selfdestruct executed
3. ALL ETH transferred to VictimContract
4. ForceEtherSender is destroyed

=========================================================
IMPORTANT OBSERVATION
=========================================================

VictimContract receives ETH:

- WITHOUT calling receive()
- WITHOUT calling fallback()
- WITHOUT user interaction

=========================================================
STATE IMPACT

address(victim).balance increases

BUT:

balanceTracker DOES NOT update automatically

=========================================================
WHY THIS IS IMPORTANT

Contracts cannot block selfdestruct ETH transfers.

=========================================================
REAL SECURITY IMPLICATIONS

This behavior affects:

- DAO accounting systems
- invariant checks
- balance-based logic
- reward calculations

=========================================================
AUDITOR INSIGHT

Auditors check:

✔ Can contract receive ETH unexpectedly?
✔ Does logic rely on msg.value only?
✔ Are balance assumptions trusted?
✔ Are invariants based on address(this).balance?

=========================================================
MODERN NOTE (IMPORTANT)

In newer Ethereum upgrades:
- selfdestruct behavior is being restricted
- but legacy behavior still matters for audits

=========================================================
COMMON BUGS CAUSED

- stuck accounting mismatches
- reward inflation/deflation bugs
- incorrect total supply assumptions
- invariant breakage in DeFi protocols

=========================================================
KEY TAKEAWAYS

- selfdestruct bypasses receive/fallback
- ETH can be forced into any contract
- balance != accounting state
- protocols must not fully trust address.balance
- forced ETH breaks assumptions in DeFi systems

=========================================================
*/
/*
Audit Report
Title

Forced ETH Transfer via selfdestruct Causes Accounting Mismatch

Severity

Medium

Reason

The contract assumes ETH enters only through the update() function and tracks deposits using balanceTracker.

However, ETH can be forcibly sent to the contract through selfdestruct, bypassing normal accounting logic.

As a result:

balanceTracker != address(this).balance
Location

Contract: VictimContract

Functions:

update()
getBalance()

Related Contract: ForceEtherSender

Function:

forceSend()
Vulnerability Description

The contract maintains internal accounting:

function update() external payable {
    balanceTracker += msg.value;
}

But an attacker can force ETH into the contract using:

selfdestruct(target);

The ETH arrives successfully even though:

No receive()
No fallback()
No call to update()

Therefore:

balanceTracker

remains unchanged while:

address(this).balance

increases.

Impact

An attacker can:

Break accounting assumptions
Cause balance inconsistencies
Manipulate reward calculations
Break protocol invariants
Affect DAO treasury accounting
Cause incorrect balance-based logic
Proof of Concept
Step 1

Deploy:

VictimContract

State:

balanceTracker = 0
balance = 0
Step 2

Deploy:

ForceEtherSender
Step 3

Call:

forceSend{value: 5 ether}(victim)
Step 4

selfdestruct executes:

selfdestruct(target);
Step 5

Observe state:

address(victim).balance = 5 ether
balanceTracker = 0

Accounting becomes inconsistent.

Root Cause

The contract relies on:

msg.value

to track deposits.

Ethereum allows ETH transfers that bypass contract functions through:

selfdestruct()

making internal accounting diverge from actual balance.

Recommendation

Do not assume:

address(this).balance

always equals tracked deposits.

Use explicit accounting variables and treat unexpected ETH as possible.

Avoid critical logic that depends solely on:

address(this).balance

Patched Code
*/
contract VictimContractSafe {

    uint256 public balanceTracker;

    event Deposit(address indexed user, uint256 amount);
    event UnexpectedBalance(
        uint256 tracked,
        uint256 actual
    );

    function update()
        external
        payable
    {
        balanceTracker += msg.value;

        emit Deposit(
            msg.sender,
            msg.value
        );
    }

    function getBalance()
        external
        view
        returns (uint256)
    {
        return address(this).balance;
    }

    function checkInvariant()
        external
    {
        if (
            address(this).balance !=
            balanceTracker
        ) {
            emit UnexpectedBalance(
                balanceTracker,
                address(this).balance
            );
        }
    }
}

