// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/*
=========================================================
PRACTICAL: Create loop with 10 iterations
CONCEPT: Basic gas usage
=========================================================

OBJECTIVE

- Learn how loops execute in Solidity
- Understand gas consumption in loops
- Learn iteration behavior internally
- Think like auditor regarding loop risks

---------------------------------------------------------
CORE IDEA
---------------------------------------------------------

Loops execute repeatedly.

---------------------------------------------------------

Each iteration:
consumes additional gas.

---------------------------------------------------------

More iterations =
more gas usage.

---------------------------------------------------------
IMPORTANT UNDERSTANDING
---------------------------------------------------------

Ethereum execution is NOT free.

---------------------------------------------------------

Every operation costs gas:

- storage writes
- arithmetic
- memory allocation
- looping
- external calls

---------------------------------------------------------
WHY THIS MATTERS
---------------------------------------------------------

Large loops can cause:

- out-of-gas reverts
- denial of service
- unusable contracts

---------------------------------------------------------
REAL-WORLD USAGE
---------------------------------------------------------

Loops appear in:

- reward distribution
- staking systems
- NFT minting
- airdrops
- governance voting
- array processing

---------------------------------------------------------
AUDITOR FOCUS
---------------------------------------------------------

Auditors inspect:

- unbounded loops
- gas scaling
- iteration complexity
- DOS risks
- storage writes inside loops

