// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/*
=========================================================
PRACTICAL: Send ETH to non-payable contract
CONCEPT: Revert behavior
=========================================================

OBJECTIVE

- Learn why ETH transfers may fail
- Understand payable vs non-payable behavior
- Learn revert propagation mechanics
- Understand safe ETH transfer handling

---------------------------------------------------------
CORE IDEA
---------------------------------------------------------

A contract CANNOT receive ETH unless:

- receive() exists
OR
- fallback() is payable
OR
- target function is payable

---------------------------------------------------------
IMPORTANT UNDERSTANDING
---------------------------------------------------------

Sending ETH to a non-payable contract:

REVERTS the transaction.

---------------------------------------------------------
WHY THIS MATTERS
---------------------------------------------------------

ETH transfer assumptions cause:

- failed withdrawals
- stuck funds
- broken integrations
- DOS vulnerabilities

---------------------------------------------------------
REAL-WORLD USAGE
---------------------------------------------------------

ETH transfer logic exists in:

- vaults
- bridges
- staking systems
- exchanges
- DAO treasuries
- payment protocols

---------------------------------------------------------
AUDITOR FOCUS
---------------------------------------------------------

Auditors inspect:

- payable correctness
- ETH acceptance logic
- transfer failure handling
- unchecked call results
- DOS possibilities

