contract ReorderLogicVulnerability {

    /*
        USER BALANCES
    */
    mapping(address => uint256) public balances;

    /*
        TOTAL SYSTEM BALANCE
    */
    uint256 public totalBalance;

    bool private locked;

// This prevents:
// same function being called again
// re-entering via external call
    modifier nonReentrant() {
    require(!locked, "Reentrant call blocked");

    locked = true;
    _;
    locked = false;
}

    /*
    =====================================================
    SAFE DEPOSIT
    =====================================================
    */

    function safeDeposit()
        external
        payable
    {

        /*
            STEP 1:
            Validate FIRST.
        */
        require(
            msg.value > 0,
            "No ETH sent"
        );

        /*
            STEP 2:
            Update user balance.
        */
        balances[msg.sender] += msg.value;

        /*
            STEP 3:
            Update global accounting.
        */
        totalBalance += msg.value;
    }

    /*
    =====================================================
    SAFE WITHDRAW
    =====================================================

    Uses:
    Checks -> Effects -> Interactions
    */

    function safeWithdraw(
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

        /*
            EFFECTS

            Update storage BEFORE external call.
        */
        balances[msg.sender] -= _amount;

        totalBalance -= _amount;

        /*
            INTERACTION

            External ETH transfer LAST.
        */
        payable(msg.sender).transfer(_amount);
    }

    /*
    =====================================================
    VULNERABLE WITHDRAW
    =====================================================

    INTENTIONALLY BAD ORDER
    */

    function vulnerableWithdraw(
        uint256 _amount
    )
        external
    {

        /*
            CHECK:
            User balance validation.
        */
        require(
            balances[msg.sender] >= _amount,
            "Insufficient balance"
        );

        /*
            DANGEROUS ORDER:

            External call BEFORE state update.
        */
        payable(msg.sender).call{ value: _amount}("");

        /*
            STATE UPDATED TOO LATE
        */
        balances[msg.sender] -= _amount;

        totalBalance -= _amount;
    }

    /*
    =====================================================
    BAD REWARD ORDER
    =====================================================
    */

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
        */
        rewards[msg.sender] =
            balances[msg.sender] / 10;

        /*
            Balance updated later.
        */
        balances[msg.sender] += _deposit;
    }

    /*
    =====================================================
    SAFE REWARD ORDER
    =====================================================
    */

    function safeRewardUpdate(
        uint256 _deposit
    )
        external
    {

        /*
            Correct order:
            update balance first.
        */
        balances[msg.sender] += _deposit;

        /*
            Reward uses NEW balance.
        */
        rewards[msg.sender] =
            balances[msg.sender] / 10;
    }

    function tokenTransfer(address to,uint amount)internal {
        // simulate external interaction
         (bool success, ) = payable(to).call{value: amount}("");
        require(success, "Token transfer failed");
    }

    function vulnerableTokenWithdraw(uint256 _amount)external {
        require(balances[msg.sender] >= _amount, "Insufficient balance");
         //  EXTERNAL CALL FIRST (BAD ORDER)
        tokenTransfer(msg.sender, _amount);

    //  STATE UPDATED LATE
        balances[msg.sender] -= _amount;
    }

    function safeTokenWithdraw(uint256 _amount)
    external
    nonReentrant
{
    require(balances[msg.sender] >= _amount, "Insufficient balance");

    balances[msg.sender] -= _amount;

    tokenTransfer(msg.sender, _amount);
}
}

