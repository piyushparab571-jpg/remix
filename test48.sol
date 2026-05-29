// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/*
=========================================================
PRACTICAL: Call multiple state updates
CONCEPT: Order dependency
=========================================================

OBJECTIVE

- Learn how multiple storage updates execute
- Understand order dependency in Solidity
- Learn why update sequence matters
- Understand state consistency risks

---------------------------------------------------------
CORE IDEA
---------------------------------------------------------

State updates execute:
line-by-line in exact order.

---------------------------------------------------------
IMPORTANT UNDERSTANDING
---------------------------------------------------------

Changing execution order can:
completely change final state.

---------------------------------------------------------
WHY THIS MATTERS
---------------------------------------------------------

Incorrect update ordering causes:

- accounting bugs
- balance corruption
- reentrancy vulnerabilities
- invariant violations

---------------------------------------------------------
REAL-WORLD USAGE
---------------------------------------------------------

Order dependency matters in:

- ERC20 transfers
- DeFi lending
- staking systems
- liquidation engines
- AMMs
- vault accounting

---------------------------------------------------------
AUDITOR FOCUS
---------------------------------------------------------

Auditors inspect:

- update sequencing
- external-call ordering
- invariant preservation
- partial state assumptions
- race-condition risks

=========================================================
*/
/*
contract OrderDependencyExample {

    /*
        USER BALANCES
    
    mapping(address => uint256) public balances;

    /*
        GLOBAL TOTAL
    
    uint256 public totalSupply;

    /*
        REWARD TRACKER
    
    mapping(address => uint256) public rewards;

    /*
    =====================================================
    CORRECT ORDER EXAMPLE
    =====================================================
    

    function depositCorrect(
        uint256 _amount
    )
        external
    {

        /*
            STEP 1:
            Validate input FIRST.
        
        require(
            _amount > 0,
            "Invalid amount"
        );

        /*
            STEP 2:
            Update user balance.
        
        balances[msg.sender] += _amount;

        /*
            STEP 3:
            Update total supply.

            Depends on balance update.
        
        totalSupply += _amount;

        /*
            STEP 4:
            Reward based on NEW balance.
        
        rewards[msg.sender] =
            balances[msg.sender] / 10;
    }

    /*
    =====================================================
    BAD ORDER EXAMPLE
    =====================================================
    

    function depositWrong(
        uint256 _amount
    )
        external
    {

        /*
            STEP 1:
            Reward calculated BEFORE
            balance update.
        
        rewards[msg.sender] =
            balances[msg.sender] / 10;

        /*
            STEP 2:
            Balance updated later.
        
        balances[msg.sender] += _amount;

        /*
            STEP 3:
            Total updated.
        
        totalSupply += _amount;
    }

    /*
    =====================================================
    TRANSFER EXAMPLE
    =====================================================
    

    function transfer(
        address _to,
        uint256 _amount
    )
        external
    {

        /*
            Validate sender balance FIRST.
        
        require(
            balances[msg.sender] >= _amount,
            "Insufficient balance"
        );

        /*
            CORRECT ORDER:
            subtract sender first.
        
        balances[msg.sender] -= _amount;

        /*
            Then add receiver.
        
        balances[_to] += _amount;
    }
}
*/
/*
=========================================================
EXECUTION FLOW
=========================================================

INITIAL STATE

balances[Alice] = 100

rewards[Alice] = 0

=========================================================
TRACE:
depositCorrect(50)
=========================================================

---------------------------------------------------------
STEP 1
---------------------------------------------------------

require(50 > 0)

RESULT:
true

---------------------------------------------------------
STEP 2
---------------------------------------------------------

balances[Alice] += 50

NEW VALUE:
150

---------------------------------------------------------
STEP 3
---------------------------------------------------------

totalSupply += 50

---------------------------------------------------------
STEP 4
---------------------------------------------------------

rewards[Alice] =
balances[Alice] / 10

150 / 10 = 15

---------------------------------------------------------
FINAL STATE
---------------------------------------------------------

balances[Alice] = 150

rewards[Alice] = 15

=========================================================
BAD ORDER TRACE
=========================================================

INITIAL:

balances[Alice] = 100

---------------------------------------------------------

CALL:
depositWrong(50)

---------------------------------------------------------
STEP 1
---------------------------------------------------------

rewards[Alice] =
balances[Alice] / 10

100 / 10 = 10

---------------------------------------------------------
STEP 2
---------------------------------------------------------

balances[Alice] += 50

NEW VALUE:
150

---------------------------------------------------------
FINAL STATE
---------------------------------------------------------

balances[Alice] = 150

rewards[Alice] = 10

---------------------------------------------------------

IMPORTANT:
Reward incorrect because
order was wrong.

=========================================================
IMPORTANT EXECUTION UNDERSTANDING
=========================================================

Solidity executes:
TOP -> DOWN

---------------------------------------------------------

Every storage update affects:
future lines immediately.

=========================================================
ORDER DEPENDENCY
=========================================================

Later logic depends on:
earlier state changes.

---------------------------------------------------------

Changing line order may:
change protocol behavior.

=========================================================
REMIX TESTING
=========================================================

STEP 1:
Deploy contract

---------------------------------------------------------

STEP 2:
Call:
depositCorrect(100)

---------------------------------------------------------

STEP 3:
Call:
balances(your_address)

EXPECTED:
100

---------------------------------------------------------

STEP 4:
Call:
rewards(your_address)

EXPECTED:
10

---------------------------------------------------------

STEP 5:
Deploy fresh contract

---------------------------------------------------------

STEP 6:
Call:
depositWrong(100)

---------------------------------------------------------

STEP 7:
Call:
rewards(your_address)

EXPECTED:
0

---------------------------------------------------------

OBSERVE:
Reward used OLD balance.

=========================================================
VERY IMPORTANT SECURITY CONCEPT
=========================================================

Incorrect update order can create:

- stale reads
- broken accounting
- exploit opportunities

=========================================================
CHECKS-EFFECTS-INTERACTIONS
=========================================================

BEST PRACTICE:

1. CHECKS
2. EFFECTS
3. INTERACTIONS

---------------------------------------------------------

Known as:
CEI pattern.

=========================================================
WHY CEI MATTERS
=========================================================

Correct ordering helps prevent:
reentrancy vulnerabilities.

=========================================================
COMMON AUDIT RISKS
=========================================================

---------------------------------------------------------
1. STALE STATE READS
---------------------------------------------------------

Logic reads old values accidentally.

---------------------------------------------------------
2. EXTERNAL CALL BEFORE UPDATE
---------------------------------------------------------

Major reentrancy risk.

---------------------------------------------------------
3. INVARIANT BREAKAGE
---------------------------------------------------------

Incorrect order corrupts accounting.

---------------------------------------------------------
4. DOUBLE-SPEND RISKS
---------------------------------------------------------

Incorrect balance sequencing dangerous.

=========================================================
GAS OBSERVATION
=========================================================

More state updates:
higher gas usage.

---------------------------------------------------------

Repeated storage reads/writes:
especially expensive.

=========================================================
SECURITY / AUDITOR MINDSET
=========================================================

Auditors ask:

- What updates happen first?
- Which values depend on prior state?
- Are stale reads possible?
- Are invariants preserved?
- Does execution order prevent exploits?

=========================================================
ATTACK THINKING
=========================================================

ATTACK SCENARIO

External call before balance reduction.

Attacker reenters repeatedly.

Result:
fund theft.

---------------------------------------------------------

ANOTHER RISK

Reward calculated before update.

Attacker gains incorrect rewards.

=========================================================
REAL AUDITOR PROCESS
=========================================================

Auditors trace:

1. Exact execution order
2. Storage reads/writes
3. Dependency chains
4. External-call timing
5. Invariant preservation

=========================================================
MINI CHALLENGE
=========================================================

Modify contract so that:

1. Add withdraw function
2. Intentionally place external call
   before balance update
3. Observe vulnerability risk
4. Fix using CEI pattern

BONUS:
Track previousBalance and newBalance.

=========================================================
IMPORTANT CONCEPTS LEARNED
=========================================================

- Solidity executes line-by-line
- State updates affect later execution immediately
- Execution order changes final behavior
- Incorrect ordering creates vulnerabilities
- CEI pattern improves security
- Stale reads are dangerous
- External-call ordering is critical
- Auditors trace exact state-update sequence
- Dependency chains matter heavily
- Order dependency is fundamental in smart contracts

=========================================================
*/
/*
Audit Report
Title
Improper State Update Ordering Leads to Reentrancy Risk

Severity: HIGH

Reason: External interaction occurs before internal state updates, violating the checks-
Effects-interction(CEI) Pattern and enabling potential reentrancy attacks

Location:
contract: OrderDependencyExample
Function: withdraw() (challenge scenario described in comments)

Vulnerability Description
The contract discussion introduces a withdraw scenario where an external call 
is intentionally executed before updating user balances.

if implemented incorrectly, the function may follow this dangerous sequence:
(bool success, ) = payable(msg.sender).call{value: _amount}("");
require(success, "Transfer failed");

balances[msg.sender] -= _amount;

Because the external call executes before the balance reduction, an attacker
conract can re-enter the withdraw() function multiple times before the 
balance is updated.

This creates a classic reentrancy vulnerability.

Imapct
An attacker can repeatedly withdraw funds before their balance is reduced.

Potential consequences include:
1. complete draining of contract funds
2. broken accounting invariants
3. corrupted totalSupply tracking
4. unauthorized repeated withdrawls
5. protocol insolvency

if integrated into real-world systems such as:
1.vaults
2.staking protocols
3.lending systems
4.AMMS
5. yield aggregators

Proof of Concept
Vulnerable Logic
      require( 
        balances[msg.sender] >= _amount, 
        "Insufficient balance" 
        ); 
        /* 
        EXTERNAL CALL FIRST 
        (VULNERABLE) 
        
        (bool success, ) = 
        payable(msg.sender).call{ 
            value: _amount 
            }(""); 
            require(success, "Transfer failed"); 
            /* 
            STATE UPDATE LATER 
            
             balances[msg.sender] -= _amount; 
             };
 Attack Scenario
 Step 1
 Attacker deposites funds.
 depositeCorrect(10 ether);
 Step 2
 Attacker calls:
 withdraw(1 ether);
 Step 3
   During the external call, the attacker fallback function re-enters:

fallback() external payable {
    vulnerable.withdraw(1 ether);
}
Step 4

Because the balance has not yet been reduced, the contract allows repeated withdrawals.

Root Cause

The vulnerability exists because:

external interaction occurs before state updates
contract violates the CEI pattern
balance dependency ordering is incorrect
stale state remains accessible during reentrant execution
Recommendation

Follow the Checks-Effects-Interactions (CEI) pattern:

Perform validation checks first
Update internal state variables
Execute external interactions last
Patched Code                 
*/
 contract OrderDependencyFixed { 
    /* 
    USER BALANCES 
    */
     mapping(address => uint256) public balances; 
     /*
      GLOBAL TOTAL
    */ 
    uint256 public totalSupply; 
    /* 
    BONUS:
     TRACK BALANCE HISTORY 
    */
     mapping(address => uint256) public previousBalance; 
     mapping(address => uint256) public newBalance; 
     /* 
     ===================================================== 
     SAFE DEPOSIT 
     =====================================================
      */ 
     function deposit( 
        uint256 _amount 
        )
         external 
         payable { 
            require( 
                _amount > 0, 
                "Invalid amount" 
                ); 
                previousBalance[msg.sender] = 
                balances[msg.sender]; 
                /*
                 EFFECTS 
                 */ 
                 balances[msg.sender] += _amount; 
                 totalSupply += _amount; 
                 newBalance[msg.sender] = 
                 balances[msg.sender]; 
                 } 
                 /* 
                 =====================================================
                  SAFE WITHDRAW 
                  ===================================================== 
                 FIXED USING: CHECKS-EFFECTS-INTERACTIONS
                  ===================================================== 
                  
                  */ 
                  function withdraw( 
                    uint256 _amount 
                    ) 
                    external
                    { 
                        /* 
                        CHECKS 
                        */ 
                        require(
                             balances[msg.sender] >= _amount, 
                             "Insufficient balance" 
                             );
                             previousBalance[msg.sender] = 
                             balances[msg.sender]; 
                             /*
                              EFFECTS FIRST
                               */ 
                               balances[msg.sender] -= _amount; 
                               totalSupply -= _amount; 
                               newBalance[msg.sender] = 
                               balances[msg.sender]; 
                               /* 
                               INTERACTION LAST 
                               */ 
                               (bool success, ) =
                                payable(msg.sender).call{ 
                                    value: _amount 
                                    }(""); 
                                    require( 
                                        success, 
                                        "Transfer failed" ); 
                                        } 
                                        /*
                                         RECEIVE ETHER 
                                         */ 
                                         receive() external payable {} 
                }