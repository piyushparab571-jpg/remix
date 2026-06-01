// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/*
=========================================================
PRACTICAL: Send ETH using transfer
CONCEPT: ETH transfer mechanics
=========================================================

OBJECTIVE

- Learn how transfer() sends ETH
- Understand native ETH movement
- Learn payable mechanics
- Understand transfer limitations + risks

---------------------------------------------------------
CORE IDEA
---------------------------------------------------------

transfer() sends native ETH
from one contract/address to another.

---------------------------------------------------------
IMPORTANT UNDERSTANDING
---------------------------------------------------------

ETH transfers:
trigger external execution.

---------------------------------------------------------

Receiving contracts may execute:
receive() or fallback().

---------------------------------------------------------
WHY THIS MATTERS
---------------------------------------------------------

ETH transfers are fundamental to:

- withdrawals
- payments
- staking
- refunds
- treasury systems
- DeFi protocols

---------------------------------------------------------
REAL-WORLD USAGE
---------------------------------------------------------

ETH transfer logic used in:

- exchanges
- vaults
- DAOs
- staking systems
- NFT marketplaces
- lending protocols

---------------------------------------------------------
AUDITOR FOCUS
---------------------------------------------------------

Auditors inspect:

- transfer ordering
- reentrancy risk
- failed transfer handling
- locked ETH risks
- DOS vectors

=========================================================
*/

contract EthTransferMechanics {

    /*
        USER BALANCES
    */
    mapping(address => uint256) public balances;

    /*
    =====================================================
    DEPOSIT ETH
    =====================================================

    payable:
    function can receive ETH.
    */

    function deposit()
        external
        payable
    {

        /*
            msg.value:
            ETH sent with transaction.
        */
        require(
            msg.value > 0,
            "No ETH sent"
        );

        /*
            Store deposited ETH amount.
        */
        balances[msg.sender] += msg.value;
    }

    /*
    =====================================================
    SEND ETH USING transfer()
    =====================================================
    */

    function withdraw(
        uint256 _amount
    )
        external
    {

        /*
            CHECK:
            user must have balance.
        */
        require(
            balances[msg.sender] >= _amount,
            "Insufficient balance"
        );

        /*
            EFFECTS:
            update storage BEFORE transfer.

            CEI pattern:
            Checks -> Effects -> Interactions
        */
        balances[msg.sender] -= _amount;

        /*
            INTERACTION:
            send ETH externally.

            transfer():
            - sends ETH
            - forwards 2300 gas
            - reverts automatically if failed
        */
        payable(msg.sender).transfer(_amount);
    }

    /*
    =====================================================
    CHECK CONTRACT ETH BALANCE
    =====================================================
    */

    function contractBalance()
        external
        view
        returns (uint256)
    {

        /*
            address(this).balance

            Native ETH stored
            inside this contract.
        */
        return address(this).balance;
    }
}

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
Transaction carries ETH.

---------------------------------------------------------

msg.value = 1 ETH

---------------------------------------------------------

STEP 2:
require(msg.value > 0)

RESULT:
true

---------------------------------------------------------

STEP 3:
Storage updated.

balances[Alice] += 1 ETH

---------------------------------------------------------

STEP 4:
Contract receives ETH.

---------------------------------------------------------

CONTRACT BALANCE:
1 ETH

=========================================================
WITHDRAW TRACE
=========================================================

CALL:
withdraw(1 ETH)

=========================================================

STEP 1:
Balance validation.

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
ETH transfer executes.

payable(msg.sender).transfer(1 ETH)

---------------------------------------------------------

ETH leaves contract.

---------------------------------------------------------

Alice receives ETH.

=========================================================
IMPORTANT transfer() UNDERSTANDING
=========================================================

transfer():

- sends native ETH
- forwards ONLY 2300 gas
- auto-reverts on failure

=========================================================
VERY IMPORTANT:
2300 GAS LIMIT
=========================================================