=========================================================
NON-PAYABLE CONTRACT
=========================================================
*/
/*
contract NonPayableReceiver {

    /*
        TRACK EXECUTION
    
    uint256 public counter;

    /*
    =====================================================
    NORMAL FUNCTION
    =====================================================

    NOT payable.
    

    function increment()
        external
    {

        counter++;
    }

    /*
    =====================================================
    IMPORTANT
    =====================================================

    NO receive()
    NO payable fallback()

    Therefore:
    direct ETH transfers fail.
    
}

/*
=========================================================
PAYABLE CONTRACT
=========================================================


contract PayableReceiver {

    /*
        TRACK RECEIVED ETH
    
    uint256 public receivedAmount;

    /*
    =====================================================
    RECEIVE ETH
    =====================================================
    

    receive()
        external
        payable
    {

        /*
            Store received ETH amount.
        
        receivedAmount += msg.value;
    }
}

/*
=========================================================
SENDER CONTRACT
=========================================================


contract ETHSender {

    /*
        TRACK LAST RESULT
    
    bool public lastSuccess;

    /*
        TRACK TOTAL SENT
    
    uint256 public totalSent;

    /*
    =====================================================
    SEND ETH SAFELY
    =====================================================
    

    function sendETH(
        address payable _receiver
    )
        external
        payable
    {

        /*
            Attempt ETH transfer using call().
        
        (bool success, ) =
            _receiver.call{
                value: msg.value
            }("");

        /*
            Save result.
        
        lastSuccess = success;

        /*
            SAFE HANDLING.

            Revert if transfer failed.
        
        require(
            success,
            "ETH transfer failed"
        );

        /*
            Update accounting ONLY after success.
        
        totalSent += msg.value;
    }

    /*
    =====================================================
    DANGEROUS SEND
    =====================================================

    Ignores success boolean.
    

    function dangerousSend(
        address payable _receiver
    )
        external
        payable
    {

        /*
            Attempt ETH transfer.
        
        _receiver.call{
            value: msg.value
        }("");

        /*
            DANGEROUS:
            Execution continues even if transfer failed.
        

        totalSent += msg.value;
    }

    /*
    =====================================================
    CHECK CONTRACT BALANCE
    =====================================================
    

    function contractBalance()
        external
        view
        returns (uint256)
    {

        return address(this).balance;
    }
}
*/
/*
=========================================================
EXECUTION FLOW
=========================================================

STEP 1:
Deploy NonPayableReceiver

---------------------------------------------------------

STEP 2:
Deploy PayableReceiver

---------------------------------------------------------

STEP 3:
Deploy ETHSender

=========================================================
TRACE:
sendETH() TO NON-PAYABLE CONTRACT
=========================================================

STEP 1:
User calls:

sendETH()

---------------------------------------------------------

VALUE:
1 ETH

---------------------------------------------------------

Receiver:
NonPayableReceiver

=========================================================
STEP 2
=========================================================

Low-level call executes:

_receiver.call{value: 1 ether}("")

=========================================================
STEP 3
=========================================================

Ethereum attempts to send ETH.

=========================================================
IMPORTANT
=========================================================

Target contract has:

---------------------------------------------------------
NO receive()
---------------------------------------------------------

AND

---------------------------------------------------------
NO payable fallback()
---------------------------------------------------------

=========================================================
STEP 4
=========================================================

ETH transfer automatically fails.

---------------------------------------------------------

success = false

=========================================================
STEP 5
=========================================================

require(success)

---------------------------------------------------------

FAILS

---------------------------------------------------------

FULL TRANSACTION REVERTS

=========================================================
FINAL RESULT
=========================================================

---------------------------------------------------------
ETH transferred?
---------------------------------------------------------

NO

---------------------------------------------------------
totalSent updated?
---------------------------------------------------------

NO

---------------------------------------------------------
Transaction status?
---------------------------------------------------------

REVERTED

=========================================================
WHY?
=========================================================

Contract cannot accept ETH.

=========================================================
TRACE:
sendETH() TO PAYABLE CONTRACT
=========================================================

STEP 1:
Call:
sendETH()

---------------------------------------------------------

VALUE:
1 ETH

---------------------------------------------------------

Receiver:
PayableReceiver

=========================================================
STEP 2
=========================================================

receive() executes successfully.

---------------------------------------------------------

success = true

=========================================================
STEP 3
=========================================================

require(success)

---------------------------------------------------------

PASSES

=========================================================
STEP 4
=========================================================

totalSent += 1 ether

=========================================================
FINAL RESULT
=========================================================

ETH transfer succeeds safely.

=========================================================
DANGEROUS TRACE
=========================================================

CALL:
dangerousSend()

---------------------------------------------------------

Receiver:
NonPayableReceiver

=========================================================

STEP 1:
ETH transfer fails.

---------------------------------------------------------

success = false

=========================================================
STEP 2
=========================================================

IMPORTANT:

success ignored completely.

=========================================================
STEP 3
=========================================================

Execution continues.

---------------------------------------------------------

totalSent += msg.value

=========================================================
CRITICAL PROBLEM
=========================================================

Internal accounting says:
ETH sent.

---------------------------------------------------------

Reality:
ETH transfer FAILED.

=========================================================
REMIX TESTING
=========================================================

STEP 1:
Deploy NonPayableReceiver

---------------------------------------------------------

STEP 2:
Deploy PayableReceiver

---------------------------------------------------------

STEP 3:
Deploy ETHSender

=========================================================
TEST 1
=========================================================

Call:
sendETH()

---------------------------------------------------------

Receiver:
NonPayableReceiver address

---------------------------------------------------------

VALUE:
1 ether

---------------------------------------------------------

EXPECTED:
Transaction reverts

=========================================================
TEST 2
=========================================================

Call:
sendETH()

---------------------------------------------------------

Receiver:
PayableReceiver address

---------------------------------------------------------

VALUE:
1 ether

---------------------------------------------------------

EXPECTED:
Success

=========================================================
TEST 3
=========================================================

Call:
dangerousSend()

---------------------------------------------------------

Receiver:
NonPayableReceiver address

---------------------------------------------------------

VALUE:
1 ether

---------------------------------------------------------

EXPECTED:
Transaction succeeds incorrectly

=========================================================
STEP 4
=========================================================

Check:
totalSent()

---------------------------------------------------------

IMPORTANT:
Accounting corrupted.

=========================================================
IMPORTANT SECURITY CONCEPT
=========================================================

ETH transfers are NOT guaranteed.

---------------------------------------------------------

Receiving contracts control acceptance behavior.

=========================================================
COMMON AUDIT RISKS
=========================================================

---------------------------------------------------------
1. UNCHECKED ETH TRANSFERS
---------------------------------------------------------

Silent failures corrupt logic.

---------------------------------------------------------
2. NON-PAYABLE TARGETS
---------------------------------------------------------

Unexpected revert conditions.

---------------------------------------------------------
3. DOS VIA REVERT
---------------------------------------------------------

Malicious contracts reject ETH intentionally.

---------------------------------------------------------
4. ACCOUNTING INCONSISTENCY
---------------------------------------------------------

Protocol state diverges from reality.

=========================================================
IMPORTANT ATTACK THINKING
=========================================================

Attackers may:

- reject ETH intentionally
- revert receive()
- break protocol assumptions
- trigger DOS conditions

=========================================================
SECURITY / AUDITOR MINDSET
=========================================================

Auditors ask:

- Can target receive ETH?
- Is success checked?
- Are failures handled safely?
- Can ETH rejection DOS protocol?
- Is accounting updated correctly?

=========================================================
REAL AUDITOR PROCESS
=========================================================

Auditors trace:

1. ETH transfer behavior
2. Payable correctness
3. Failure propagation
4. Accounting consistency
5. External trust assumptions

=========================================================
BEST PRACTICE
=========================================================

Always:

---------------------------------------------------------
(bool success, ) = receiver.call{value: x}("");

require(success)
---------------------------------------------------------

=========================================================
MINI CHALLENGE
=========================================================

Modify contract so that:

1. Add payable fallback()
2. Add try/catch handling
3. Add event logging
4. Compare transfer/send/call

BONUS:
Create malicious ETH-rejecting DOS contract.

=========================================================
IMPORTANT CONCEPTS LEARNED
=========================================================

- Non-payable contracts reject ETH
- ETH transfers may revert
- receive() enables ETH reception
- call() returns success manually
- Ignoring success is dangerous
- External ETH handling is untrusted
- Reverts rollback transaction state
- Accounting must follow successful transfers
- Auditors inspect ETH-transfer assumptions
- Safe ETH handling is critical in Solidity

=========================================================
*/
/*
Audit Report
Title
Unchecked Return Value In dangerousSend()

Severity: Medium

Reason
The contract performs a low-level ETH transfer using call() but does not
verify wheather the transfer succeeded before updating internal accounting.

Location
Contract:ETHSender
Function:dangerousSend()

Vulnerability Description
The dangerousSend() function transfers ETH using a low-level call():
_receiver.call{value: msg.value}("");
However, the returned success flag is ignored.
function dangerousSend(
    address payable _receiver
)
    external
    payable
{
    _receiver.call{
        value: msg.value
    }("");
    totalSent += msg.value
}

if the recipient contract cannot receive ETH or intentionally rejects it, the
transfer fails silently while execution continues.
As a result, the contract records ETH as sent even through no transfer occured.

Impact
An attacker can causeETH transfers to fail while the protocol continues
execution

Potential consequences include:
1. Incorrect acounting
2. False paument records
3. Treasury inconsistencies
4. Denial-of-service scenarios
5. State divergence between aactual balances and recorded balances
if other protocol logic relies on totalSent, incorrect decisions may be made
based on invalid accounting data.

Proof of concept
Step 1
Deploy:
NonPayableReciver
ETHSender

Step 2
Call:
dangerousSend(
    payable(nonPayableReceiver)
)

with 1 ETH

Step 3
The transfer executes:
_receiver.call{value: 1 ether}("");

Since NonPayableReceiver has:

NO receive()
NO payable fallback()

the ETH transfer fails.

Step 4
Despite failure:

totalSent += msg.value;

still executes.

Result
Actual Transfer:
0 ETH sent
Internal accounting:
1 ETH recorded as sent
The contract state becomes inconsistent with reality.

Root Cause
The return value of the low-level call is ignored.
_receiver.call{value: msg.value}("");
No validation exists to ensure that the transfer succeeded before updating
protocol state.

Recommendation
Always validate the return value from low-level calls before updating state.
Example:
(bool success, ) = 
_receiver.call{value: msg.value}("");
require(
    success,
    "ETH transfer failed"
);
only update accounting after successful execution.

Patched code:
*/
/*
=========================================================
NON-PAYABLE RECEIVER (MODIFIED)
=========================================================
*/
contract NonPayableReceiver {

    uint256 public counter;
    uint256 public fallbackReceived;

    event Incremented(address caller);
    event FallbackReceived(
        address sender,
        uint256 amount,
        bytes data
    );

    function increment()
        external
    {
        counter++;

        emit Incremented(msg.sender);
    }

    /*
    =====================================================
    PAYABLE FALLBACK ADDED
    =====================================================
    */
    fallback()
        external
        payable
    {
        fallbackReceived += msg.value;

        emit FallbackReceived(
            msg.sender,
            msg.value,
            msg.data
        );
    }
}

