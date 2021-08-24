// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

import "./token/BEP20/IBEP20.sol";
import "./math/SafeMath.sol";
import "./utils/BasicContract.sol";
import "./interfaces/cream/CErc20Delegator.sol";
import "./interfaces/cream/InterestRateModel.sol";
import "./interfaces/cream/PriceOracleProxyBSC.sol";

contract CreamExecution is BasicContract {
    
    address private constant ORACLE = 0xab548FFf4Db8693c999e98551C756E6C2948C408;
    
    address private constant crWBNB = 0x15CC701370cb8ADA2a2B6f4226eC5CF6AA93bC67;
    address private constant crBNB = 0x1Ffe17B99b439bE0aFC831239dDECda2A790fF3A;
    address private constant crUSDC = 0xD83C88DB3A6cA4a32FFf1603b0f7DDce01F5f727;
    
    function getAvailableBorrow(address crtoken_address) public view returns (uint) {
        return CErc20Delegator(crtoken_address).getCash();
    }
    
    function getBorrowRate(address crtoken_address) public view returns (uint) {
        uint cash = CErc20Delegator(crtoken_address).getCash();
        uint borrows = CErc20Delegator(crtoken_address).totalBorrows();
        uint reserves = CErc20Delegator(crtoken_address).totalReserves();
        uint decimals = CErc20Delegator(crtoken_address).decimals();
        
        address interest_rate_address = CErc20Delegator(crtoken_address).interestRateModel();
        
        uint borrowRate = InterestRateModel(interest_rate_address).getBorrowRate(cash, borrows, reserves);
        
        return SafeMath.div(borrowRate, 10**(decimals + 1));
    }
    
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
    
    function getBorrowAmount(address crtoken_address) public view returns (uint) {
        if (crtoken_address == crWBNB) {
            revert("we never use WBNB (insufficient liquidity), so just use BNB instead");
        }
        return CErc20Delegator(crtoken_address).borrowBalanceStored(address(this));
    }
    
    function getUserTotalSupply(address crtoken_address) public returns (uint) {
        return CErc20Delegator(crtoken_address).balanceOfUnderlying(address(this));
    }
    
    function getUSDCBNBPrice() public view returns (uint) {
        return PriceOracleProxyBSC(ORACLE).getUnderlyingPrice(crUSDC);
    }
    
    function getCrTokenBalance(address crtoken_address) public view returns (uint) {
        return PriceOracleProxyBSC(ORACLE).getUnderlyingPrice(crtoken_address);
    }
    
    function getTokenPrice(address crtoken_address) public view returns (uint) {
        return PriceOracleProxyBSC(ORACLE).getUnderlyingPrice(crtoken_address);
    }

    function getUSDPrice(address crtoken_address) public view returns (uint) {
        uint token_bnb_price = PriceOracleProxyBSC(ORACLE).getUnderlyingPrice(crtoken_address);
        uint usd_bnb_price = PriceOracleProxyBSC(ORACLE).getUnderlyingPrice(crUSDC);
        return SafeMath.div(token_bnb_price, usd_bnb_price);
    }
    
    function getExchangeRate(address crtoken_address) public view returns (uint) {
        return CErc20Delegator(crtoken_address).exchangeRateStored();
    }
    
    function getBorrowLimit(address borrow_ctoken_address, uint supply_amount, uint borrow_amount) public view returns (uint) {
        uint borrow_token_price = getTokenPrice(borrow_ctoken_address);
        uint usdc_bnb_price = getTokenPrice(crUSDC);
        
        uint token_price = SafeMath.mul(borrow_token_price, SafeMath.div(1, usdc_bnb_price));
        uint borrow_usdc_value = SafeMath.mul(token_price, borrow_amount);
        
        supply_amount = SafeMath.mul(supply_amount, 100);
        supply_amount = SafeMath.div(supply_amount, 75);
        
        return SafeMath.div(borrow_usdc_value, supply_amount);
    }
    
    function getWalletAmount(address crtoken_address) public view returns (uint) {
        return CErc20Delegator(crtoken_address).balanceOf(address(this));
    }
    
    function borrow(address crtoken_address, uint borrow_amount) public returns (uint) {
        return CErc20Delegator(crtoken_address).borrow(borrow_amount);
    }
    
    function repay(address crtoken_address, uint repay_amount) public returns (uint) {
        return CErc20Delegator(crtoken_address).repayBorrow(repay_amount);
    }
    
    function repayETH(uint repay_amount) public returns (uint) {
        return CErc20Delegator(crBNB).repayBorrow(repay_amount);
    }
    
    function repayAll(address token_addr, address crtoken_address) public returns (bool) {
        uint current_wallet_amount = getWalletAmount(token_addr);
        uint borrow_amount = getBorrowAmount(crtoken_address);
        
        emit IntLog("current_wallet_amount", current_wallet_amount);
        emit IntLog("borrow_amount", borrow_amount);
        
        require(current_wallet_amount > borrow_amount, "Not enough funds in the wallet for the transaction");
        repay(crtoken_address, borrow_amount);
        
        return true;
    }
    
}