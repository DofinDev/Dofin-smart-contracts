// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

import "../token/BEP20/IBEP20.sol";
import "../math/SafeMath.sol";
import { PancakeSwapExecution } from "./PancakeSwapExecution.sol";
import { CreamExecution } from "./CreamExecution.sol";
import "../interfaces/chainlink/AggregatorInterface.sol";

/// @title High level system execution
/// @author Andrew FU
/// @dev All functions haven't finished unit test
library HighLevelSystem {    

    // Addresss of ChainLink.
    struct LinkAddressConfig {
        address token_oracle; // Address of Link oracle contract.
        address token_a_oracle; // Address of Link oracle contract.
        address token_b_oracle; // Address of Link oracle contract.
        address cake_oracle; // Address of Link oracle contract.
    }

    // HighLevelSystem config
    struct HLSConfig {
        LinkAddressConfig LinkConfig;
        CreamExecution.CreamConfig CreamConfig;
        PancakeSwapExecution.PancakeSwapConfig PancakeSwapConfig;
    }
    
    // Cream token required
    struct CreamToken {
        address crWBNB;
        address crUSDC;
    }
    
    // StableCoin required
    struct StableCoin {
        address WBNB;
        address CAKE;
        address USDC;
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
    }
    
    /// @param self refer HLSConfig struct on the top.
    /// @param _crtokens refer CreamToken struct on the top.
    /// @param _stablecoins refer StableCoin struct on the top.
    /// @param _position refer Position struct on the top.
    /// @dev Helper function to enter => addLiquidity + stakeLP.
    function enter(HLSConfig memory self, CreamToken memory _crtokens, StableCoin memory _stablecoins, Position memory _position) internal returns (bool) {
        // add liquidity
        addLiquidity(self, _crtokens, _stablecoins, _position);
        
        // stake
        stakeLP(self, _position);

        return true;
    }

    /// @param self refer HLSConfig struct on the top.
    /// @param token_a_amount amountIn of token a.
    /// @param token_b_amount amountIn of token b.
    /// @dev Get the price for two tokens, from LINK if possible, else => straight from router.
    function getChainLinkValues(HLSConfig memory self, uint token_a_amount, uint token_b_amount) internal view returns (uint, uint) {
        
        // check if we can get data from chainlink
        uint token_price;
        uint token_a_price;
        uint token_b_price;
        uint token_a_rate;
        uint token_b_rate;
        if (self.LinkConfig.token_oracle != address(0)  && self.LinkConfig.token_a_oracle != address(0) && self.LinkConfig.token_b_oracle != address(0)) {
            token_price = uint(AggregatorInterface(self.LinkConfig.token_oracle).latestAnswer());
            token_a_price = uint(AggregatorInterface(self.LinkConfig.token_a_oracle).latestAnswer());
            token_b_price = uint(AggregatorInterface(self.LinkConfig.token_b_oracle).latestAnswer());

            token_a_rate = SafeMath.div(token_a_price, token_price);
            token_b_rate = SafeMath.div(token_b_price, token_price);
            return (SafeMath.mul(token_a_amount, token_a_rate), SafeMath.mul(token_b_amount, token_b_rate));
        }

        return (0, 0);
    }

    /// @param self refer HLSConfig struct on the top.
    /// @param cake_amount amountIn of CAKE.
    /// @dev Get the price for two tokens, from LINK if possible, else => straight from router.
    function getCakeChainLinkValue(HLSConfig memory self, uint cake_amount) internal view returns (uint) {
        
        // check if we can get data from chainlink
        uint token_price;
        uint cake_price;
        uint cake_rate;
        if (self.LinkConfig.token_oracle != address(0)  && self.LinkConfig.cake_oracle != address(0)) {
            token_price = uint(AggregatorInterface(self.LinkConfig.token_oracle).latestAnswer());
            cake_price = uint(AggregatorInterface(self.LinkConfig.cake_oracle).latestAnswer());

            cake_rate = SafeMath.div(cake_price, token_price);
            return SafeMath.mul(cake_amount, cake_rate);
        }

        return 0;
    }
    
    /// @param self refer HLSConfig struct on the top.
    /// @param _token_a BEP20 token address.
    /// @param _token_b BEP20 token address.
    /// @param _amountIn amount of token a.
    /// @dev Get the amount out from PancakeSwap.
    function getPancakeSwapAmountOut(HLSConfig memory self, address _token_a, address _token_b, uint _amountIn) internal view returns (uint) {
        
        return PancakeSwapExecution.getAmountsOut(self.PancakeSwapConfig, _token_a, _token_b, _amountIn);
    }
    
    /// @param self refer HLSConfig struct on the top.
    /// @param _stablecoins refer StableCoin struct on the top.
    /// @param _position refer Position struct on the top.
    /// @dev Helper function to exit => removeLiquidity + unstakeLP.
    function exit(HLSConfig memory self, StableCoin memory _stablecoins, Position memory _position) internal returns (bool) {
        // unstake
        unstakeLP(self, _position);

        // remove liquidity
        removeLiquidity(self, _stablecoins, _position);
        
        return true;
    }

    /// @param _crtokens refer CreamToken struct on the top.
    /// @dev Returns a map of <crtoken_address, borrow_amount> of all the borrowed coins.
    function getTotalBorrowAmount(CreamToken memory _crtokens, address _crtoken_a, address _crtoken_b) internal view returns (uint, uint) {
        uint crtoken_a_borrow_amount = CreamExecution.getBorrowAmount(_crtoken_a, _crtokens.crWBNB);
        uint crtoken_b_borrow_amount = CreamExecution.getBorrowAmount(_crtoken_b, _crtokens.crWBNB);
        return (crtoken_a_borrow_amount, crtoken_b_borrow_amount);
    }

    /// @param self refer HLSConfig struct on the top.
    /// @dev Returns pending cake rewards for all the positions we are in.
    function getTotalCakePendingRewards(HLSConfig memory self, uint _pool_id) internal view returns (uint) {
        uint cake_amnt = PancakeSwapExecution.getPendingFarmRewards(self.PancakeSwapConfig, _pool_id);
        return cake_amnt;
    }

    /// @param _crtoken Cream crToken address.
    /// @param _amount amount of tokens to supply.
    /// @dev Supplies 'amount' worth of tokens to cream.
    function supplyCream(address _crtoken, uint _amount) internal returns (uint) {
        uint exchange_rate = CreamExecution.getExchangeRate(_crtoken);
        uint crtoken_amount = SafeMath.div(_amount, exchange_rate);
        return CreamExecution.supply(_crtoken, crtoken_amount);
    }
    
    /// @param _crtoken Cream crToken address.
    /// @param _amount amount of tokens to redeem.
    /// @dev Redeem amount worth of crtokens back.
    function redeemCream(address _crtoken, uint _amount) internal returns (uint) {
        
        return CreamExecution.redeemUnderlying(_crtoken, _amount);
    }

    /// @param self refer HLSConfig struct on the top.
    /// @param _crtokens refer CreamToken struct on the top.
    /// @param _stablecoins refer StableCoin struct on the top.
    /// @param _position refer Position struct on the top.
    /// @dev Main entry function to borrow and enter a given position.
    function enterPosition(HLSConfig memory self, CreamToken memory _crtokens, StableCoin memory _stablecoins, Position memory _position, uint _type) external returns (Position memory) {
        
        if (_type == 1) {
            // Supply position
            uint token_balance = IBEP20(_position.token).balanceOf(address(this));
            uint enter_amount = SafeMath.div(SafeMath.mul(token_balance, _position.supply_funds_percentage), 100);
            supplyCream(_position.supply_crtoken, enter_amount);
            _position.token_amount = IBEP20(_position.token).balanceOf(address(this));
            _position.crtoken_amount = IBEP20(_position.supply_crtoken).balanceOf(address(this));
        }
        
        if (_type == 1 || _type == 2) {
            // Borrowing position
            borrowPosition(_position);
            _position.token_a_amount = IBEP20(_position.token_a).balanceOf(address(this));
            _position.token_b_amount = IBEP20(_position.token_b).balanceOf(address(this));
        }
        
        if (_type == 1 || _type == 2 || _type == 3) {
            // Entering position
            enter(self, _crtokens, _stablecoins, _position); 
            _position.lp_token_amount = IBEP20(_position.lp_token).balanceOf(address(this));
            _position.token_a_amount = IBEP20(_position.token_a).balanceOf(address(this));
            _position.token_b_amount = IBEP20(_position.token_b).balanceOf(address(this));
        }
        
        return _position;
    }

    /// @param self refer HLSConfig struct on the top.
    /// @param _crtokens refer CreamToken struct on the top.
    /// @param _stablecoins refer StableCoin struct on the top.
    /// @param _position refer Position struct on the top.
    /// @dev Main exit function to exit and repay a given position.
    function exitPosition(HLSConfig memory self, CreamToken memory _crtokens, StableCoin memory _stablecoins, Position memory _position, uint _type) external returns (Position memory) {
        
        if (_type == 1 || _type == 2 || _type == 3) {
            // Exiting position
            exit(self, _stablecoins, _position);
            _position.lp_token_amount = IBEP20(_position.lp_token).balanceOf(address(this));
            _position.token_a_amount = IBEP20(_position.token_a).balanceOf(address(this));
            _position.token_b_amount = IBEP20(_position.token_b).balanceOf(address(this));
        }
        
        if (_type == 1 || _type == 2) {
            // Returning borrow
            returnBorrow(_crtokens, _stablecoins, _position);
            _position.supply_crtoken_amount = IBEP20(_position.supply_crtoken).balanceOf(address(this));
            _position.token_a_amount = IBEP20(_position.token_a).balanceOf(address(this));
            _position.token_b_amount = IBEP20(_position.token_b).balanceOf(address(this));
        }
        
        if (_type == 1) {
            // Redeem position
            uint exit_amount_a = IBEP20(_position.token_a).balanceOf(address(this));
            uint exit_amount_b = IBEP20(_position.token_b).balanceOf(address(this));
            redeemCream(_position.borrowed_crtoken_a, exit_amount_a);
            redeemCream(_position.borrowed_crtoken_b, exit_amount_b);
            _position.token_amount = IBEP20(_position.token).balanceOf(address(this));
            _position.crtoken_amount = IBEP20(_position.supply_crtoken).balanceOf(address(this));
            _position.token_a_amount = IBEP20(_position.token_a).balanceOf(address(this));
            _position.token_b_amount = IBEP20(_position.token_b).balanceOf(address(this));
        }

        return _position;
    }

    /// @param _crtokens refer CreamToken struct on the top.
    /// @param _stablecoins refer StableCoin struct on the top.
    /// @param _position refer Position struct on the top.
    /// @dev Repay the tokens borrowed from cream.
    function returnBorrow(CreamToken memory _crtokens, StableCoin memory _stablecoins, Position memory _position) internal {
        uint borrowed_a = CreamExecution.getBorrowAmount(_position.borrowed_crtoken_a, _crtokens.crWBNB);
        uint borrowed_b = CreamExecution.getBorrowAmount(_position.borrowed_crtoken_b, _crtokens.crWBNB);

        uint current_a_balance = CreamExecution.getTokenBalance(_position.borrowed_crtoken_a);
        uint current_b_balance = CreamExecution.getTokenBalance(_position.borrowed_crtoken_b);

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
            CreamExecution.repay(_position.borrowed_crtoken_a, a_repay_amount);
            CreamExecution.repay(_position.borrowed_crtoken_b, b_repay_amount);
        } else if (_isWBNB == 1) {
            CreamExecution.repayETH(_position.borrowed_crtoken_a, a_repay_amount);
            CreamExecution.repay(_position.borrowed_crtoken_b, b_repay_amount);
        } else if (_isWBNB == 0)  {
            CreamExecution.repay(_position.borrowed_crtoken_a, a_repay_amount);
            CreamExecution.repayETH(_position.borrowed_crtoken_b, b_repay_amount);
        }

    }

    /// @param _position refer Position struct on the top.
    /// @dev Borrow the required tokens for a given position on CREAM.
    function borrowPosition(Position memory _position) internal {
        CreamExecution.borrow(_position.borrowed_crtoken_a, _position.token_a_amount);
        CreamExecution.borrow(_position.borrowed_crtoken_b, _position.token_b_amount);
    }

    /// @param _stablecoins refer StableCoin struct on the top.
    /// @param _token_a BEP20 token address.
    /// @param _token_b BEP20 token address.
    /// @dev Checks if either token address is WBNB.
    function isWBNB(StableCoin memory _stablecoins, address _token_a, address _token_b) internal pure returns (uint) {
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

    /// @param self refer HLSConfig struct on the top.
    /// @param _crtokens refer CreamToken struct on the top.
    /// @param _stablecoins refer StableCoin struct on the top.
    /// @param _position refer Position struct on the top.
    /// @param self refer HLSConfig struct on the top.
    /// @dev Gets the total borrow limit for all positions on cream.
    function checkCurrentBorrowLimit(HLSConfig memory self, CreamToken memory _crtokens, StableCoin memory _stablecoins, Position memory _position) external returns (uint) {
        uint crtoken_a_supply_amount = CreamExecution.getUserTotalSupply(_position.borrowed_crtoken_a);
        uint crtoken_a_borrow_amount = CreamExecution.getBorrowAmount(_position.borrowed_crtoken_a, _crtokens.crWBNB);
        uint crtoken_a_limit = CreamExecution.getBorrowLimit(self.CreamConfig, _position.borrowed_crtoken_a, _crtokens.crUSDC, _stablecoins.USDC, crtoken_a_supply_amount, crtoken_a_borrow_amount);

        uint crtoken_b_supply_amount = CreamExecution.getUserTotalSupply(_position.borrowed_crtoken_b);
        uint crtoken_b_borrow_amount = CreamExecution.getBorrowAmount(_position.borrowed_crtoken_b, _crtokens.crWBNB);
        uint crtoken_b_limit = CreamExecution.getBorrowLimit(self.CreamConfig, _position.borrowed_crtoken_b, _crtokens.crUSDC, _stablecoins.USDC, crtoken_b_supply_amount, crtoken_b_borrow_amount);
        return crtoken_a_limit + crtoken_b_limit;
    }

    /// @param _crtoken Cream crToken address.
    /// @dev Gets the total supply amount on cream.
    function getCreamUserTotalSupply(address _crtoken) internal view returns (uint) {

        return CreamExecution.getUserTotalSupply(_crtoken);
    }

    /// @param self refer HLSConfig struct on the top.
    /// @param _crtokens refer CreamToken struct on the top.
    /// @param _stablecoins refer StableCoin struct on the top.
    /// @param _position refer Position struct on the top.
    /// @dev Adds liquidity to a given pool.
    function addLiquidity(HLSConfig memory self, CreamToken memory _crtokens, StableCoin memory _stablecoins, Position memory _position) internal returns (uint) {
        uint max_available_staking_a;
        uint max_available_staking_b;

        uint bnb_check = isWBNB(_stablecoins, _position.token_a, _position.token_b);
        if (bnb_check != 2) {
            if (bnb_check == 1) {
                max_available_staking_a = IBEP20(_position.token_a).balanceOf(address(this));
                max_available_staking_b = address(this).balance;
                require(SafeMath.sub(max_available_staking_b, SafeMath.mul(3, 10**17)) > 0, "No enought BNB to pay transaction fees");
                return PancakeSwapExecution.addLiquidityETH(self.PancakeSwapConfig, _position.token_a, _stablecoins.WBNB, max_available_staking_a, max_available_staking_b);
            } else {
                max_available_staking_a = address(this).balance;
                max_available_staking_b = IBEP20(_position.token_b).balanceOf(address(this));
                require(SafeMath.sub(max_available_staking_a, SafeMath.mul(3, 10**17)) > 0, "No enought BNB to pay transaction fees");
                return PancakeSwapExecution.addLiquidityETH(self.PancakeSwapConfig, _position.token_b, _stablecoins.WBNB, max_available_staking_b, max_available_staking_a);
            }
        } else {
            max_available_staking_a = IBEP20(_position.token_a).balanceOf(address(this));
            max_available_staking_b = IBEP20(_position.token_b).balanceOf(address(this));
            return PancakeSwapExecution.addLiquidity(self.PancakeSwapConfig, _position.token_a, _position.token_b, max_available_staking_a, max_available_staking_b);
        }
    }

    /// @param self refer HLSConfig struct on the top.
    /// @param _stablecoins refer StableCoin struct on the top.
    /// @param _position refer Position struct on the top.
    /// @dev Removes liquidity from a given pool.
    function removeLiquidity(HLSConfig memory self, StableCoin memory _stablecoins, Position memory _position) internal returns (bool) {
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
    function stakeLP(HLSConfig memory self, Position memory _position) internal returns (bool) {
        uint lp_balance = PancakeSwapExecution.getLPBalance(_position.lp_token);
        return PancakeSwapExecution.stakeLP(self.PancakeSwapConfig, _position.pool_id, lp_balance);
    }

    /// @param self refer HLSConfig struct on the top.
    /// @param _position refer Position struct on the top.
    /// @dev Removes liquidity from a given farm.
    function unstakeLP(HLSConfig memory self, Position memory _position) internal returns (bool) {
        uint lp_balance = PancakeSwapExecution.getStakedLP(self.PancakeSwapConfig, _position.pool_id);
        return PancakeSwapExecution.unstakeLP(self.PancakeSwapConfig, _position.pool_id, lp_balance);
    }
    
    /// @param self refer HLSConfig struct on the top.
    /// @param _position refer Position struct on the top.
    /// @dev Return staked tokens.
    function getStakedTokens(HLSConfig memory self, Position memory _position) internal view returns (uint, uint) {
        uint lp_balance = PancakeSwapExecution.getStakedLP(self.PancakeSwapConfig, _position.pool_id);
        (uint token_a_amnt, uint token_b_amnt) = PancakeSwapExecution.getLPConstituients(lp_balance, _position.lp_token);
        return (token_a_amnt, token_b_amnt);
    }

    /// @param self refer HLSConfig struct on the top.
    /// @param _crtokens refer CreamToken struct on the top.
    /// @param _stablecoins refer StableCoin struct on the top.
    /// @param _position refer Position struct on the top.
    /// @dev Return total debts.
    function getTotalDebts(HLSConfig memory self, CreamToken memory _crtokens, StableCoin memory _stablecoins, Position memory _position) external view returns (uint) {
        // Free funds amount
        uint freeFunds = IBEP20(_position.token).balanceOf(address(this));
        // Cream borrowed amount
        (uint crtoken_a_debt, uint crtoken_b_debt) = getTotalBorrowAmount(_crtokens, _position.borrowed_crtoken_a, _position.borrowed_crtoken_b);
        // PancakeSwap pending cake amount
        uint pending_cake_amount = getTotalCakePendingRewards(self, _position.pool_id);
        // PancakeSwap staked amount
        (uint token_a_amount, uint token_b_amount) = getStakedTokens(self, _position);

        uint cream_total_supply = getCreamUserTotalSupply(_position.supply_crtoken);
        (uint token_a_value, uint token_b_value) = getChainLinkValues(self, SafeMath.sub(token_a_amount, crtoken_a_debt), SafeMath.sub(token_b_amount, crtoken_b_debt));
        uint pending_cake_value = getCakeChainLinkValue(self, pending_cake_amount);
        if (token_a_value == 0 && token_b_value == 0) {
            token_a_value = getPancakeSwapAmountOut(self, _position.token_a, _position.token, SafeMath.sub(token_a_amount, crtoken_a_debt));
            token_b_value = getPancakeSwapAmountOut(self, _position.token_b, _position.token, SafeMath.sub(token_b_amount, crtoken_b_debt));
        }
        if (pending_cake_value ==0) {
            pending_cake_value = getPancakeSwapAmountOut(self, _stablecoins.CAKE, _position.token, pending_cake_amount);
        }
        
        return SafeMath.add(SafeMath.add(cream_total_supply, pending_cake_value), SafeMath.add(token_a_value, token_b_value));
    }

}





