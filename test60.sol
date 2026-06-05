// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/*
=========================================================
PRACTICAL: Ignore success boolean from call
CONCEPT: Dangerous coding
=========================================================

OBJECTIVE

- Learn why unchecked call() is dangerous
- Understand silent external-call failures
- Learn inconsistent state vulnerabilities
- Think like professional auditor

---------------------------------------------------------
CORE IDEA
---------------------------------------------------------

Low-level call() returns:

(bool success, bytes memory data)

---------------------------------------------------------

If success is ignored:

execution may continue
even when external call FAILED.

---------------------------------------------------------
IMPORTANT UNDERSTANDING
---------------------------------------------------------

This creates:
silent failure vulnerabilities.

---------------------------------------------------------

Protocol may assume:
external interaction succeeded.

---------------------------------------------------------

Reality:
it failed completely.

---------------------------------------------------------
WHY THIS MATTERS
---------------------------------------------------------

Unchecked external calls caused:

- stuck funds
- accounting corruption
- broken logic
- DOS vulnerabilities
- protocol inconsistencies

---------------------------------------------------------
REAL-WORLD USAGE
---------------------------------------------------------

External calls exist in:

- token transfers
- swaps
- governance execution
- vault withdrawals
- bridges
- staking systems

---------------------------------------------------------
AUDITOR FOCUS
---------------------------------------------------------

Auditors ALWAYS inspect:

- ignored success booleans
- unchecked external calls
- silent failures
- accounting assumptions
- inconsistent state

