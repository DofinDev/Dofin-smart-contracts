// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

import "../token/BEP20/IBEP20.sol";
import "../math/SafeMath.sol";
import "../interfaces/pancakeswap/IPancakePair.sol";
import "../interfaces/pancakeswap/IPancakeFactory.sol";
import "../interfaces/pancakeswap/MasterChef.sol";
import "../interfaces/pancakeswap/IPancakeRouter02.sol";

/// @title PancakeSwap execution
/// @author Andrew FU
/// @dev All functions haven't finished unit test
library PancakeSwapExecution {
    
    // Addresss of PancakeSwap.
    struct PancakeSwapConfig {
        address router; // Address of PancakeSwap router contract.
        address factory; // Address of PancakeSwap factory contract.
        address masterchef; // Address of PancakeSwap masterchef contract.
    }
    
    function getLPBalance(address lp_token) external view returns (uint) {
        
        return IPancakePair(lp_token).balanceOf(address(this));
    }
    
    /// @param lp_token_address PancakeSwap LPtoken address.
    /// @dev Gets the token0 and token1 addresses from LPtoken.
    /// @return token0, token1.
    function getLPTokenAddresses(address lp_token_address) external view returns (address, address) {
        
        return (IPancakePair(lp_token_address).token0(), IPancakePair(lp_token_address).token1());
    }
    
    /// @param lp_token_amnt The LP token amount.
    /// @param lp_token_addr address of the LP token.
    /// @dev Returns the amount of token0, token1s the specified number of LP token represents.
    function getLPConstituients(uint lp_token_amnt, address lp_token_addr) external view returns (uint, uint) {
        (uint reserve0, uint reserve1, uint blockTimestampLast) = IPancakePair(lp_token_addr).getReserves();
        uint total_supply = IPancakePair(lp_token_addr).totalSupply();
        
        uint token_a_amnt = SafeMath.div(SafeMath.mul(reserve0, lp_token_amnt), total_supply);
        uint token_b_amnt = SafeMath.div(SafeMath.mul(reserve1, lp_token_amnt), total_supply);
        return (token_a_amnt, token_b_amnt);
    }
    
    /// @param self config of PancakeSwap.
    /// @param token_addr address of the BEP20 token.
    /// @param token_amnt amount of token to add.
    /// @param eth_amnt amount of BNB to add.
    /// @dev Adds a pair of tokens into a liquidity pool.
    function addLiquidityETH(PancakeSwapConfig memory self, address token_addr, address eth_addr, uint token_amnt, uint eth_amnt) external returns (uint) {
        IBEP20(token_addr).approve(self.router, token_amnt);
        (uint reserves0, uint reserves1, uint blockTimestampLast) = IPancakePair(IPancakeFactory(self.factory).getPair(token_addr, eth_addr)).getReserves();
        
        uint min_token_amnt = IPancakeRouter02(self.router).quote(token_amnt, reserves0, reserves1);
        uint min_eth_amnt = IPancakeRouter02(self.router).quote(eth_amnt, reserves1, reserves0);
        (uint amountToken, uint amountETH, uint amountLP) = IPancakeRouter02(self.router).addLiquidityETH{value: eth_amnt}(token_addr, token_amnt, min_token_amnt, min_eth_amnt, address(this), block.timestamp);
        
        return amountLP;
    }
    
    /// @param self config of PancakeSwap.
    /// @param token_a_addr address of the BEP20 token.
    /// @param token_b_addr address of the BEP20 token.
    /// @param a_amnt amount of token a to add.
    /// @param b_amnt amount of token b to add.
    /// @dev Adds a pair of tokens into a liquidity pool.
    function addLiquidity(PancakeSwapConfig memory self, address token_a_addr, address token_b_addr, uint a_amnt, uint b_amnt) external returns (uint){
        
        IBEP20(token_a_addr).approve(self.router, a_amnt);
        IBEP20(token_b_addr).approve(self.router, b_amnt);
        address pair = IPancakeFactory(self.factory).getPair(token_a_addr, token_b_addr);
        (uint reserves0, uint reserves1, uint blockTimestampLast) = IPancakePair(pair).getReserves();
    
        uint min_a_amnt = IPancakeRouter02(self.router).quote(a_amnt, reserves0, reserves1);
        uint min_b_amnt = IPancakeRouter02(self.router).quote(b_amnt, reserves1, reserves0);
        (uint amountA, uint amountB, uint amountLP) = IPancakeRouter02(self.router).addLiquidity(token_a_addr, token_b_addr, a_amnt, b_amnt, min_a_amnt, min_b_amnt, address(this), block.timestamp);
        
        return amountLP;
    }
    
    /// @param self config of PancakeSwap.
    /// @param lp_contract_addr address of the BEP20 token.
    /// @param token_a_addr address of the BEP20 token.
    /// @param token_b_addr address of the BEP20 token.
    /// @param liquidity amount of LP tokens to be removed.
    /// @param a_amnt amount of token a to remove.
    /// @param b_amnt amount of token b to remove.
    /// @dev Removes a pair of tokens from a liquidity pool.
    function removeLiquidity(PancakeSwapConfig memory self, address lp_contract_addr, address token_a_addr, address token_b_addr, uint liquidity, uint a_amnt, uint b_amnt) external {
        
        IBEP20(lp_contract_addr).approve(self.router, liquidity);
        IPancakeRouter02(self.router).removeLiquidity(token_a_addr, token_b_addr, liquidity, a_amnt, b_amnt, address(this), block.timestamp);
    }
    
    /// @param self config of PancakeSwap.
    /// @param lp_contract_addr address of the BEP20 token.
    /// @param token_addr address of the BEP20 token.
    /// @param liquidity amount of LP tokens to be removed.
    /// @param a_amnt amount of token a to remove.
    /// @param b_amnt amount of BNB to remove.
    /// @dev Removes a pair of tokens from a liquidity pool.
    function removeLiquidityETH(PancakeSwapConfig memory self, address lp_contract_addr, address token_addr, uint liquidity, uint a_amnt, uint b_amnt) external {
        
        IBEP20(lp_contract_addr).approve(self.router, liquidity);
        IPancakeRouter02(self.router).removeLiquidityETH(token_addr, liquidity, a_amnt, b_amnt, address(this), block.timestamp);
    }
    
    /// @param self config of PancakeSwap.
    function getAmountsOut(PancakeSwapConfig memory self, address token_a_address, address token_b_address, uint amountIn) external view returns (uint) {
        address pair = IPancakeFactory(self.factory).getPair(token_a_address, token_b_address);
        (uint reserve0, uint reserve1, uint blockTimestampLast) = IPancakePair(pair).getReserves();
        if (token_a_address == IPancakePair(pair).token0()) {
            return IPancakeRouter02(self.router).getAmountOut(amountIn, reserve0, reserve1);
        }
        else {
            return IPancakeRouter02(self.router).getAmountOut(amountIn, reserve1, reserve0);
        }
    }
    
    /// @param self config of PancakeSwap.
    /// @param pool_id Id of the PancakeSwap pool.
    /// @dev Gets the current number of LP tokens staked in the pool.
    function getStakedLP(PancakeSwapConfig memory self, uint pool_id) external view returns (uint) {
        (uint amount, uint rewardDebt) = MasterChef(self.masterchef).userInfo(pool_id, address(this));
        return amount;
    }

    /// @param self config of PancakeSwap.
    /// @param pool_id Id of the PancakeSwap pool.
    /// @dev Gets the pending CAKE amount for a partictular pool_id.
    function getPendingFarmRewards(PancakeSwapConfig memory self, uint pool_id) external view returns (uint) {
        
        return MasterChef(self.masterchef).pendingCake(pool_id, address(this));
    }
    
    /// @param self config of PancakeSwap.
    /// @param pool_id Id of the PancakeSwap pool.
    /// @param unstake_amount amount of LP tokens to unstake.
    /// @dev Removes 'unstake_amount' of LP tokens from 'pool_id'.
    function unstakeLP(PancakeSwapConfig memory self, uint pool_id, uint unstake_amount) external returns (bool) {
        MasterChef(self.masterchef).withdraw(pool_id, unstake_amount);
        return true;
    }
    
    /// @param self config of PancakeSwap.
    /// @param pool_id Id of the PancakeSwap pool.
    /// @param stake_amount amount of LP tokens to stake.
    /// @dev Gets pending reward for the user from the specific pool_id.
    function stakeLP(PancakeSwapConfig memory self, uint pool_id, uint stake_amount) external returns (bool) {
        MasterChef(self.masterchef).deposit(pool_id, stake_amount);
        return true;
    }
    
}