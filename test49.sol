// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/*
=========================================================
PRACTICAL: Reorder logic intentionally
CONCEPT: Vulnerability creation
=========================================================

OBJECTIVE

- Learn how bad execution order creates vulnerabilities
- Understand dangerous state-update sequencing
- Learn reentrancy-style ordering issues
- Think like a smart contract auditor

---------------------------------------------------------
CORE IDEA
---------------------------------------------------------

Execution order is SECURITY CRITICAL.

Changing line order may:
- break invariants
- expose reentrancy
- corrupt accounting
- enable fund theft

---------------------------------------------------------
IMPORTANT UNDERSTANDING
---------------------------------------------------------

Same logic
+
Different order
=
Completely different security outcome.

---------------------------------------------------------
WHY THIS MATTERS
---------------------------------------------------------

Many real-world hacks happened because:
logic executed in wrong order.

---------------------------------------------------------
REAL-WORLD USAGE
---------------------------------------------------------

Ordering mistakes affected:

- DAO hack
- lending protocols
- vault systems
- reward systems
- staking protocols
- AMMs

---------------------------------------------------------
AUDITOR FOCUS
---------------------------------------------------------

Auditors inspect:

- state-update order
- external-call timing
- validation placement
- stale-state reads
- invariant preservation

=========================================================
*/
/*
contract ReorderLogicVulnerability {

    /*
        USER BALANCES
    
    mapping(address => uint256) public balances;

    /*
        TOTAL SYSTEM BALANCE
    
    uint256 public totalBalance;

    /*
    =====================================================
    SAFE DEPOSIT
    =====================================================
    

    function safeDeposit()
        external
        payable
    {

        /*
            STEP 1:
            Validate FIRST.
        
        require(
            msg.value > 0,
            "No ETH sent"
        );

        /*
            STEP 2:
            Update user balance.
        
        balances[msg.sender] += msg.value;

        /*
            STEP 3:
            Update global accounting.
        
        totalBalance += msg.value;
    }

    /*
    =====================================================
    SAFE WITHDRAW
    =====================================================

    Uses:
    Checks -> Effects -> Interactions
    

    function safeWithdraw(
        uint256 _amount
    )
        external
    {

        /*
            CHECKS
        
        require(
            balances[msg.sender] >= _amount,
            "Insufficient balance"
        );

        /*
            EFFECTS

            Update storage BEFORE external call.
        
        balances[msg.sender] -= _amount;

        totalBalance -= _amount;

        /*
            INTERACTION

            External ETH transfer LAST.
        
        payable(msg.sender).transfer(_amount);
    }

    /*
    =====================================================
    VULNERABLE WITHDRAW
    =====================================================

    INTENTIONALLY BAD ORDER
    

    function vulnerableWithdraw(
        uint256 _amount
    )
        external
    {

        /*
            CHECK:
            User balance validation.
        
        require(
            balances[msg.sender] >= _amount,
            "Insufficient balance"
        );

        /*
            DANGEROUS ORDER:

            External call BEFORE state update.
        
        payable(msg.sender).call{
            value: _amount
        }("");

        /*
            STATE UPDATED TOO LATE
        
        balances[msg.sender] -= _amount;

        totalBalance -= _amount;
    }

    /*
    =====================================================
    BAD REWARD ORDER
    =====================================================
    

    mapping(address => uint256) public rewards;

    function badRewardUpdate(
        uint256 _deposit
    )
        external
    {

        /*
            WRONG ORDER:

            Reward calculated BEFORE
            balance update.
        
        rewards[msg.sender] =
            balances[msg.sender] / 10;

        /*
            Balance updated later.
        
        balances[msg.sender] += _deposit;
    }

    /*
    =====================================================
    SAFE REWARD ORDER
    =====================================================
    

    function safeRewardUpdate(
        uint256 _deposit
    )
        external
    {

        /*
            Correct order:
            update balance first.
        
        balances[msg.sender] += _deposit;

        /*
            Reward uses NEW balance.
        
        rewards[msg.sender] =
            balances[msg.sender] / 10;
    }
}
*/
/*
=========================================================
IMPORTANT SECURITY UNDERSTANDING
=========================================================

BAD ORDER:
interaction before state update

=
classic reentrancy vulnerability.

=========================================================
SAFE WITHDRAW TRACE
=========================================================

CALL:
safeWithdraw(10)

=========================================================

STEP 1:
Balance check.

---------------------------------------------------------

STEP 2:
balances[Alice] -= 10

---------------------------------------------------------

STEP 3:
totalBalance -= 10

---------------------------------------------------------

STEP 4:
ETH transfer occurs LAST.

---------------------------------------------------------

SAFE:
state already updated.

=========================================================
VULNERABLE TRACE
=========================================================

CALL:
vulnerableWithdraw(10)

=========================================================

STEP 1:
Balance validated.

---------------------------------------------------------

STEP 2:
External ETH call occurs FIRST.

---------------------------------------------------------

DANGER:
Attacker contract can reenter NOW.

---------------------------------------------------------

STEP 3:
Balance reduced TOO LATE.

---------------------------------------------------------

ATTACK RESULT:
multiple withdrawals possible.

=========================================================
WHY REORDERING CREATES VULNERABILITIES
=========================================================

Security depends on:
WHEN state changes occur.

---------------------------------------------------------

Incorrect ordering may expose:
temporary inconsistent state.

=========================================================
REWARD BUG TRACE
=========================================================

INITIAL:

balances[Alice] = 100

---------------------------------------------------------

CALL:
badRewardUpdate(50)

---------------------------------------------------------

STEP 1:
Reward calculated.

100 / 10 = 10

---------------------------------------------------------

STEP 2:
Balance updated later.

balances[Alice] = 150

---------------------------------------------------------

FINAL:
Reward stale and incorrect.

=========================================================
REMIX TESTING
=========================================================

STEP 1:
Deploy contract

---------------------------------------------------------

STEP 2:
Call:
safeRewardUpdate(100)

---------------------------------------------------------

STEP 3:
Call:
rewards(your_address)

EXPECTED:
10

---------------------------------------------------------

STEP 4:
Deploy fresh contract

---------------------------------------------------------

STEP 5:
Call:
badRewardUpdate(100)

---------------------------------------------------------

STEP 6:
Call:
rewards(your_address)

EXPECTED:
0

---------------------------------------------------------

OBSERVE:
Wrong order caused stale calculation.

=========================================================
CRITICAL AUDITOR CONCEPT
=========================================================

Auditors care deeply about:

EXECUTION ORDER

---------------------------------------------------------

Because:
same code + different order
can create exploits.

=========================================================
CHECKS-EFFECTS-INTERACTIONS
=========================================================

SAFE PATTERN:

1. CHECKS
2. EFFECTS
3. INTERACTIONS

---------------------------------------------------------

Prevents:
many reentrancy attacks.

=========================================================
COMMON AUDIT RISKS
=========================================================

---------------------------------------------------------
1. EXTERNAL CALL BEFORE STATE UPDATE
---------------------------------------------------------

Classic reentrancy risk.

---------------------------------------------------------
2. STALE STATE READS
---------------------------------------------------------

Logic reads outdated values.

---------------------------------------------------------
3. INVARIANT VIOLATIONS
---------------------------------------------------------

Temporary inconsistent state exposed.

---------------------------------------------------------
4. PARTIAL EXECUTION ASSUMPTIONS
---------------------------------------------------------

Incorrect ordering breaks accounting.

=========================================================
GAS OBSERVATION
=========================================================

Incorrect ordering may:
waste gas during revert paths.

=========================================================
SECURITY / AUDITOR MINDSET
=========================================================

Auditors ask:

- What executes first?
- When is state updated?
- Are external calls dangerous?
- Can temporary state be abused?
- Are invariants preserved throughout execution?

=========================================================
ATTACK THINKING
=========================================================

ATTACK SCENARIO

Attacker deploys malicious contract.

---------------------------------------------------------

During vulnerableWithdraw():

1. receives ETH
2. fallback triggers
3. reenters withdraw()
4. balance still unchanged
5. steals funds repeatedly

=========================================================
REAL AUDITOR PROCESS
=========================================================

Auditors trace:

1. Exact execution order
2. Storage update timing
3. External interaction timing
4. Revert points
5. Reentrancy windows

=========================================================
MINI CHALLENGE
=========================================================

Modify contract so that:

1. Add external token transfer
2. Intentionally place it before
   balance reduction
3. Analyze vulnerability
4. Fix using CEI pattern

BONUS:
Implement nonReentrant modifier.

=========================================================
IMPORTANT CONCEPTS LEARNED
=========================================================

- Execution order is security critical
- Reordering logic can create vulnerabilities
- External calls before state updates are dangerous
- CEI pattern prevents many attacks
- Stale reads create incorrect accounting
- Temporary inconsistent state is exploitable
- Reentrancy depends heavily on ordering
- Auditors trace exact execution sequence
- Same logic with different order changes security
- Order dependency is fundamental to smart contract auditing

=========================================================
*/
/*
Audit report
Title
Reentrancy Vulnerability via incorrect External Token Transfer Ordering

Severity: High

Location
Contract:  RecorderLogicVulnerability
Function: vulnerableTokenWithdraw()

Vulnerable Description
The vulnerableTokenWithdraw() function performs token transfer
before updating internal accounting state variables.

This violates the checks-Effects-interactions (CEI) security pattern and creates a 
reentrancy vulnerability window.
Because state updates occure after the external interaction, a malicious contract
may reenter the function multiple times before balances are reduced.

Vulnerable Code
function vulnerableTokenWithdraw(
    uint256 _amount
)
    external
{
    require(
        balances[msg.sender] >= _amount,
        "Insufficient balance"
    );
    
     // DANGEROUS:
    //External token transfer FIRST
    
    token.transfer(
        msg.sender,
        _amount 
    );
    
    //STATE UPDATED TOO LATE
    
    balances[msg.sender] -= _amount;
    tottalBalance -= _amount;
}

Impact

An attacker can rpeatedly reenter the withdrawl logic before balance
reduction occurs.

Potential consequences include:
1.repeated unauthorized withdrawals
2.draining protocol token reserves
3.broken accounting invariants
4.protocol insolvency
if integrated into production DeFi systems. this vulnerability could lead to
complete fund loss.

Root Cause
The external token interaction executes before internal state updates.
Vulnerable ordering:
1. CHECK
2. EXTERNAL INTERACTION
3. STATE UPDATE
During the external call, attacker-controlled code may execute and reenter the
function while balances remain unchanged

Prrof of Concept
Step 1 -User Deposits
Attacker deposites tokens.
State:
balances[attacker] = 100
Stepn 2 -Attacker Calls Vulnerable withdraw
vulnerableToken Withdraw(100)
Balances validation succeeds.
Step 3 -External Token Transfer Executes
token.transfer(attacker, 100)
Attacker contract receives tokens.
Its fallback/hook triggers malicious logic.
Step 4-Reentrancy Occurs
Attacker reenters:
vulnerableTokenWithdraw(100)
Because balaces were not yet reduced:
balances[attacker] == 100
still eveluates true.
Step 5-Multiple Withdrawals Occur
The attacker repeatedly drains protocol funds before the original execution
updates storage.

Vulnerability Analysis
Why External Calls Are Dangerous
External token transfers may:
1. trigger fallback logic
2.invoke hooks
3. call malicious contracts
4. reenter prtocol functions 
This is especially dangerous when state has not yet been updated.

Core Security Issue
Temporary inconsistent state becomes externally observable.
At this moment:
balances[msg.sender]
still contains the old value.
Attackers exploit this incnsistency

Violated Security Principle
The function violates:
Checks ---> Effects ---> Interactions
correct order should always be:
1. CHECKS
2. EFFECTS
3. INTERACTIONS

Recommendation Update all internal accounting before performing external interactions
Additionally:
1. use nonReentrant
2. validate token transfer success
3. minimize external call exposure

Patched Code

*/ 
interface IERC20 { 
    function transfer( 
        address to, 
        uint256 amount 
    ) external 
    returns (bool); 
} contract SafeTokenWithdraw { 
    IERC20 public token; 
    mapping(address => uint256) 
       public balances; 
       uint256 public totalBalance; 
       /* 
       REENTRANCY LOCK 
       */ 
       bool private locked;
        constructor(address _token) { 
            token = IERC20(_token); 
            }
             /* 
             ===================================================== 
             NONREENTRANT MODIFIER 
             ===================================================== 
             */ 
             modifier nonReentrant() { 
                require( 
                    !locked, 
                    "Reentrancy blocked"
                     ); 
                     locked = true;
                      _; 
                      locked = false; 
                      } 
                      /* 
                      ===================================================== 
                      SAFE TOKEN WITHDRAW
                    ===================================================== 
                    Uses: 
                    Checks -> Effects -> Interactions 
                    */ 
                    function safeTokenWithdraw( 
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
                              totalBalance -= _amount; 
                              /* 
                              INTERACTIONS
                               */ 
                             bool success =
            token.transfer( 
                msg.sender, 
                _amount 
             ); 
         require( 
             success, 
            "Transfer failed" 
         );
     } 
}