=========================================================
MALICIOUS / FAILING CONTRACT
=========================================================
*/
/*
contract RejectETH {

    /*
        Track calls
    
    uint256 public counter;

    /*
    =====================================================
    ALWAYS REVERT ON ETH
    =====================================================
    

    receive()
        external
        payable
    {

        revert("ETH rejected");
    }

    /*
    =====================================================
    ALWAYS FAIL FUNCTION
    =====================================================
    

    function failFunction()
        external
        pure
    {

        revert("Function failed");
    }

    /*
    =====================================================
    SUCCESS FUNCTION
    =====================================================
    

    function successFunction()
        external
    {

        /*
            Increment counter.
        
        counter++;
    }
}

/*
=========================================================
VULNERABLE CONTRACT
=========================================================


contract DangerousUncheckedCall {

    /*
        USER BALANCES
    
    mapping(address => uint256) public balances;

    /*
        TRACK WITHDRAWALS
    
    mapping(address => bool) public withdrawn;

    /*
    =====================================================
    DEPOSIT ETH
    =====================================================
    

    function deposit()
        external
        payable
    {

        balances[msg.sender] += msg.value;
    }

    /*
    =====================================================
    DANGEROUS WITHDRAW
    =====================================================

    PROBLEM:
    ignores success boolean.
    

    function dangerousWithdraw(
        address payable _receiver,
        uint256 _amount
    )
        external
    {

        /*
            Validate balance.
        
        require(
            balances[msg.sender] >= _amount,
            "Insufficient balance"
        );

        /*
            EFFECTS:
            Update storage FIRST.
        
        balances[msg.sender] -= _amount;

        withdrawn[msg.sender] = true;

        /*
        =================================================
        DANGEROUS EXTERNAL CALL
        =================================================

        ETH transfer may FAIL.

        BUT:
        success boolean ignored.
        

        _receiver.call{
            value: _amount
        }("");

        /*
            Execution continues regardless.

            HUGE PROBLEM.
        
    }

    /*
    =====================================================
    SAFE VERSION
    =====================================================
    

    function safeWithdraw(
        address payable _receiver,
        uint256 _amount
    )
        external
    {

        /*
            Validate balance.
        
        require(
            balances[msg.sender] >= _amount,
            "Insufficient balance"
        );

        /*
            Update storage.
        
        balances[msg.sender] -= _amount;

        /*
            Properly check success.
        
        (bool success, ) =
            _receiver.call{
                value: _amount
            }("");

        /*
            Revert if transfer failed.
        
        require(
            success,
            "ETH transfer failed"
        );
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
Deploy RejectETH

---------------------------------------------------------

STEP 2:
Deploy DangerousUncheckedCall

=========================================================
TRACE:
dangerousWithdraw()
=========================================================

STEP 1:
User deposits ETH.

---------------------------------------------------------

balances[user] = 1 ETH

=========================================================
STEP 2
=========================================================

Call:
dangerousWithdraw()

---------------------------------------------------------

Receiver:
RejectETH contract

=========================================================
STEP 3
=========================================================

Balance validation passes.

=========================================================
STEP 4
=========================================================

Storage updated FIRST.

---------------------------------------------------------

balances[user] -= 1 ETH

---------------------------------------------------------

withdrawn[user] = true

=========================================================
STEP 5
=========================================================

External ETH call executes.

---------------------------------------------------------

Receiver contract:
REVERTS intentionally.

=========================================================
STEP 6
=========================================================

IMPORTANT:

call() returns:

success = false

---------------------------------------------------------

BUT:

success is IGNORED.

=========================================================
STEP 7
=========================================================

Execution continues normally.

---------------------------------------------------------

Transaction DOES NOT revert.

=========================================================
FINAL RESULT
=========================================================

PROBLEM:

---------------------------------------------------------
USER BALANCE REDUCED
---------------------------------------------------------

YES

---------------------------------------------------------
withdrawn FLAG SET
---------------------------------------------------------

YES

---------------------------------------------------------
ETH ACTUALLY TRANSFERRED?
---------------------------------------------------------

NO

=========================================================
CRITICAL VULNERABILITY
=========================================================

Internal accounting says:
withdraw succeeded.

---------------------------------------------------------

Reality:
ETH never transferred.

=========================================================
WHY THIS IS DANGEROUS
=========================================================

Creates:
INCONSISTENT STATE.

---------------------------------------------------------

Protocol assumptions become false.

=========================================================
SAFE VERSION TRACE
=========================================================

safeWithdraw()

=========================================================

STEP 1:
External call fails.

---------------------------------------------------------

success = false

=========================================================
STEP 2
=========================================================

require(success)

---------------------------------------------------------

Transaction REVERTS.

=========================================================
STEP 3
=========================================================

ALL state changes rollback.

---------------------------------------------------------

balances restored.

---------------------------------------------------------

No inconsistent state.

=========================================================
REMIX TESTING
=========================================================

STEP 1:
Deploy RejectETH

---------------------------------------------------------

STEP 2:
Deploy DangerousUncheckedCall

---------------------------------------------------------

STEP 3:
Deposit 1 ETH

---------------------------------------------------------

STEP 4:
Call:
dangerousWithdraw()

Inputs:
- RejectETH address
- 1 ether

---------------------------------------------------------

EXPECTED:
Transaction succeeds unexpectedly.

=========================================================
STEP 5
=========================================================

Check:

balances(user)

EXPECTED:
0

---------------------------------------------------------

withdrawn(user)

EXPECTED:
true

---------------------------------------------------------

BUT:
RejectETH received NO ETH.

=========================================================
STEP 6
=========================================================

Test:
safeWithdraw()

---------------------------------------------------------

EXPECTED:
Transaction reverts safely.

=========================================================
IMPORTANT LOW-LEVEL CALL UNDERSTANDING
=========================================================

call() NEVER auto-reverts.

---------------------------------------------------------

Developer MUST manually check:

success

=========================================================
COMMON AUDIT RISKS
=========================================================

---------------------------------------------------------
1. UNCHECKED RETURN VALUES
---------------------------------------------------------

Classic Solidity vulnerability.

---------------------------------------------------------
2. ACCOUNTING CORRUPTION
---------------------------------------------------------

Internal state diverges from reality.

---------------------------------------------------------
3. SILENT FAILURES
---------------------------------------------------------

Protocol believes operation succeeded.

---------------------------------------------------------
4. DOS CONDITIONS
---------------------------------------------------------

Malicious contracts block execution silently.

=========================================================
IMPORTANT SECURITY CONCEPT
=========================================================

External calls are:
UNTRUSTED INTERACTIONS.

---------------------------------------------------------

Assume:
external execution may fail.

=========================================================
ATTACK THINKING
=========================================================

Attacker intentionally:

- rejects ETH
- reverts calls
- breaks assumptions
- causes inconsistent state

---------------------------------------------------------

Protocol logic becomes corrupted.

=========================================================
SECURITY / AUDITOR MINDSET
=========================================================

Auditors ALWAYS search for:

---------------------------------------------------------
.call(
---------------------------------------------------------

without:

---------------------------------------------------------
require(success)
---------------------------------------------------------

=========================================================
REAL AUDITOR PROCESS
=========================================================

Auditors trace:

1. External interaction
2. Failure handling
3. Return-value checks
4. Accounting consistency
5. Silent-failure paths

=========================================================
WHY THIS BUG IS SUBTLE
=========================================================

Transaction appears:
successful.

---------------------------------------------------------

But:
protocol state corrupted internally.

=========================================================
MINI CHALLENGE
=========================================================

Modify contract so that:

1. Add event logging
2. Add try/catch handling
3. Add revert-message decoding
4. Compare checked vs unchecked execution

BONUS:
Create token-transfer version
of unchecked-call bug.

=========================================================
IMPORTANT CONCEPTS LEARNED
=========================================================

- call() returns success manually
- Ignoring success is dangerous
- External calls may silently fail
- Silent failures corrupt accounting
- Transactions only revert if forced
- require(success) prevents inconsistencies
- Unchecked calls are major audit issue
- External interactions are untrusted
- Auditors inspect return-value handling carefully
- Error handling is critical in Solidity security

=========================================================
*/
/*
Audit Report
Title: Unchecked Loe-Level Call in dangerousWithdraw()

Severity: High

Reason:
The contract performs a low-level .call() to transfer ETH but ignores the returned
success boolean.

Location:
Contract: DangerousUncheckedCall
Function: dangerousWithdraw()

Vulnerability Description:
The dangerousWithdraw() function sends ETH using low-level call:
_reciver.call{value: _amount}("");
However, the returned success value is ignored.
if the reciver contract rejects ETH transfers or reverts during execution, the ETH 
transfer fails silently while the protocol state is still updated.

The function:
1. deducts user balance
2. marks withdrawl as completed
3. continues execution even when transfer failed
This creates inconsistent accounting and loss of funds

Impact:
An attacker or incompatible receiver contract can cause:
1. permanent user fund loss
2. incorrect accounting
3. false withdrawl records
4. broken protocol state
Example consequences:
1. user balance reduced even through ETH never arrived
2. withdraw[msg.sender] = true despite failed transfer
3. Locked ETH remains trapped inside protocol

Proof of Concept:
step 1 -Deploy RejectETH
This contract always reverts on ETH reception.
reciver() external payable {
    revert("ETH rejected");
}

Step 2 -Deposite ETH
User deposites 1 ETH into DangerousUncheckedCall.
deposite{value: 1 ether}()

Step 3 -Call dangerousWithdraw()
dangerousWithdraw(rejectContract, 1  ether)

Result:
The low-level call fails internally:
_receiver.call{value:_amount}("");
BUT execution continues.

State changes remain:
balances[msg.sender] -= _amount;
withdrawn[msg.sender] = true;
ETH never leaves the contract.
User loses withdrawable balace.

Root Cause:
Low-level calls return:
(bool success, bytes memory data)
The contract ignores the success value completely.

No validation exists after the external call

Recommendation:
Always validate low-level call success.

Example:
(bool success, ) = _receiver.call{value:_amount}("");
require(success, "ETH transfer failed");
Additionally:
1. emit events
2. decode revert reasons
3. use try/catch patterns where applicable
4. follow Checks-Effects-Interactions carefully

Patched Code
*/
/*
=========================================================
REJECT ETH RECEIVER
=========================================================
*/