/*
=========================================================
PAYABLE RECEIVER (MODIFIED)
=========================================================
*/
contract PayableReceiver {

    uint256 public receivedAmount;

    event EtherReceived(
        address sender,
        uint256 amount
    );

    event FallbackReceived(
        address sender,
        uint256 amount,
        bytes data
    );

    receive()
        external
        payable
    {
        receivedAmount += msg.value;

        emit EtherReceived(
            msg.sender,
            msg.value
        );
    }

    /*
    =====================================================
    PAYABLE FALLBACK ADDED
    =====================================================
    */
    fallback()
        external
        payable
    {
        receivedAmount += msg.value;

        emit FallbackReceived(
            msg.sender,
            msg.value,
            msg.data
        );
    }
}

/*
=========================================================
TRY/CATCH TARGET
=========================================================
*/
contract TargetContract {

    function success()
        external
        pure
        returns (string memory)
    {
        return "Success";
    }

    function fail()
        external
        pure
    {
        revert("Target reverted");
    }
}

/*
=========================================================
SENDER CONTRACT (MODIFIED)
=========================================================
*/
contract ETHSender {

    bool public lastSuccess;
    uint256 public totalSent;

    /*
    =====================================================
    EVENTS
    =====================================================
    */
    event EtherSent(
        address indexed receiver,
        uint256 amount
    );

    event EtherTransferFailed(
        address indexed receiver,
        uint256 amount
    );

    event TransferResult(
        string method,
        bool success
    );

    event TryCatchSuccess(
        string result
    );

    event TryCatchFailure(
        string reason
    );

    /*
    =====================================================
    SEND ETH USING CALL
    =====================================================
    */
    function sendETH(
        address payable _receiver
    )
        external
        payable
    {
        (bool success, ) =
            _receiver.call{
                value: msg.value
            }("");

        lastSuccess = success;

        require(
            success,
            "ETH transfer failed"
        );

        totalSent += msg.value;

        emit EtherSent(
            _receiver,
            msg.value
        );
    }

    /*
    =====================================================
    DANGEROUS SEND
    =====================================================
    */
    function dangerousSend(
        address payable _receiver
    )
        external
        payable
    {
        (bool success, ) =
            _receiver.call{
                value: msg.value
            }("");

        lastSuccess = success;

        if (!success) {
            emit EtherTransferFailed(
                _receiver,
                msg.value
            );
        }

        totalSent += msg.value;
    }

    /*
    =====================================================
    COMPARE transfer()
    =====================================================
    */
    function sendViaTransfer(
        address payable _receiver
    )
        external
        payable
    {
        _receiver.transfer(
            msg.value
        );

        emit TransferResult(
            "transfer",
            true
        );
    }

    /*
    =====================================================
    COMPARE send()
    =====================================================
    */
    function sendViaSend(
        address payable _receiver
    )
        external
        payable
    {
        bool success =
            _receiver.send(
                msg.value
            );

        emit TransferResult(
            "send",
            success
        );

        require(
            success,
            "send failed"
        );
    }

    /*
    =====================================================
    COMPARE call()
    =====================================================
    */
    function sendViaCall(
        address payable _receiver
    )
        external
        payable
    {
        (bool success, ) =
            _receiver.call{
                value: msg.value
            }("");

        emit TransferResult(
            "call",
            success
        );

        require(
            success,
            "call failed"
        );
    }

    /*
    =====================================================
    TRY/CATCH HANDLING
    =====================================================
    */
    function testTryCatchSuccess(
        address _target
    )
        external
    {
        try
            TargetContract(_target)
                .success()
        returns (
            string memory result
        ) {
            emit TryCatchSuccess(
                result
            );
        }
        catch Error(
            string memory reason
        ) {
            emit TryCatchFailure(
                reason
            );
        }
        catch {
            emit TryCatchFailure(
                "Unknown error"
            );
        }
    }

    function testTryCatchFailure(
        address _target
    )
        external
    {
        try
            TargetContract(_target)
                .fail()
        {
            emit TryCatchSuccess(
                "Unexpected success"
            );
        }
        catch Error(
            string memory reason
        ) {
            emit TryCatchFailure(
                reason
            );
        }
        catch {
            emit TryCatchFailure(
                "Unknown error"
            );
        }
    }

    function contractBalance()
        external
        view
        returns (uint256)
    {
        return address(this).balance;
    }

    receive() external payable {}
}

/*
=========================================================
BONUS: MALICIOUS ETH-REJECTING DOS CONTRACT
=========================================================
*/
contract RejectETHDOS {

    event Rejected(
        address sender,
        uint256 amount
    );

    receive()
        external
        payable
    {
        emit Rejected(
            msg.sender,
            msg.value
        );

        revert(
            "ETH rejected"
        );
    }

    fallback()
        external
        payable
    {
        emit Rejected(
            msg.sender,
            msg.value
        );

        revert(
            "ETH rejected"
        );
    }
}