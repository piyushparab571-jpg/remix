// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/*
=========================================================
PRACTICAL: Store many array values
CONCEPT: Storage gas cost
=========================================================

OBJECTIVE

- Learn why storage is expensive
- Understand array storage gas scaling
- Observe gas growth with many writes
- Think like auditor about storage-heavy logic

---------------------------------------------------------
CORE IDEA
---------------------------------------------------------

Every storage write costs gas.

---------------------------------------------------------

Writing MANY array values =
VERY expensive execution.

---------------------------------------------------------
IMPORTANT UNDERSTANDING
---------------------------------------------------------

Storage is permanent blockchain data.

---------------------------------------------------------

Permanent storage is among the MOST
expensive EVM operations.

---------------------------------------------------------
WHY THIS MATTERS
---------------------------------------------------------

Storage-heavy contracts may become:

- too expensive
- DOS vulnerable
- inefficient
- unscalable

---------------------------------------------------------
REAL-WORLD USAGE
---------------------------------------------------------

Storage arrays appear in:

- NFT ownership
- staking lists
- governance records
- reward systems
- order books
- protocol accounting

---------------------------------------------------------
AUDITOR FOCUS
---------------------------------------------------------

Auditors inspect:

- storage-heavy loops
- array growth
- scalability
- gas DOS risks
- unnecessary writes

