// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/*
=========================================================
PRACTICAL: Trigger fallback during call
CONCEPT: External execution
=========================================================

OBJECTIVE

- Learn how fallback() gets triggered
- Understand low-level external execution
- Learn unknown-function behavior
- Understand fallback attack surface

---------------------------------------------------------
CORE IDEA
---------------------------------------------------------

fallback() executes when:

1. unknown function called
OR
2. calldata does not match any function

---------------------------------------------------------
IMPORTANT UNDERSTANDING
---------------------------------------------------------

fallback() is external execution.

---------------------------------------------------------

Control jumps into:
another contract unexpectedly.

---------------------------------------------------------
WHY THIS MATTERS
---------------------------------------------------------

fallback() is heavily used in:

- proxies
- routers
- upgradeable contracts
- ETH receivers
- attack contracts
- low-level interactions

---------------------------------------------------------
REAL-WORLD USAGE
---------------------------------------------------------

Fallback logic appears in:

- proxy delegation
- DeFi routing
- reentrancy attacks
- ETH receiving
- upgrade patterns

---------------------------------------------------------
AUDITOR FOCUS
---------------------------------------------------------

Auditors inspect:

- fallback execution paths
- hidden external calls
- reentrancy behavior
- delegatecall risks
- gas usage

=========================================================
TARGET CONTRACT
=========================================================
*/
/*
contract TargetContract {

    /*
        TRACK FALLBACK EXECUTION
    
    uint256 public fallbackCounter;

    uint256 public receivedETH;

    /*
    =====================================================
    FALLBACK FUNCTION
    =====================================================

    Triggered when:
    - unknown function called
    - calldata unmatched
    

    fallback()
        external
        payable
    {

        /*
            Track execution.
        
        fallbackCounter++;

        /*
            Track ETH received.
        
        receivedETH += msg.value;
    }

    /*
    =====================================================
    RECEIVE FUNCTION
    =====================================================

    Triggered when:
    ETH sent with EMPTY calldata.
    

    receive()
        external
        payable
    {

        receivedETH += msg.value;
    }

    /*
    =====================================================
    NORMAL FUNCTION
    =====================================================
    

    function normalFunction()
        external
        pure
        returns (string memory)
    {

        return "Normal execution";
    }
}

/*
=========================================================
CALLER CONTRACT
=========================================================

contract FallbackCaller {

    /*
        STORE TARGET ADDRESS
    
    address public target;

    /*
        LAST CALL STATUS
    
    bool public lastSuccess;

    /*
        CONSTRUCTOR
    
    constructor(address _target)
    {

        target = _target;
    }

    /*
    =====================================================
    CALL UNKNOWN FUNCTION
    =====================================================
    

    function triggerFallback()
        external
    {

        /*
            LOW-LEVEL CALL

            Calling NON-EXISTENT function:
            "doesNotExist()"
        
        (bool success, ) =
            target.call(
                abi.encodeWithSignature(
                    "doesNotExist()"
                )
            );

        /*
            Save result.
        
        lastSuccess = success;
    }

    /*
    =====================================================
    SEND ETH + UNKNOWN CALLDATA
    =====================================================
    

    function triggerFallbackWithETH()
        external
        payable
    {

        /*
            Sends:
            - ETH
            - invalid function calldata
        
        (bool success, ) =
            target.call{
                value: msg.value
            }(
                abi.encodeWithSignature(
                    "fakeFunction()"
                )
            );

        lastSuccess = success;
    }

    /*
    =====================================================
    SEND PLAIN ETH
    =====================================================
    

    function triggerReceive()
        external
        payable
    {

        /*
            Empty calldata.

            receive() executes.
        
        (bool success, ) =
            target.call{
                value: msg.value
            }("");

        lastSuccess = success;
    }
}
*/
/*
=========================================================
EXECUTION FLOW
=========================================================

STEP 1:
Deploy TargetContract

---------------------------------------------------------

STEP 2:
Deploy FallbackCaller

Constructor input:
TargetContract address

=========================================================
TRACE:
triggerFallback()
=========================================================

STEP 1:
Caller contract executes.

---------------------------------------------------------

STEP 2:
Low-level call created:

target.call(
    abi.encodeWithSignature(
        "doesNotExist()"
    )
)

---------------------------------------------------------

STEP 3:
Execution jumps into:
TargetContract

---------------------------------------------------------

EVM searches for:

doesNotExist()

---------------------------------------------------------

RESULT:
Function NOT FOUND

---------------------------------------------------------

STEP 4:
fallback() automatically executes.

=========================================================
INSIDE fallback()
=========================================================

fallbackCounter++

---------------------------------------------------------

NEW VALUE:
1

---------------------------------------------------------

receivedETH += msg.value

msg.value = 0

=========================================================
IMPORTANT FALLBACK UNDERSTANDING
=========================================================

fallback() executes when:
no matching function exists.

=========================================================
ETH + FALLBACK TRACE
=========================================================

CALL:
triggerFallbackWithETH()

VALUE:
1 ETH

=========================================================

STEP 1:
ETH + invalid calldata sent.

---------------------------------------------------------

STEP 2:
No matching function found.

---------------------------------------------------------

STEP 3:
fallback() executes.

---------------------------------------------------------

fallbackCounter++

---------------------------------------------------------

receivedETH += 1 ETH

=========================================================
RECEIVE TRACE
=========================================================

CALL:
triggerReceive()

VALUE:
1 ETH

=========================================================

STEP 1:
ETH sent with EMPTY calldata.

---------------------------------------------------------

STEP 2:
receive() executes.

---------------------------------------------------------

receivedETH += 1 ETH

=========================================================
IMPORTANT DIFFERENCE
=========================================================

---------------------------------------------------------
receive()
---------------------------------------------------------

Triggered when:
- ETH sent
- calldata EMPTY

---------------------------------------------------------
fallback()
---------------------------------------------------------

Triggered when:
- unknown function called
- calldata unmatched

=========================================================
REMIX TESTING
=========================================================

STEP 1:
Deploy TargetContract

---------------------------------------------------------

STEP 2:
Deploy FallbackCaller

Input:
TargetContract address

---------------------------------------------------------

STEP 3:
Call:
triggerFallback()

---------------------------------------------------------

STEP 4:
Open TargetContract

---------------------------------------------------------

STEP 5:
Call:
fallbackCounter()

EXPECTED:
1

---------------------------------------------------------

STEP 6:
In VALUE field:
enter 1 ether

---------------------------------------------------------

STEP 7:
Call:
triggerFallbackWithETH()

---------------------------------------------------------

STEP 8:
Call:
receivedETH()

EXPECTED:
1 ETH in wei

---------------------------------------------------------

STEP 9:
Call:
triggerReceive()

with 1 ETH

---------------------------------------------------------

STEP 10:
Call:
receivedETH()

EXPECTED:
2 ETH total

=========================================================
IMPORTANT SECURITY UNDERSTANDING
=========================================================

fallback() enables:
unexpected external execution.

---------------------------------------------------------

Huge attack surface.

=========================================================
COMMON AUDIT RISKS
=========================================================

---------------------------------------------------------
1. REENTRANCY
---------------------------------------------------------

fallback() may reenter vulnerable contract.

---------------------------------------------------------
2. PROXY RISKS
---------------------------------------------------------

fallback() commonly delegates execution.

---------------------------------------------------------
3. UNEXPECTED EXECUTION
---------------------------------------------------------

Unknown calls may trigger hidden logic.

---------------------------------------------------------
4. GAS DOS
---------------------------------------------------------

Complex fallback may exhaust gas.

=========================================================
VERY IMPORTANT ATTACK CONCEPT
=========================================================

Malicious contracts often attack using:

fallback()/receive()

---------------------------------------------------------

Because:
they trigger automatically during ETH transfer.

=========================================================
LOW-LEVEL CALL UNDERSTANDING
=========================================================

call() bypasses:
compile-time function checks.

---------------------------------------------------------

Meaning:
ANY calldata possible.

=========================================================
SECURITY / AUDITOR MINDSET
=========================================================

Auditors ask:

- Can fallback trigger unexpectedly?
- Can fallback reenter?
- Does fallback delegatecall?
- Is fallback payable?
- Are unknown calls handled safely?

=========================================================
ATTACK THINKING
=========================================================

ATTACK SCENARIO

Victim contract sends ETH.

---------------------------------------------------------

Attacker fallback executes automatically.

---------------------------------------------------------

Fallback reenters victim contract.

---------------------------------------------------------

Result:
fund theft.

=========================================================
REAL AUDITOR PROCESS
=========================================================

Auditors trace:

1. External call flow
2. Fallback trigger conditions
3. Reentrancy windows
4. ETH transfer behavior
5. Unknown calldata handling

=========================================================
MINI CHALLENGE
=========================================================

Modify contracts so that:

1. Add event inside fallback()
2. Add reentrant fallback attack
3. Add nonReentrant protection
4. Compare receive vs fallback execution

BONUS:
Build mini proxy fallback contract.

=========================================================
IMPORTANT CONCEPTS LEARNED
=========================================================

- fallback() handles unknown function calls
- receive() handles plain ETH transfers
- Low-level call() can trigger fallback
- fallback() creates external execution flow
- fallback() is major attack surface
- Reentrancy often uses fallback()
- call() bypasses compile-time safety
- Unknown calldata may trigger hidden logic
- Auditors inspect fallback paths carefully
- External execution is critical in Solidity security

=========================================================
*/
/*
Audit Report
Title:
Unsafe Fallback Handling and Missing Reentrancy Protection

Severity:
High

Location:
Contract:
TargetContract

Functions:
fallback()
receive()

Vulnerability Description:
The contract accepts ETH through both fallback() and receive() but lacks:
1. event logging
2. reentrancy protection
3. fallback execution monitoring
4. proxy-safe delegation logic
Additionally, fallback functions can become a dangerous when external cals or state-
changing logic are introduced.

An attacker may exploit fallback execution paths to repeatedly trigger rcursive calls
changing logic are introduced.

An attacker may exploit fallback execution paths to repeatedly trigger recursive calls
and manipulate contract state.

Impact:
Potential risks include:
1. Reentrancy attacks
2. Unexpected fallback execution
3. ETH draining
4. Proy misconfiguration
5. Hidden calldata execution
6. Inconsistent ETH accounting

Root cause:
The contract:
1. has not nonReentrant modifier
2. performs ststae updates without protection
3. lacks fallback execution transparency
4. does not distinguish fallback-trigger conditions via events

Recommendition:
Implement:
1. nonReentrant modifier
2. fallback event logging
3. receive event logging
4. attack simulation contract
5. proxy fallback architecture
6. execution comparison tracking

Patched contract
*/
contract TargetContract {

    /*
    =====================================================
    STORAGE
    =====================================================
    */

    uint256 public fallbackCounter;

    uint256 public receiveCounter;

    uint256 public receivedETH;

    /*
        Reentrancy lock.
    */
    bool private locked;

    /*
    =====================================================
    EVENTS
    =====================================================
    */

    event FallbackTriggered(
        address indexed sender,
        uint256 value,
        bytes data
    );

    event ReceiveTriggered(
        address indexed sender,
        uint256 value
    );

    event ETHWithdrawn(
        address indexed to,
        uint256 amount
    );

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
    FALLBACK FUNCTION
    =====================================================

    Triggered when:
    - unknown function called
    - calldata unmatched
    */

    fallback()
        external
        payable
        nonReentrant
    {

        fallbackCounter++;

        receivedETH += msg.value;

        emit FallbackTriggered(
            msg.sender,
            msg.value,
            msg.data
        );
    }

    /*
    =====================================================
    RECEIVE FUNCTION
    =====================================================

    Triggered when:
    ETH sent with EMPTY calldata.
    */

    receive()
        external
        payable
        nonReentrant
    {

        receiveCounter++;

        receivedETH += msg.value;

        emit ReceiveTriggered(
            msg.sender,
            msg.value
        );
    }

    /*
    =====================================================
    NORMAL FUNCTION
    =====================================================
    */

    function normalFunction()
        external
        pure
        returns (string memory)
    {

        return "Normal execution";
    }

    /*
    =====================================================
    WITHDRAW FUNCTION
    =====================================================
    */

    function withdraw(
        uint256 _amount
    )
        external
        nonReentrant
    {

        require(
            address(this).balance >= _amount,
            "Insufficient ETH"
        );

        (bool success, ) =
            payable(msg.sender).call{
                value: _amount
            }("");

        require(
            success,
            "Transfer failed"
        );

        emit ETHWithdrawn(
            msg.sender,
            _amount
        );
    }

    /*
    =====================================================
    COMPARE EXECUTION COUNTS
    =====================================================
    */

    function compareExecution()
        external
        view
        returns (
            uint256 fallbackExecutions,
            uint256 receiveExecutions
        )
    {

        return (
            fallbackCounter,
            receiveCounter
        );
    }
}
```
