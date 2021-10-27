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

    using SafeMath for uint256;

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
        uint256 pool_id;
        uint256 token_amount;
        uint256 token_a_amount;
        uint256 token_b_amount;
        uint256 lp_token_amount;
        uint256 crtoken_amount;
        uint256 supply_crtoken_amount;
        address token;
        address token_a;
        address token_b;
        address lp_token;
        address supply_crtoken;
        address borrowed_crtoken_a;
        address borrowed_crtoken_b;
        uint256 supply_funds_percentage;
        uint256 total_depts;
    }

    /// @param _position refer Position struct on the top.
    /// @dev Supplies 'amount' worth of tokens to cream.
    function _supplyCream(Position memory _position) private returns(Position memory) {
        uint256 supply_amount = IBEP20(_position.token).balanceOf(address(this)).mul(_position.supply_funds_percentage).div(100);
        uint256 exchange_rate = CErc20Delegator(_position.supply_crtoken).exchangeRateStored();
        supply_amount = supply_amount.div(exchange_rate);
        
        CErc20Delegator(_position.supply_crtoken).mint(supply_amount);

        // Update posititon amount data
        _position.token_amount = IBEP20(_position.token).balanceOf(address(this));
        _position.crtoken_amount = IBEP20(_position.supply_crtoken).balanceOf(address(this));
        _position.supply_crtoken_amount = supply_amount;

        return _position;
    }

    /// @param self refer HLSConfig struct on the top.
    /// @param _position refer Position struct on the top.
    /// @dev Borrow the required tokens for a given position on CREAM.
    function _borrow(HLSConfig memory self, Position memory _position) private returns(Position memory) {
        uint256 token_value = _position.supply_crtoken_amount.mul(100).div(75);
        token_value = token_value.mul(1000).div(375);
        
        uint256 token_price = uint256(AggregatorInterface(self.token_oracle).latestAnswer());
        uint256 token_a_price = uint256(AggregatorInterface(self.token_a_oracle).latestAnswer()).mul(10**8);
        uint256 token_b_price = uint256(AggregatorInterface(self.token_b_oracle).latestAnswer()).mul(10**8);
        // Borrow token_a
        uint256 token_a_rate = token_a_price.div(token_price);
        uint256 token_a_borrow_amount = token_value.div(token_a_rate).mul(10**8);
        // Borrow token_b
        uint256 token_b_rate = token_b_price.div(token_price);
        uint256 token_b_borrow_amount = token_value.div(token_b_rate).mul(10**8);
        
        CErc20Delegator(_position.borrowed_crtoken_a).borrow(token_a_borrow_amount);
        CErc20Delegator(_position.borrowed_crtoken_b).borrow(token_b_borrow_amount);

        // Update posititon amount data
        _position.token_a_amount = IBEP20(_position.token_a).balanceOf(address(this));
        _position.token_b_amount = IBEP20(_position.token_b).balanceOf(address(this));

        return _position;
    }

    /// @param self refer HLSConfig struct on the top.
    /// @param _position refer Position struct on t he top.
    /// @dev Adds liquidity to a given pool.
    function _addLiquidity(HLSConfig memory self, Position memory _position) private returns (Position memory) {
        uint256 max_available_staking_a = IBEP20(_position.token_a).balanceOf(address(this));
        uint256 max_available_staking_b = IBEP20(_position.token_b).balanceOf(address(this));
        (uint256 reserves0, uint256 reserves1, uint256 blockTimestampLast) = IPancakePair(_position.lp_token).getReserves();
        uint256 min_a_amnt = IPancakeRouter02(self.router).quote(max_available_staking_a, reserves0, reserves1);
        uint256 min_b_amnt = IPancakeRouter02(self.router).quote(max_available_staking_b, reserves1, reserves0);

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
    function enterPosition(HLSConfig memory self, Position memory _position, uint256 _type) external returns (Position memory) {
        
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
        uint256 a_repay_amount = CErc20Delegator(_position.borrowed_crtoken_a).borrowBalanceStored(address(this));
        uint256 b_repay_amount = CErc20Delegator(_position.borrowed_crtoken_b).borrowBalanceStored(address(this));

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
        (uint256 reserve0, uint256 reserve1, uint256 blockTimestampLast) = IPancakePair(_position.lp_token).getReserves();
        uint256 total_supply = IPancakePair(_position.lp_token).totalSupply();
        uint256 token_a_amnt = reserve0.mul(_position.lp_token_amount).div(total_supply);
        uint256 token_b_amnt = reserve1.mul(_position.lp_token_amount).div(total_supply);

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
        (uint256 lp_amount, uint256 rewardDebt) = MasterChef(self.masterchef).userInfo(_position.pool_id, address(this));
        
        MasterChef(self.masterchef).withdraw(_position.pool_id, lp_amount);

        // Update posititon amount data
        _position.lp_token_amount = IBEP20(_position.lp_token).balanceOf(address(this));

        return _position;
    }

    /// @param self refer HLSConfig struct on the top.
    /// @param _position refer Position struct on the top.
    /// @dev Main exit function to exit and repay a given position.
    function exitPosition(HLSConfig memory self, Position memory _position, uint256 _type) external returns (Position memory) {
        
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
    function getCreamUserTotalSupply(address _crtoken) private view returns (uint256) {

        uint256 exch_rate = CErc20Delegator(_crtoken).exchangeRateStored();
        exch_rate = exch_rate.div(10**18);
        uint256 crtoken_decimals = CErc20Delegator(_crtoken).decimals();
        uint256 token_decimals = IBEP20(CErc20Delegator(_crtoken).underlying()).decimals();
        uint256 balance = CErc20Delegator(_crtoken).balanceOf(address(this));
        balance = balance.div(10**crtoken_decimals);
        uint256 total_supply = balance.mul(exch_rate);
        total_supply = total_supply.div(10**SafeMath.sub(18, crtoken_decimals));

        return total_supply.mul(10**token_decimals);
    }

    /// @param self refer HLSConfig struct on the top.
    /// @param token_a_amount amountIn of token a.
    /// @param token_b_amount amountIn of token b.
    /// @dev Get the price for two tokens, from LINK if possible, else => straight from router.
    function getChainLinkValues(HLSConfig memory self, uint256 token_a_amount, uint256 token_b_amount) private view returns (uint256, uint256) {
        
        // check if we can get data from chainlink
        uint256 token_price = uint256(AggregatorInterface(self.token_oracle).latestAnswer());
        uint256 token_a_price = uint256(AggregatorInterface(self.token_a_oracle).latestAnswer());
        uint256 token_b_price = uint256(AggregatorInterface(self.token_b_oracle).latestAnswer());

        return (token_a_amount.mul(token_a_price).div(token_price), token_b_amount.mul(token_b_price).div(token_price));
    }

    /// @param self refer HLSConfig struct on the top.
    /// @param cake_amount amountIn of CAKE.
    /// @dev Get the price for two tokens, from LINK if possible, else => straight from router.
    function getCakeChainLinkValue(HLSConfig memory self, uint256 cake_amount) private view returns (uint256) {
        
        // check if we can get data from chainlink
        uint256 token_price;
        uint256 cake_price;
        if (self.token_oracle != address(0)  && self.cake_oracle != address(0)) {
            token_price = uint256(AggregatorInterface(self.token_oracle).latestAnswer());
            cake_price = uint256(AggregatorInterface(self.cake_oracle).latestAnswer());

            return cake_amount.mul(cake_price).div(token_price);
        }

        return 0;
    }

    /// @param _crtoken_a Cream token.
    /// @param _crtoken_b Cream token.
    /// @dev Returns a map of <crtoken_address, borrow_amount> of all the borrowed coins.
    function getTotalBorrowAmount(address _crtoken_a, address _crtoken_b) private view returns (uint256, uint256) {
        
        uint256 crtoken_a_borrow_amount = CErc20Delegator(_crtoken_a).borrowBalanceStored(address(this));
        uint256 crtoken_b_borrow_amount = CErc20Delegator(_crtoken_b).borrowBalanceStored(address(this));
        return (crtoken_a_borrow_amount, crtoken_b_borrow_amount);
    }
    
    /// @param _position refer Position struct on the top.
    /// @dev Return staked tokens.
    function getStakedTokens(Position memory _position) private view returns (uint256, uint256) {
        (uint256 reserve0, uint256 reserve1, uint256 blockTimestampLast) = IPancakePair(_position.lp_token).getReserves();
        uint256 total_supply = IPancakePair(_position.lp_token).totalSupply();
        uint256 token_a_amnt = reserve0.mul(_position.lp_token_amount).div(total_supply);
        uint256 token_b_amnt = reserve1.mul(_position.lp_token_amount).div(total_supply);
        return (token_a_amnt, token_b_amnt);
    }

    /// @param self refer HLSConfig struct on the top.
    /// @param _position refer Position struct on the top.
    /// @dev Return total debts.
    function getTotalDebts(HLSConfig memory self, Position memory _position) public view returns (uint256) {
        // Cream borrowed amount
        (uint256 crtoken_a_debt, uint256 crtoken_b_debt) = getTotalBorrowAmount(_position.borrowed_crtoken_a, _position.borrowed_crtoken_b);
        // PancakeSwap pending cake amount(getTotalCakePendingRewards)
        uint256 pending_cake_amount = MasterChef(self.masterchef).pendingCake(_position.pool_id, address(this));
        // PancakeSwap staked amount
        (uint256 token_a_amount, uint256 token_b_amount) = getStakedTokens(_position);

        uint256 cream_total_supply = getCreamUserTotalSupply(_position.supply_crtoken);
        (uint256 token_a_value, uint256 token_b_value) = getChainLinkValues(self, token_a_amount.sub(crtoken_a_debt), token_b_amount.sub(crtoken_b_debt));
        uint256 pending_cake_value = getCakeChainLinkValue(self, pending_cake_amount);
        
        return cream_total_supply.add(pending_cake_value).add(token_a_value).add(token_b_value);
    }

}





