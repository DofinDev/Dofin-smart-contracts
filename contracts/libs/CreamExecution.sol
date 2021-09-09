// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

import "../token/BEP20/IBEP20.sol";
import "../math/SafeMath.sol";
import "../interfaces/cream/CErc20Delegator.sol";
import "../interfaces/cream/InterestRateModel.sol";
import "../interfaces/cream/PriceOracleProxyBSC.sol";
import "../interfaces/cream/Unitroller.sol";

/// @title Cream execution
/// @author Andrew FU
/// @dev All functions haven't finished unit test
library CreamExecution {
    
    // Addresss of Cream.
    struct CreamConfig {
        address oracle; // Address of Cream oracle contract.
        address troller; // Address of Cream troller contract.
    }
    
    /// @param crtoken_address Cream crToken address.
    function getAvailableBorrow(address crtoken_address) public view returns (uint) {
        
        return CErc20Delegator(crtoken_address).getCash();
    }
    
    /// @param crtoken_address Cream crToken address.
    /// @dev Gets the current borrow rate for the underlying token.
    function getBorrowRate(address crtoken_address) public view returns (uint) {
        uint cash = CErc20Delegator(crtoken_address).getCash();
        uint borrows = CErc20Delegator(crtoken_address).totalBorrows();
        uint reserves = CErc20Delegator(crtoken_address).totalReserves();
        uint decimals = CErc20Delegator(crtoken_address).decimals();
        
        address interest_rate_address = CErc20Delegator(crtoken_address).interestRateModel();
        
        uint borrowRate = InterestRateModel(interest_rate_address).getBorrowRate(cash, borrows, reserves);
        
        return SafeMath.div(borrowRate, 10**(decimals + 1));
    }
    
    /// @param crtoken_address Cream crToken address.
    /// @dev Gets the current borrow rate for a token.
    function getSupplyRate(address crtoken_address) public view returns (uint) {
        uint cash = CErc20Delegator(crtoken_address).getCash();
        uint borrows = CErc20Delegator(crtoken_address).totalBorrows();
        uint reserves = CErc20Delegator(crtoken_address).totalReserves();
        uint mantissa = CErc20Delegator(crtoken_address).reserveFactorMantissa();
        uint decimals = CErc20Delegator(crtoken_address).decimals();
        
        address interest_rate_address = CErc20Delegator(crtoken_address).interestRateModel();
        
        uint supplyRate = InterestRateModel(interest_rate_address).getSupplyRate(cash, borrows, reserves, mantissa);
        
        return SafeMath.div(supplyRate, 10**(decimals + 1));
    }
    
    /// @param crtoken_address Cream crToken address.
    /// @param crWBNB_address Cream crWBNB address.
    /// @dev Gets the borrowed amount for a particular token.
    /// @return crToken amount
    function getBorrowAmount(address crtoken_address, address crWBNB_address) public view returns (uint) {
        if (crtoken_address == crWBNB_address) {
            revert("we never use WBNB (insufficient liquidity), so just use BNB instead");
        }
        return CErc20Delegator(crtoken_address).borrowBalanceStored(address(this));
    }
    
    /// @param crtoken_address Cream crToken address.
    /// @dev Gets the borrowed amount for a particular token.
    /// @return crToken amount.
    function getUserTotalSupply(address crtoken_address) public returns (uint) {
        
        return CErc20Delegator(crtoken_address).balanceOfUnderlying(address(this));
    }
    
    /// @dev Gets the USDCBNB price.
    function getUSDCBNBPrice(CreamConfig memory self, address crUSDC_address) public view returns (uint) {
        
        return PriceOracleProxyBSC(self.oracle).getUnderlyingPrice(crUSDC_address);
    }
    
    /// @dev Gets the bnb amount.
    function getCrTokenBalance(CreamConfig memory self, address crtoken_address) public view returns (uint) {
        
        return PriceOracleProxyBSC(self.oracle).getUnderlyingPrice(crtoken_address);
    }
    
    /// @param crtoken_address Cream crToken address.
    /// @dev Gets the crtoken/BNB price.
    function getTokenPrice(CreamConfig memory self, address crtoken_address) public view returns (uint) {
        
        return PriceOracleProxyBSC(self.oracle).getUnderlyingPrice(crtoken_address);
    }
    
    /// @param crtoken_address Cream crToken address.
    /// @dev Gets the current exchange rate for a ctoken.
    function getExchangeRate(address crtoken_address) public view returns (uint) {
        
        return CErc20Delegator(crtoken_address).exchangeRateStored();
    }
    
    /// @return the current borrow limit on the platform.
    function getBorrowLimit(CreamConfig memory self, address borrow_crtoken_address, address crUSDC_address, address USDC_address, uint supply_amount, uint borrow_amount) public view returns (uint) {
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
    
    /// @return the amount in the wallet for a given token.
    function getWalletAmount(address crtoken_address) public view returns (uint) {
        
        return CErc20Delegator(crtoken_address).balanceOf(address(this));
    }
    
    function borrow(address crtoken_address, uint borrow_amount) public returns (uint) {
        // TODO make sure don't borrow more than the limit
        return CErc20Delegator(crtoken_address).borrow(borrow_amount);
    }

    /// @param token_address Address of the underlying BEP-20 token .
    /// @dev Gets the address of the cToken that represents the underlying token.
    function getCrTokenAddress(CreamConfig memory self, address token_address) public view returns (address) {
        address[] memory markets = Unitroller(self.troller).getAllMarkets();

        for (uint i = 0; i <= markets.length; i++) {
            if (markets[i] == token_address) {
                return markets[i];
            }
        }

        return address(0);
    }

    function getUnderlyingAddress(address crtoken_address) public view returns (address) {
        
        return CErc20Delegator(crtoken_address).underlying();
    }
    
    /// @param crtoken_address Cream crToken address.
    /// @dev Get the token/BNB price.
    function getUSDPrice(CreamConfig memory self, address crtoken_address, address crUSDC_address, address USDC_address) public view returns (uint) {
        uint token_bnb_price = getTokenPrice(self, crtoken_address);
        uint usd_bnb_price = getUSDCBNBPrice(self, crUSDC_address);
        
        uint usdc_decimals = IBEP20(USDC_address).decimals();
        uint one_unit_of_usdc = SafeMath.mul(1, 10**usdc_decimals);
        return SafeMath.div(SafeMath.mul(token_bnb_price, one_unit_of_usdc), usd_bnb_price);
    }
    
    function repay(address crtoken_address, uint repay_amount) public returns (uint) {
        address underlying_address = getUnderlyingAddress(crtoken_address);
        IBEP20(underlying_address).approve(crtoken_address, repay_amount);
        return CErc20Delegator(crtoken_address).repayBorrow(repay_amount);
    }
    
    function repayETH(address crBNB_address, uint repay_amount) public returns (uint) {
        
        return CErc20Delegator(crBNB_address).repayBorrow(repay_amount);
    }
    
    function repayAll(address token_addr, address crtoken_address, address crWBNB_address) public returns (bool) {
        uint current_wallet_amount = getWalletAmount(token_addr);
        uint borrow_amount = getBorrowAmount(crtoken_address, crWBNB_address);
        
        require(current_wallet_amount > borrow_amount, "Not enough funds in the wallet for the transaction");
        repay(crtoken_address, borrow_amount);
        
        return true;
    }

    /// @param crtoken_address Cream crToken address
    /// @param amount amount of tokens to mint.
    /// @dev Supplies amount worth of crtokens into cream.
    function supply(address crtoken_address, uint amount) public returns (uint) {
        address underlying_address = getUnderlyingAddress(crtoken_address);
        IBEP20(underlying_address).approve(crtoken_address, amount);
        return CErc20Delegator(crtoken_address).mint(amount);
    }
    
    function getTokenBalance(address token_address) public view returns (uint) {
        
        return IBEP20(token_address).balanceOf(address(this));
    }

}