Receiving contract gets:

ONLY 2300 gas

---------------------------------------------------------

This usually prevents:
complex execution.

---------------------------------------------------------

Historically helped reduce:
reentrancy risk.

=========================================================
WHAT HAPPENS INTERNALLY
=========================================================

transfer():

1. deducts ETH from sender contract
2. sends ETH externally
3. triggers receiver execution
4. reverts if receiver fails

=========================================================
REMIX TESTING
=========================================================

STEP 1:
Deploy contract

---------------------------------------------------------

STEP 2:
Expand VALUE field in Remix

---------------------------------------------------------

STEP 3:
Enter:
1 ether

---------------------------------------------------------

STEP 4:
Call:
deposit()

---------------------------------------------------------

STEP 5:
Call:
contractBalance()

EXPECTED:
1000000000000000000

(1 ETH in wei)

---------------------------------------------------------

STEP 6:
Call:
balances(your_address)

EXPECTED:
1 ETH in wei

---------------------------------------------------------

STEP 7:
Call:
withdraw(500000000000000000)

(0.5 ETH)

---------------------------------------------------------

STEP 8:
Call:
balances(your_address)

EXPECTED:
0.5 ETH remaining

=========================================================
IMPORTANT PAYABLE UNDERSTANDING
=========================================================

Functions receiving ETH
must be marked:

payable

---------------------------------------------------------

Otherwise:
transaction reverts.

=========================================================
WEI UNDERSTANDING
=========================================================

1 ETH =
1,000,000,000,000,000,000 wei

---------------------------------------------------------

Solidity stores ETH in:
wei internally.

=========================================================
COMMON AUDIT RISKS
=========================================================

---------------------------------------------------------
1. REENTRANCY
---------------------------------------------------------

External ETH transfer dangerous
if state updated too late.

---------------------------------------------------------
2. DOS VIA transfer()
---------------------------------------------------------

2300 gas may break receivers.

---------------------------------------------------------
3. LOCKED ETH
---------------------------------------------------------

No withdraw path exists.

---------------------------------------------------------
4. FAILED TRANSFER ASSUMPTIONS
---------------------------------------------------------

Receiver may revert intentionally.

=========================================================
IMPORTANT SECURITY CONCEPT
=========================================================

External ETH transfer =
external interaction.

---------------------------------------------------------

Treat as:
UNTRUSTED execution.

=========================================================
CEI PATTERN
=========================================================

SAFE ORDER:

1. CHECKS
2. EFFECTS
3. INTERACTIONS

---------------------------------------------------------

Used in withdraw() above.

=========================================================
WHY transfer() BECAME LESS PREFERRED
=========================================================

Modern Solidity often prefers:

call{value: amount}()

---------------------------------------------------------

Reason:
2300 gas assumptions became unreliable.

=========================================================
SECURITY / AUDITOR MINDSET
=========================================================

Auditors ask:

- Is ETH transfer ordered safely?
- Can receiver reenter?
- Can transfer fail unexpectedly?
- Is ETH permanently lockable?
- Are balances updated before transfer?

=========================================================
ATTACK THINKING
=========================================================

ATTACK SCENARIO

State updated AFTER transfer.

---------------------------------------------------------

Attacker contract:
reenters withdraw repeatedly.

---------------------------------------------------------

Result:
fund theft.

=========================================================
REAL AUDITOR PROCESS
=========================================================

Auditors trace:

1. ETH movement
2. State-update ordering
3. External interaction timing
4. Revert behavior
5. Receiver execution flow

=========================================================
MINI CHALLENGE
=========================================================

Modify contract so that:

1. Add vulnerable withdraw()
2. Move transfer BEFORE balance update
3. Analyze reentrancy risk
4. Fix using CEI pattern

BONUS:
Implement withdraw using:
call{value: amount}()

