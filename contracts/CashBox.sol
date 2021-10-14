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
    
    // Link
    // address private link_oracle;
    
    // Cream
    // address private constant cream_oracle = 0xab548FFf4Db8693c999e98551C756E6C2948C408;
    // address private constant cream_troller = 0x589DE0F0Ccf905477646599bb3E5C622C84cC0BA;
    
    // PancakeSwap
    // address private constant ROUTER = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    // address private constant FACTORY = 0xcA143Ce32Fe78f1f7019d7d551a6402fC5350c73;
    // address private constant MASTERCHEF = 0x73feaa1eE314F8c655E354234017bE2193C9E24E;
    
    // Cream token
    // address private constant crWBNB = 0x15CC701370cb8ADA2a2B6f4226eC5CF6AA93bC67;
    // address private constant crBNB = 0x1Ffe17B99b439bE0aFC831239dDECda2A790fF3A;
    // address private constant crUSDC = 0xD83C88DB3A6cA4a32FFf1603b0f7DDce01F5f727;
    
    // StableCoin
    // address private constant WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    // address private constant BNB = 0xcA143Ce32Fe78f1f7019d7d551a6402fC5350c73;
    // address private constant USDT = 0x55d398326f99059fF775485246999027B3197955;
    // address private constant TUSD = 0x14016E85a25aeb13065688cAFB43044C2ef86784;
    // address private constant BUSD = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;
    // address private constant USDC = 0x8AC76a51cc950d9822D68b83fE1Ad97B32Cd580d;
    
    HighLevelSystem.HLSConfig private HLSConfig;
    HighLevelSystem.CreamToken private CreamToken;
    HighLevelSystem.StableCoin private StableCoin;
    HighLevelSystem.Position private position;
    
    using SafeMath for uint;
    using SafeMath for uint256;
    string public constant name = "Proof token";
    string public constant symbol = "pToken";
    uint8 public constant decimals = 18;
    uint256 private totalSupply_;
    
    bool public activable;
    address private dofin;
    uint private deposit_limit;
    
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
            max_amount_per_position: _uints[1],
            supply_funds_percentage: _uints[2]
        });
        
        activable = true;
        dofin = _dofin;
        deposit_limit = _deposit_limit;
    }

    modifier checkActivable() {
        require(activable == true, 'CashBox is not activable.');
        _;
    }
    
    function setConfig(address[] memory _config) public onlyOwner {
        HLSConfig.LinkConfig.oracle = _config[0];
        HLSConfig.CreamConfig.oracle = _config[1];
        HLSConfig.PancakeSwapConfig.router = _config[2];
        HLSConfig.PancakeSwapConfig.factory = _config[3];
        HLSConfig.PancakeSwapConfig.masterchef = _config[4];
    }
    
    function setCreamTokens(address[] memory _creamtokens) public onlyOwner {
        CreamToken.crWBNB = _creamtokens[0];
        CreamToken.crBNB = _creamtokens[1];
        CreamToken.crUSDC = _creamtokens[2];
    }
    
    function setStableCoins(address[] memory _stablecoins) public onlyOwner {
        StableCoin.WBNB = _stablecoins[0];
        StableCoin.CAKE = _stablecoins[1];
        StableCoin.USDT = _stablecoins[2];
        StableCoin.TUSD = _stablecoins[3];
        StableCoin.BUSD = _stablecoins[4];
        StableCoin.USDC = _stablecoins[5];
    }

    function setActivable(bool _activable) public onlyOwner {
        
        activable = _activable;
    }
    
    function getPosition() public onlyOwner view returns(HighLevelSystem.Position memory) {
        
        return position;
    }
    
    function reblanceWithRepay() public onlyOwner checkActivable {
        HighLevelSystem.exitPosition(HLSConfig, CreamToken, StableCoin, position, 3);
        position = HighLevelSystem.enterPosition(HLSConfig, CreamToken, StableCoin, position, 3);
    }
    
    function reblanceWithoutRepay() public onlyOwner checkActivable {
        HighLevelSystem.exitPosition(HLSConfig, CreamToken, StableCoin, position, 2);
        position = HighLevelSystem.enterPosition(HLSConfig, CreamToken, StableCoin, position, 2);
    }
    
    function reblance() public onlyOwner checkActivable  {
        HighLevelSystem.exitPosition(HLSConfig, CreamToken, StableCoin, position, 1);
        position = HighLevelSystem.enterPosition(HLSConfig, CreamToken, StableCoin, position, 1);
    }
    
    function checkAddNewFunds() onlyOwner checkActivable public returns (uint) {
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
    }
    
    function enter(uint _type) public onlyOwner checkActivable {
        
        position = HighLevelSystem.enterPosition(HLSConfig, CreamToken, StableCoin, position, _type);
    }

    function exit(uint _type) public onlyOwner checkActivable {
        
        HighLevelSystem.exitPosition(HLSConfig, CreamToken, StableCoin, position, _type);
    }
    
    function checkCurrentBorrowLimit() onlyOwner public returns (uint) {
        
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
        // Cream borrowed amount
        (uint crtoken_a_debt, uint crtoken_b_debt) = HighLevelSystem.getTotalBorrowAmount(CreamToken, position.borrowed_crtoken_a, position.borrowed_crtoken_b);
        // PancakeSwap pending cake amount
        uint pending_cake_amount = HighLevelSystem.getTotalCakePendingRewards(HLSConfig, position.pool_id);
        // PancakeSwap staked amount
        (uint token_a_amount, uint token_b_amount) = HighLevelSystem.getStakedTokens(HLSConfig, position);

        crtoken_a_debt = HighLevelSystem.getPancakeSwapAmountOut(HLSConfig, position.token_a, position.token, crtoken_a_debt);
        crtoken_b_debt = HighLevelSystem.getPancakeSwapAmountOut(HLSConfig, position.token_b, position.token, crtoken_b_debt);
        pending_cake_amount = HighLevelSystem.getPancakeSwapAmountOut(HLSConfig, StableCoin.CAKE, position.token, pending_cake_amount);
        token_a_amount = HighLevelSystem.getPancakeSwapAmountOut(HLSConfig, position.token_a, position.token, token_a_amount);
        token_b_amount = HighLevelSystem.getPancakeSwapAmountOut(HLSConfig, position.token_b, position.token, token_b_amount);
        
        uint total_assets = SafeMath.sub(SafeMath.add(token_a_amount, token_b_amount), SafeMath.add(crtoken_a_debt, crtoken_b_debt));
        total_assets = SafeMath.add(total_assets, pending_cake_amount);
        total_assets = SafeMath.add(total_assets, IBEP20(position.token).balanceOf(address(this)));
        return total_assets;
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
    
    function deposit(address _token, uint _deposit_amount) public checkActivable returns (bool) {
        require(_deposit_amount <= SafeMath.mul(deposit_limit, 10**IBEP20(position.token).decimals()), "Deposit too much!");
        require(_token == position.token, "Wrong token to deposit.");
        require(_deposit_amount > 0, "Deposit amount must bigger than 0.");
        
        // Calculation of pToken amount need to mint
        uint shares = getDepositAmountOut(_deposit_amount);
        
        // Mint pToken and transfer Token to cashbox
        mint(msg.sender, shares);
        IBEP20(position.token).transferFrom(msg.sender, address(this), _deposit_amount);
        
        // Check need to supply or not.
        // checkAddNewFunds();
        
        return true;
    }
    
    function getWithdrawAmount(uint _ptoken_amount) public view returns (uint) {
        uint totalAssets = getTotalAssets();
        uint value = SafeMath.div(SafeMath.mul(_ptoken_amount, totalAssets), totalSupply_);
        uint user_value = SafeMath.div(SafeMath.mul(80, value), 100);
        
        return user_value;
    }
    
    function withdraw(uint _withdraw_amount) public checkActivable returns (bool) {
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