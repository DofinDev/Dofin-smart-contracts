// SPDX-License-Identifier: MIT
pragma solidity >=0.8;

import "../math/SafeMath.sol";

/// @title ProofToken
/// @author Andrew FU
/// @dev All functions haven't finished unit test
contract ProofToken {
    
    using SafeMath for uint256;
    string public name;
    string public symbol;
    uint8 public decimals;
    uint256 internal totalSupply_;
    
    event Approval(address indexed tokenOwner, address indexed spender, uint256 tokens);
    event Transfer(address indexed from, address indexed to, uint256 tokens);
    
    mapping(address => uint256) internal balances;
    mapping(address => mapping (address => uint256)) internal allowed;

    function initializeToken(string memory _name, string memory _symbol, uint8 _decimals) internal {
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
    }
    
    function totalSupply() public view returns (uint256) {
        
        return totalSupply_;
    }
    
    function balanceOf(address account) public view returns (uint256) {
        
        return balances[account];
    }

    function transfer(address recipient, uint256 amount) public returns (bool) {
        require(amount <= balances[msg.sender]);
        balances[msg.sender] = balances[msg.sender].sub(amount);
        balances[recipient] = balances[recipient].add(amount);
        emit Transfer(msg.sender, recipient, amount);
        return true;
    }

    function approve(address spender, uint256 amount) public returns (bool) {
        allowed[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function allowance(address owner, address spender) public view returns (uint256) {
        
        return allowed[owner][spender];
    }

    function transferFrom(address owner, address buyer, uint256 numTokens) public returns (bool) {
        require(numTokens <= balances[owner]);    
        require(numTokens <= allowed[owner][msg.sender]);
    
        balances[owner] = balances[owner].sub(numTokens);
        allowed[owner][msg.sender] = allowed[owner][msg.sender].sub(numTokens);
        balances[buyer] = balances[buyer].add(numTokens);
        emit Transfer(owner, buyer, numTokens);
        return true;
    }
    
    function mint(address account, uint256 amount) internal returns (bool) {
        require(account != address(0), "ERC20: mint to the zero address");

        totalSupply_ += amount;
        balances[account] += amount;
        emit Transfer(address(0), account, amount);

        return true;
    }
    
    function burn(address account, uint256 amount) internal returns (bool) {
        require(account != address(0), "ERC20: burn from the zero address");

        uint256 accountBalance = balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            balances[account] = accountBalance - amount;
        }
        totalSupply_ -= amount;
        emit Transfer(account, address(0), amount);

        return true;
    }
    
}