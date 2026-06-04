// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/*
=========================================================
PRACTICAL: Send ETH using call
CONCEPT: Low-level call behavior
=========================================================

OBJECTIVE

- Learn how call() sends ETH
- Understand low-level external calls
- Learn return-value handling
- Understand dangerous execution behavior

---------------------------------------------------------
CORE IDEA
---------------------------------------------------------

call() is the most flexible
and dangerous external interaction method.

---------------------------------------------------------
IMPORTANT UNDERSTANDING
---------------------------------------------------------

call():

- can send ETH
- can call functions
- forwards remaining gas
- returns success/failure manually

---------------------------------------------------------
WHY THIS MATTERS
---------------------------------------------------------

Modern Solidity commonly uses:
call{value: amount}()

instead of transfer().

---------------------------------------------------------
REAL-WORLD USAGE
---------------------------------------------------------

call() used in:

- DeFi protocols
- vaults
- proxies
- multicall systems
- upgradeable contracts
- bridges

---------------------------------------------------------
AUDITOR FOCUS
---------------------------------------------------------

Auditors inspect:

- reentrancy windows
- unchecked return values
- external-call ordering
- arbitrary call risks
- gas forwarding behavior

=========================================================
*/
/*
contract LowLevelCallExample {

    /*
        USER BALANCES
    
    mapping(address => uint256) public balances;

    /*
    =====================================================
    DEPOSIT ETH
    ====================================================
    

    function deposit()
        external
        payable
    {

        /*
            Store ETH balance.
        
        balances[msg.sender] += msg.value;
    }

    /*
    =====================================================
    SAFE WITHDRAW USING call()
    =====================================================
    

    function safeWithdraw(
        uint256 _amount
    )
        external
    {

        /*
            CHECK:
            Ensure sufficient balance.
        
        require(
            balances[msg.sender] >= _amount,
            "Insufficient balance"
        );

        /*
            EFFECTS:
            Update storage BEFORE interaction.

            CEI pattern.
        
        balances[msg.sender] -= _amount;

        /*
            INTERACTION:
            Send ETH using low-level call.

            Syntax:
            address.call{value: amount}("")
        
        (bool success, ) =
            payable(msg.sender).call{
                value: _amount
            }("");

        /*
            IMPORTANT:
            call() does NOT auto-revert.

            Must manually check success.
        
        require(
            success,
            "ETH transfer failed"
        );
    }

    /*
    =====================================================
    DANGEROUS WITHDRAW
    =====================================================

    INTENTIONALLY VULNERABLE
    

    function vulnerableWithdraw(
        uint256 _amount
    )
        external
    {

        /*
            Validation.
        
        require(
            balances[msg.sender] >= _amount,
            "Insufficient balance"
        );

        /*
            DANGEROUS ORDER:

            External call BEFORE
            state update.
        
        (bool success, ) =
            payable(msg.sender).call{
                value: _amount
            }("");

        require(
            success,
            "Transfer failed"
        );

        /*
            STATE UPDATED TOO LATE.

            Reentrancy risk.
        
        balances[msg.sender] -= _amount;
    }

    /*
    =====================================================
    CHECK CONTRACT ETH BALANCE
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
User deposits ETH.

---------------------------------------------------------

CALL:
deposit()

VALUE:
1 ETH

=========================================================
DEPOSIT TRACE
=========================================================

STEP 1:
msg.value = 1 ETH

---------------------------------------------------------

STEP 2:
balances[Alice] += 1 ETH

---------------------------------------------------------

STEP 3:
Contract receives ETH.

=========================================================
SAFE WITHDRAW TRACE
=========================================================

CALL:
safeWithdraw(1 ETH)

=========================================================

STEP 1:
Balance validated.

---------------------------------------------------------

balances[Alice] >= 1 ETH

RESULT:
true

---------------------------------------------------------
STEP 2:
Storage updated FIRST.

balances[Alice] -= 1 ETH

---------------------------------------------------------

NEW VALUE:
0

---------------------------------------------------------
STEP 3:
Low-level external call executes.

call{value: 1 ETH}("")

---------------------------------------------------------

ETH transferred externally.

---------------------------------------------------------
STEP 4:
success returned.

success = true

---------------------------------------------------------
STEP 5:
require(success)

RESULT:
true

---------------------------------------------------------

TRANSACTION SUCCEEDS

=========================================================
VERY IMPORTANT call() UNDERSTANDING
=========================================================

call():

- forwards remaining gas
- allows arbitrary execution
- returns success manually

---------------------------------------------------------

Unlike transfer():

call() does NOT auto-revert.

=========================================================
RETURN VALUES
=========================================================

call() returns:

(bool success, bytes memory data)

---------------------------------------------------------

success:
true/false

---------------------------------------------------------

data:
returned function data

=========================================================
WHY call() IS DANGEROUS
=========================================================

Receiving contract gets:
almost ALL remaining gas.

---------------------------------------------------------

Meaning:
receiver can execute complex logic.

---------------------------------------------------------

Including:
reentrant attacks.

=========================================================
VULNERABLE TRACE
=========================================================

CALL:
vulnerableWithdraw(1 ETH)

=========================================================

STEP 1:
Validation passes.

---------------------------------------------------------

STEP 2:
External call executes FIRST.

---------------------------------------------------------

Attacker contract receives ETH.

---------------------------------------------------------

fallback()/receive() executes.

---------------------------------------------------------

Attacker reenters:
vulnerableWithdraw()

---------------------------------------------------------

IMPORTANT:
balance NOT reduced yet.

---------------------------------------------------------

Multiple withdrawals possible.

=========================================================
REMIX TESTING
=========================================================

STEP 1:
Deploy contract

---------------------------------------------------------

STEP 2:
In VALUE field:
enter 1 ether

---------------------------------------------------------

STEP 3:
Call:
deposit()

---------------------------------------------------------

STEP 4:
Call:
contractBalance()

EXPECTED:
1 ETH in wei

---------------------------------------------------------

STEP 5:
Call:
safeWithdraw(0.5 ether)

---------------------------------------------------------

STEP 6:
Call:
balances(your_address)

EXPECTED:
0.5 ETH remaining

=========================================================
IMPORTANT DIFFERENCE
=========================================================

---------------------------------------------------------
transfer()
---------------------------------------------------------

- 2300 gas
- auto-reverts
- limited execution

---------------------------------------------------------
call()
---------------------------------------------------------

- forwards gas
- manual success handling
- highly flexible
- more dangerous

=========================================================
MODERN SOLIDITY PREFERENCE
=========================================================

Modern Solidity often prefers:

call{value: amount}()

---------------------------------------------------------

Reason:
transfer() gas assumptions outdated.

=========================================================
COMMON AUDIT RISKS
=========================================================

---------------------------------------------------------
1. REENTRANCY
---------------------------------------------------------

Largest risk with call().

---------------------------------------------------------
2. UNCHECKED SUCCESS
---------------------------------------------------------

ETH transfer may silently fail.

---------------------------------------------------------
3. ARBITRARY EXECUTION
---------------------------------------------------------

Receiver contract may behave maliciously.

---------------------------------------------------------
4. DOS RISKS
---------------------------------------------------------

Receiver intentionally reverts.

=========================================================
IMPORTANT SECURITY CONCEPT
=========================================================

Every external call =
UNTRUSTED EXECUTION

---------------------------------------------------------

Never trust:
receiver behavior.

=========================================================
CEI PATTERN
=========================================================

SAFE ORDER:

1. CHECKS
2. EFFECTS
3. INTERACTIONS

---------------------------------------------------------

safeWithdraw() follows this.

=========================================================
GAS OBSERVATION
=========================================================

call():
forwards remaining gas by default.

---------------------------------------------------------

Makes execution more flexible,
but more dangerous.

=========================================================
SECURITY / AUDITOR MINDSET
=========================================================

Auditors ask:

- Is call() ordered safely?
- Can receiver reenter?
- Is success checked?
- Can ETH become stuck?
- Is arbitrary execution possible?

=========================================================
ATTACK THINKING
=========================================================

ATTACK SCENARIO

Malicious receiver contract:

1. receives ETH
2. fallback() triggers
3. reenters vulnerable function
4. drains contract repeatedly

=========================================================
REAL AUDITOR PROCESS
=========================================================

Auditors trace:

1. External interaction timing
2. State-update ordering
3. Gas forwarding behavior
4. Reentrancy windows
5. Failure handling

=========================================================
MINI CHALLENGE
=========================================================

Modify contract so that:

1. Add nonReentrant modifier
2. Protect vulnerableWithdraw()
3. Add event emission
4. Handle failed transfers safely

BONUS:
Create attacker contract
to simulate reentrancy.

=========================================================
IMPORTANT CONCEPTS LEARNED
=========================================================

- call() sends ETH using low-level interaction
- call() forwards remaining gas
- call() requires manual success checking
- call() enables arbitrary external execution
- Reentrancy risk increases heavily with call()
- CEI pattern improves safety
- External calls are untrusted interactions
- State updates must occur before call()
- Auditors inspect call() extremely carefully
- Low-level calls are core to DeFi architecture

=========================================================
*/
/*
Audit Report
Title
Reentrancy Vulnerability in vulnerableWithdraw()

Severity: High

Location:
Contract:
LowLevelCallExample

Function:
vulnerableWithdraw(uint256 _amount)

Vulnerability Description:
The vulnerableWithdraw() function is vulnerable to a reentrancy attack because it
performs an eternal ETH transfer using call() before updating the users balance.

An attacker can exploit this by creating a malicious contract with a fallback/receive
function that recursively calls vulnerableWithdraw() before tha balance is reduced.


Impact:
An attacker can:
1. Re-enter the contract multiple times
2. Drain ETH from the contract
3. Bypass intended balance accounting
4. Steal funds belonging to other users

This can lead to complete loss of contract funds.

Proof of Concept:
Attack flow
1. Attacker deposites ETH.
2. Attacker calls vulnerableWithdraw()
3. Contract sends ETH before updating storage.
4. Attacker fallback function re-enters vulnerableWithdraw().
5. Funds are drained repeatedly

Root cause:
The contract violates the CEI patteren:
external interaction occurs BEFORE state update.

Vulnerable Code:
(bool success, ) =
    payable(msg.sender).call{
        value: _amount
    }("");

require(success, "Transfer failed");

balances[msg.sender] -= _amount;

Recommendation:
implement:
1. nonReentrant modifier
2. CEI pattern
3. Event emission
4. safe transfer failure handling

Patched contract
*/
contract LowLevelCallExample {

    /*
    =====================================================
    STATE VARIABLES
    =====================================================
    */

    mapping(address => uint256) public balances;

    /*
        Reentrancy lock.
    */
    bool private locked;

    /*
    =====================================================
    EVENTS
    =====================================================
    */

    event Deposit(
        address indexed user,
        uint256 amount
    );

    event Withdraw(
        address indexed user,
        uint256 amount
    );

    event TransferFailed(
        address indexed user,
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
    DEPOSIT ETH
    =====================================================
    */

    function deposit()
        external
        payable
    {

        require(
            msg.value > 0,
            "Must send ETH"
        );

        balances[msg.sender] += msg.value;

        emit Deposit(
            msg.sender,
            msg.value
        );
    }

    /*
    =====================================================
    SAFE WITHDRAW
    =====================================================
    */

    function safeWithdraw(
        uint256 _amount
    )
        external
        nonReentrant
    {

        /*
            CHECKS
        */
        require(
            balances[msg.sender] >= _amount,
            "Insufficient balance"
        );

        /*
            EFFECTS
        */
        balances[msg.sender] -= _amount;

        /*
            INTERACTION
        */
        (bool success, ) =
            payable(msg.sender).call{
                value: _amount
            }("");

        /*
            HANDLE FAILED TRANSFER
        */
        if (!success) {

            /*
                Restore balance.
            */
            balances[msg.sender] += _amount;

            emit TransferFailed(
                msg.sender,
                _amount
            );

            revert("ETH transfer failed");
        }

        emit Withdraw(
            msg.sender,
            _amount
        );
    }

    /*
    =====================================================
    PATCHED VULNERABLE WITHDRAW
    =====================================================
    */

    function vulnerableWithdraw(
        uint256 _amount
    )
        external
        nonReentrant
    {

        /*
            CHECKS
        */
        require(
            balances[msg.sender] >= _amount,
            "Insufficient balance"
        );

        /*
            EFFECTS FIRST
            (CEI PATTERN)
        */
        balances[msg.sender] -= _amount;

        /*
            INTERACTION
        */
        (bool success, ) =
            payable(msg.sender).call{
                value: _amount
            }("");

        /*
            HANDLE FAILURE SAFELY
        */
        if (!success) {

            /*
                Restore balance.
            */
            balances[msg.sender] += _amount;

            emit TransferFailed(
                msg.sender,
                _amount
            );

            revert("Transfer failed");
        }

        emit Withdraw(
            msg.sender,
            _amount
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