contract RejectETH {

    uint256 public counter;

    event ReceiveAttempt(
        address indexed sender,
        uint256 amount
    );

    event FunctionFailure(
        address indexed caller,
        string reason
    );

    receive()
        external
        payable
    {
        emit ReceiveAttempt(
            msg.sender,
            msg.value
        );

        revert("ETH rejected");
    }

    function failFunction()
        external
        pure
    {
        revert("Function failed");
    }

    function successFunction()
        external
    {
        counter++;
    }
}

/*
=========================================================
INTERFACE FOR TRY/CATCH
=========================================================
*/

interface IRejectETH {

    function failFunction()
        external;

    function successFunction()
        external;
}

/*
=========================================================
PATCHED + DEMO CONTRACT
=========================================================
*/

contract CheckedVsUnchecked {

    /*
    =====================================================
    STORAGE
    =====================================================
    */

    mapping(address => uint256)
        public balances;

    mapping(address => bool)
        public withdrawn;

    /*
    =====================================================
    EVENTS
    =====================================================
    */

    event Deposit(
        address indexed user,
        uint256 amount
    );

    event WithdrawAttempt(
        address indexed user,
        address indexed receiver,
        uint256 amount
    );

    event WithdrawSuccess(
        address indexed user,
        address indexed receiver,
        uint256 amount
    );

    event WithdrawFailure(
        address indexed user,
        address indexed receiver,
        uint256 amount,
        string reason
    );

    event LowLevelResult(
        bool success,
        bytes data
    );

    event TryCatchSuccess(
        address target
    );

    event TryCatchFailure(
        string reason
    );

    /*
    =====================================================
    DEPOSIT
    =====================================================
    */

    function deposit()
        external
        payable
    {
        balances[msg.sender] += msg.value;

        emit Deposit(
            msg.sender,
            msg.value
        );
    }

    /*
    =====================================================
    UNCHECKED VERSION
    =====================================================
    */

    function dangerousWithdraw(
        address payable receiver,
        uint256 amount
    )
        external
    {
        require(
            balances[msg.sender] >= amount,
            "Insufficient balance"
        );

        balances[msg.sender] -= amount;

        withdrawn[msg.sender] = true;

        emit WithdrawAttempt(
            msg.sender,
            receiver,
            amount
        );

        /*
            BUG:
            success ignored
        */
        (bool success, bytes memory data) =
            receiver.call{value: amount}("");

        emit LowLevelResult(
            success,
            data
        );

        /*
            Execution continues anyway.
        */
    }

    /*
    =====================================================
    SAFE VERSION
    =====================================================
    */

    function safeWithdraw(
        address payable receiver,
        uint256 amount
    )
        external
    {
        require(
            balances[msg.sender] >= amount,
            "Insufficient balance"
        );

        emit WithdrawAttempt(
            msg.sender,
            receiver,
            amount
        );

        /*
            INTERACTION
        */
        (bool success, bytes memory data) =
            receiver.call{value: amount}("");

        /*
            CHECK RESULT
        */
        if (!success) {

            string memory revertReason =
                _getRevertMsg(data);

            emit WithdrawFailure(
                msg.sender,
                receiver,
                amount,
                revertReason
            );

            revert(revertReason);
        }

        /*
            EFFECTS ONLY AFTER SUCCESS
        */
        balances[msg.sender] -= amount;

        withdrawn[msg.sender] = true;

        emit WithdrawSuccess(
            msg.sender,
            receiver,
            amount
        );
    }

    /*
    =====================================================
    TRY/CATCH DEMO
    =====================================================
    */

    function testTryCatch(
        address target,
        bool shouldFail
    )
        external
    {
        if (shouldFail) {

            try
                IRejectETH(target)
                    .failFunction()
            {
                emit TryCatchSuccess(
                    target
                );

            } catch Error(
                string memory reason
            ) {

                emit TryCatchFailure(
                    reason
                );

            } catch {

                emit TryCatchFailure(
                    "Unknown failure"
                );
            }

        } else {

            try
                IRejectETH(target)
                    .successFunction()
            {
                emit TryCatchSuccess(
                    target
                );

            } catch Error(
                string memory reason
            ) {

                emit TryCatchFailure(
                    reason
                );

            } catch {

                emit TryCatchFailure(
                    "Unknown failure"
                );
            }
        }
    }

    /*
    =====================================================
    REVERT MESSAGE DECODER
    =====================================================
    */

    function _getRevertMsg(
        bytes memory revertData
    )
        internal
        pure
        returns (string memory)
    {
        /*
            Empty revert data
        */
        if (revertData.length < 68) {
            return "Transaction reverted silently";
        }

        assembly {
            revertData := add(revertData, 0x04)
        }

        return abi.decode(
            revertData,
            (string)
        );
    }

    /*
    =====================================================
    CONTRACT BALANCE
    =====================================================
    */

    function contractBalance()
        external
        view
        returns (uint256)
    {
        return address(this).balance;
    }
}
