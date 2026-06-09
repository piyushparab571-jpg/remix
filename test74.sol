// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/*
=========================================================
PRACTICAL: Call function with zero values
CONCEPT: Edge-case behavior
=========================================================

OBJECTIVE

- Understand how contracts behave with zero inputs
- Learn why edge cases matter in auditing
- Observe storage + logic behavior with 0
- Think like auditor checking boundary conditions

---------------------------------------------------------
CORE IDEA
---------------------------------------------------------

Zero is NOT "nothing" in Solidity.

---------------------------------------------------------

0 is a valid input and can still:

- change state
- trigger logic
- affect storage
- break assumptions

---------------------------------------------------------
IMPORTANT UNDERSTANDING
---------------------------------------------------------

Many bugs happen because developers assume:

"value > 0 always"

---------------------------------------------------------
WHY THIS MATTERS
---------------------------------------------------------

Zero-value edge cases can cause:

- logic bypass
- division errors
- unnecessary state changes
- incorrect accounting

---------------------------------------------------------
AUDITOR FOCUS
---------------------------------------------------------

Auditors check:

- zero input handling
- boundary conditions
- default values
- uninitialized logic
- false assumptions

=========================================================
ZERO VALUE CONTRACT
=========================================================
*/
/*
contract ZeroValueEdgeCase {

    /*
        STORAGE VARIABLES
    
    uint256 public total;
    uint256 public lastInput;
    uint256 public counter;

    /*
        STORAGE ARRAY
    
    uint256[] public values;

    /*
    =====================================================
    FUNCTION: ADD VALUE (INCLUDING ZERO)
    =====================================================
    

    function addValue(uint256 value)
        external
    {

        /*
        =================================================
        EDGE CASE: ZERO INPUT
        =================================================
        

        lastInput = value;

        /*
            Even if value = 0,
            state is still updated.
        

        total += value;

        /*
            Storage write ALWAYS happens.
        
        values.push(value);

        /*
            Counter always increases,
            even for zero.
        
        counter++;
    }

    /*
    =====================================================
    SAFE VERSION (ZERO CHECK)
    =====================================================
    
    function addValueSafe(uint256 value)
        external
    {

        /*
            Ignore zero values.
        
        require(value > 0, "Zero not allowed");

        lastInput = value;
        total += value;
        values.push(value);
        counter++;
    }

    /*
    =====================================================
    ZERO TEST FUNCTION
    =====================================================
    

    function testZero()
        external
    {

        /*
            Explicit zero input calls.
        
        addValue(0);
        addValue(0);
        addValue(0);
    }

    /*
    =====================================================
    GET ARRAY LENGTH
    =====================================================
    

    function getLength()
        external
        view
        returns (uint256)
    {

        return values.length;
    }
}
*/
/*
=========================================================
EXECUTION FLOW
=========================================================

STEP 1:
Deploy ZeroValueEdgeCase

=========================================================
TRACE:
addValue(0)
=========================================================

STEP 1:
value = 0

---------------------------------------------------------

lastInput = 0

=========================================================
STEP 2
=========================================================

total += 0

---------------------------------------------------------

NO change in total

=========================================================
STEP 3
=========================================================

values.push(0)

---------------------------------------------------------

IMPORTANT:
ZERO is still stored in blockchain.

=========================================================
STEP 4
=========================================================

counter++

---------------------------------------------------------

counter increases even for zero input.

=========================================================
FINAL STATE AFTER 3 CALLS
=========================================================

CALL:
testZero()

---------------------------------------------------------
counter
---------------------------------------------------------

= 3

---------------------------------------------------------
values
---------------------------------------------------------

[0, 0, 0]

---------------------------------------------------------
total
---------------------------------------------------------

= 0

---------------------------------------------------------
lastInput
---------------------------------------------------------

= 0

=========================================================
IMPORTANT OBSERVATION
=========================================================

Zero STILL causes:

- storage writes
- gas consumption
- state updates

=========================================================
SAFE VERSION BEHAVIOR
=========================================================

CALL:
addValueSafe(0)

=========================================================

STEP 1:
require(value > 0)

---------------------------------------------------------

value = 0 → REVERT

=========================================================
RESULT
=========================================================

Transaction fails BEFORE state change.

=========================================================
IMPORTANT SECURITY CONCEPT
=========================================================

Zero values are:

---------------------------------------------------------
VALID INPUTS
---------------------------------------------------------

BUT often:

---------------------------------------------------------
LOGICALLY IGNORED BY SYSTEMS
---------------------------------------------------------

=========================================================
COMMON BUGS FROM ZERO VALUES
=========================================================

---------------------------------------------------------
1. DIVISION BY ZERO
---------------------------------------------------------

if (a / value)

---------------------------------------------------------

---------------------------------------------------------
2. LOGIC BYPASS
---------------------------------------------------------

if (value > 0) { ... }

---------------------------------------------------------

---------------------------------------------------------
3. UNEXPECTED STORAGE WRITE
---------------------------------------------------------

storing useless zero values

---------------------------------------------------------

---------------------------------------------------------
4. INCORRECT ACCOUNTING
---------------------------------------------------------

totals not updated correctly

=========================================================
ATTACK THINKING
=========================================================

Attackers may:

- send zero values repeatedly
- bloat storage arrays
- trigger unnecessary gas costs
- exploit missing zero checks

=========================================================
SECURITY / AUDITOR MINDSET
=========================================================

Auditors check:

- is zero handled?
- does zero cause state change?
- can zero break logic?
- is validation missing?

=========================================================
REAL AUDITOR PROCESS
=========================================================

Auditors test:

---------------------------------------------------------
BOUNDARY INPUTS:
0, 1, max uint256
---------------------------------------------------------

=========================================================
BEST PRACTICES
=========================================================

- Validate inputs when needed
- Handle zero explicitly
- Avoid storing useless values
- Document zero behavior
- Test boundary conditions

=========================================================
MINI CHALLENGE
=========================================================

Modify contract:

1. Reject zero and negative-like edge cases
2. Compare gas usage with/without zero validation
3. Add event logging instead of storage push
4. Handle max uint256 input safely

BONUS:
Create full edge-case testing suite.

=========================================================
IMPORTANT CONCEPTS LEARNED
=========================================================

- Zero is a valid Solidity value
- Zero still consumes gas if stored
- State updates happen even for zero
- Edge cases cause real vulnerabilities
- Input validation is critical
- Auditors test boundary conditions
- Storage grows even with useless values
- Safe design avoids unnecessary writes
- Zero can break assumptions
- Robust contracts handle all inputs

=========================================================
*/
/*
Audit Report
Title
Improper Handling of Zero Values and Maximum integer inputs

Severity: Medium

Reason
The contract allows zero-value inputs that still modify state and consume gas.
Additionally, repeated additions near type(uint256).max can revert due to
arithmetic overflow.

Location
Contract: ZeroValueEdgeCase
Functions: addValue(uint256 value) , addValueSafe(uint256 value)

Vulnerability Description
The original implementation accepts zero values:
total += value;
values.push(value);
counter++;
Even when value == 0, storage writes occur.

The contract also lacks explicit validation for maximum values that may cause
overflow when addeed to total.

Impact
- Unnecessary gas consumption
- Sorage bloat
- Potential transaction reverts near uint256 limits
- Inefficient handling of edge causes

Root Cause
Missing validation checks:
value > 0
and lack of overflow pre-checked before:
total += value;

Recommendation
- Reject Zero input
- Add overflow protection for maximum values.
- Measure gas usage for validate vs non-validated execution paths.

Patched code:
*/
contract ZeroValueEdgeCase {
    /*
    STORAGE VARIABLES
    */
    uint256 public total;
    uint256 public lastInput;
    uint256 public counter;
    /*
    GAS TRACKING
    */
    uint256 public gasWithoutValidation;
    uint256 public gasWithValidation;
    /*
    EVENT LOGGING
    */
    event ValueAdded(
        address indexed user,
        uint256 value
    );
    /*
    ==================================
    WITHOUT VALIDATION
    ==================================
    */
       function addValue(
        uint256 value
    )
        external
    {
        uint256 startGas =
            gasleft();

        lastInput = value;
        total += value;
        counter++;

        emit ValueAdded(
            msg.sender,
            value
        );

        gasWithoutValidation =
            startGas - gasleft();
    }

    /*
    =======================
    SAFE VERSION
    =======================
    */
    
    function addValueSafe(
        uint256 value
    )
        external
    {
        uint256 startGas =
            gasleft();

        // 1. Reject zero / negative-like edge case
        require(
            value != 0,
            "Zero not allowed"
        );

        // 4. Safe max uint256 handling
        require(
            total <=
            type(uint256).max - value,
            "Overflow risk"
        );

        lastInput = value;
        total += value;
        counter++;

        // 3. Event logging instead of storage push
        emit ValueAdded(
            msg.sender,
            value
        );

        // 2. Gas comparison
        gasWithValidation =
            startGas - gasleft();
    }

    /*
    =====================================================
    GAS COMPARISON
    =====================================================
    */
    function compareGas()
        external
        view
        returns (
            uint256 withoutValidation,
            uint256 withValidation
        )
    {
        return (
            gasWithoutValidation,
            gasWithValidation
        );
    }

    /*
    =====================================================
    MAX UINT TEST
    =====================================================
    */
    function maxUint()
        external
        pure
        returns (uint256)
    {
        return
            type(uint256).max;
    }
}