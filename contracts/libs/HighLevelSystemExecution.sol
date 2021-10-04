// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

import "../token/BEP20/IBEP20.sol";
import "../math/SafeMath.sol";
import { PancakeSwapExecution } from "./PancakeSwapExecution.sol";
import { CreamExecution } from "./CreamExecution.sol";
import { LinkBSCOracle } from "./LinkBSCOracle.sol";

/// @title High level system execution
/// @author Andrew FU
/// @dev All functions haven't finished unit test
library HighLevelSystem {
    // Chainlink
    using LinkBSCOracle for LinkBSCOracle.LinkConfig;
    // address private link_oracle;

    // Cream
    using CreamExecution for CreamExecution.CreamConfig;

    // PancakeSwap
    using PancakeSwapExecution for PancakeSwapExecution.PancakeSwapConfig;
    
    // HighLevelSystem config
    struct HLSConfig {
        LinkBSCOracle.LinkConfig LinkConfig;
        CreamExecution.CreamConfig CreamConfig;
        PancakeSwapExecution.PancakeSwapConfig PancakeSwapConfig;
    }
    
    // Cream token required
    struct CreamToken {
        address crWBNB;
        address crBNB;
        address crUSDC;
    }
    
    // StableCoin required
    struct StableCoin {
        address WBNB;
        address BNB;
        address USDT;
        address TUSD;
        address BUSD;
        address USDC;
    }
    
    // Position
    struct Position {
        uint pool_id;
        uint a_amount;
        uint b_amount;
        address token_a;
        address token_b;
        address lp_token;
        address crtoken_a;
        address crtoken_b;
        uint max_amount_per_position;
        uint freefunds_percentage;
    }
    
    /// @param self refer HLSConfig struct on the top.
    /// @param _crtokens refer CreamToken struct on the top.
    /// @param _stablecoins refer StableCoin struct on the top.
    /// @param _position refer Position struct on the top.
    /// @dev Helper function to enter => addLiquidity + stakeLP.
    function enter(HLSConfig memory self, CreamToken memory _crtokens, StableCoin memory _stablecoins, Position memory _position) public returns (bool) {
        // add liquidity
        addLiquidity(self, _crtokens, _stablecoins, _position);
        
        // stake
        stakeLP(self, _position);
        
        return true;
    }
    
    /// @param _stablecoins refer StableCoin struct on the top.
    /// @param _token BEP20 token address.
    /// @dev Checks whether a token is a stable coin or not.
    function isStableCoin(StableCoin memory _stablecoins, address _token) public pure returns (bool) {
        if (_token == _stablecoins.USDT) {
            return true;
        }
        else if (_token == _stablecoins.TUSD) {
            return true;
        }
        else if (_token == _stablecoins.BUSD) {
            return true;
        }
        else if (_token == _stablecoins.USDC) {
            return true;
        }
        else {
            return false;
        }
    }
    
    /// @param self refer HLSConfig struct on the top.
    /// @param _crtokens refer CreamToken struct on the top.
    /// @param _stablecoins refer StableCoin struct on the top.
    /// @param _token_a BEP20 token address.
    /// @param _token_b BEP20 token address.
    /// @param _crtoken_a Cream crToken address.
    /// @param _crtoken_b Cream crToken address.
    /// @dev Get the price for two tokens, from LINK if possible, else => straight from router.
    function getPrice(HLSConfig memory self, CreamToken memory _crtokens, StableCoin memory _stablecoins, address _token_a, address _token_b, address _crtoken_a, address _crtoken_b) public view returns (uint) {
        address WBNB = _stablecoins.WBNB;
        address BNB = _stablecoins.BNB;
        address USDC = _stablecoins.USDC;
        address crUSDC = _crtokens.crUSDC;
        CreamExecution.CreamConfig memory CreamConfig = self.CreamConfig;
        
        if (_token_a == WBNB) {
            _token_a = BNB;
        }
        if (_token_b == WBNB) {
            _token_b = BNB;
        }
        if (isStableCoin(_stablecoins, _token_a) && isStableCoin(_stablecoins, _token_b)) {
            return 1;
        }

        // check if we can get data from chainlink
        uint price;
        if (self.LinkConfig.oracle != address(0)) {
            price = uint(LinkBSCOracle.getPrice(self.LinkConfig));
            return price;
        }

        // check if we can get data from cream
        if (_crtoken_a != address(0) && _crtoken_b != address(0)) {
            uint price_a = CreamExecution.getUSDPrice(CreamConfig, _crtoken_a, crUSDC, USDC);
            uint price_b = CreamExecution.getUSDPrice(CreamConfig, _crtoken_b, crUSDC, USDC);
            return SafeMath.div(price_a, price_b);
        }

        // check if we can get data from pancake
        price = PancakeSwapExecution.getAmountsOut(self.PancakeSwapConfig, _token_a, _token_b);
        return price;
    }

    /// @param _position refer Position struct on the top.
    /// @dev Checks if there is sufficient borrow liquidity on cream. Only borrow if there is 2x more liquidty than our borrow amount.
    function checkBorrowLiquidity(Position memory _position) public view returns (bool) {
        uint available_a = CreamExecution.getAvailableBorrow(_position.crtoken_a);
        uint available_b = CreamExecution.getAvailableBorrow(_position.crtoken_b);

        if (available_a > _position.a_amount && available_b > _position.b_amount) {
            return true;
        } else {
            return false;
        }
    }

    /// @param self refer HLSConfig struct on the top.
    /// @param _crtokens refer CreamToken struct on the top.
    /// @param _stablecoins refer StableCoin struct on the top.
    /// @param lp_constituient_0 The LP token amount.
    /// @param lp_constituient_1 The LP token amount.
    /// @param _lp_token address of the LP token.
    /// @param _crtoken_a address of the Cream token.
    /// @param _crtoken_b address of the Cream token.
    /// @dev Function returns the amount of token0, token1s the specified number of LP token represents.
    function getLPUSDValue(HLSConfig memory self, CreamToken memory _crtokens, StableCoin memory _stablecoins, uint lp_constituient_0, uint lp_constituient_1, address _lp_token, address _crtoken_a, address _crtoken_b) public view returns (uint) {
        (address token_0, address token_1) = PancakeSwapExecution.getLPTokenAddresses(_lp_token);
        address USDC = _stablecoins.USDC;
        address crUSDC = _crtokens.crUSDC;

        uint token_0_exch_rate = getPrice(self, _crtokens, _stablecoins, token_0, USDC, _crtoken_a, crUSDC);
        uint token_1_exch_rate = getPrice(self, _crtokens, _stablecoins, token_1, USDC, _crtoken_b, crUSDC);

        uint usd_value_0 = SafeMath.mul(token_0_exch_rate, lp_constituient_0);
        uint usd_value_1 = SafeMath.mul(token_1_exch_rate, lp_constituient_1);

        return usd_value_0 + usd_value_1;
    }
    
    /// @param self refer HLSConfig struct on the top.
    /// @param _crtokens refer CreamToken struct on the top.
    /// @param _stablecoins refer StableCoin struct on the top.
    /// @param _position refer Position struct on the top.
    /// @dev Enters positions based on the opportunity.
    function checkEntry(HLSConfig memory self, CreamToken memory _crtokens, StableCoin memory _stablecoins, Position memory _position) public {
        bool signal = checkBorrowLiquidity(_position);
        if (signal == true) {
            enterPosition(self, _crtokens, _stablecoins, _position, 1);
        }
    }
    
    /// @param self refer HLSConfig struct on the top.
    /// @param _stablecoins refer StableCoin struct on the top.
    /// @param _position refer Position struct on the top.
    /// @dev Helper function to exit => removeLiquidity + unstakeLP.
    function exit(HLSConfig memory self, StableCoin memory _stablecoins, Position memory _position) public returns (bool) {
        // unstake
        unstakeLP(self, _position);

        // remove liquidity
        removeLiquidity(self, _stablecoins, _position);
        
        return true;
    }

    /// @param _crtokens refer CreamToken struct on the top.
    /// @dev Returns a map of <crtoken_address, borrow_amount> of all the borrowed coins.
    function getTotalBorrowAmount(CreamToken memory _crtokens, address _crtoken_a, address _crtoken_b) public view returns (uint, uint) {
        uint crtoken_a_borrow_amount = CreamExecution.getBorrowAmount(_crtoken_a, _crtokens.crWBNB);
        uint crtoken_b_borrow_amount = CreamExecution.getBorrowAmount(_crtoken_b, _crtokens.crWBNB);
        return (crtoken_a_borrow_amount, crtoken_b_borrow_amount);
    }

    /// @param self refer HLSConfig struct on the top.
    /// @dev Returns pending cake rewards for all the positions we are in.
    function getTotalCakePendingRewards(HLSConfig memory self, uint _pool_id) public view returns (uint) {
        uint cake_amnt = PancakeSwapExecution.getPendingFarmRewards(self.PancakeSwapConfig, _pool_id);
        return cake_amnt;
    }

    /// @param _crtoken Cream crToken address.
    /// @param _amount amount of tokens to supply.
    /// @dev Supplies 'amount' worth of tokens to cream.
    function supplyCream(address _crtoken, uint _amount) public returns (uint) {
        uint exchange_rate = CreamExecution.getExchangeRate(_crtoken);
        uint crtoken_amount = SafeMath.div(_amount, exchange_rate);
        return CreamExecution.supply(_crtoken, crtoken_amount);
    }
    
    /// @param _crtoken Cream crToken address.
    /// @param _amount amount of tokens to redeem.
    /// @dev Redeem amount worth of crtokens back.
    function redeemCream(address _crtoken, uint _amount) public returns (uint) {
        
        return CreamExecution.redeemUnderlying(_crtoken, _amount);
    }

    /// @param _crtokens refer CreamToken struct on the top.
    /// @dev check how much free cash we have left (whatever we can borrow up to 75% will be regarded as free cash) => after > 75% free cash would be negative.
    function getFreeCash(CreamToken memory _crtokens, address _crtoken_a, address _crtoken_b) public returns (uint) {
        address crWBNB = _crtokens.crWBNB;
        uint current_supply_amount = CreamExecution.getUserTotalSupply(_crtokens.crUSDC);
        uint position_a_amnt = CreamExecution.getBorrowAmount(_crtoken_a, crWBNB);
        uint position_b_amnt = CreamExecution.getBorrowAmount(_crtoken_b, crWBNB);
        uint current_borrow_amount = SafeMath.add(position_a_amnt, position_b_amnt);
        uint free_cash = SafeMath.sub(SafeMath.div(SafeMath.mul(current_supply_amount, 75), 100), current_borrow_amount);

        return free_cash;
    }

    /// @param self refer HLSConfig struct on the top.
    /// @param _crtokens refer CreamToken struct on the top.
    /// @param _stablecoins refer StableCoin struct on the top.
    /// @param _position refer Position struct on the top.
    /// @dev Given a dollar amount, find out how many units of a and b can we get.
    function splitUnits(HLSConfig memory self, CreamToken memory _crtokens, StableCoin memory _stablecoins, Position memory _position, uint dollar_amount) public view returns (uint, uint) {
        uint half_amount = SafeMath.div(dollar_amount, 2);
        address USDT = _stablecoins.USDT;
        address crUSDC = _crtokens.crUSDC;
        
        uint price_a = getPrice(self, _crtokens, _stablecoins, _position.token_a, USDT, _position.crtoken_a, crUSDC);
        uint price_b = getPrice(self, _crtokens, _stablecoins, _position.token_b, USDT, _position.crtoken_b, crUSDC);
        
        uint units_a = SafeMath.div(half_amount, price_a);
        uint units_b = SafeMath.div(half_amount, price_b);

        return (units_a, units_b);
    }

    /// @param self refer HLSConfig struct on the top.
    /// @param _crtokens refer CreamToken struct on the top.
    /// @param _stablecoins refer StableCoin struct on the top.
    /// @param _position refer Position struct on the top.
    /// @dev Given an opportunity object, calculate the position sizes based on current margin levels.
    function calculateEntryAmounts(HLSConfig memory self, CreamToken memory _crtokens, StableCoin memory _stablecoins, Position memory _position) public returns (uint, uint) {
        (uint max_position_size_a, uint max_position_size_b) = splitUnits(self, _crtokens, _stablecoins, _position, _position.max_amount_per_position);
        uint max_borrow_limit = checkPotentialBorrowLimit(self, _crtokens, _stablecoins, _position, max_position_size_a, max_position_size_b);
        max_borrow_limit = SafeMath.mul(max_borrow_limit, 100);
        // TODO need to < 0.75
        if (max_borrow_limit < 75) {
            return (max_position_size_a, max_position_size_b);
        }

        uint free_cash = getFreeCash(_crtokens, _position.crtoken_a, _position.crtoken_b);
        (uint min_position_size_a, uint min_position_size_b) = splitUnits(self, _crtokens, _stablecoins, _position, free_cash);
        uint min_borrow_limit = checkPotentialBorrowLimit(self, _crtokens, _stablecoins, _position, max_position_size_a, max_position_size_b);
        min_borrow_limit = SafeMath.mul(min_borrow_limit, 100);
        // TODO need to < 0.75
        if (min_borrow_limit < 75) {
            return (min_position_size_a, min_position_size_b);
        }

        // cannot enter position
        return (0, 0);
    }

    /// @param self refer HLSConfig struct on the top.
    /// @param _crtokens refer CreamToken struct on the top.
    /// @param _stablecoins refer StableCoin struct on the top.
    /// @param _position refer Position struct on the top.
    /// @dev use a greedy apporach to allocate the cash.
    function generatePosition(HLSConfig memory self, CreamToken memory _crtokens, StableCoin memory _stablecoins, Position memory _position) public returns (Position memory) {
        (uint a_amount, uint b_amount) = calculateEntryAmounts(self, _crtokens, _stablecoins, _position);
        Position memory update_position = Position(_position.pool_id, a_amount, b_amount, _position.token_a, _position.token_b, _position.lp_token, _position.crtoken_a, _position.crtoken_b, _position.max_amount_per_position, _position.freefunds_percentage);
        return update_position;
    }

    /// @param self refer HLSConfig struct on the top.
    /// @param _crtokens refer CreamToken struct on the top.
    /// @param _stablecoins refer StableCoin struct on the top.
    /// @param _position refer Position struct on the top.
    /// @dev Main entry function to borrow and enter a given position.
    function enterPosition(HLSConfig memory self, CreamToken memory _crtokens, StableCoin memory _stablecoins, Position memory _position, uint _type) public returns (Position memory) {
        
        if (_type == 1) {
            // Supply position
            uint token_a_balance = IBEP20(_position.token_a).balanceOf(address(this));
            uint token_b_balance = IBEP20(_position.token_b).balanceOf(address(this));
            uint enter_amount_a = SafeMath.div(SafeMath.mul(token_a_balance, _position.freefunds_percentage), 100);
            uint enter_amount_b = SafeMath.div(SafeMath.mul(token_b_balance, _position.freefunds_percentage), 100);
            supplyCream(_position.crtoken_a, enter_amount_a);
            supplyCream(_position.crtoken_b, enter_amount_b);
            _position.a_amount = enter_amount_a;
            _position.b_amount = enter_amount_b;
        }
        
        if (_type == 1 || _type == 2) {
            // Borrowing position
            borrowPosition(_position);
        }
        
        if (_type == 1 || _type == 2 || _type == 3) {
            // Entering position
            enter(self, _crtokens, _stablecoins, _position);    
        }
        
        return _position;
    }

    /// @param self refer HLSConfig struct on the top.
    /// @param _crtokens refer CreamToken struct on the top.
    /// @param _stablecoins refer StableCoin struct on the top.
    /// @param _position refer Position struct on the top.
    /// @dev Main exit function to exit and repay a given position.
    function exitPosition(HLSConfig memory self, CreamToken memory _crtokens, StableCoin memory _stablecoins, Position memory _position, uint _type) public {
        
        if (_type == 1) {
            // Redeem position
            uint exit_amount_a = IBEP20(_position.crtoken_a).balanceOf(address(this));
            uint exit_amount_b = IBEP20(_position.crtoken_b).balanceOf(address(this));
            redeemCream(_position.crtoken_a, exit_amount_a);
            redeemCream(_position.crtoken_b, exit_amount_b);
        }
        
        if (_type == 1 || _type == 2) {
            // Exiting position
            exit(self, _stablecoins, _position);
        }
        
        if (_type == 1 || _type == 2 || _type == 3) {
            // Returning borrow
            returnBorrow(_crtokens, _stablecoins, _position);
        }
    }

    /// @param _crtokens refer CreamToken struct on the top.
    /// @param _stablecoins refer StableCoin struct on the top.
    /// @param _position refer Position struct on the top.
    /// @dev Repay the tokens borrowed from cream.
    function returnBorrow(CreamToken memory _crtokens, StableCoin memory _stablecoins, Position memory _position) public {
        uint borrowed_a = CreamExecution.getBorrowAmount(_position.crtoken_a, _crtokens.crWBNB);
        uint borrowed_b = CreamExecution.getBorrowAmount(_position.crtoken_b, _crtokens.crWBNB);

        uint current_a_balance = CreamExecution.getTokenBalance(_position.crtoken_a);
        uint current_b_balance = CreamExecution.getTokenBalance(_position.crtoken_b);

        uint a_repay_amount;
        uint b_repay_amount;

        if (borrowed_a < current_a_balance) {
            a_repay_amount = borrowed_a;
        } else {
            a_repay_amount = current_a_balance;
        }
        if (borrowed_b < current_b_balance) {
            b_repay_amount = borrowed_b;
        } else {
            b_repay_amount = current_b_balance;
        }

        // CrTokenAddress issue
        uint _isWBNB = isWBNB(_stablecoins, _position.token_a, _position.token_b);
        if (_isWBNB == 2) {
            CreamExecution.repay(_position.crtoken_a, a_repay_amount);
            CreamExecution.repay(_position.crtoken_b, b_repay_amount);
        } else if (_isWBNB == 1) {
            CreamExecution.repayETH(_position.crtoken_a, a_repay_amount);
            CreamExecution.repay(_position.crtoken_b, b_repay_amount);
        } else if (_isWBNB == 0)  {
            CreamExecution.repay(_position.crtoken_a, a_repay_amount);
            CreamExecution.repayETH(_position.crtoken_b, b_repay_amount);
        }

    }

    /// @param _position refer Position struct on the top.
    /// @dev Borrow the required tokens for a given position on CREAM.
    function borrowPosition(Position memory _position) public {
        CreamExecution.borrow(_position.crtoken_a, _position.a_amount);
        CreamExecution.borrow(_position.crtoken_b, _position.b_amount);
    }

    /// @param _stablecoins refer StableCoin struct on the top.
    /// @param _token_a BEP20 token address.
    /// @param _token_b BEP20 token address.
    /// @dev Checks if either token address is WBNB.
    function isWBNB(StableCoin memory _stablecoins, address _token_a, address _token_b) public pure returns (uint) {
        if (_token_a == _stablecoins.WBNB && _token_b == _stablecoins.WBNB) {
            return 2;
        } else if (_token_a == _stablecoins.WBNB) {
            return 1;
        } else if (_token_b == _stablecoins.WBNB) {
            return 0;
        } else {
            return 2;
        }
    }

    /// @param _crtoken_a Cream crToken address..
    /// @param _crtoken_b Cream crToken address..
    /// @dev Gets an array of all the cream tokens that have been borrowed.
    function getBorrowedCreamTokens(address _crtoken_a, address _crtoken_b) public pure returns (address, address) {
        
        return (_crtoken_a, _crtoken_b);
    }

    /// @param self refer HLSConfig struct on the top.
    /// @param _crtokens refer CreamToken struct on the top.
    /// @param _stablecoins refer StableCoin struct on the top.
    /// @param _position refer Position struct on the top.
    /// @param self refer HLSConfig struct on the top.
    /// @dev Gets the total borrow limit for all positions on cream.
    function checkCurrentBorrowLimit(HLSConfig memory self, CreamToken memory _crtokens, StableCoin memory _stablecoins, Position memory _position) public returns (uint) {
        uint crtoken_a_supply_amount = CreamExecution.getUserTotalSupply(_position.crtoken_a);
        uint crtoken_a_borrow_amount = CreamExecution.getBorrowAmount(_position.crtoken_a, _crtokens.crWBNB);
        uint crtoken_a_limit = CreamExecution.getBorrowLimit(self.CreamConfig, _position.crtoken_a, _crtokens.crUSDC, _stablecoins.USDC, crtoken_a_supply_amount, crtoken_a_borrow_amount);

        uint crtoken_b_supply_amount = CreamExecution.getUserTotalSupply(_position.crtoken_a);
        uint crtoken_b_borrow_amount = CreamExecution.getBorrowAmount(_position.crtoken_b, _crtokens.crWBNB);
        uint crtoken_b_limit = CreamExecution.getBorrowLimit(self.CreamConfig, _position.crtoken_b, _crtokens.crUSDC, _stablecoins.USDC, crtoken_b_supply_amount, crtoken_b_borrow_amount);
        return crtoken_a_limit + crtoken_b_limit;
    }

    /// @param self refer HLSConfig struct on the top.
    /// @param _crtokens refer CreamToken struct on the top.
    /// @param _stablecoins refer StableCoin struct on the top.
    /// @param _position refer Position struct on the top.
    /// @param new_amount_a amount of token a.
    /// @param new_amount_b amount of token b.
    /// @dev Check if entering this new position will violate any borrow/lending limits.
    function checkPotentialBorrowLimit(HLSConfig memory self, CreamToken memory _crtokens, StableCoin memory _stablecoins, Position memory _position, uint new_amount_a, uint new_amount_b) public returns (uint) {
        uint current_borrow_limit = checkCurrentBorrowLimit(self, _crtokens, _stablecoins, _position);

        uint crtoken_a_supply_amount = CreamExecution.getUserTotalSupply(_position.crtoken_a);
        uint borrow_limit_a = CreamExecution.getBorrowLimit(self.CreamConfig, _position.crtoken_a, _crtokens.crUSDC, _stablecoins.USDC, crtoken_a_supply_amount, new_amount_a);
        
        uint crtoken_b_supply_amount = CreamExecution.getUserTotalSupply(_position.crtoken_b);
        uint borrow_limit_b = CreamExecution.getBorrowLimit(self.CreamConfig, _position.crtoken_b, _crtokens.crUSDC, _stablecoins.USDC, crtoken_b_supply_amount, new_amount_b);

        return current_borrow_limit + borrow_limit_a + borrow_limit_b;
    }

    /// @param self refer HLSConfig struct on the top.
    /// @param _crtokens refer CreamToken struct on the top.
    /// @param _stablecoins refer StableCoin struct on the top.
    /// @param _position refer Position struct on the top.
    /// @dev Adds liquidity to a given pool.
    function addLiquidity(HLSConfig memory self, CreamToken memory _crtokens, StableCoin memory _stablecoins, Position memory _position) public returns (uint) {
        uint pair_price = getPrice(self, _crtokens, _stablecoins, _position.token_a, _position.token_b, _position.crtoken_a, _position.crtoken_b);
        uint price_decimals = PancakeSwapExecution.getPairDecimals(PancakeSwapExecution.getPair(self.PancakeSwapConfig, _position.token_a, _position.token_b));

        // make sure if one of the tokens is WBNB => have a minimum of 0.3 BNB in the wallet at all times
        // get a 50:50 split of the tokens in USD and make sure the two tokens are in correct order
        (uint max_available_staking_a, uint max_available_staking_b) = PancakeSwapExecution.splitTokensEvenly(_position.a_amount, _position.b_amount, pair_price, price_decimals);

        // todo check the lineups => amount for tokens a and tokens b is off
        (max_available_staking_a, max_available_staking_b) = PancakeSwapExecution.lineUpPairs(_position.token_a, _position.token_b, max_available_staking_a, max_available_staking_b, _position.lp_token);
        (address token_a, address token_b) = PancakeSwapExecution.getLPTokenAddresses(_position.lp_token);

        uint bnb_check = isWBNB(_stablecoins, token_a, token_b);
        if (bnb_check != 2) {
            if (bnb_check == 1) {
                return PancakeSwapExecution.addLiquidityETH(self.PancakeSwapConfig, token_a, _stablecoins.WBNB, max_available_staking_b, max_available_staking_a);
            } else {
                return PancakeSwapExecution.addLiquidityETH(self.PancakeSwapConfig, token_b, _stablecoins.WBNB, max_available_staking_a, max_available_staking_b);
            }
        } else {
            return PancakeSwapExecution.addLiquidity(self.PancakeSwapConfig, token_a, token_b, max_available_staking_a, max_available_staking_b);
        }
    }

    /// @param self refer HLSConfig struct on the top.
    /// @param _stablecoins refer StableCoin struct on the top.
    /// @param _position refer Position struct on the top.
    /// @dev Removes liquidity from a given pool.
    function removeLiquidity(HLSConfig memory self, StableCoin memory _stablecoins, Position memory _position) public returns (bool) {
        // check how much (token0 and token1) we have in the current farm
        //this function already sorts the token orders according to the contract
        uint lp_balance = PancakeSwapExecution.getLPBalance(_position.lp_token);
        (uint token_a_amnt, uint token_b_amnt) = PancakeSwapExecution.getLPConstituients(lp_balance, _position.lp_token);

        (address token_a, address token_b) = PancakeSwapExecution.getLPTokenAddresses(_position.lp_token);
        uint bnb_check = isWBNB(_stablecoins, token_a, token_b);

        if (bnb_check != 2) {
            if (bnb_check == 1) {
                PancakeSwapExecution.removeLiquidityETH(self.PancakeSwapConfig, _position.lp_token, token_a, lp_balance, token_a_amnt, token_b_amnt);
            } else {
                PancakeSwapExecution.removeLiquidityETH(self.PancakeSwapConfig, _position.lp_token, token_b, lp_balance, token_b_amnt, token_a_amnt);
            }
        } else {
            PancakeSwapExecution.removeLiquidity(self.PancakeSwapConfig, _position.lp_token, token_a, token_b, lp_balance, token_a_amnt, token_b_amnt);
        }

        return true;
    }

    /// @param self refer HLSConfig struct on the top.
    /// @param _position refer Position struct on the top.
    /// @dev Stakes LP tokens into a farm.
    function stakeLP(HLSConfig memory self, Position memory _position) public returns (bool) {
        uint lp_balance = PancakeSwapExecution.getLPBalance(_position.lp_token);
        return PancakeSwapExecution.stakeLP(self.PancakeSwapConfig, _position.pool_id, lp_balance);
    }

    /// @param self refer HLSConfig struct on the top.
    /// @param _position refer Position struct on the top.
    /// @dev Removes liquidity from a given farm.
    function unstakeLP(HLSConfig memory self, Position memory _position) public returns (bool) {
        uint lp_balance = PancakeSwapExecution.getStakedLP(self.PancakeSwapConfig, _position.pool_id);
        return PancakeSwapExecution.unstakeLP(self.PancakeSwapConfig, _position.pool_id, lp_balance);
    }
    
    /// @param self refer HLSConfig struct on the top.
    /// @param _position refer Position struct on the top.
    /// @dev Return staked tokens.
    function getStakedTokens(HLSConfig memory self, Position memory _position) public view returns (uint, uint) {
        uint lp_balance = PancakeSwapExecution.getStakedLP(self.PancakeSwapConfig, _position.pool_id);
        (uint token_a_amnt, uint token_b_amnt) = PancakeSwapExecution.getLPConstituients(lp_balance, _position.lp_token);
        return (token_a_amnt, token_b_amnt);
    }

}





