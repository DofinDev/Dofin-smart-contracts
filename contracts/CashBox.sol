// SPDX-License-Identifier: MIT
pragma solidity >=0.8;

import "./token/BEP20/IBEP20.sol";
import "./math/SafeMath.sol";
import "./utils/BasicContract.sol";
import { HighLevelSystem } from "./libs/HighLevelSystem.sol";

/// @title CashBox
/// @author Andrew FU
/// @dev All functions haven't finished unit test
contract CashBox is BasicContract {
    
    HighLevelSystem.HLSConfig private HLSConfig;
    HighLevelSystem.CreamToken private CreamToken;
    HighLevelSystem.StableCoin private StableCoin;
    HighLevelSystem.Position private position;
    
    using SafeMath for uint256;
    string public constant name = "Proof token of USDC";
    string public constant symbol = "pUSDC";
    uint8 public constant decimals = 18;
    uint256 private totalSupply_;

    uint private deposit_limit;
    bool public activable;
    address private dofin;
    
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
    event Transfer(address indexed from, address indexed to, uint tokens);
    
    mapping(address => uint256) private balances;
    mapping(address => mapping (address => uint256)) private allowed;

    constructor(uint[] memory _uints, address[] memory _addrs, address _dofin, uint _deposit_limit) {
        position = HighLevelSystem.Position({
            pool_id: _uints[0],
            token_amount: 0,
            token_a_amount: 0,
            token_b_amount: 0,
            lp_token_amount: 0,
            crtoken_amount: 0,
            supply_crtoken_amount: 0,
            token: _addrs[0],
            token_a: _addrs[1],
            token_b: _addrs[2],
            lp_token: _addrs[3],
            supply_crtoken: _addrs[4],
            borrowed_crtoken_a: _addrs[5],
            borrowed_crtoken_b: _addrs[6],
            supply_funds_percentage: _uints[1]
        });
        
        activable = true;
        dofin = _dofin;
        deposit_limit = _deposit_limit;
    }

    modifier checkActivable() {
        require(activable == true, 'CashBox is not activable.');
        _;
    }
    
    function setConfig(address[] memory _config) external onlyOwner {
        HLSConfig.LinkConfig.token_oracle = _config[0];
        HLSConfig.LinkConfig.token_a_oracle = _config[1];
        HLSConfig.LinkConfig.token_b_oracle = _config[2];
        HLSConfig.LinkConfig.cake_oracle = _config[3];
        HLSConfig.CreamConfig.oracle = _config[4];
        HLSConfig.PancakeSwapConfig.router = _config[5];
        HLSConfig.PancakeSwapConfig.factory = _config[6];
        HLSConfig.PancakeSwapConfig.masterchef = _config[7];
    }
    
    function setCreamTokens(address[] memory _creamtokens) external onlyOwner {
        CreamToken.crWBNB = _creamtokens[0];
        CreamToken.crUSDC = _creamtokens[1];
    }
    
    function setStableCoins(address[] memory _stablecoins) external onlyOwner {
        StableCoin.WBNB = _stablecoins[0];
        StableCoin.CAKE = _stablecoins[1];
        StableCoin.USDC = _stablecoins[2];
    }

    function setActivable(bool _activable) external onlyOwner {
        
        activable = _activable;
    }
    
    function getPosition() external onlyOwner view returns(HighLevelSystem.Position memory) {
        
        return position;
    }
    
    function rebalanceWithRepay() external onlyOwner checkActivable {
        position = HighLevelSystem.exitPosition(HLSConfig, CreamToken, StableCoin, position, 3);
        position = HighLevelSystem.enterPosition(HLSConfig, CreamToken, StableCoin, position, 3);
    }
    
    function rebalanceWithoutRepay() external onlyOwner checkActivable {
        position = HighLevelSystem.exitPosition(HLSConfig, CreamToken, StableCoin, position, 2);
        position = HighLevelSystem.enterPosition(HLSConfig, CreamToken, StableCoin, position, 2);
    }
    
    function rebalance() external onlyOwner checkActivable  {
        position = HighLevelSystem.exitPosition(HLSConfig, CreamToken, StableCoin, position, 1);
        position = HighLevelSystem.enterPosition(HLSConfig, CreamToken, StableCoin, position, 1);
    }
    
    function checkAddNewFunds() onlyOwner checkActivable external view returns (uint) {
        uint free_funds = IBEP20(position.token).balanceOf(address(this));
        uint token_balance = getTotalAssets();
        token_balance = SafeMath.div(SafeMath.mul(token_balance, 100), position.supply_funds_percentage);
        uint condition = SafeMath.div(SafeMath.mul(token_balance, SafeMath.sub(100, position.supply_funds_percentage)), 100);
        if (free_funds >= condition) {
            if (position.token_a_amount == 0 && position.token_b_amount == 0) {
                // Need to enter
                return 1;
            } else {
                // Need to rebalance
                return 2;
            }
        }
        return 0;
    }
    
    function enter(uint _type) external onlyOwner checkActivable {
        
        position = HighLevelSystem.enterPosition(HLSConfig, CreamToken, StableCoin, position, _type);
    }

    function exit(uint _type) external onlyOwner checkActivable {
        
        position = HighLevelSystem.exitPosition(HLSConfig, CreamToken, StableCoin, position, _type);
    }
    
    function checkCurrentBorrowLimit() onlyOwner external returns (uint) {
        
        return HighLevelSystem.checkCurrentBorrowLimit(HLSConfig, CreamToken, StableCoin, position);
    }
    
    function totalSupply() public view returns (uint256) {
        
        return totalSupply_;
    }
    
    function balanceOf(address account) public view returns (uint) {
        
        return balances[account];
    }

    function transfer(address recipient, uint amount) public returns (bool) {
        require(amount <= balances[msg.sender]);
        balances[msg.sender] = balances[msg.sender].sub(amount);
        balances[recipient] = balances[recipient].add(amount);
        emit Transfer(msg.sender, recipient, amount);
        return true;
    }

    function approve(address spender, uint amount) public returns (bool) {
        allowed[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function allowance(address owner, address spender) public view returns (uint) {
        
        return allowed[owner][spender];
    }

    function transferFrom(address owner, address buyer, uint numTokens) public returns (bool) {
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

    function getTotalAssets() public view returns (uint) {
        // Free funds amount
        uint freeFunds = IBEP20(position.token).balanceOf(address(this));
        // Total Debts amount from Cream, PancakeSwap
        uint totalDebts = HighLevelSystem.getTotalDebts(HLSConfig, CreamToken, StableCoin, position);
        
        return SafeMath.add(freeFunds, totalDebts);
    }

    function getDepositAmountOut(uint _deposit_amount) public view returns (uint) {
        uint totalAssets = getTotalAssets();
        uint shares;
        if (totalSupply_ > 0) {
            shares = SafeMath.div(SafeMath.mul(_deposit_amount, totalSupply_), totalAssets);
        } else {
            shares = _deposit_amount;
        }
        return shares;
    }
    
    function deposit(address _token, uint _deposit_amount) external checkActivable returns (bool) {
        require(_deposit_amount <= SafeMath.mul(deposit_limit, 10**IBEP20(position.token).decimals()), "Deposit too much!");
        require(_token == position.token, "Wrong token to deposit.");
        require(_deposit_amount > 0, "Deposit amount must bigger than 0.");
        
        // Calculation of pToken amount need to mint
        uint shares = getDepositAmountOut(_deposit_amount);
        
        // Mint pToken and transfer Token to cashbox
        mint(msg.sender, shares);
        IBEP20(position.token).transferFrom(msg.sender, address(this), _deposit_amount);
        
        return true;
    }
    
    function getWithdrawAmount(uint _ptoken_amount) public view returns (uint) {
        uint totalAssets = getTotalAssets();
        uint value = SafeMath.div(SafeMath.mul(_ptoken_amount, totalAssets), totalSupply_);
        uint user_value = SafeMath.div(SafeMath.mul(80, value), 100);
        
        return user_value;
    }
    
    function withdraw(uint _withdraw_amount) external checkActivable returns (bool) {
        require(_withdraw_amount <= balanceOf(msg.sender), "Wrong amount to withdraw.");
        
        uint freeFunds = IBEP20(position.token).balanceOf(address(this));
        uint totalAssets = getTotalAssets();
        uint value = SafeMath.div(SafeMath.mul(_withdraw_amount, totalAssets), totalSupply_);
        bool need_rebalance = false;
        // If no enough amount of free funds can transfer will trigger exit position
        if (value > freeFunds) {
            HighLevelSystem.exitPosition(HLSConfig, CreamToken, StableCoin, position, 1);
            need_rebalance = true;
        }
        
        // Will charge 20% fees
        burn(msg.sender, _withdraw_amount);
        uint dofin_value = SafeMath.div(SafeMath.mul(20, value), 100);
        uint user_value = SafeMath.div(SafeMath.mul(80, value), 100);
        IBEP20(position.token).transferFrom(address(this), dofin, dofin_value);
        IBEP20(position.token).transferFrom(address(this), msg.sender, user_value);
        
        if (need_rebalance == true) {
            HighLevelSystem.enterPosition(HLSConfig, CreamToken, StableCoin, position, 1);
        }
        
        return true;
    }
    
}