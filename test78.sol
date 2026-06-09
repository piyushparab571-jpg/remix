// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/*
=========================================================
PRACTICAL: Fix Reentrancy using CEI Pattern
CONCEPT: Secure execution order
=========================================================

OBJECTIVE

- Fix reentrancy vulnerability
- Apply Checks → Effects → Interactions pattern
- Ensure secure ETH withdrawal flow
- Prevent recursive external calls exploitation

---------------------------------------------------------
CORE IDEA (CEI PATTERN)
---------------------------------------------------------

✔ CHECKS        → validate conditions
✔ EFFECTS       → update state FIRST
✔ INTERACTIONS  → external calls LAST

---------------------------------------------------------

This prevents reentrancy because:

state is already updated
before external contract can re-enter

=========================================================
SECURE BANK CONTRACT
=========================================================
*/
/*
contract SecureBank {

    /*
        USER BALANCES
    
    mapping(address => uint256) public balance;

    /*
    =====================================================
    DEPOSIT ETH
    =====================================================
    

    function deposit() external payable {
        balance[msg.sender] += msg.value;
    }

    /*
    =====================================================
    SECURE WITHDRAW (FIXED)
    =====================================================
    

    function withdraw(uint256 amount) external {

        /*
        =================================================
        1. CHECKS
        =================================================
        
        require(balance[msg.sender] >= amount, "Insufficient balance");

        /*
        =================================================
        2. EFFECTS (STATE UPDATE FIRST) ✅ FIX
        =================================================
        

        balance[msg.sender] -= amount;

        /*
        =================================================
        3. INTERACTIONS (EXTERNAL CALL LAST)
        =================================================
        

        (bool success, ) = msg.sender.call{value: amount}("");
        require(success, "Transfer failed");
    }

    /*
    =====================================================
    VIEW BALANCE
    =====================================================
    

    function getBalance(address user)
        external
        view
        returns (uint256)
    {
        return balance[user];
    }
}
*/
/*
Audit Report
Title
Reentrancy Vulnerability Remediated Using Checks-Effects-Interactions(CEI) Pattern

Severity: Informational

Reason
The contract correctly implements the checks-effects -interaction(CEI) pattern,
preventing reentrancy attacks by updating user balances before performing external
ETH transfers.

Location
Contract: SecureBank
Function: withdraw(uint256 amount)

Vulnerability Description
The original reentrancy issue occurs when a contract send ETH to an external
address before updating internal state.

In vulnerable implementations:
(bool success, ) = msg.sender.call{value: amount}("");
require(success);
balance[msg.sender] -= amount;
An  attacker can re-enter withdraw() from a fallback function before the balance is
reduced.
The SecureBank contract fixex this issue by updating the balance before the external
call.

Impact
Before Fix
- Multiple withdrawls possible from a single balance.
- Complete contract drain possible.
- Theft of Funds belonging to other users.

After Fix
- Recursive withdrawals fail.
- User balance is reduced before ETH transfer.
- Reentrancy attack path is eliminated

Proof of Validation
User Deposits
deposit{value: 1 ether}();
Balance:
balance[user] = 1 ETH

User Withdraws
withdraw(1 ether);
Execution Order:
Step 1 --check
require(
    balance[msg.sender] >= amount,
    "Insufficient balance'
);
Passes

Step 2 --Effects
balance[msg.sender] -= amount;
Balance becomes:
0 ETH
Step 3 --Interaction
(bool success, ) =
msg.sender.call{value: amount}(""):
require(success, "Transfer failed");
ETH is transferred

Reentrant Attempt
Attacker fallback tries:
withdraw(1 ether);
Check executed again:
balance[msg.sender] >= 1 ether
Result:
false
Transaction reverts.
Attack fails.

Root Cause
The original vulnerability was caused by:
External call -> State Update
This allowed an attacker to re-enter before the balance changed

Recommendation
Apply the CEI pattern:
Checks -> Effects -> Interactions

Implemented fix:
require(balance[msg.sender] >= amount);
balance[msg.sender] -= amount;
(bool success, ) = 
msg.sender.call{value: amount}("");
require(success);

Patched Code;
*/
contract SecureBank {
    /*
    USER BALANCES
    */
    mapping(address => uint256) public balances;
    /*
    REENTRANCY LOCK
    */
    bool private locked;
    /*
    ====================
    REENTRANCY GUARD
    ====================
    */
    modifier nonReentrant(){
        require(!locked, "Reentrant call");
        locked = true;
        _;
        locked= false;
    }
    /*
    =================================
    DEPOSITE ETH
    =================================
    */
    function deposit() external payable {
        balances[msg.sender] += msg.value;
    }
    /*
    ==================================================
    SECURE WITHDRAW (PATCHED)
    ==================================================
    */
    function withdraw(uint256 amount)
    external nonReentrant
    {
        /*
        CHECKS
        */
        require(
            balances[msg.sender] >= amount,
            "Insufficient balance"
        );
        /*
        EFFECTS
        */
        balances[msg.sender] -= amount;
        /*
        INTERACTIONS
        */
        (bool succes, ) = 
        msg.sender.call{value: amount}("");
        require(
            succes,
            "Transfer failed"
        );
    }
    /*
    =========================================
    VIEW BALANCE
    ==========================================
    */
    function getBalance(address user)
    external
    view
    returns (uint256)
    {
        return balances[user];
    }

}