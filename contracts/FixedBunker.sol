// SPDX-License-Identifier: MIT
pragma solidity >=0.8;

import "./token/BEP20/IBEP20.sol";
import "./math/SafeMath.sol";
import "./utils/BasicContract.sol";
import "./utils/ProofToken.sol";
import { HighLevelSystem } from "./libs/HighLevelSystem.sol";

/// @title FixedBunker
/// @author Andrew FU
contract FixedBunker is BasicContract, ProofToken {

    struct User {
        uint256 depositPtokenAmount;
        uint256 depositTokenAmount;
        uint256 depositBlockTimestamp;
    }

    HighLevelSystem.HLSConfig private HLSConfig;
    HighLevelSystem.Position private position;
    
    using SafeMath for uint256;
    uint256 constant private MAX_INT_EXPONENTIATION = 2**256 - 1;

    uint256 private deposit_limit;
    uint256 private temp_free_funds;
    bool public TAG = false;
    address private dofin;

    mapping (address => User) private users;

    constructor(uint256[1] memory _uints, address[6] memory _addrs, string memory _name, string memory _symbol, uint8 _decimals) ProofToken(_name, _symbol, _decimals) public {
        position = HighLevelSystem.Position({
            pool_id: 0,
            token_amount: 0,
            token_a_amount: 0,
            token_b_amount: 0,
            lp_token_amount: 0,
            crtoken_amount: 0,
            supply_crtoken_amount: 0,
            token: _addrs[0],
            token_a: _addrs[1],
            token_b: _addrs[2],
            lp_token: address(0),
            supply_crtoken: _addrs[3],
            borrowed_crtoken_a: _addrs[4],
            borrowed_crtoken_b: _addrs[5],
            supply_funds_percentage: _uints[0],
            total_depts: 0
        });
    }

    modifier checkTag() {
        require(TAG == true, 'TAG ERROR.');
        _;
    }
    
    function setConfig(address[4] memory _config, address _dofin, uint256 _deposit_limit) external onlyOwner {
        HLSConfig.token_oracle = _config[0];
        HLSConfig.token_a_oracle = _config[1];
        HLSConfig.token_b_oracle = _config[2];
        HLSConfig.comptroller = _config[3];

        dofin = _dofin;
        deposit_limit = _deposit_limit;

        // Approve for Cream borrow 
        IBEP20(position.token).approve(position.supply_crtoken, MAX_INT_EXPONENTIATION);
        // Approve for Cream repay
        IBEP20(position.token_a).approve(position.borrowed_crtoken_a, MAX_INT_EXPONENTIATION);
        IBEP20(position.token_b).approve(position.borrowed_crtoken_b, MAX_INT_EXPONENTIATION);
        // Approve for Cream redeem
        IBEP20(position.supply_crtoken).approve(position.supply_crtoken, MAX_INT_EXPONENTIATION);

        // Set Tag
        setTag(true);
    }

    function setTag(bool _tag) public onlyOwner {
        
        TAG = _tag;
        if (_tag == true) {
            address[] memory crtokens = new address[] (3);
            crtokens[0] = address(0x0000000000000000000000000000000000000020);
            crtokens[1] = address(0x0000000000000000000000000000000000000001);
            crtokens[2] = position.supply_crtoken;
            HighLevelSystem.enterMarkets(HLSConfig.comptroller, crtokens);
        } else {
            HighLevelSystem.exitMarket(HLSConfig.comptroller, position.supply_crtoken);
        }
    }
    
    function getPosition() external onlyOwner view returns(HighLevelSystem.Position memory) {
        
        return position;
    }

    function getUser(address _account) external view returns (User memory) {
        
        return users[_account];
    }
    
    function rebalanceWithRepay() external onlyOwner checkTag {
        position = HighLevelSystem.exitPositionFixed(HLSConfig, position, 2);
        position = HighLevelSystem.enterPositionFixed(HLSConfig, position, 2);
        temp_free_funds = IBEP20(position.token).balanceOf(address(this));
    }
    
    function rebalance() external onlyOwner checkTag  {
        position = HighLevelSystem.exitPositionFixed(HLSConfig, position, 1);
        position = HighLevelSystem.enterPositionFixed(HLSConfig, position, 1);
        temp_free_funds = IBEP20(position.token).balanceOf(address(this));
    }
    
    function checkAddNewFunds() external onlyOwner checkTag view returns (uint256) {
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
    
    function enter(uint256 _type) external onlyOwner checkTag {
        
        position = HighLevelSystem.enterPositionFixed(HLSConfig, position, _type);
        temp_free_funds = IBEP20(position.token).balanceOf(address(this));
    }

    function exit(uint256 _type) external onlyOwner checkTag {
        
        position = HighLevelSystem.exitPositionFixed(HLSConfig, position, _type);
    }

    function getTotalAssets() public view returns (uint256) {
        // Free funds amount
        uint256 freeFunds = IBEP20(position.token).balanceOf(address(this));
        // Total Debts amount from Cream, PancakeSwap
        uint256 totalDebts = HighLevelSystem.getTotalDebtsFixed(HLSConfig, position);
        
        return freeFunds.add(totalDebts);
    }

    function getDepositAmountOut(uint256 _deposit_amount) public view returns (uint256) {
        uint256 totalAssets = IBEP20(position.token).balanceOf(address(this)).add(position.total_depts);
        uint256 shares;
        if (totalSupply_ > 0) {
            shares = _deposit_amount.mul(totalSupply_).div(totalAssets);
        } else {
            shares = _deposit_amount;
        }
        return shares;
    }
    
    function deposit(uint256 _deposit_amount) external checkTag returns (bool) {
        require(_deposit_amount <= deposit_limit.mul(10**IBEP20(position.token).decimals()), "Deposit too much!");
        require(_deposit_amount > 0, "Deposit amount must bigger than 0.");
        
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
    
    function withdraw() external checkTag returns (bool) {
        uint256 withdraw_amount = balanceOf(msg.sender);
        uint256 totalAssets = getTotalAssets();
        uint256 value = withdraw_amount.mul(totalAssets).div(totalSupply_);
        User memory user = users[msg.sender];
        bool need_rebalance = false;
        require(withdraw_amount > user.depositPtokenAmount, "Proof token amount incorrect");
        require(block.timestamp > user.depositBlockTimestamp, "Deposit and withdraw in same block");
        // If no enough amount of free funds can transfer will trigger exit position
        if (value > IBEP20(position.token).balanceOf(address(this))) {
            HighLevelSystem.exitPositionFixed(HLSConfig, position, 1);
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
            HighLevelSystem.enterPositionFixed(HLSConfig, position, 1);
            temp_free_funds = IBEP20(position.token).balanceOf(address(this));
        }
        
        return true;
    }
    
}