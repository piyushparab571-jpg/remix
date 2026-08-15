//SPX-license-Identifier; MIT
pragma solidity ^0.8.20;
contract Practicle99 {
    mapping(address => uint256) public balances;
    function deposite() public payable {
        balances[msg.sender] += msg.value;
    }
    function withdraw(uint256 amount) public {
        require(amount > 0, "Zero amount");
        require(amount <= balances[msg.sender], "Insufficient balance");
        balances[msg.sender] -= amount;
        payable(msg.sender).transfer(amount);
    }
    function transferBalance(address to, uint256 amount) public {
        require(to != address(0)."Zero address");
        require(amount <= balances[msg.sender]," Insufficient balance");
        balances[msg.sender] -= amount;
        balances[to] += amount; 
    }
    function getBalance() public view returns (uint256) {
        return balances[msg.sender];
    }
}