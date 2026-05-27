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

/*contract ManualRevertExample {

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

    /*
    =====================================================
    REVERT WITHOUT MESSAGE
    ====================================================
    

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
Title: Missing Balance Validation in withdraw() Enables Unauthorized Withdrawls

Severity: Medium

Reason
Faliure to validate user balances before withdrawl can lead to incorrect accounting
and unauthorized fund withdrawl attempts.

Location
Contract: ManuelRevertExample
Functon: withdraw(uint256 _amount) (to be implemented)

Vulnerability Description
The contract currently tracks balances through the balances mapping but does not 
implement a withdrawl mechanism

If a withdraw() function is added without checking whether the caller has sufficient
balance, users may attempt to withdrawmore than their recorded balance


Example vulnerable implementation:
function withdraw(uint256 _amount) external {
    balances[msg.sender] -= _amount;
    totalCounter -= _amount;
}
Although Solifity 0.8+ automatically reverts on arithmetic underflow, relying solely
on underflow checks provides poor error reporting and can make business logic less explicit.

Impact
An attacker can attempt withdrawals exceeding their available balance.
Potiential consequences include:
Failed transactions due to underflow
Poor user experience due to generic panic errors
Incorrect accounting logic in future protocol upgrades
Increased debugging complexity

If integrated with token transfers or treasury assets, improper validation could introduce severe financial risks.

Proof of Concept
Step 1: Deposit Funds
dangerousDeposit(5);

State:

balances[user] = 5
totalCounter = 5
Step 2: Attempt Excessive Withdrawal
withdraw(10);

Without proper validation:

balances[user] -= 10;

The operation triggers an arithmetic underflow revert instead of a meaningful protocol error.

Root Cause

The withdrawal logic does not verify that:

balances[msg.sender] >= _amount

before updating storage.

No custom error or validation mechanism exists to enforce balance constraints.

Recommendation

Implement explicit balance validation using a custom error.

Example:

if (balances[msg.sender] < _amount) {
    revert InsufficientBalance(
        _amount,
        balances[msg.sender]
    );
}

Custom errors are more gas-efficient than revert strings and provide clearer failure information.

Patched Code
*/
contract ManualRevertExample {

    /*
        STORAGE VARIABLES
    */
    uint256 public totalCounter;

    mapping(address => uint256) public balances;

    /*
    =====================================================
    CUSTOM ERRORS
    =====================================================
    */

    error AmountExceedsLimit(uint256 amount);

    error InsufficientBalance(
        uint256 requested,
        uint256 available
    );

    error OddNumberRejected(uint256 number);

    error CorruptedState();

    /*
    =====================================================
    DEPOSIT
    =====================================================
    */

    function dangerousDeposit(
        uint256 _amount
    )
        external
    {
        balances[msg.sender] += _amount;
        totalCounter += _amount;

        if (_amount > 10) {
            revert AmountExceedsLimit(_amount);
        }

        _checkInvariant();
    }

    /*
    =====================================================
    WITHDRAW
    =====================================================
    */

    function withdraw(
        uint256 _amount
    )
        external
    {
        uint256 userBalance =
            balances[msg.sender];

        if (userBalance < _amount) {
            revert InsufficientBalance(
                _amount,
                userBalance
            );
        }

        balances[msg.sender] =
            userBalance - _amount;

        totalCounter -= _amount;

        _checkInvariant();
    }

    /*
    =====================================================
    CUSTOM ERROR VERSION
    =====================================================
    */

    function onlyEven(
        uint256 _number
    )
        external
        pure
        returns (string memory)
    {
        if (_number % 2 != 0) {
            revert OddNumberRejected(
                _number
            );
        }

        return "Even number accepted";
    }

    /*
    =====================================================
    REQUIRE VERSION
    =====================================================
    */

    function onlyEvenRequire(
        uint256 _number
    )
        external
        pure
        returns (string memory)
    {
        require(
            _number % 2 == 0,
            "Odd number rejected"
        );

        return "Even number accepted";
    }

    /*
    =====================================================
    INVARIANT CHECK
    =====================================================
    */

    function _checkInvariant()
        internal
        view
    {
        if (
            balances[msg.sender] >
            totalCounter
        ) {
            revert CorruptedState();
        }
    }
}