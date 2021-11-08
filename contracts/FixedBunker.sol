// SPDX-License-Identifier: MIT
pragma solidity >=0.8;

import "./libs/IBEP20.sol";
import "./libs/SafeMath.sol";
import "./utils/ProofToken.sol";
import { HighLevelSystem } from "./libs/HighLevelSystem.sol";

/// @title FixedBunker
/// @author Andrew FU
contract FixedBunker is ProofToken {

    struct User {
        uint256 depositPtokenAmount;
        uint256 depositTokenAmount;
        uint256 depositBlockTimestamp;
    }

    HighLevelSystem.HLSConfig private HLSConfig;
    HighLevelSystem.Position private position;
    
    using SafeMath for uint256;
    uint256 constant private MAX_INT_EXPONENTIATION = 2**256 - 1;

    uint256 private total_deposit_limit;
    uint256 private deposit_limit;
    uint256 private temp_free_funds;
    bool public TAG = false;
    address private dofin = address(0);
    address private factory = address(0);

    mapping (address => User) private users;

    function checkCaller() public view returns (bool) {
        if (msg.sender == factory || msg.sender == dofin) {
            return true;
        }
        return false;
    }

    function initialize(uint256[1] memory _uints, address[2] memory _addrs, string memory _name, string memory _symbol, uint8 _decimals) external {
        if (dofin!=address(0) && factory!=address(0)) {
            require(checkCaller() == true, "Only factory or dofin can call this function");
        }
        position = HighLevelSystem.Position({
            pool_id: 0,
            token_amount: 0,
            token_a_amount: 0,
            token_b_amount: 0,
            lp_token_amount: 0,
            crtoken_amount: 0,
            supply_crtoken_amount: 0,
            token: _addrs[0],
            token_a: address(0),
            token_b: address(0),
            lp_token: address(0),
            supply_crtoken: _addrs[1],
            borrowed_crtoken_a: address(0),
            borrowed_crtoken_b: address(0),
            supply_funds_percentage: _uints[0],
            total_depts: 0
        });
        initializeToken(_name, _symbol, _decimals);
        factory = msg.sender;
    }
    
    function setConfig(address[1] memory _config, address _dofin, uint256[2] memory _deposit_limit) external {
        if (dofin!=address(0) && factory!=address(0)) {
            require(checkCaller() == true, "Only factory or dofin can call this function");
        }
        HLSConfig.token_oracle = _config[0];

        dofin = _dofin;
        deposit_limit = _deposit_limit[0];
        total_deposit_limit = _deposit_limit[1];

        // Approve for Cream borrow 
        IBEP20(position.token).approve(position.supply_crtoken, MAX_INT_EXPONENTIATION);
        // Approve for Cream redeem
        IBEP20(position.supply_crtoken).approve(position.supply_crtoken, MAX_INT_EXPONENTIATION);
        // Approve for withdraw
        IBEP20(position.token).approve(address(this), MAX_INT_EXPONENTIATION);

        // Set Tag
        setTag(true);
    }

    function setTag(bool _tag) public {
        require(checkCaller() == true, "Only factory or dofin can call this function");
        TAG = _tag;
    }
    
    function getPosition() external view returns(HighLevelSystem.Position memory) {
        
        return position;
    }

    function getUser(address _account) external view returns (User memory) {
        
        return users[_account];
    }
    
    function rebalance() external  {
        require(checkCaller() == true, "Only factory or dofin can call this function");
        require(TAG == true, 'TAG ERROR.');
        position = HighLevelSystem.exitPositionFixed(position);
        position = HighLevelSystem.enterPositionFixed(position);
        temp_free_funds = IBEP20(position.token).balanceOf(address(this));
    }
    
    function checkAddNewFunds() external view returns (uint256) {
        uint256 free_funds = IBEP20(position.token).balanceOf(address(this));
        if (free_funds > temp_free_funds) {
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
    
    function enter() external {
        require(checkCaller() == true, "Only factory or dofin can call this function");
        require(TAG == true, 'TAG ERROR.');
        position = HighLevelSystem.enterPositionFixed(position);
        temp_free_funds = IBEP20(position.token).balanceOf(address(this));
    }

    function exit() external {
        require(checkCaller() == true, "Only factory or dofin can call this function");
        require(TAG == true, 'TAG ERROR.');
        position = HighLevelSystem.exitPositionFixed(position);
    }

    function getTotalAssets() public view returns (uint256) {
        // Free funds amount
        uint256 freeFunds = IBEP20(position.token).balanceOf(address(this));
        // Total Debts amount from Cream
        uint256 totalDebts = HighLevelSystem.getTotalDebtsFixed(position);
        
        return freeFunds.add(totalDebts);
    }

    function getDepositAmountOut(uint256 _deposit_amount) public view returns (uint256) {
        require(_deposit_amount <= deposit_limit.mul(10**IBEP20(position.token).decimals()), "Deposit too much");
        require(_deposit_amount > 0, "Deposit amount must bigger than 0");
        uint256 totalAssets = IBEP20(position.token).balanceOf(address(this)).add(position.total_depts);
        require(total_deposit_limit.mul(10**IBEP20(position.token).decimals()) >= totalAssets.add(_deposit_amount), "Deposit get limited");
        uint256 shares;
        if (totalSupply_ > 0) {
            shares = _deposit_amount.mul(totalSupply_).div(totalAssets);
        } else {
            shares = _deposit_amount;
        }
        return shares;
    }
    
    function deposit(uint256 _deposit_amount) external returns (bool) {
        require(TAG == true, 'TAG ERROR.');
        // Calculation of pToken amount need to mint
        uint256 shares = getDepositAmountOut(_deposit_amount);
        
        // Record user deposit amount
        users[msg.sender] = User({
            depositPtokenAmount: shares,
            depositTokenAmount: _deposit_amount,
            depositBlockTimestamp: block.timestamp
        });

        // Mint pToken and transfer Token to cashbox
        mint(msg.sender, shares);
        IBEP20(position.token).transferFrom(msg.sender, address(this), _deposit_amount);
        
        return true;
    }
    
    function getWithdrawAmount() external view returns (uint256) {
        uint256 totalAssets = getTotalAssets();
        uint256 withdraw_amount = balanceOf(msg.sender);
        uint256 value = withdraw_amount.mul(totalAssets).div(totalSupply_);
        User memory user = users[msg.sender];
        if (withdraw_amount > user.depositPtokenAmount) {
            return 0;
        }
        uint256 dofin_value;
        uint256 user_value;
        if (value > user.depositTokenAmount) {
            dofin_value = value.sub(user.depositTokenAmount).mul(20).div(100);
            user_value = value.sub(dofin_value);
        } else {
            user_value = value;
        }
        
        return user_value;
    }
    
    function withdraw() external returns (bool) {
        require(TAG == true, 'TAG ERROR.');
        uint256 withdraw_amount = balanceOf(msg.sender);
        uint256 totalAssets = getTotalAssets();
        uint256 value = withdraw_amount.mul(totalAssets).div(totalSupply_);
        User memory user = users[msg.sender];
        bool need_rebalance = false;
        require(withdraw_amount <= user.depositPtokenAmount, "Proof token amount incorrect");
        require(block.timestamp > user.depositBlockTimestamp, "Deposit and withdraw in same block");
        // If no enough amount of free funds can transfer will trigger exit position
        if (value > IBEP20(position.token).balanceOf(address(this)).add(10**IBEP20(position.token).decimals())) {
            HighLevelSystem.exitPositionFixed(position);
            totalAssets = IBEP20(position.token).balanceOf(address(this));
            value = withdraw_amount.mul(totalAssets).div(totalSupply_);
            need_rebalance = true;
        }
        // Will charge 20% fees
        burn(msg.sender, withdraw_amount);
        uint256 dofin_value;
        uint256 user_value;
        if (value > user.depositTokenAmount) {
            dofin_value = value.sub(user.depositTokenAmount).mul(20).div(100);
            user_value = value.sub(dofin_value);
        } else {
            user_value = value;
        }
        // Modify user state data
        user.depositPtokenAmount = 0;
        user.depositTokenAmount = 0;
        user.depositBlockTimestamp = 0;
        users[msg.sender] = user;
        IBEP20(position.token).transferFrom(address(this), dofin, dofin_value);
        IBEP20(position.token).transferFrom(address(this), msg.sender, user_value);
        // Enter position again
        if (need_rebalance == true) {
            HighLevelSystem.enterPositionFixed(position);
            temp_free_funds = IBEP20(position.token).balanceOf(address(this));
        }
        
        return true;
    }
    
}