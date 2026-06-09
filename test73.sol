// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/*
=========================================================
PRACTICAL: Stress test repeated calls
CONCEPT: Stability testing
=========================================================

OBJECTIVE

- Understand system behavior under repeated calls
- Learn how state grows over time
- Observe gas accumulation risks
- Think like auditor performing stress tests

---------------------------------------------------------
CORE IDEA
---------------------------------------------------------

Repeated function calls simulate real-world load.

---------------------------------------------------------

Each call:
modifies state
consumes gas
adds cumulative load

---------------------------------------------------------
IMPORTANT UNDERSTANDING
---------------------------------------------------------

Stress testing is used to detect:

- gas exhaustion
- storage bloating
- performance degradation
- DOS risks

---------------------------------------------------------
WHY THIS MATTERS
---------------------------------------------------------

In real systems:

- users call contracts repeatedly
- bots interact heavily
- protocols accumulate state over time

---------------------------------------------------------
AUDITOR FOCUS
---------------------------------------------------------

Auditors test:

- repeated execution stability
- state growth over time
- gas scaling behavior
- worst-case repeated usage
- storage accumulation

=========================================================
STRESS TEST CONTRACT
=========================================================
*/
/*
contract StressTestCalls {

    /*
        STORAGE STATE
    
    uint256 public counter;

    uint256 public totalCalls;

    uint256[] public history;

    /*
    =====================================================
    SINGLE STATE UPDATE FUNCTION
    =====================================================
    

    function singleCall(uint256 value)
        public
    {

        /*
            Increment counters.
        
        counter++;
        totalCalls++;

        /*
            Store value.
        
        history.push(value);
    }

    /*
    =====================================================
    STRESS TEST FUNCTION (LOOPED CALLS)
    =====================================================
    

    function stressTest(uint256 times)
        external
    {

        /*
        =================================================
        WARNING:
        =================================================

        This simulates repeated usage.

        Gas grows linearly with `times`.
        

        for (
            uint256 i = 0;
            i < times;
            i++
        ) {

            /*
                Repeated internal execution.
            
            singleCall(i);
        }
    }

    /*
    =====================================================
    DIRECT CALL STRESS (EXTERNAL STYLE SIMULATION)
    =====================================================
    

    function externalStyleStress(uint256 times)
        external
    {

        for (
            uint256 i = 0;
            i < times;
            i++
        ) {

            /*
                Simulates repeated user interactions.
            
            this.singleCall(i);
        }
    }

    /*
    =====================================================
    RESET STATE (FOR TESTING ONLY)
    =====================================================
    

    function reset()
        external
    {

        counter = 0;
        totalCalls = 0;

        delete history;
    }

    /*
    =====================================================
    GET HISTORY SIZE
    =====================================================
    

    function getHistoryLength()
        external
        view
        returns (uint256)
    {

        return history.length;
    }
}
*/
/*
=========================================================
EXECUTION FLOW
=========================================================

STEP 1:
Deploy StressTestCalls

=========================================================
TRACE:
stressTest(5)
=========================================================

STEP 1:
i = 0

---------------------------------------------------------

singleCall(0)

=========================================================
STEP 2
=========================================================

STATE CHANGES:

counter++
totalCalls++
history.push(0)

=========================================================
STEP 3
=========================================================

i = 1 → repeat

=========================================================
STEP 4
=========================================================

i = 2 → repeat

=========================================================
STEP 5
=========================================================

i = 3 → repeat

=========================================================
STEP 6
=========================================================

i = 4 → repeat

=========================================================
FINAL STATE
=========================================================

---------------------------------------------------------
counter
---------------------------------------------------------

= 5

---------------------------------------------------------
totalCalls
---------------------------------------------------------

= 5

---------------------------------------------------------
history
---------------------------------------------------------

[0,1,2,3,4]

=========================================================
IMPORTANT OBSERVATION
=========================================================

Each loop iteration:

---------------------------------------------------------
1 storage increment
1 storage increment
1 array push
---------------------------------------------------------

Gas grows quickly.

=========================================================
TRACE:
externalStyleStress()
=========================================================

STEP 1:
this.singleCall(i)

---------------------------------------------------------

IMPORTANT:

This creates EXTERNAL CALLS to same contract.

=========================================================
STEP 2
=========================================================

Execution context switches:

Contract → Contract (external call)

=========================================================
STEP 3
=========================================================

Each iteration:

- external call overhead
- higher gas usage
- more execution cost

=========================================================
IMPORTANT DIFFERENCE
=========================================================

---------------------------------------------------------
singleCall()
---------------------------------------------------------

cheap internal call

---------------------------------------------------------

---------------------------------------------------------
this.singleCall()
---------------------------------------------------------

expensive external call

=========================================================
STRESS TEST INSIGHT
=========================================================

Repeated calls reveal:

- gas scaling issues
- storage growth
- execution bottlenecks
- stability limits

=========================================================
REMIX TESTING
=========================================================

STEP 1:
Deploy contract

=========================================================
TEST 1
=========================================================

Call:
stressTest(10)

EXPECTED:
fast execution

=========================================================
STEP 2
=========================================================

Call:
stressTest(1000)

EXPECTED:
high gas usage / possible failure

=========================================================
TEST 3
=========================================================

Call:
externalStyleStress(10)

EXPECTED:
higher gas than internal version

=========================================================
IMPORTANT SECURITY CONCEPT
=========================================================

Repeated calls can cause:

---------------------------------------------------------
GAS DOS
---------------------------------------------------------

AND

---------------------------------------------------------
STORAGE BLOAT
---------------------------------------------------------

=========================================================
COMMON AUDIT RISKS
=========================================================

---------------------------------------------------------
1. UNBOUNDED REPEATED CALLS
---------------------------------------------------------

can exhaust gas

---------------------------------------------------------
2. STORAGE GROWTH
---------------------------------------------------------

array keeps increasing

---------------------------------------------------------
3. EXTERNAL CALL OVERHEAD
---------------------------------------------------------

increases gas significantly

---------------------------------------------------------
4. SYSTEM INSTABILITY
---------------------------------------------------------

becomes unscalable under load

=========================================================
ATTACK THINKING
=========================================================

Attackers may:

- spam function calls
- increase gas usage
- force storage growth
- degrade protocol performance

=========================================================
SECURITY / AUDITOR MINDSET
=========================================================

Auditors test:

- repeated call behavior
- worst-case gas usage
- storage scaling
- external call risks
- system stability under load

=========================================================
REAL AUDITOR PROCESS
=========================================================

Auditors simulate:

---------------------------------------------------------
HIGH-FREQUENCY USAGE
---------------------------------------------------------

to find failure points.

=========================================================
BEST PRACTICES
=========================================================

- Avoid unbounded loops
- Minimize storage writes per call
- Prefer batch processing
- Avoid unnecessary external calls
- Design for scalability

=========================================================
MINI CHALLENGE
=========================================================

Modify contract:

1. Limit stressTest to 100 calls
2. Replace storage writes with events
3. Compare internal vs external call gas
4. Add gas measurement logging

BONUS:
Create batch-stress-safe architecture.

=========================================================
IMPORTANT CONCEPTS LEARNED
=========================================================

- Repeated calls simulate real load
- Gas grows with execution frequency
- Storage accumulates over time
- External calls are more expensive
- Stress testing reveals vulnerabilities
- System scalability must be designed
- Auditors simulate heavy usage scenarios
- Unbounded execution is dangerous
- Storage + loops = high risk pattern
- Stability testing is critical for security

=========================================================
*/
/*
Audit Report
Title
Unbounded Streee Test Loops Cause Exxessive Gas Consumption

Severity:Medium

Reason
The contract allows an arbitraray number of loop iteations and performs storage
writes during each iteration. Additionally, externalStyleStress() uses external self-
calls(this.singleCall()), which are significantly more expensive than internal calls.

Location
Contract: StressTestCalls
Functions: stressTest(uint256 times) , externalStyleStress(uint256 times)

Vulnerability Description
The original implementation:
singleCall(i);
and
this.singleCall(i);
performs repeated state changes and storage writes.

Problems:
- No upper bounds on times
- Gas usage grows linearly
- Repeated history.push() storage writes
- External self-calls are significantly more expensive

Impact
- High gas consumption
- Potential out-of-gas failures
- Unnecessary storage growth
- Inefficient benchmarking

Root Cause
user-controlled loops:
for (
    uint256 i = 0;
    i < times;
    i++
)
combined wth:
history.push(value);
and:
this.singleCall(i);

Recommendation
- Limit stress tests to 100 iterations.
- Replace storage writes with events.
- Measure gas Consumption.
- Compare internal vs external execution costs.

Patched code:
*/
contract StressTestCalls {
    /*
    STORAGE STATE
    */
    uint256 public counter;
    uint256 public totalCalls;
    /*
    GAS TRACKING
    */
    uint256 public internalGasUsed;
    uint256 public externalGasUsed;
    /*
    EVENT LOGGING
    */
    event CallExecuted(uint256 value);
    event GasMeasured(
        string callType,
        uint256 gasUsed
    );
    /*
    ===========================
    SINGLE CALL
    ===========================
    */
    function singleCall(
        uint256 value
    )
    public
    {
        counter++;
        totalCalls++;
        //Event instead of storage write
        emit CallExecuted(value);
    }
    /*
    =====================================
    INTERAL CALL STRESS TEST
    ======================================
    */
    function stressTest(
        uint256 times
    )
    external
    {
        require(
            times <= 100,
            "Max 100 calls"
        );
        uint256 startGas =
        gasleft();
     for (
        uint256 i = 0;
        i < times;
        i++
    ) {
        singleCall(i);
    }
    internalGasUsed =
        startGas - gasleft();

    emit GasMeasured(
        "Internal",
        internalGasUsed
    );
}
    /*
    ================================================
    EXTERNAL CALL STRESS TEST
    ================================================
    */
    function externalStyleStress(
        uint256 times
    )
    external
    {
        require(
            times <= 100,
            "Max 100 calls"
        );
        uint256 startGas =
        gasleft();
        for (
            uint256 i = 0;
            i < times;
            i++
        ){
            this.singleCall(i);
        }
        externalGasUsed = 
            startGas - gasleft();
            emit GasMeasured(
                "External",
                externalGasUsed
            );
    }
    /*
    ==========================
    GAS COMPARISION
    ==========================
    */
    function compareGas()
    external
    view
    returns (
        uint256 internalGas,
        uint256 externalGas
    )
    {
        return (
            internalGasUsed,
            externalGasUsed
        );
    }
    /*
    ================================
    RESET
    ================================
    */
    function reset()
         external
    {
        counter = 0;
        totalCalls = 0;
    }     

}