=========================================================
IMPORTANT CONCEPTS LEARNED
=========================================================

- transfer() sends native ETH
- payable functions receive ETH
- msg.value contains sent ETH
- transfer() forwards 2300 gas
- External ETH transfers are dangerous
- CEI pattern improves security
- State must update before transfer
- ETH stored internally as wei
- Auditors trace ETH movement carefully
- Interactions create reentrancy risk

=========================================================
*/
/*
Audit Report
Title
Reentrancy Vulnerability via incorrect ETH Transfer Ordering

Severity: High

Reason
Extrenal ETH transfer occurs before internal balance reduction, exposing a
reentrancy window.

Location
contract: 

Function:vulnerableWithdraw()

Contract Explanation
The contract demonstrates how ETH transfers work i solidity and why 
execution order is security critical.

Safe pattern used
CHECKS --> EFFECTS --> INTERACTIONS(CEI)

CHECKS
require(
    balances[msg.sender] >= _amount,
    "Insufficient balance"
);
validates user balance

EFFECTS
balances[msg.sender] -= _amount;
Updates storage BEFORE external interaction.

INTERACTIONS
payable(msg.sender).transfer(_amount);
Sends ETH externally.

Vulnerability Analysis

Root Cause
The external interaction occurs BEFORE storageupdate.

Bad execution order:
1. CHECKS
2. INTERACTIONS
3. EFFFECTS

correct execution order:
1. CHECKS
2. EFFECTS
3. INTERACTIONS

Reentrancy Attack Scenario

Initial state:

balances[attacker] = 10 ETH
Step 1 — Attacker Calls
vulnerableWithdraw(10 ether)
Check passes

Step 2 — External ETH Transfer Executes
call{value:10 ether}
Attacker contract receives ETH.
Fallback function executes automatically.

Step 3 — Reentrancy
Inside fallback:
vulnerableWithdraw(10 ether)
is called AGAIN.

Problem
Balance was NOT reduced yet.
So:
balances[attacker] >= 10 ether
still evaluates TRUE.

Result
Attacker repeatedly drains contract ETH.

Patched code
*/
/*
INCORRECT IMPLEMENTATION

contract VulnerableETHTransfer {
    mapping(address => uint256) public balances;
    /*
    =======================================
    DEPOSIT ETH
    =======================================
    
    function deposite()
    external
    payable
 {
    require(msg.value > 0, "No ETH sent");
    balances[msg.sender] += msg.value;
 }    
    /*
    ==============================
    VULNERABLE WITHDRAW
    ==============================
    PROBLEM:
    ETH transfer happens BEFORE balance update.
    This allows reentrancy attacks.
    
    function withdraw(uint256 _amount)
    external
    {
        require(
            balances[msg.sender] >= _amount,
            "Insufficient balance"
        );
        /*
        INTERACTION FIRST (BAD)
        
        payable(msg.sender).transfer(_amount);
        /*
        EFFECTS AFTER INTERACTION (BAD)
        Attacker can re-enter BEFORE
        this line executes.
        
        balances[msg.sender] -= _amount;
    }
    function contractBalance()
    external 
    view
    returns (uint256)
    {
        return address(this).balance;

    }
   
}
*/
//CORRECT IMPLEMENTATION
contract SecureEthTransfer {
    mapping(address => uint256) public balances;
    function deposit()
        external
        payable
    {
        require(msg.value > 0, "No ETH sent");
        balances[msg.sender] += msg.value;
    }
    /*
    =====================================================
    SECURE WITHDRAW (CEI PATTERN)
    =====================================================
    */
    function withdraw(uint256 _amount)
        external
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
            Update storage FIRST
        */
        balances[msg.sender] -= _amount;
        /*
            INTERACTIONS
            External call LAST
        */
        payable(msg.sender).transfer(_amount);
    }
    function contractBalance()
        external
        view
        returns (uint256)
    {
        return address(this).balance;
    }
}