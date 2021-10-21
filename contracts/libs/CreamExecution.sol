// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

import "../token/BEP20/IBEP20.sol";
import "../math/SafeMath.sol";
import "../interfaces/cream/CErc20Delegator.sol";
import "../interfaces/cream/InterestRateModel.sol";
import "../interfaces/cream/PriceOracleProxy.sol";

/// @title Cream execution
/// @author Andrew FU
/// @dev All functions haven't finished unit test
library CreamExecution {
    
    // Addresss of Cream.
    struct CreamConfig {
        address oracle; // Address of Cream oracle contract.
    }
    
    /// @param crtoken_address Cream crToken address.
    /// @param crWBNB_address Cream crWBNB address.
    /// @dev Gets the borrowed amount for a particular token.
    /// @return crToken amount
    function getBorrowAmount(address crtoken_address, address crWBNB_address) external view returns (uint) {
        if (crtoken_address == crWBNB_address) {
            revert("we never use WBNB (insufficient liquidity), so just use BNB instead");
        }
        return CErc20Delegator(crtoken_address).borrowBalanceStored(address(this));
    }
    
    /// @param crtoken_address Cream crToken address.
    /// @dev Gets the borrowed amount for a particular token.
    /// @return crToken amount.
    function getUserTotalSupply(address crtoken_address) external view returns (uint) {
        uint exch_rate = CErc20Delegator(crtoken_address).exchangeRateStored();
        exch_rate = SafeMath.div(exch_rate, 10**18);
        uint crtoken_decimals = CErc20Delegator(crtoken_address).decimals();
        uint token_decimals = IBEP20(CErc20Delegator(crtoken_address).underlying()).decimals();
        uint balance = CErc20Delegator(crtoken_address).balanceOf(address(this));
        balance = SafeMath.div(balance, 10**crtoken_decimals);
        uint total_supply = SafeMath.mul(balance, exch_rate);
        total_supply = SafeMath.div(total_supply, 10**SafeMath.sub(18, crtoken_decimals));
        
        return SafeMath.mul(total_supply, 10**token_decimals);
    }
    
    /// @param crtoken_address Cream crToken address.
    /// @dev Gets the crtoken/BNB price.
    function getTokenPrice(CreamConfig memory self, address crtoken_address) internal view returns (uint) {
        
        return PriceOracleProxy(self.oracle).getUnderlyingPrice(crtoken_address);
    }
    
    /// @param crtoken_address Cream crToken address.
    /// @dev Gets the current exchange rate for a ctoken.
    function getExchangeRate(address crtoken_address) external view returns (uint) {
        
        return CErc20Delegator(crtoken_address).exchangeRateStored();
    }
    
    /// @return the current borrow limit on the platform.
    function getBorrowLimit(CreamConfig memory self, address borrow_crtoken_address, address crUSDC_address, address USDC_address, uint supply_amount, uint borrow_amount) external view returns (uint) {
        uint borrow_token_price = getTokenPrice(self, borrow_crtoken_address);
        uint usdc_bnb_price = getTokenPrice(self, crUSDC_address);
        uint usdc_decimals = IBEP20(USDC_address).decimals();
        uint one_unit_of_usdc = SafeMath.mul(1, 10**usdc_decimals);
        
        uint token_price = SafeMath.div(SafeMath.mul(borrow_token_price, one_unit_of_usdc), usdc_bnb_price);
        uint borrow_usdc_value = SafeMath.mul(token_price, borrow_amount);
        
        supply_amount = SafeMath.mul(supply_amount, 100);
        supply_amount = SafeMath.div(supply_amount, 75);
        
        return SafeMath.div(borrow_usdc_value, supply_amount);
    }
    
    function borrow(address crtoken_address, uint borrow_amount) external returns (uint) {
        // TODO make sure don't borrow more than the limit
        return CErc20Delegator(crtoken_address).borrow(borrow_amount);
    }

    function getUnderlyingAddress(address crtoken_address) internal view returns (address) {
        
        return CErc20Delegator(crtoken_address).underlying();
    }
    
    function repay(address crtoken_address, uint repay_amount) external returns (uint) {
        address underlying_address = getUnderlyingAddress(crtoken_address);
        IBEP20(underlying_address).approve(crtoken_address, repay_amount);
        return CErc20Delegator(crtoken_address).repayBorrow(repay_amount);
    }
    
    function repayETH(address crBNB_address, uint repay_amount) external returns (uint) {
        
        return CErc20Delegator(crBNB_address).repayBorrow(repay_amount);
    }

    /// @param crtoken_address Cream crToken address
    /// @param amount amount of tokens to mint.
    /// @dev Supplies amount worth of crtokens into cream.
    function supply(address crtoken_address, uint amount) external returns (uint) {
        address underlying_address = getUnderlyingAddress(crtoken_address);
        IBEP20(underlying_address).approve(crtoken_address, amount);
        return CErc20Delegator(crtoken_address).mint(amount);
    }
    
    /// @param crtoken_address Cream crToken address
    /// @param amount amount of crtokens to redeem.
    /// @dev Redeem amount worth of crtokens back.
    function redeemUnderlying(address crtoken_address, uint amount) external returns (uint) {
        IBEP20(crtoken_address).approve(crtoken_address, amount);
        return CErc20Delegator(crtoken_address).redeemUnderlying(amount);
    }
    
    function getTokenBalance(address token_address) external view returns (uint) {
        
        return IBEP20(token_address).balanceOf(address(this));
    }

}