// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/*
=========================================================
PRACTICAL: Trigger revert manually
CONCEPT: Full rollback
=========================================================

OBJECTIVE

- Learn how revert() works
- Understand manual transaction rollback
- Learn EVM atomicity behavior
- Understand state restoration after revert

---------------------------------------------------------
CORE IDEA
---------------------------------------------------------

revert() immediately:
- stops execution
- undoes ALL state changes
- returns remaining gas

---------------------------------------------------------
IMPORTANT UNDERSTANDING
---------------------------------------------------------

Even if storage was modified BEFORE revert():

ALL changes are undone.

---------------------------------------------------------
WHY THIS MATTERS
---------------------------------------------------------

Manual revert is critical for:

- validation
- invariant enforcement
- protocol safety
- emergency protection

---------------------------------------------------------
REAL-WORLD USAGE
---------------------------------------------------------

revert() used in:

- DeFi protocols
- ERC20 tokens
- staking systems
- governance logic
- liquidation engines
- vault protections

---------------------------------------------------------
AUDITOR FOCUS
---------------------------------------------------------

Auditors inspect:

- revert conditions
- rollback guarantees
- partial execution risks
- state consistency
- revert message clarity

=========================================================
*/
/*
contract ManualRevertExample {

    /*
        STORAGE VARIABLES
    
    uint256 public totalCounter;

    mapping(address => uint256) public balances;

    /*
    =====================================================
    MANUAL REVERT EXAMPLE
    =====================================================
    

    function dangerousDeposit(
        uint256 _amount
    )
        external
    {

        /*
            STEP 1:
            Update storage.

            TEMPORARY until transaction succeeds.
        
        balances[msg.sender] += _amount;

        totalCounter += _amount;

        /*
            STEP 2:
            Manual revert condition.
        
        if (_amount > 10) {

            /*
                MANUAL REVERT

                ALL earlier state changes rollback.
            
            revert("Amount exceeds limit");
        }

        /*
            If execution reaches here:
            transaction succeeds.
        
    }

    /*
    =====================================================
    CONDITIONAL REVERT EXAMPLE
    =====================================================
    

    function onlyEven(
        uint256 _number
    )
        external
        pure
        returns (string memory)
    {

        /*
            Reject odd numbers.
        
        if (_number % 2 != 0) {

            revert("Odd number rejected");
        }

        return "Even number accepted";
    }

    
    =====================================================
    REVERT WITHOUT MESSAGE
    =====================================================
    

    function silentRevert(
        bool _shouldFail
    )
        external
        pure
    {

        if (_shouldFail) {

            /*
                Revert without reason string.
            
            revert();
        }
    }
}
*/
/*
=========================================================
EXECUTION FLOW
=========================================================

INITIAL STATE

balances[Alice] = 0

totalCounter = 0

=========================================================
TRACE:
dangerousDeposit(5)
=========================================================

---------------------------------------------------------
STEP 1
---------------------------------------------------------

balances[Alice] += 5

TEMP VALUE:
5

---------------------------------------------------------

totalCounter += 5

TEMP VALUE:
5

---------------------------------------------------------
STEP 2
---------------------------------------------------------

if (_amount > 10)

CHECK:
5 > 10

RESULT:
false

---------------------------------------------------------

NO REVERT OCCURS

---------------------------------------------------------

TRANSACTION SUCCEEDS

---------------------------------------------------------

FINAL STATE:

balances[Alice] = 5

totalCounter = 5

=========================================================
REVERT TRACE
=========================================================

CALL:
dangerousDeposit(50)

=========================================================

---------------------------------------------------------
STEP 1
---------------------------------------------------------

balances[Alice] += 50

TEMP VALUE:
55

---------------------------------------------------------

totalCounter += 50

TEMP VALUE:
55

---------------------------------------------------------
STEP 2
---------------------------------------------------------

CHECK:
50 > 10

RESULT:
true

---------------------------------------------------------

revert("Amount exceeds limit")

---------------------------------------------------------

TRANSACTION STOPS IMMEDIATELY

---------------------------------------------------------

ALL STATE CHANGES ROLLBACK

---------------------------------------------------------

FINAL STATE:

balances[Alice] = 5

totalCounter = 5

---------------------------------------------------------

IMPORTANT:
Temporary updates disappear.

=========================================================
REMIX TESTING
=========================================================

STEP 1:
Deploy contract

---------------------------------------------------------

STEP 2:
Call:
dangerousDeposit(5)

---------------------------------------------------------

STEP 3:
Call:
balances(your_address)

EXPECTED:
5

---------------------------------------------------------

STEP 4:
Call:
dangerousDeposit(50)

EXPECTED:
Revert

---------------------------------------------------------

STEP 5:
Call:
balances(your_address)

EXPECTED:
Still 5

---------------------------------------------------------

STEP 6:
Call:
totalCounter()

EXPECTED:
Still 5

---------------------------------------------------------

OBSERVE:
Failed transaction changed NOTHING.

---------------------------------------------------------

STEP 7:
Call:
onlyEven(4)

EXPECTED:
"Even number accepted"

---------------------------------------------------------

STEP 8:
Call:
onlyEven(5)

EXPECTED:
Revert

=========================================================
IMPORTANT REVERT UNDERSTANDING
=========================================================

revert() immediately:

- stops execution
- undoes state changes
- restores previous state

=========================================================
EVM ATOMICITY
=========================================================

Ethereum transactions are:

ATOMIC

---------------------------------------------------------

Meaning:

Either:
- everything succeeds

OR:
- everything reverts

=========================================================
REVERT VS RETURN
=========================================================

---------------------------------------------------------
RETURN
---------------------------------------------------------

- stops execution
- keeps state changes

---------------------------------------------------------
REVERT
---------------------------------------------------------

- stops execution
- undoes state changes

=========================================================
REVERT VS REQUIRE
=========================================================

require(condition, "msg")

is internally similar to:

if (!condition) {
    revert("msg");
}

=========================================================
COMMON AUDIT RISKS
=========================================================

---------------------------------------------------------
1. MISSING REVERTS
---------------------------------------------------------

Invalid state may persist.

---------------------------------------------------------
2. LATE REVERTS
---------------------------------------------------------

Gas wasted after expensive computation.

---------------------------------------------------------
3. EXTERNAL CALL BEFORE REVERT
---------------------------------------------------------

Dangerous execution ordering.

---------------------------------------------------------
4. UNCLEAR ERROR REASONS
---------------------------------------------------------

Poor debugging visibility.

=========================================================
GAS OBSERVATION
=========================================================

revert():
refunds REMAINING gas only.

---------------------------------------------------------

Gas already consumed:
is NOT recovered.

=========================================================
SECURITY / AUDITOR MINDSET
=========================================================

Auditors ask:

- What conditions trigger revert?
- Does rollback fully restore state?
- Can partial execution escape?
- Are invariants protected?
- Are revert reasons meaningful?

=========================================================
ATTACK THINKING
=========================================================

ATTACK SCENARIO

Attacker intentionally triggers:
expensive computation + revert.

Result:
gas griefing DOS.

---------------------------------------------------------

ANOTHER RISK

Improper external-call ordering
before revert may expose vulnerabilities.

=========================================================
REAL AUDITOR PROCESS
=========================================================

Auditors trace:

1. State before revert
2. State after revert
3. Execution ordering
4. External interactions
5. Rollback guarantees

=========================================================
MINI CHALLENGE
=========================================================

Modify contract so that:

1. Add withdraw() function
2. Revert on insufficient balance
3. Add custom errors
4. Compare gas with require()

BONUS:
Implement invariant check:
that reverts on corruption.

=========================================================
IMPORTANT CONCEPTS LEARNED
=========================================================

- revert() manually stops execution
- revert() undoes all state changes
- Ethereum transactions are atomic
- Temporary storage updates disappear after revert
- revert() and require() are closely related
- return() and revert() behave differently
- Reverted transactions still consume gas
- Execution order matters heavily
- Auditors verify rollback guarantees
- Full rollback is critical for protocol safety

=========================================================
*/
/*
Audit Report

Title: Missing Access Control in dangerousDeposit()

Severity: Medium

Reason

Unauthorized users can modify protocol state variables without any authorization restrictions.

Location

Contract: ManualRevertExample
Function: dangerousDeposit(uint256 _amount)

Vulnerability Description

The dangerousDeposit() function allows any external user to increase both the balances mapping and the totalCounter state variable because no access control mechanism is implemented.

function dangerousDeposit(uint256 _amount) external {
    balances[msg.sender] += _amount;
    totalCounter += _amount;

    if (_amount > 10) {
        revert("Amount exceeds limit");
    }
}

Any user can call this function and alter protocol accounting values.

Impact

An attacker can arbitrarily manipulate protocol state by increasing:

balances[msg.sender]
totalCounter

If these variables are later used for:

accounting logic
reward calculations
governance voting power
treasury management
protocol configuration

then unauthorized users may gain unintended influence over protocol behavior.

Proof of Concept
Step 1: Deploy Contract

Deploy the ManualRevertExample contract.

Step 2: Legitimate User Calls
dangerousDeposit(5);

State:

balances[userA] = 5
totalCounter = 5
Step 3: Attacker Calls
dangerousDeposit(10);

State:

balances[attacker] = 10
totalCounter = 15

The protocol state changes successfully despite no authorization.

Root Cause

The function is declared external without implementing any authorization mechanism.

No validation exists to restrict callers:

function dangerousDeposit(uint256 _amount)
    external
{
    ...
}

No ownership checks or role-based permissions are enforced.

Recommendation

Restrict access using an ownership or role-based access control mechanism.

Example:

require(msg.sender == owner, "Not owner");

Alternatively, use OpenZeppelin's Ownable contract.

Patched Code
*/
contract ManualRevertExample {

    address public owner;

    uint256 public totalCounter;

    mapping(address => uint256) public balances;

    constructor() {
        owner = msg.sender;
    }

    function dangerousDeposit(
        uint256 _amount
    )
        external
    {
        require(
            msg.sender == owner,
            "Not owner"
        );

        balances[msg.sender] += _amount;

        totalCounter += _amount;

        if (_amount > 10) {
            revert("Amount exceeds limit");
        }
    }
}