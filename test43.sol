// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/*
=========================================================
PRACTICAL: Call function from function
CONCEPT: Execution chaining
=========================================================

OBJECTIVE

- Learn how one function calls another
- Understand execution chaining
- Learn execution stack flow
- Understand chained state updates

---------------------------------------------------------
CORE IDEA
---------------------------------------------------------

Functions can call:
other functions.

This creates:
execution chains.

---------------------------------------------------------
IMPORTANT UNDERSTANDING
---------------------------------------------------------

Execution flows step-by-step:

Function A
   ->
Function B
   ->
Function C

Then returns backward.

---------------------------------------------------------
WHY THIS MATTERS
---------------------------------------------------------

Most smart contracts use:
multi-function execution flow.

---------------------------------------------------------
REAL-WORLD USAGE
---------------------------------------------------------

Execution chaining used in:

- ERC20 transfers
- DeFi swaps
- staking systems
- lending protocols
- liquidation systems
- governance execution

---------------------------------------------------------
AUDITOR FOCUS
---------------------------------------------------------

Auditors inspect:

- execution order
- hidden state updates
- reentrancy risk
- recursive loops
- validation propagation

=========================================================
*/
/*
contract FunctionExecutionChaining {

    /*
        STORAGE VARIABLES
    
    mapping(address => uint256) public balances;

    uint256 public totalDeposits;

    /*
    =====================================================
    MAIN ENTRY FUNCTION
    =====================================================
    

    function deposit(
        uint256 _amount
    )
        external
    {

        /*
            STEP 1:
            Validate input.
        
        validateAmount(_amount);

        /*
            STEP 2:
            Add balance.
        
        addBalance(
            msg.sender,
            _amount
        );

        /*
            STEP 3:
            Update global total.
        
        updateTotal(_amount);
    }

    /*
    =====================================================
    VALIDATION FUNCTION
    =====================================================
    

    function validateAmount(
        uint256 _amount
    )
        internal
        pure
    {

        require(
            _amount > 0,
            "Amount must be > 0"
        );

        require(
            _amount <= 100,
            "Amount too large"
        );
    }

    /*
    =====================================================
    BALANCE UPDATE FUNCTION
    =====================================================
    

    function addBalance(
        address _user,
        uint256 _amount
    )
        internal
    {

        /*
            Storage update.
        
        balances[_user] += _amount;
    }

    /*
    =====================================================
    TOTAL UPDATE FUNCTION
    =====================================================
    

    function updateTotal(
        uint256 _amount
    )
        internal
    {

        totalDeposits += _amount;
    }

    /*
    =====================================================
    CHAINED BONUS FLOW
    =====================================================
    

    function depositWithBonus(
        uint256 _amount
    )
        external
    {

        /*
            Function calling another function.
        
        depositInternal(_amount);

        /*
            Additional bonus logic.
        
        addBalance(
            msg.sender,
            10
        );
    }

    /*
    =====================================================
    INTERNAL DEPOSIT FLOW
    =====================================================
    

    function depositInternal(
        uint256 _amount
    )
        internal
    {

        /*
            Chained execution continues.
        
        validateAmount(_amount);

        addBalance(
            msg.sender,
            _amount
        );

        updateTotal(_amount);
    }
}

/*
=========================================================
EXECUTION FLOW
=========================================================

CALL:
deposit(50)

=========================================================

STEP 1:
deposit() executes.

---------------------------------------------------------

STEP 2:
deposit() calls:

validateAmount(50)

---------------------------------------------------------

VALIDATION PASSES

---------------------------------------------------------

CONTROL RETURNS TO:
deposit()

---------------------------------------------------------

STEP 3:
deposit() calls:

addBalance(Alice, 50)

---------------------------------------------------------

STORAGE UPDATE:

balances[Alice] += 50

---------------------------------------------------------

CONTROL RETURNS TO:
deposit()

---------------------------------------------------------

STEP 4:
deposit() calls:

updateTotal(50)

---------------------------------------------------------

STORAGE UPDATE:

totalDeposits += 50

---------------------------------------------------------

FINAL STATE:

balances[Alice] = 50

totalDeposits = 50

=========================================================
CHAINED FLOW TRACE
=========================================================

CALL:
depositWithBonus(100)

=========================================================

STEP 1:
depositWithBonus() executes.

---------------------------------------------------------

STEP 2:
Calls:

depositInternal(100)

---------------------------------------------------------

depositInternal() calls:

validateAmount(100)

---------------------------------------------------------

Validation passes.

---------------------------------------------------------

depositInternal() calls:

addBalance(Alice, 100)

---------------------------------------------------------

depositInternal() calls:

updateTotal(100)

---------------------------------------------------------

depositInternal() finishes.

---------------------------------------------------------

CONTROL RETURNS TO:
depositWithBonus()

---------------------------------------------------------

STEP 3:
Bonus added:

addBalance(Alice, 10)

---------------------------------------------------------

FINAL STATE:

balances[Alice] += 110

=========================================================
IMPORTANT EXECUTION UNDERSTANDING
=========================================================

Function execution behaves like:
STACK FLOW.

---------------------------------------------------------

Execution enters:
called function

Then returns:
to caller function.

=========================================================
VISUAL FLOW
=========================================================

depositWithBonus()
    |
    +--> depositInternal()
             |
             +--> validateAmount()
             |
             +--> addBalance()
             |
             +--> updateTotal()

=========================================================
REMIX TESTING
=========================================================

STEP 1:
Deploy contract

---------------------------------------------------------

STEP 2:
Call:
deposit(50)

---------------------------------------------------------

STEP 3:
Call:
balances(your_address)

EXPECTED:
50

---------------------------------------------------------

STEP 4:
Call:
totalDeposits()

EXPECTED:
50

---------------------------------------------------------

STEP 5:
Call:
depositWithBonus(100)

---------------------------------------------------------

STEP 6:
Call:
balances(your_address)

EXPECTED:
160

---------------------------------------------------------

STEP 7:
Call:
totalDeposits()

EXPECTED:
150

=========================================================
IMPORTANT FUNCTION CHAINING UNDERSTANDING
=========================================================

Functions may:
- validate
- compute
- mutate state
- call helper functions

---------------------------------------------------------

Execution order matters heavily.

=========================================================
COMMON AUDIT RISKS
=========================================================

---------------------------------------------------------
1. HIDDEN STATE MUTATIONS
---------------------------------------------------------

Called functions may:
modify storage unexpectedly.

---------------------------------------------------------
2. VALIDATION GAPS
---------------------------------------------------------

One chain path may skip validation.

---------------------------------------------------------
3. RECURSION RISK
---------------------------------------------------------

Functions calling each other recursively
may exhaust gas.

---------------------------------------------------------
4. EXECUTION ORDER BUGS
---------------------------------------------------------

Incorrect call ordering
may break invariants.

=========================================================
GAS OBSERVATION
=========================================================

More chained calls:
More gas usage.

---------------------------------------------------------

Deep chains:
Harder auditing.

=========================================================
SECURITY / AUDITOR MINDSET
=========================================================

Auditors ask:

- Which functions call others?
- What state changes occur?
- Is validation always enforced?
- Can attacker influence flow?
- Are external calls involved?

=========================================================
ATTACK THINKING
=========================================================

ATTACK SCENARIO

Developer forgets validation
in one chain path.

Attacker uses unsafe path.

---------------------------------------------------------

ANOTHER RISK

External call inside chain
may enable reentrancy.

=========================================================
REAL AUDITOR PROCESS
=========================================================

Auditors trace:

1. Call hierarchy
2. Execution order
3. State mutations
4. Validation propagation
5. Revert behavior

=========================================================
MINI CHALLENGE
=========================================================

Modify contract so that:

1. Add withdraw chain
2. Add fee deduction function
3. Add blacklist validation function
4. Trace full execution manually

BONUS:
Create recursive function
and observe gas behavior.

=========================================================
IMPORTANT CONCEPTS LEARNED
=========================================================

- Functions can call other functions
- Execution follows stack-like flow
- Called function returns control to caller
- Function chains organize logic
- Hidden state mutations may occur
- Validation must propagate through chains
- Execution order matters heavily
- Recursive calls can be dangerous
- Auditors trace full call hierarchy
- Function chaining is core Solidity architecture

=========================================================
*/
/*
Audit Report:
Title:Misiing withdrawal chain, free processing, and Blacklist 
validation in function execution flow
Severity: Medium
Reason: The contract demonstrates function execution chanining but 
lacks additional chained execution paths commonly found in production systems,
including withdrawals, fee processing, and blacklist validation.

Location
Contract: FunctionExecutionChaining
Misiing Functions:
1. withdraw()
2. withdrawInternal()
3. deduceFee()
4. validateBlacklist()

Vulnerability Description
The contract currently demonstrates a deposite execution chain:
deposite()
|- validateAmount()
|- addBalance()
|- updateTotal()

and a nested execution chain:

depositWithBonus()
   depositeInternal()
         |- validateAmount()
         |- addBalance()
            updateTotal()

However, no corressponding withdrawl execution chain exists.

Additionally:
1. No fee deduction logic exists.
2. No blacklist validation exists.
3. No demonstration of recursive execution behavoir exists.

These omnissions limit understanding of more complex execution flows.

Impact
potential consequences include:
1. No withdrawl processing path
2. No fee accounting demonstration
3. No user restriction mechanism
4. No visibility into recursive gas consumption
while not directly exploitable, the implementation is incomplete from a function-
chaining perspective.

Root Cause
The contract only models deposit execution flows.
Additional chained execution paths were not implemented

Recommendation
Add:
Withdrawl chain
function withdraw(
    uint256 _amount
    )
    external;

Free Deduction function
function deductFree(
    uint256 _amount
    )
        internal
        pure 
        returns (uint256);

 Black Validation
 function validateBlacklist(
    address _user
    )
      internal
      view;

Recursive Function
implemented a controlled recursive function to demonstrate execution depth and gas
consuption.

Patched code:
*/
contract FunctionExecutionChaining {

    /*
        STORAGE VARIABLES
    */

    mapping(address => uint256) public balances;

    mapping(address => bool) public blacklisted;

    uint256 public totalDeposits;

    /*
    =====================================================
    MAIN ENTRY FUNCTION
    =====================================================
    */

    function deposit(
        uint256 _amount
    )
        external
    {
        validateBlacklist(
            msg.sender
        );

        validateAmount(_amount);

        addBalance(
            msg.sender,
            _amount
        );

        updateTotal(_amount);
    }

    /*
    =====================================================
    WITHDRAW ENTRY FUNCTION
    =====================================================
    */

    function withdraw(
        uint256 _amount
    )
        external
    {
        withdrawInternal(
            _amount
        );
    }

    /*
    =====================================================
    BLACKLIST VALIDATION
    =====================================================
    */

    function validateBlacklist(
        address _user
    )
        internal
        view
    {
        require(
            !blacklisted[_user],
            "User blacklisted"
        );
    }

    /*
    =====================================================
    AMOUNT VALIDATION
    =====================================================
    */

    function validateAmount(
        uint256 _amount
    )
        internal
        pure
    {
        require(
            _amount > 0,
            "Amount must be > 0"
        );

        require(
            _amount <= 100,
            "Amount too large"
        );
    }

    /*
    =====================================================
    BALANCE ADDITION
    =====================================================
    */

    function addBalance(
        address _user,
        uint256 _amount
    )
        internal
    {
        balances[_user] += _amount;
    }

    /*
    =====================================================
    BALANCE SUBTRACTION
    =====================================================
    */

    function subtractBalance(
        address _user,
        uint256 _amount
    )
        internal
    {
        require(
            balances[_user] >= _amount,
            "Insufficient balance"
        );

        balances[_user] -= _amount;
    }

    /*
    =====================================================
    TOTAL UPDATE
    =====================================================
    */

    function updateTotal(
        uint256 _amount
    )
        internal
    {
        totalDeposits += _amount;
    }

    /*
    =====================================================
    TOTAL REDUCTION
    =====================================================
    */

    function reduceTotal(
        uint256 _amount
    )
        internal
    {
        totalDeposits -= _amount;
    }

    /*
    =====================================================
    FEE DEDUCTION
    =====================================================
    */

    function deductFee(
        uint256 _amount
    )
        internal
        pure
        returns (uint256)
    {
        uint256 fee =
            (_amount * 2) / 100;

        return _amount - fee;
    }

    /*
    =====================================================
    BONUS FLOW
    =====================================================
    */

    function depositWithBonus(
        uint256 _amount
    )
        external
    {
        depositInternal(
            _amount
        );

        addBalance(
            msg.sender,
            10
        );
    }

    /*
    =====================================================
    INTERNAL DEPOSIT FLOW
    =====================================================
    */

    function depositInternal(
        uint256 _amount
    )
        internal
    {
        validateBlacklist(
            msg.sender
        );

        validateAmount(_amount);

        addBalance(
            msg.sender,
            _amount
        );

        updateTotal(_amount);
    }

    /*
    =====================================================
    INTERNAL WITHDRAW FLOW
    =====================================================
    */

    function withdrawInternal(
        uint256 _amount
    )
        internal
    {
        validateBlacklist(
            msg.sender
        );

        uint256 finalAmount =
            deductFee(_amount);

        subtractBalance(
            msg.sender,
            _amount
        );

        reduceTotal(
            finalAmount
        );
    }

    /*
    =====================================================
    RECURSIVE FUNCTION
    =====================================================
    */

    function recursiveCount(
        uint256 _n
    )
        public
        pure
        returns (uint256)
    {
        if (_n == 0) {
            return 0;
        }

        return
            1 +
            recursiveCount(
                _n - 1
            );
    }
}