=========================================================
STORAGE ARRAY CONTRACT
=========================================================
*/
/*

contract StorageGasCost {

    /*
        LARGE STORAGE ARRAY
    
    uint256[] public storedValues;

    /*
        TRACK TOTAL WRITES
    
    uint256 public totalWrites;

    /*
        TRACK FINAL VALUE
    
    uint256 public lastStoredValue;

    /*
    =====================================================
    STORE MANY VALUES
    =====================================================
    

    function storeManyValues()
        external
    {

        /*
        =================================================
        LOOP 100 TIMES
        =================================================

        Every iteration performs:
        STORAGE WRITE.
        

        for (
            uint256 i = 0;
            i < 100;
            i++
        ) {

            /*
            =============================================
            VERY EXPENSIVE OPERATION
            =============================================

            Push value into storage array.
            

            storedValues.push(i);

            /*
                Another storage write.
            
            totalWrites++;

            /*
                Another storage write.
            
            lastStoredValue = i;
        }
    }

    /*
    =====================================================
    CHEAPER MEMORY VERSION
    =====================================================
    

    function useMemoryArray()
        external
        pure
        returns (uint256[] memory)
    {

        /*
            Memory array exists temporarily.

            MUCH cheaper than storage.
        
        uint256[] memory temp =
            new uint256[](100);

        /*
            Fill memory array.
        
        for (
            uint256 i = 0;
            i < 100;
            i++
        ) {

            temp[i] = i;
        }

        /*
            Return temporary memory array.
        
        return temp;
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

        return storedValues.length;
    }
}
*/
/*
=========================================================
EXECUTION FLOW
=========================================================

STEP 1:
Deploy StorageGasCost

=========================================================
TRACE:
storeManyValues()
=========================================================

STEP 1:
Loop starts.

---------------------------------------------------------

i = 0

=========================================================
STEP 2
=========================================================

Storage write executes:

storedValues.push(0)

=========================================================
IMPORTANT
=========================================================

This writes permanently to blockchain storage.

---------------------------------------------------------

VERY expensive operation.

=========================================================
STEP 3
=========================================================

Another storage write:

totalWrites++

=========================================================
STEP 4
=========================================================

Another storage write:

lastStoredValue = 0

=========================================================
STEP 5
=========================================================

Loop repeats.

---------------------------------------------------------

i = 1

=========================================================
STEP 6
=========================================================

Again:

---------------------------------------------------------

storedValues.push(1)

---------------------------------------------------------

totalWrites++

---------------------------------------------------------

lastStoredValue = 1

=========================================================
LOOP CONTINUES
=========================================================

This repeats:

100 TIMES.

=========================================================
FINAL RESULT
=========================================================

---------------------------------------------------------
storedValues.length
---------------------------------------------------------

100

---------------------------------------------------------
totalWrites
---------------------------------------------------------

100

---------------------------------------------------------
lastStoredValue
---------------------------------------------------------

99

=========================================================
IMPORTANT GAS UNDERSTANDING
=========================================================

Gas usage becomes VERY HIGH because:

---------------------------------------------------------
100 STORAGE ARRAY WRITES
---------------------------------------------------------

occur.

=========================================================
MOST EXPENSIVE LINE
=========================================================

THIS:

storedValues.push(i)

=========================================================
WHY STORAGE IS EXPENSIVE
=========================================================

Blockchain storage is:

---------------------------------------------------------
PERMANENT
---------------------------------------------------------

and

---------------------------------------------------------
REPLICATED ACROSS ALL NODES
---------------------------------------------------------

=========================================================
MEMORY VERSION TRACE
=========================================================

CALL:
useMemoryArray()

=========================================================

STEP 1:
Memory array created.

---------------------------------------------------------

Temporary allocation only.

=========================================================
STEP 2
=========================================================

Values stored in memory.

---------------------------------------------------------

NOT permanent blockchain storage.

=========================================================
STEP 3
=========================================================

Function returns array.

---------------------------------------------------------

Memory automatically destroyed
after execution.

=========================================================
IMPORTANT COMPARISON
=========================================================

---------------------------------------------------------
STORAGE ARRAY
---------------------------------------------------------

- permanent
- expensive
- persists on blockchain

=========================================================

---------------------------------------------------------
MEMORY ARRAY
---------------------------------------------------------

- temporary
- cheaper
- destroyed after execution

=========================================================
REMIX TESTING
=========================================================

STEP 1:
Deploy contract

=========================================================
TEST 1
=========================================================

Call:
storeManyValues()

---------------------------------------------------------

Observe:
HIGH gas usage

=========================================================
STEP 2
=========================================================

Check:
getLength()

EXPECTED:
100

=========================================================
TEST 2
=========================================================

Call:
useMemoryArray()

---------------------------------------------------------

Observe:
MUCH lower gas usage

=========================================================
IMPORTANT SECURITY CONCEPT
=========================================================

Storage growth increases:

---------------------------------------------------------
EXECUTION COST
---------------------------------------------------------

and

---------------------------------------------------------
SCALABILITY RISK
---------------------------------------------------------

=========================================================
COMMON AUDIT RISKS
=========================================================

---------------------------------------------------------
1. UNBOUNDED STORAGE GROWTH
---------------------------------------------------------

Arrays grow forever.

---------------------------------------------------------
2. STORAGE WRITES INSIDE LOOPS
---------------------------------------------------------

Huge gas consumption.

---------------------------------------------------------
3. GAS DOS
---------------------------------------------------------

Functions become uncallable.

---------------------------------------------------------
4. UNNECESSARY STORAGE
---------------------------------------------------------

Wasted blockchain resources.

=========================================================
IMPORTANT ATTACK THINKING
=========================================================

Attackers may:

- enlarge arrays
- force expensive writes
- trigger gas exhaustion
- DOS protocol execution

=========================================================
SECURITY / AUDITOR MINDSET
=========================================================

Auditors ask:

- Does storage grow infinitely?
- Are writes necessary?
- Can attacker force writes?
- Is loop bounded?
- Can gas exceed safe limits?

=========================================================
REAL AUDITOR PROCESS
=========================================================

Auditors analyze:

---------------------------------------------------------
STORAGE COMPLEXITY
---------------------------------------------------------

AND

---------------------------------------------------------
LONG-TERM SCALABILITY
---------------------------------------------------------

=========================================================
WHY STORAGE OPTIMIZATION MATTERS
=========================================================

Storage costs REAL ETH.

---------------------------------------------------------

Bad storage design =
expensive protocol.

=========================================================
BEST PRACTICES
=========================================================

- Minimize storage writes
- Prefer memory when possible
- Avoid large loops
- Batch operations carefully
- Limit array growth

=========================================================
MINI CHALLENGE
=========================================================

Modify contract so that:

1. Store 1000 values
2. Compare gas usage
3. Remove unnecessary writes
4. Use struct arrays

BONUS:
Create gas-optimized batch storage.

=========================================================
IMPORTANT CONCEPTS LEARNED
=========================================================

- Storage writes are expensive
- Arrays increase storage cost
- Permanent blockchain data costs gas
- Memory is cheaper than storage
- Large arrays create scalability risk
- Storage-heavy loops are dangerous
- Ethereum charges for permanent state
- Auditors inspect storage complexity
- Gas optimization is critical
- Unbounded storage growth is risky

=========================================================
*/
/*
Audit Report
Title; Excessive Storage writes causing High Gas Consumption

Severity: Medium

Reason
The contract perfroms multiple storage writes during every loop iteration. Increasing
storage operations grom 100 to 1000 entries significantly increases gas consumption
because storage writes are among the most expensive EVM operations.

Location
Contract; StorageGasCost
Function: storeManyValues()

Vulnerability Description
The original implementation performs three storage writes during each iteration:
storedValues.push(i);
totalWrites++;
lastStoredValue = i;

For 1000 iterations this results in:
1000 array writes
1000 totalWrites updates
1000 lastStoredValue updates
Total:
3000 storage writes
This creates unnecessary gas costs.

Impact
Potential consequences include:
- High transaction fees
- Reduced scalability
- Increased execution time
- Possible out-of gas failures
- Inefficient storage usage

Proof of Concept
original Pattern
for (
    uint256 i = 0;
    i < 1000;
    i++
) {
    storedValues.push(i);
    totalWrites++;
    lastStoredValue = i;
}

Observation
lastStoredValue is written every iteration and only the final value is retained.

Root Cause
Repeated storage writes inside loops:
totalWrites++;
lastStoredValue= i;
are executed unnecessarily.

Recommendation
- Store 1000 values using a struct array.
- Update counters once after the loop
- Avoid repeated overwritting of storage variables.
- Use memory when persistence is unnecessary

Patched code
*/
contract StorageGasCost{
    /*
    ==============================
    STRUCT ARRAY
    ==============================
    */
    struct ValueData {
        uint256 value;
    }
    ValueData[] public storedValues;
    uint256 public totalWrites;
    uint256 public lastStoredValue;
    uint256 public gasUsedStorage;
    uint256 public gasUsedMemory;
    /*
    =========================
    STORE 1000 VALUES
    =========================
    Gas Comparision:
    Expensive:
    = Storage writes
    cheap:
    - Memory operations
    */
    function store1000Values()
    external
    {
        uint256 startGas =
        gasleft();
        for (
            uint256 i = 0;
            i < 1000;
            i++
        ){
            storedValues.push(
                ValueData(i)
            );
        }
        //Single writes
        totalWrites += 1000;
        lastStoredValue = 999;

        gasUsedStorage =
        startGas - gasleft(); 
    }
    /*
    ============================
    MEMORY VERSION
    =============================
    */
    function memoryVersion()
    external
    {
        uint256 startGas =
        gasleft();
        ValueData[] memory temp =
        new ValueData[](1000);
        for (
            uint256 i = 0;
            i < 1000;
            i++
        ){
            temp[i] =
            ValueData(i);
        }
        gasUsedMemory =
        startGas - gasleft();
    }
    function getLength()
    external
    view
    returns (uint256)
    {
        return storedValues.length;
    }
}