=========================================================
LOOP CONTRACT
=========================================================
*/
/*
contract LoopGasUsage {

    /*
        STORE LOOP RESULTS
    
    uint256[] public storedNumbers;

    /*
        TRACK TOTAL ITERATIONS
    
    uint256 public totalIterations;

    /*
        TRACK FINAL SUM
    
    uint256 public finalSum;

    /*
    =====================================================
    LOOP 10 TIMES
    =====================================================
    

    function runLoop()
        external
    {

        /*
            Local variable stored in memory/stack.

            NOT permanent storage.
        
        uint256 sum = 0;

        /*
        =================================================
        FOR LOOP
        =================================================

        Executes 10 times:

        i = 0
        i = 1
        ...
        i = 9
        

        for (
            uint256 i = 0;
            i < 10;
            i++
        ) {

            /*
            =============================================
            EACH ITERATION DOES:
            =============================================

            1. Comparison:
               i < 10

            2. Arithmetic:
               sum += i

            3. Storage write:
               push into array

            4. Increment:
               i++
            

            sum += i;

            /*
                STORAGE WRITE

                Expensive operation.
            
            storedNumbers.push(i);

            /*
                Update storage counter.
            
            totalIterations++;
        }

        /*
            Save final result to storage.
        
        finalSum = sum;
    }

    /*
    =====================================================
    READ ARRAY LENGTH
    =====================================================
    

    function getArrayLength()
        external
        view
        returns (uint256)
    {

        return storedNumbers.length;
    }
}
*/
/*
=========================================================
EXECUTION FLOW
=========================================================

STEP 1:
Deploy LoopGasUsage

=========================================================
TRACE:
runLoop()
=========================================================

STEP 1:
Function execution starts.

---------------------------------------------------------

sum = 0

---------------------------------------------------------

Stored:
temporary stack/memory variable

=========================================================
STEP 2
=========================================================

Loop initializes:

uint256 i = 0

=========================================================
STEP 3
=========================================================

Condition checked:

i < 10

---------------------------------------------------------

0 < 10

---------------------------------------------------------

TRUE

=========================================================
STEP 4
=========================================================

Loop body executes.

---------------------------------------------------------

sum += i

---------------------------------------------------------

sum = 0 + 0

---------------------------------------------------------

sum = 0

=========================================================
STEP 5
=========================================================

Storage write:

storedNumbers.push(0)

---------------------------------------------------------

VERY IMPORTANT:
Storage writes cost high gas.

=========================================================
STEP 6
=========================================================

Storage update:

totalIterations++

---------------------------------------------------------

totalIterations = 1

=========================================================
STEP 7
=========================================================

Increment:

i++

---------------------------------------------------------

i = 1

=========================================================
STEP 8
=========================================================

Loop repeats again.

---------------------------------------------------------

1 < 10

---------------------------------------------------------

TRUE

=========================================================
LOOP CONTINUES
=========================================================

Iterations:

---------------------------------------------------------
Iteration 1
---------------------------------------------------------

i = 0

---------------------------------------------------------
Iteration 2
---------------------------------------------------------

i = 1

---------------------------------------------------------
Iteration 3
---------------------------------------------------------

i = 2

---------------------------------------------------------
...
---------------------------------------------------------

---------------------------------------------------------
Iteration 10
---------------------------------------------------------

i = 9

=========================================================
FINAL ITERATION
=========================================================

After i = 9:

---------------------------------------------------------

i++

---------------------------------------------------------

i = 10

=========================================================
LOOP EXIT
=========================================================

Condition checked:

10 < 10

---------------------------------------------------------

FALSE

---------------------------------------------------------

Loop stops.

=========================================================
FINAL STORAGE UPDATE
=========================================================

finalSum = 45

---------------------------------------------------------

Why 45?

---------------------------------------------------------

0+1+2+3+4+5+6+7+8+9

=========================================================
FINAL RESULT
=========================================================

---------------------------------------------------------
storedNumbers
---------------------------------------------------------

[0,1,2,3,4,5,6,7,8,9]

---------------------------------------------------------
totalIterations
---------------------------------------------------------

10

---------------------------------------------------------
finalSum
---------------------------------------------------------

45

=========================================================
IMPORTANT GAS UNDERSTANDING
=========================================================

Each iteration consumes gas.

---------------------------------------------------------

Gas increases because of:

- comparison
- arithmetic
- increment
- storage writes

=========================================================
MOST EXPENSIVE PART
=========================================================

THIS LINE:

storedNumbers.push(i)

---------------------------------------------------------

Storage writes are expensive.

=========================================================
VERY IMPORTANT SECURITY CONCEPT
=========================================================

Loops scale gas usage linearly.

---------------------------------------------------------

10 iterations =
manageable

---------------------------------------------------------

10,000 iterations =
dangerous

=========================================================
REMIX TESTING
=========================================================

STEP 1:
Deploy contract

---------------------------------------------------------

STEP 2:
Call:
runLoop()

---------------------------------------------------------

EXPECTED:
successful execution

=========================================================
STEP 3
=========================================================

Check:
finalSum()

EXPECTED:
45

---------------------------------------------------------

Check:
totalIterations()

EXPECTED:
10

---------------------------------------------------------

Check:
getArrayLength()

EXPECTED:
10

=========================================================
STEP 4
=========================================================

Inspect transaction gas used
inside Remix.

---------------------------------------------------------

Observe:
gas increases because of loop.

=========================================================
IMPORTANT AUDITOR UNDERSTANDING
=========================================================

Loops are dangerous when:

---------------------------------------------------------
USER-CONTROLLED
---------------------------------------------------------

or

---------------------------------------------------------
UNBOUNDED
---------------------------------------------------------

=========================================================
COMMON AUDIT RISKS
=========================================================

---------------------------------------------------------
1. UNBOUNDED LOOPS
---------------------------------------------------------

Infinite scalability risk.

---------------------------------------------------------
2. GAS DOS
---------------------------------------------------------

Too many iterations cause revert.

---------------------------------------------------------
3. STORAGE WRITES INSIDE LOOP
---------------------------------------------------------

Massive gas consumption.

---------------------------------------------------------
4. EXTERNAL CALLS INSIDE LOOP
---------------------------------------------------------

Very dangerous execution pattern.

=========================================================
IMPORTANT ATTACK THINKING
=========================================================

Attackers may:

- enlarge arrays
- force expensive loops
- trigger gas exhaustion
- DOS protocol execution

=========================================================
SECURITY / AUDITOR MINDSET
=========================================================

Auditors ask:

- Is loop bounded?
- Can attacker increase iterations?
- Are storage writes inside loop?
- Can gas exceed block limit?
- Is external call inside loop?

=========================================================
REAL AUDITOR PROCESS
=========================================================

Auditors estimate:

---------------------------------------------------------
TIME COMPLEXITY
---------------------------------------------------------

and

---------------------------------------------------------
GAS SCALING
---------------------------------------------------------

=========================================================
WHY LOOPS ARE RISKY
=========================================================

Ethereum has:
block gas limits.

---------------------------------------------------------

Too much computation =
transaction failure.

=========================================================
MINI CHALLENGE
=========================================================

Modify contract so that:

1. Loop 100 times
2. Compare gas usage
3. Remove storage writes
4. Add external call inside loop

BONUS:
Create gas-optimized loop version.

=========================================================
IMPORTANT CONCEPTS LEARNED
=========================================================

- Loops consume gas every iteration
- Storage writes are expensive
- Gas scales with iteration count
- for-loops repeatedly execute logic
- Large loops risk DOS
- Unbounded loops are dangerous
- Ethereum has gas limits
- Auditors inspect loop scalability
- Gas optimization matters heavily
- Loop complexity affects protocol security

=========================================================
*/
/*
Audit Report
Title
Unbounded Loop with External Calls Can Cause Excessive Gas Consumption and
Denial of Service

Severity: Medium

Reason
The runLoop() function performs multiple operations inside a loop, including
storage writes. Increasing the loop count and adding external calls significantly
increases gas consumption and may cause transactions to exceed block gas limits.

Location
Contract: LoopGasUsage
Function: runLoop()

Vulnerability Description
The function executes a loop and performs expensive operations during every
iteration:
for (
    uint256 i = 0;
    i < 10;
    i++
) {
    sum += i;

    storedNumbers.push(i);

    totalIterations++;
}

Each iteration performs:
1. Loop comparison
2. Arithmetic operation
3. Storage write (push)
4. Storage update (totalInteractions++)
if the loop size is increased to 100 or more interations and external calls are
introduced, gas costs grow significantly
Example:
for (
    uint256 i = 0;
    i < 100;
    i++
) {
    worker.doWork();
}

External calls are among the most expensive EVM operations and can caue
transaction failures due to gas exhaustion.

Impact
Potential consequences include:
1. High transaction costs
2. Out-of-gas failures
3. Denial of service
4. Reduced protocol scalability
5. Inefficient contract execution
if the loop bounds become user-controlled, attackers may intentionally trigger gas
exhaustion.

Proof of Concept
Step 1
Modify loop size:
for (
    uint256 i = 0;
    i < 100;
    i++
)

Step 2
Add external call
worker.doWork();

Step 3
Execute:
runLoop();

Result:
Gas usage increases substantially because every iteation performs:
1.Arithmetic
2. External call
3. Storage update
The tansaction becomes significantly more expensive compared to the original implementation.

Root Cause
The contract performs expensive operations inside a repetitive loop:
storeNumbers.push(i);
and
worker.dowork();
Storage writes and external calls are executed repeatedly.

Recommendation
1. Remove unnecessary storage writes.
2.Minimize external calls inside loops.
3. Use memory variables whenever possible.
4. Use unchecked arithmtic where overflow is impossible.
5.Batch updates after loop completion.

Patched code
*/
contract ExternalWorker {
    uint256 public callCount;

    function doWork()
        external
    {
        callCount++;
    }
}

contract LoopGasUsage {

    uint256 public totalIterations;
    uint256 public finalSum;

    ExternalWorker public worker;

    constructor(address _worker)
    {
        worker = ExternalWorker(_worker);
    }

    function runLoop()
        external
    {
        uint256 sum = 0;

        for (
            uint256 i = 0;
            i < 100;
            i++
        ) {
            sum += i;

            worker.doWork();

            totalIterations++;
        }

        finalSum = sum;
    }
}
