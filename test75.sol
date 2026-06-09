// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/*
=========================================================
PRACTICAL: Call function with max uint
CONCEPT: Boundary testing (audit-focused)
=========================================================

OBJECTIVE

- Test system behavior at extreme input limits
- Detect overflow assumptions and logic breaks
- Observe gas impact of boundary values
- Simulate real audit-style fuzz inputs

---------------------------------------------------------
CORE IDEA
---------------------------------------------------------

Max uint256 = extreme boundary condition.

It is used to test:
- arithmetic safety
- comparison logic
- storage correctness
- gas behavior

=========================================================
CONTRACT
=========================================================
*/
/*
contract MaxUintBoundaryTest {

    uint256 public lastValue;
    uint256 public sum;
    uint256 public calls;

    event ValueReceived(uint256 value);

    /*
    =====================================================
    NORMAL FUNCTION
    =====================================================
    

    function set(uint256 value) external {
        lastValue = value;
        sum += value;
        calls++;

        emit ValueReceived(value);
    }

    /*
    =====================================================
    BOUNDARY TEST: MAX UINT
    =====================================================
    

    function testMaxUint() external {
        uint256 max = type(uint256).max;

        set(max);
    }

    /*
    =====================================================
    STRESS BOUNDARY TEST
    =====================================================
    

    function stressMax(uint256 n) external {
        uint256 max = type(uint256).max;

        for (uint256 i = 0; i < n; i++) {
            set(max);
        }
    }

    /*
    =====================================================
    SAFE CHECK VERSION
    =====================================================
    

    function safeSet(uint256 value) external {
        require(value < type(uint256).max, "Max not allowed");

        lastValue = value;
        sum += value;
        calls++;
    }
}
*/
/*
=========================================================
EXECUTION TRACE
=========================================================

CALL:
testMaxUint()

---------------------------------------------------------

STEP 1:
value = 2^256 - 1

---------------------------------------------------------

STEP 2:
lastValue = max uint256
(sum storage write happens)

---------------------------------------------------------

IMPORTANT:

Solidity 0.8+ prevents overflow automatically.

So:
sum += value is SAFE

BUT gas cost is still high due to large number.

=========================================================
STRESS TEST TRACE
=========================================================

CALL:
stressMax(5)

---------------------------------------------------------

Each iteration:

- set(max)
- storage write
- event emission
- counter increment

---------------------------------------------------------

Total effect:

5 full state updates

=========================================================
IMPORTANT OBSERVATIONS
=========================================================

1. MAX VALUE DOES NOT BREAK ARITHMETIC
---------------------------------------------------------
No overflow occurs.

2. GAS IS STILL CONSUMED NORMALLY
---------------------------------------------------------
Size of number does NOT reduce gas.

3. LOGIC MAY STILL BREAK
---------------------------------------------------------
Example issues:
- comparisons like value < threshold
- incorrect assumptions about range
- UI misinterpretation

=========================================================
REAL AUDITOR INSIGHT
=========================================================

Auditors do NOT just test “normal values”.

They test:

- 0
- 1
- max uint256
- max-1
- random fuzz inputs

Because bugs appear at boundaries.

=========================================================
COMMON VULNERABILITIES FOUND HERE
=========================================================

- incorrect upper-bound checks
- overflow assumptions in legacy logic
- mispriced calculations
- incorrect fee systems
- broken reward distributions

=========================================================
GAS INSIGHT
=========================================================

Max uint does NOT significantly increase gas by itself.

BUT:
- repeated storage writes dominate cost
- loops + max values = worst-case scenario testing

=========================================================
KEY TAKEAWAY
=========================================================

Max uint testing is NOT about breaking arithmetic.

It is about breaking assumptions.

=========================================================
MINI CHALLENGE
=========================================================

Modify contract:

1. Reject max uint automatically
2. Compare gas:
   - normal value (100)
   - max value
3. Add batch processing for max inputs
4. Simulate fuzz testing (random values)

=========================================================
IMPORTANT CONCEPTS LEARNED
=========================================================

- max uint256 = boundary edge case
- Solidity 0.8 prevents overflow automatically
- logic bugs still happen at boundaries
- gas cost is independent of value size
- auditors always test extreme inputs
- stress testing exposes hidden assumptions
- real failures come from logic, not arithmetic

=========================================================
*/
/*
Audit Report
Title
Improper Handling Of uint256.max Boundary Values

Severity: Medium

Reason
The contract allows type(uint256).max to be passed into set(). while solidity 0.8+
prevents overflows by reverting, repeated use of maximum values can cause
unexpecte transaction failures and wasted gas.

Location
Contract: MaxUintBoundaryTest
Function: set(uint256 value), testMaxUint() , stressMax(uint256 n)

Vulnerability Description
The original implementation accepts:
type(uint256).max
and performs:
sum += value;
if sum already contains a non-zero value, adding uint256.max causes an overflow and reverts.

Impact
- Unexpected transaction reverts
- Wastes gas
- Failed batch operations
- Poor handling of boundary values

Root Cause
Missing validation before:
sum += value;
and acceptance of:
type(uint256).max

Recommendation
- Reject uint256.max automatically.
- Compare gas usage for normal and max-value paths.
- Add batch processing with validation
- Simulate fuzz testing using pseudo-random values.

Patched code:
*/
contract MaxUintBoundaryTest {

    uint256 public lastValue;
    uint256 public sum;
    uint256 public calls;

    uint256 public normalGas;
    uint256 public maxGas;

    event ValueReceived(uint256 value);
    event FuzzValue(uint256 value);

    /*
    =====================================================
    REJECT MAX UINT AUTOMATICALLY
    =====================================================
    */
    function set(uint256 value)
        public
    {
        require(
            value != type(uint256).max,
            "Max uint not allowed"
        );

        lastValue = value;
        sum += value;
        calls++;

        emit ValueReceived(value);
    }

    /*
    =====================================================
    GAS TEST: NORMAL VALUE (100)
    =====================================================
    */
    function testNormalGas()
        external
    {
        uint256 startGas =
            gasleft();

        set(100);

        normalGas =
            startGas - gasleft();
    }

    /*
    =====================================================
    GAS TEST: MAX VALUE
    =====================================================
    */
    function testMaxGas()
        external
    {
        uint256 startGas =
            gasleft();

        try this.set(
            type(uint256).max
        ) {

        } catch {

        }

        maxGas =
            startGas - gasleft();
    }

    /*
    =====================================================
    BATCH PROCESSING
    =====================================================
    */
    function batchSet(
        uint256[] calldata values
    )
        external
    {
        for (
            uint256 i = 0;
            i < values.length;
            i++
        ) {
            if (
                values[i] !=
                type(uint256).max
            ) {
                set(values[i]);
            }
        }
    }

    /*
    =====================================================
    FUZZ TEST SIMULATION
    =====================================================
    */
    function fuzzTest(
        uint256 iterations
    )
        external
    {
        for (
            uint256 i = 0;
            i < iterations;
            i++
        ) {
            uint256 randomValue =
                uint256(
                    keccak256(
                        abi.encodePacked(
                            block.timestamp,
                            block.prevrandao,
                            i
                        )
                    )
                );

            emit FuzzValue(
                randomValue
            );
        }
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
            uint256 normal,
            uint256 maxValue
        )
    {
        return (
            normalGas,
            maxGas
        );
    }
}