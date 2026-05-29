// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/*
=========================================================
PRACTICAL: Reorder logic intentionally
CONCEPT: Vulnerability creation
=========================================================

OBJECTIVE

- Learn how bad execution order creates vulnerabilities
- Understand dangerous state-update sequencing
- Learn reentrancy-style ordering issues
- Think like a smart contract auditor

---------------------------------------------------------
CORE IDEA
---------------------------------------------------------

Execution order is SECURITY CRITICAL.

Changing line order may:
- break invariants
- expose reentrancy
- corrupt accounting
- enable fund theft

---------------------------------------------------------
IMPORTANT UNDERSTANDING
---------------------------------------------------------

Same logic
+
Different order
=
Completely different security outcome.

---------------------------------------------------------
WHY THIS MATTERS
---------------------------------------------------------

Many real-world hacks happened because:
logic executed in wrong order.

---------------------------------------------------------
REAL-WORLD USAGE
---------------------------------------------------------

Ordering mistakes affected:

- DAO hack
- lending protocols
- vault systems
- reward systems
- staking protocols
- AMMs

---------------------------------------------------------
AUDITOR FOCUS
---------------------------------------------------------

Auditors inspect:

- state-update order
- external-call timing
- validation placement
- stale-state reads
- invariant preservation

=========================================================
*/
/*
contract ReorderLogicVulnerability {

    /*
        USER BALANCES
    
    mapping(address => uint256) public balances;

    /*
        TOTAL SYSTEM BALANCE
    
    uint256 public totalBalance;

    /*
    =====================================================
    SAFE DEPOSIT
    =====================================================
    

    function safeDeposit()
        external
        payable
    {

        /*
            STEP 1:
            Validate FIRST.
        
        require(
            msg.value > 0,
            "No ETH sent"
        );

        /*
            STEP 2:
            Update user balance.
        
        balances[msg.sender] += msg.value;

        /*
            STEP 3:
            Update global accounting.
        
        totalBalance += msg.value;
    }

    /*
    =====================================================
    SAFE WITHDRAW
    =====================================================

    Uses:
    Checks -> Effects -> Interactions
    

    function safeWithdraw(
        uint256 _amount
    )
        external
    {

        /*
            CHECKS
        
        require(
            balances[msg.sender] >= _amount,
            "Insufficient balance"
        );

        /*
            EFFECTS

            Update storage BEFORE external call.
        
        balances[msg.sender] -= _amount;

        totalBalance -= _amount;

        /*
            INTERACTION

            External ETH transfer LAST.
        
        payable(msg.sender).transfer(_amount);
    }

    /*
    =====================================================
    VULNERABLE WITHDRAW
    =====================================================

    INTENTIONALLY BAD ORDER
    

    function vulnerableWithdraw(
        uint256 _amount
    )
        external
    {

        /*
            CHECK:
            User balance validation.
        
        require(
            balances[msg.sender] >= _amount,
            "Insufficient balance"
        );

        /*
            DANGEROUS ORDER:

            External call BEFORE state update.
        
        payable(msg.sender).call{
            value: _amount
        }("");

        /*
            STATE UPDATED TOO LATE
        
        balances[msg.sender] -= _amount;

        totalBalance -= _amount;
    }

    /*
    =====================================================
    BAD REWARD ORDER
    ====================================================
    

    mapping(address => uint256) public rewards;

    function badRewardUpdate(
        uint256 _deposit
    )
        external
    {

        /*
            WRONG ORDER:

            Reward calculated BEFORE
            balance update.
        
        rewards[msg.sender] =
            balances[msg.sender] / 10;

        /*
            Balance updated later.
        
        balances[msg.sender] += _deposit;
    }

    /*
    =====================================================
    SAFE REWARD ORDER
    =====================================================
    

    function safeRewardUpdate(
        uint256 _deposit
    )
        external
    {

        /*
            Correct order:
            update balance first.
        
        balances[msg.sender] += _deposit;

        /*
            Reward uses NEW balance.
        
        rewards[msg.sender] =
            balances[msg.sender] / 10;
    }
}
*/
/*
=========================================================
IMPORTANT SECURITY UNDERSTANDING
=========================================================

BAD ORDER:
interaction before state update

=
classic reentrancy vulnerability.

=========================================================
SAFE WITHDRAW TRACE
=========================================================

CALL:
safeWithdraw(10)

=========================================================

STEP 1:
Balance check.

---------------------------------------------------------

STEP 2:
balances[Alice] -= 10

---------------------------------------------------------

STEP 3:
totalBalance -= 10

---------------------------------------------------------

STEP 4:
ETH transfer occurs LAST.

---------------------------------------------------------

SAFE:
state already updated.

=========================================================
VULNERABLE TRACE
=========================================================

CALL:
vulnerableWithdraw(10)

=========================================================

STEP 1:
Balance validated.

---------------------------------------------------------

STEP 2:
External ETH call occurs FIRST.

---------------------------------------------------------

DANGER:
Attacker contract can reenter NOW.

---------------------------------------------------------

STEP 3:
Balance reduced TOO LATE.

---------------------------------------------------------

ATTACK RESULT:
multiple withdrawals possible.

=========================================================
WHY REORDERING CREATES VULNERABILITIES
=========================================================

Security depends on:
WHEN state changes occur.

---------------------------------------------------------

Incorrect ordering may expose:
temporary inconsistent state.

=========================================================
REWARD BUG TRACE
=========================================================

INITIAL:

balances[Alice] = 100

---------------------------------------------------------

CALL:
badRewardUpdate(50)

---------------------------------------------------------

STEP 1:
Reward calculated.

100 / 10 = 10

---------------------------------------------------------

STEP 2:
Balance updated later.

balances[Alice] = 150

---------------------------------------------------------

FINAL:
Reward stale and incorrect.

=========================================================
REMIX TESTING
=========================================================

STEP 1:
Deploy contract

---------------------------------------------------------

STEP 2:
Call:
safeRewardUpdate(100)

---------------------------------------------------------

STEP 3:
Call:
rewards(your_address)

EXPECTED:
10

---------------------------------------------------------

STEP 4:
Deploy fresh contract

---------------------------------------------------------

STEP 5:
Call:
badRewardUpdate(100)

---------------------------------------------------------

STEP 6:
Call:
rewards(your_address)

EXPECTED:
0

---------------------------------------------------------

OBSERVE:
Wrong order caused stale calculation.

=========================================================
CRITICAL AUDITOR CONCEPT
=========================================================

Auditors care deeply about:

EXECUTION ORDER

---------------------------------------------------------

Because:
same code + different order
can create exploits.

=========================================================
CHECKS-EFFECTS-INTERACTIONS
=========================================================

SAFE PATTERN:

1. CHECKS
2. EFFECTS
3. INTERACTIONS

---------------------------------------------------------

Prevents:
many reentrancy attacks.

=========================================================
COMMON AUDIT RISKS
=========================================================

---------------------------------------------------------
1. EXTERNAL CALL BEFORE STATE UPDATE
---------------------------------------------------------

Classic reentrancy risk.

---------------------------------------------------------
2. STALE STATE READS
---------------------------------------------------------

Logic reads outdated values.

---------------------------------------------------------
3. INVARIANT VIOLATIONS
---------------------------------------------------------

Temporary inconsistent state exposed.

---------------------------------------------------------
4. PARTIAL EXECUTION ASSUMPTIONS
---------------------------------------------------------

Incorrect ordering breaks accounting.

=========================================================
GAS OBSERVATION
=========================================================

Incorrect ordering may:
waste gas during revert paths.

=========================================================
SECURITY / AUDITOR MINDSET
=========================================================

Auditors ask:

- What executes first?
- When is state updated?
- Are external calls dangerous?
- Can temporary state be abused?
- Are invariants preserved throughout execution?

=========================================================
ATTACK THINKING
=========================================================

ATTACK SCENARIO

Attacker deploys malicious contract.

---------------------------------------------------------

During vulnerableWithdraw():

1. receives ETH
2. fallback triggers
3. reenters withdraw()
4. balance still unchanged
5. steals funds repeatedly

=========================================================
REAL AUDITOR PROCESS
=========================================================

Auditors trace:

1. Exact execution order
2. Storage update timing
3. External interaction timing
4. Revert points
5. Reentrancy windows

=========================================================
MINI CHALLENGE
=========================================================

Modify contract so that:

1. Add external token transfer
2. Intentionally place it before
   balance reduction
3. Analyze vulnerability
4. Fix using CEI pattern

BONUS:
Implement nonReentrant modifier.

=========================================================
IMPORTANT CONCEPTS LEARNED
=========================================================

- Execution order is security critical
- Reordering logic can create vulnerabilities
- External calls before state updates are dangerous
- CEI pattern prevents many attacks
- Stale reads create incorrect accounting
- Temporary inconsistent state is exploitable
- Reentrancy depends heavily on ordering
- Auditors trace exact execution sequence
- Same logic with different order changes security
- Order dependency is fundamental to smart contract auditing

=========================================================
*/
/*
# Audit Report

## Title

Improper Execution Order Enables Reentrancy and Stale-State Vulnerabilities

## Severity

High

## Reason

Critical logic executes in an unsafe order, allowing external interactions before state updates and causing stale-state calculations.

---

## Location

* **Contract:** `ReorderLogicVulnerability`
* **Functions:**

  * `vulnerableWithdraw()`
  * `badRewardUpdate()`

---

## Vulnerability Description

The contract intentionally demonstrates dangerous execution ordering patterns.

The primary issue exists in `vulnerableWithdraw()` where an external ETH transfer occurs before internal balances are updated.

```solidity
payable(msg.sender).call{value: _amount}("");

balances[msg.sender] -= _amount;
```

This exposes a reentrancy window where an attacker can repeatedly re-enter the function before the balance reduction executes.

A secondary issue exists in `badRewardUpdate()` where rewards are calculated before balances are updated.

```solidity
rewards[msg.sender] =
    balances[msg.sender] / 10;

balances[msg.sender] += _deposit;
```

This causes stale-state reads and incorrect reward accounting.

---

## Impact

### Reentrancy Impact

An attacker may:

* repeatedly withdraw funds
* drain contract ETH
* corrupt accounting state
* bypass intended balance restrictions
* break protocol invariants

### Reward Accounting Impact

Incorrect execution ordering may:

* generate stale rewards
* produce inaccurate accounting
* distribute incorrect incentives
* break reward logic assumptions

If integrated into real-world DeFi systems such as:

* staking protocols
* vault systems
* lending markets
* AMMs
* reward distribution engines

the impact could become severe.

---

## Proof of Concept

## Vulnerable Withdraw Logic

```solidity
function vulnerableWithdraw(
    uint256 _amount
)
    external
{

    require(
        balances[msg.sender] >= _amount,
        "Insufficient balance"
    );

    /*
     EXTERNAL CALL FIRST
    
    payable(msg.sender).call{
        value: _amount
    }("");

    /*
        STATE UPDATED TOO LATE
    
    balances[msg.sender] -= _amount;

    totalBalance -= _amount;
}
```

---

## Reentrancy Attack Scenario

### Step 1

Attacker deposits ETH.

```solidity
safeDeposit();
```

---

### Step 2

Attacker calls:

```solidity
vulnerableWithdraw(1 ether);
```

---

### Step 3

During ETH reception, attacker fallback executes:

```solidity
fallback() external payable {
    target.vulnerableWithdraw(1 ether);
}
```

---

### Step 4

Because balances are not yet reduced, multiple withdrawals succeed.

---

## Stale Reward Logic

```solidity
function badRewardUpdate(
    uint256 _deposit
)
    external
{

    rewards[msg.sender] =
        balances[msg.sender] / 10;

    balances[msg.sender] += _deposit;
}
```

---

## Stale-State Example

### Initial State

```solidity
balances[Alice] = 100;
```

---

### Call

```solidity
badRewardUpdate(50);
```

---

### Result

```solidity
Reward = 10
Balance = 150
```

Expected reward should have been:

```solidity
150 / 10 = 15
```

---

## Root Cause

The vulnerabilities occur because:

* external interactions execute before state updates
* contract violates CEI principles
* stale values are used in calculations
* temporary inconsistent state becomes externally observable
* execution ordering does not preserve invariants

---

## Recommendation

Implement the Checks-Effects-Interactions (CEI) pattern consistently.

### Recommended Order

1. Checks
2. Effects
3. Interactions

Additionally:

* avoid stale-state calculations
* update balances before dependent logic
* use `nonReentrant` protection where appropriate
* validate all accounting invariants

---

# Patched Code
*/
contract ReorderLogicFixed {

    /*
        USER BALANCES
    */
    mapping(address => uint256) public balances;

    /*
        TOTAL SYSTEM BALANCE
    */
    uint256 public totalBalance;

    /*
        REWARD TRACKER
    */
    mapping(address => uint256) public rewards;

    /*
        REENTRANCY LOCK
    */
    bool private locked;

    /*
    =====================================================
    NON-REENTRANT MODIFIER
    =====================================================
    */

    modifier nonReentrant() {

        require(
            !locked,
            "Reentrancy detected"
        );

        locked = true;

        _;

        locked = false;
    }

    /*
    =====================================================
    SAFE DEPOSIT
    =====================================================
    */

    function safeDeposit()
        external
        payable
    {

        require(
            msg.value > 0,
            "No ETH sent"
        );

        balances[msg.sender] += msg.value;

        totalBalance += msg.value;
    }

    /*
    =====================================================
    FIXED WITHDRAW
    =====================================================

    Uses:
    CHECKS -> EFFECTS -> INTERACTIONS
    =====================================================
    */

    function safeWithdraw(
        uint256 _amount
    )
        external
        nonReentrant
    {

        /*
            CHECKS
        */
        require(
            balances[msg.sender] >= _amount,
            "Insufficient balance"
        );

        /*
            EFFECTS FIRST
        */
        balances[msg.sender] -= _amount;

        totalBalance -= _amount;

        /*
            INTERACTION LAST
        */
        (bool success, ) =
            payable(msg.sender).call{
                value: _amount
            }("");

        require(
            success,
            "Transfer failed"
        );
    }

    /*
    =====================================================
    FIXED REWARD UPDATE
    =====================================================
    */

    function safeRewardUpdate(
        uint256 _deposit
    )
        external
    {

        /*
            UPDATE BALANCE FIRST
        */
        balances[msg.sender] += _deposit;

        /*
            CALCULATE REWARD
            USING UPDATED STATE
        */
        rewards[msg.sender] =
            balances[msg.sender] / 10;
    }

    /*
        RECEIVE ETHER
    */
    receive() external payable {}
}


