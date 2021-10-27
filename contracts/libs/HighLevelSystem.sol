// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

import "../token/BEP20/IBEP20.sol";
import "../math/SafeMath.sol";
import "../interfaces/chainlink/AggregatorInterface.sol";
import "../interfaces/cream/CErc20Delegator.sol";
import "../interfaces/pancakeswap/IPancakePair.sol";
import "../interfaces/pancakeswap/IPancakeFactory.sol";
import "../interfaces/pancakeswap/MasterChef.sol";
import "../interfaces/pancakeswap/IPancakeRouter02.sol";

/// @title High level system execution
/// @author Andrew FU
/// @dev All functions haven't finished unit test
library HighLevelSystem {    

    // HighLevelSystem config
    struct HLSConfig {
        address token_oracle; // Address of Link oracle contract.
        address token_a_oracle; // Address of Link oracle contract.
        address token_b_oracle; // Address of Link oracle contract.
        address cake_oracle; // Address of Link oracle contract.
        address router; // Address of PancakeSwap router contract.
        address factory; // Address of PancakeSwap factory contract.
        address masterchef; // Address of PancakeSwap masterchef contract.
        address CAKE; // Address of ERC20 CAKE contract.
    }
    
    // Position
    struct Position {
        uint pool_id;
        uint token_amount;
        uint token_a_amount;
        uint token_b_amount;
        uint lp_token_amount;
        uint crtoken_amount;
        uint supply_crtoken_amount;
        address token;
        address token_a;
        address token_b;
        address lp_token;
        address supply_crtoken;
        address borrowed_crtoken_a;
        address borrowed_crtoken_b;
        uint supply_funds_percentage;
        uint total_depts;
    }

    /// @param _position refer Position struct on the top.
    /// @dev Supplies 'amount' worth of tokens to cream.
    function _supplyCream(Position memory _position) private returns(Position memory) {
        uint enter_amount = SafeMath.div(SafeMath.mul(IBEP20(_position.token).balanceOf(address(this)), _position.supply_funds_percentage), 100);
        uint exchange_rate = CErc20Delegator(_position.supply_crtoken).exchangeRateStored();
        uint crtoken_amount = SafeMath.div(enter_amount, exchange_rate);
        
        CErc20Delegator(_position.supply_crtoken).mint(crtoken_amount);

        // Update posititon amount data
        _position.token_amount = IBEP20(_position.token).balanceOf(address(this));
        _position.crtoken_amount = IBEP20(_position.supply_crtoken).balanceOf(address(this));
        _position.supply_crtoken_amount = crtoken_amount;

        return _position;
    }

    /// @param self refer HLSConfig struct on the top.
    /// @param _position refer Position struct on the top.
    /// @dev Borrow the required tokens for a given position on CREAM.
    function _borrow(HLSConfig memory self, Position memory _position) private returns(Position memory) {
        uint token_value = SafeMath.div(SafeMath.mul(_position.supply_crtoken_amount, 100), 75);
        token_value = SafeMath.div(SafeMath.mul(token_value, 1000), 375);
        
        uint token_price = uint(AggregatorInterface(self.token_oracle).latestAnswer());
        // Borrow token_a
        uint token_a_rate = SafeMath.div(uint(AggregatorInterface(self.token_a_oracle).latestAnswer()), token_price);
        uint token_a_borrow_amount = SafeMath.div(token_value, token_a_rate);
        // Borrow token_b
        uint token_b_rate = SafeMath.div(uint(AggregatorInterface(self.token_b_oracle).latestAnswer()), token_price);
        uint token_b_borrow_amount = SafeMath.div(token_value, token_b_rate);
        
        CErc20Delegator(_position.borrowed_crtoken_a).borrow(token_a_borrow_amount);
        CErc20Delegator(_position.borrowed_crtoken_b).borrow(token_b_borrow_amount);

        // Update posititon amount data
        _position.token_a_amount = IBEP20(_position.token_a).balanceOf(address(this));
        _position.token_b_amount = IBEP20(_position.token_b).balanceOf(address(this));

        return _position;
    }

    /// @param self refer HLSConfig struct on the top.
    /// @param _position refer Position struct on the top.
    /// @dev Adds liquidity to a given pool.
    function _addLiquidity(HLSConfig memory self, Position memory _position) private returns (Position memory) {
        uint max_available_staking_a = IBEP20(_position.token_a).balanceOf(address(this));
        uint max_available_staking_b = IBEP20(_position.token_b).balanceOf(address(this));
        (uint reserves0, uint reserves1, uint blockTimestampLast) = IPancakePair(_position.lp_token).getReserves();
        uint min_a_amnt = IPancakeRouter02(self.router).quote(max_available_staking_a, reserves0, reserves1);
        uint min_b_amnt = IPancakeRouter02(self.router).quote(max_available_staking_b, reserves1, reserves0);

        IPancakeRouter02(self.router).addLiquidity(_position.token_a, _position.token_b, max_available_staking_a, max_available_staking_b, min_a_amnt, min_b_amnt, address(this), block.timestamp);
        
        // Update posititon amount data
        _position.lp_token_amount = IBEP20(_position.lp_token).balanceOf(address(this));
        _position.token_a_amount = IBEP20(_position.token_a).balanceOf(address(this));
        _position.token_b_amount = IBEP20(_position.token_b).balanceOf(address(this));

        return _position;
    }

    /// @param self refer HLSConfig struct on the top.
    /// @param _position refer Position struct on the top.
    /// @dev Stakes LP tokens into a farm.
    function _stake(HLSConfig memory self, Position memory _position) private returns (Position memory) {
        MasterChef(self.masterchef).deposit(_position.pool_id, IBEP20(_position.lp_token).balanceOf(address(this)));

        // Update posititon amount data
        _position.lp_token_amount = IBEP20(_position.lp_token).balanceOf(address(this));

        return _position;
    }

    /// @param self refer HLSConfig struct on the top.
    /// @param _position refer Position struct on the top.
    /// @param _type enter type.
    /// @dev Main entry function to borrow and enter a given position.
    function enterPosition(HLSConfig memory self, Position memory _position, uint _type) external returns (Position memory) {
        
        if (_type == 1) {
            // Supply position
            _position = _supplyCream(_position);
        }
        
        if (_type == 1 || _type == 2) {
            // Borrow
            _position = _borrow(self, _position);
        }
        
        if (_type == 1 || _type == 2 || _type == 3) {
            // Add liquidity
            _position = _addLiquidity(self, _position);

            // Stake
            _position = _stake(self, _position);
        }
        
        _position.total_depts = getTotalDebts(self, _position);

        return _position;
    }

    /// @param _position refer Position struct on the top.
    /// @dev Redeem amount worth of crtokens back.
    function _redeemCream(Position memory _position) private returns (Position memory) {
        CErc20Delegator(_position.supply_crtoken).redeemUnderlying(IBEP20(_position.supply_crtoken).balanceOf(address(this)));

        // Update posititon amount data
        _position.crtoken_amount = IBEP20(_position.supply_crtoken).balanceOf(address(this));
        _position.supply_crtoken_amount = 0;

        return _position;
    }

    /// @param _position refer Position struct on the top.
    /// @dev Repay the tokens borrowed from cream.
    function _repay(Position memory _position) private returns (Position memory) {
        uint a_repay_amount = CErc20Delegator(_position.borrowed_crtoken_a).borrowBalanceStored(address(this));
        uint b_repay_amount = CErc20Delegator(_position.borrowed_crtoken_b).borrowBalanceStored(address(this));

        CErc20Delegator(_position.borrowed_crtoken_a).repayBorrow(a_repay_amount);
        CErc20Delegator(_position.borrowed_crtoken_b).repayBorrow(b_repay_amount);

        // Update posititon amount data
        _position.token_a_amount = IBEP20(_position.token_a).balanceOf(address(this));
        _position.token_b_amount = IBEP20(_position.token_b).balanceOf(address(this));

        return _position;
    }

    /// @param self refer HLSConfig struct on the top.
    /// @param _position refer Position struct on the top.
    /// @dev Removes liquidity from a given pool.
    function _removeLiquidity(HLSConfig memory self, Position memory _position) private returns (Position memory) {
        (uint reserve0, uint reserve1, uint blockTimestampLast) = IPancakePair(_position.lp_token).getReserves();
        uint total_supply = IPancakePair(_position.lp_token).totalSupply();
        uint token_a_amnt = SafeMath.div(SafeMath.mul(reserve0, _position.lp_token_amount), total_supply);
        uint token_b_amnt = SafeMath.div(SafeMath.mul(reserve1, _position.lp_token_amount), total_supply);

        IPancakeRouter02(self.router).removeLiquidity(_position.token_a, _position.token_b, _position.lp_token_amount, token_a_amnt, token_b_amnt, address(this), block.timestamp);

        // Update posititon amount data
        _position.lp_token_amount = IBEP20(_position.lp_token).balanceOf(address(this));
        _position.token_a_amount = IBEP20(_position.token_a).balanceOf(address(this));
        _position.token_b_amount = IBEP20(_position.token_b).balanceOf(address(this));

        return _position;
    }

    /// @param self refer HLSConfig struct on the top.
    /// @param _position refer Position struct on the top.
    /// @dev Removes liquidity from a given farm.
    function _unstake(HLSConfig memory self, Position memory _position) private returns (Position memory) {
        (uint lp_amount, uint rewardDebt) = MasterChef(self.masterchef).userInfo(_position.pool_id, address(this));
        
        MasterChef(self.masterchef).withdraw(_position.pool_id, lp_amount);

        // Update posititon amount data
        _position.lp_token_amount = IBEP20(_position.lp_token).balanceOf(address(this));

        return _position;
    }

    /// @param self refer HLSConfig struct on the top.
    /// @param _position refer Position struct on the top.
    /// @dev Main exit function to exit and repay a given position.
    function exitPosition(HLSConfig memory self, Position memory _position, uint _type) external returns (Position memory) {
        
        if (_type == 1 || _type == 2 || _type == 3) {
            // Unstake
            _position = _unstake(self, _position);
            
            // Unstake
            _position = _removeLiquidity(self, _position);
        }
        
        if (_type == 1 || _type == 2) {
            // Repay
            _position = _repay(_position);
        }
        
        if (_type == 1) {
            // Redeem
            _position = _redeemCream(_position);
        }

        _position.total_depts = getTotalDebts(self, _position);

        return _position;
    }

    /// @param _crtoken Cream crToken address.
    /// @dev Gets the total supply amount on cream.
    function getCreamUserTotalSupply(address _crtoken) private view returns (uint) {

        uint exch_rate = CErc20Delegator(_crtoken).exchangeRateStored();
        exch_rate = SafeMath.div(exch_rate, 10**18);
        uint crtoken_decimals = CErc20Delegator(_crtoken).decimals();
        uint token_decimals = IBEP20(CErc20Delegator(_crtoken).underlying()).decimals();
        uint balance = CErc20Delegator(_crtoken).balanceOf(address(this));
        balance = SafeMath.div(balance, 10**crtoken_decimals);
        uint total_supply = SafeMath.mul(balance, exch_rate);
        total_supply = SafeMath.div(total_supply, 10**SafeMath.sub(18, crtoken_decimals));

        return SafeMath.mul(total_supply, 10**token_decimals);
    }

    /// @param self refer HLSConfig struct on the top.
    /// @param token_a_amount amountIn of token a.
    /// @param token_b_amount amountIn of token b.
    /// @dev Get the price for two tokens, from LINK if possible, else => straight from router.
    function getChainLinkValues(HLSConfig memory self, uint token_a_amount, uint token_b_amount) private view returns (uint, uint) {
        
        // check if we can get data from chainlink
        uint token_price = uint(AggregatorInterface(self.token_oracle).latestAnswer());
        uint token_a_price = uint(AggregatorInterface(self.token_a_oracle).latestAnswer());
        uint token_b_price = uint(AggregatorInterface(self.token_b_oracle).latestAnswer());

        uint token_a_rate = SafeMath.div(token_a_price, token_price);
        uint token_b_rate = SafeMath.div(token_b_price, token_price);
        return (SafeMath.mul(token_a_amount, token_a_rate), SafeMath.mul(token_b_amount, token_b_rate));
    }

    /// @param self refer HLSConfig struct on the top.
    /// @param cake_amount amountIn of CAKE.
    /// @dev Get the price for two tokens, from LINK if possible, else => straight from router.
    function getCakeChainLinkValue(HLSConfig memory self, uint cake_amount) private view returns (uint) {
        
        // check if we can get data from chainlink
        uint token_price;
        uint cake_price;
        uint cake_rate;
        if (self.token_oracle != address(0)  && self.cake_oracle != address(0)) {
            token_price = uint(AggregatorInterface(self.token_oracle).latestAnswer());
            cake_price = uint(AggregatorInterface(self.cake_oracle).latestAnswer());

            cake_rate = SafeMath.div(cake_price, token_price);
            return SafeMath.mul(cake_amount, cake_rate);
        }

        return 0;
    }

    /// @param _crtoken_a Cream token.
    /// @param _crtoken_b Cream token.
    /// @dev Returns a map of <crtoken_address, borrow_amount> of all the borrowed coins.
    function getTotalBorrowAmount(address _crtoken_a, address _crtoken_b) private view returns (uint, uint) {
        
        uint crtoken_a_borrow_amount = CErc20Delegator(_crtoken_a).borrowBalanceStored(address(this));
        uint crtoken_b_borrow_amount = CErc20Delegator(_crtoken_b).borrowBalanceStored(address(this));
        return (crtoken_a_borrow_amount, crtoken_b_borrow_amount);
    }
    
    /// @param _position refer Position struct on the top.
    /// @dev Return staked tokens.
    function getStakedTokens(Position memory _position) private view returns (uint, uint) {
        (uint reserve0, uint reserve1, uint blockTimestampLast) = IPancakePair(_position.lp_token).getReserves();
        uint total_supply = IPancakePair(_position.lp_token).totalSupply();
        uint token_a_amnt = SafeMath.div(SafeMath.mul(reserve0, _position.lp_token_amount), total_supply);
        uint token_b_amnt = SafeMath.div(SafeMath.mul(reserve1, _position.lp_token_amount), total_supply);
        return (token_a_amnt, token_b_amnt);
    }

    /// @param self refer HLSConfig struct on the top.
    /// @param _position refer Position struct on the top.
    /// @dev Return total debts.
    function getTotalDebts(HLSConfig memory self, Position memory _position) public view returns (uint) {
        // Cream borrowed amount
        (uint crtoken_a_debt, uint crtoken_b_debt) = getTotalBorrowAmount(_position.borrowed_crtoken_a, _position.borrowed_crtoken_b);
        // PancakeSwap pending cake amount(getTotalCakePendingRewards)
        uint pending_cake_amount = MasterChef(self.masterchef).pendingCake(_position.pool_id, address(this));
        // PancakeSwap staked amount
        (uint token_a_amount, uint token_b_amount) = getStakedTokens(_position);

        uint cream_total_supply = getCreamUserTotalSupply(_position.supply_crtoken);
        (uint token_a_value, uint token_b_value) = getChainLinkValues(self, SafeMath.sub(token_a_amount, crtoken_a_debt), SafeMath.sub(token_b_amount, crtoken_b_debt));
        uint pending_cake_value = getCakeChainLinkValue(self, pending_cake_amount);
        
        return SafeMath.add(SafeMath.add(cream_total_supply, pending_cake_value), SafeMath.add(token_a_value, token_b_value));
    }

}





