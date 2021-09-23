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
    
    // Info of each pool.
    struct PoolInfo {
        address lpToken;           // Address of LP token contract.
        uint allocPoint;       // How many allocation points assigned to this pool. CAKEs to distribute per block.
        uint lastRewardBlock;  // Last block number that CAKEs distribution occurs.
        uint accCakePerShare; // Accumulated CAKEs per share, times 1e12. See below.
    }
    
    function getBalanceBNB(address wallet_address, address BNB_address) public view returns (uint) {
        
        return IBEP20(BNB_address).balanceOf(wallet_address);
    }
    
    function getLPBalance(address lp_token) public view returns (uint) {
        
        return IPancakePair(lp_token).balanceOf(address(this));
    }
    
    /// @param lp_token_address PancakeSwap LPtoken address.
    /// @dev Gets the token0 and token1 addresses from LPtoken.
    /// @return token0, token1.
    function getLPTokenAddresses(address lp_token_address) public view returns (address, address) {
        
        return (IPancakePair(lp_token_address).token0(), IPancakePair(lp_token_address).token1());
    }
    
    /// @param lp_token_address PancakeSwap LPtoken address.
    /// @dev Gets the token0 and token1 symbol name from LPtoken.
    /// @return token0, token1.
    function getLPTokenSymbols(address lp_token_address) public view returns (string memory, string memory) {
        (address token0, address token1) = getLPTokenAddresses(lp_token_address);
        return (IBEP20(token0).symbol(), IBEP20(token1).symbol());
    }
    
    /// @param self config of PancakeSwap.
    /// @param pool_id Id of the PancakeSwap pool.
    /// @dev Gets pool info from the masterchef contract and stores results in an array.
    /// @return pooInfo.
    function getPoolInfo(PancakeSwapConfig memory self, uint pool_id) public view returns (address, uint256, uint256, uint256) {
        
        return MasterChef(self.masterchef).poolInfo(pool_id);
    }

    /// @param self config of PancakeSwap.
    /// @return poolsInfo
    function getAllPoolInfo(PancakeSwapConfig memory self) public view returns (PoolInfo[] memory poolsInfo) {
        uint pool_length = MasterChef(self.masterchef).poolLength();
        
        for(uint i = 0; i <= pool_length ; i++) {
            (address _lpToken, uint _allocPoint, uint _lastRewardBlock, uint _accCakePerShare) = MasterChef(self.masterchef).poolInfo(i);
            poolsInfo[i] = PoolInfo({
                lpToken: _lpToken,
                allocPoint: _allocPoint,
                lastRewardBlock: _lastRewardBlock,
                accCakePerShare: _accCakePerShare
            });
        }
        
        return poolsInfo;
    }
    
    function getReserves(address lp_token_address) public view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast) {
        
        return IPancakePair(lp_token_address).getReserves();
    }

    /// @param self config of PancakeSwap.
    /// @param token_a_addr BEP20 token address.
    /// @param token_b_addr BEP20 token address.
    /// @dev Returns the LP token address for the token pairs.
    /// @return pair address.
    function getPair(PancakeSwapConfig memory self, address token_a_addr, address token_b_addr) public view returns (address) {
        
        return IPancakeFactory(self.factory).getPair(token_a_addr, token_b_addr);
    }
    
    /// @dev Will line up our assumption with the contracts.
    function lineUpPairs(address token_a_address, address token_b_address, uint data_a, uint data_b, address lp_token_address) public view returns (uint, uint) {
        address contract_token_0_address = IPancakePair(lp_token_address).token0();
        address contract_token_1_address = IPancakePair(lp_token_address).token1();
        
        if (token_a_address == contract_token_0_address && token_b_address == contract_token_1_address) {
            return (data_a, data_b);
        } else if (token_b_address == contract_token_0_address && token_a_address == contract_token_1_address) {
            return (data_b, data_a);
        } else {
            revert("No this pair");
        }
    }
    
    /// @param lp_token_amnt The LP token amount.
    /// @param lp_token_addr address of the LP token.
    /// @dev Returns the amount of token0, token1s the specified number of LP token represents.
    function getLPConstituients(uint lp_token_amnt, address lp_token_addr) public view returns (uint, uint) {
        (uint reserve0, uint reserve1, uint blockTimestampLast) = IPancakePair(lp_token_addr).getReserves();
        uint total_supply = IPancakePair(lp_token_addr).totalSupply();
        
        uint token_a_amnt = SafeMath.div(SafeMath.mul(reserve0, lp_token_amnt), total_supply);
        uint token_b_amnt = SafeMath.div(SafeMath.mul(reserve1, lp_token_amnt), total_supply);
        return (token_a_amnt, token_b_amnt);
    }
    
    /// @param self config of PancakeSwap.
    function getPendingStakedCake(PancakeSwapConfig memory self, uint pool_id) public view returns (uint) {
        
        return MasterChef(self.masterchef).pendingCake(pool_id, address(this));
    }
    
    /// @param self config of PancakeSwap.
    /// @param token_addr address of the BEP20 token.
    /// @param token_amnt amount of token to add.
    /// @param eth_amnt amount of BNB to add.
    /// @dev Adds a pair of tokens into a liquidity pool.
    function addLiquidityETH(PancakeSwapConfig memory self, address token_addr, address eth_addr, uint token_amnt, uint eth_amnt) public returns (uint) {
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
    function addLiquidity(PancakeSwapConfig memory self, address token_a_addr, address token_b_addr, uint a_amnt, uint b_amnt) public returns (uint){
        
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
    function removeLiquidity(PancakeSwapConfig memory self, address lp_contract_addr, address token_a_addr, address token_b_addr, uint liquidity, uint a_amnt, uint b_amnt) public {
        
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
    function removeLiquidityETH(PancakeSwapConfig memory self, address lp_contract_addr, address token_addr, uint liquidity, uint a_amnt, uint b_amnt) public {
        
        IBEP20(lp_contract_addr).approve(self.router, liquidity);
        IPancakeRouter02(self.router).removeLiquidityETH(token_addr, liquidity, a_amnt, b_amnt, address(this), block.timestamp);
    }
    
    /// @param self config of PancakeSwap.
    function getAmountsOut(PancakeSwapConfig memory self, address token_a_address, address token_b_address) public view returns (uint) {
        uint token_a_decimals = IBEP20(token_a_address).decimals();
        uint min_amountIn = SafeMath.mul(1, 10**token_a_decimals);
        address pair = IPancakeFactory(self.factory).getPair(token_a_address, token_b_address);
        (uint reserve0, uint reserve1, uint blockTimestampLast) = IPancakePair(pair).getReserves();
        uint price = IPancakeRouter02(self.router).getAmountOut(min_amountIn, reserve0, reserve1);
        
        return price;
    }
    
    /// @param lp_token_address address of the LP token.
    /// @dev Gets the current price for a pair.
    function getPairPrice(address lp_token_address) public view returns (uint) {
        (uint reserve0, uint reserve1, uint blockTimestampLast) = IPancakePair(lp_token_address).getReserves();
        return reserve0 + reserve1;
    }
    
    /// @param self config of PancakeSwap.
    /// @param pool_id Id of the PancakeSwap pool.
    /// @dev Gets the current number of LP tokens staked in the pool.
    function getStakedLP(PancakeSwapConfig memory self, uint pool_id) public view returns (uint) {
        (uint amount, uint rewardDebt) = MasterChef(self.masterchef).userInfo(pool_id, address(this));
        return amount;
    }

    /// @param self config of PancakeSwap.
    /// @param pool_id Id of the PancakeSwap pool.
    /// @dev Gets the pending CAKE amount for a partictular pool_id.
    function getPendingFarmRewards(PancakeSwapConfig memory self, uint pool_id) public view returns (uint) {
        
        return MasterChef(self.masterchef).pendingCake(pool_id, address(this));
    }
    
    /// @param self config of PancakeSwap.
    /// @param pool_id Id of the PancakeSwap pool.
    /// @param unstake_amount amount of LP tokens to unstake.
    /// @dev Removes 'unstake_amount' of LP tokens from 'pool_id'.
    function unstakeLP(PancakeSwapConfig memory self, uint pool_id, uint unstake_amount) public returns (bool) {
        MasterChef(self.masterchef).withdraw(pool_id, unstake_amount);
        return true;
    }
    
    /// @param self config of PancakeSwap.
    /// @param token_address address of BEP20 token.
    /// @param USDT_address address of USDT token.
    /// @dev Returns the USD price for a particular BEP20 token.
    function getTokenPriceUSD(PancakeSwapConfig memory self, address token_address, address USDT_address) public view returns (uint) {
        uint token_decimals = IBEP20(token_address).decimals();
        uint min_amountIn = SafeMath.mul(1, 10**token_decimals);
        address pair = IPancakeFactory(self.factory).getPair(token_address, USDT_address);
        (uint reserve0, uint reserve1, uint blockTimestampLast) = IPancakePair(pair).getReserves();
        uint price = IPancakeRouter02(self.router).getAmountOut(min_amountIn, reserve0, reserve1);
        return price;
    }
    
    /// @param self config of PancakeSwap.
    /// @param pool_id Id of the PancakeSwap pool.
    /// @param stake_amount amount of LP tokens to stake.
    /// @dev Gets pending reward for the user from the specific pool_id.
    function stakeLP(PancakeSwapConfig memory self, uint pool_id, uint stake_amount) public returns (bool) {
        MasterChef(self.masterchef).deposit(pool_id, stake_amount);
        return true;
    }
    
    /// @param token_addr address of BEP20 token.
    /// @param stake_contract_addr address of PancakeSwap masterchef.
    /// @param amount amount of CAKE tokens to stake.
    /// @dev Enables a syrup staking pool on PancakeSwap.
    function enablePool(address token_addr, address stake_contract_addr, uint amount) public returns (bool) {
        IBEP20(token_addr).approve(stake_contract_addr, amount);
        return true;
    }
    
    /// @param lp_token_address address of PancakeSwap LPtoken.
    /// @dev Enables a syrup staking pool on PancakeSwap.
    function enableFarm(address lp_token_address) public returns (bool) {
        IBEP20(lp_token_address).approve(0x73feaa1eE314F8c655E354234017bE2193C9E24E, 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff);
        return true;
    }
    
    /// @param self config of PancakeSwap.
    /// @param pool_id Id of the PancakeSwap pool.
    /// @dev Get the number of tokens staked into the pool.
    function getStakedPoolTokens(PancakeSwapConfig memory self, uint pool_id) public view returns (uint) {
        (uint amount, uint rewardDebt) = MasterChef(self.masterchef).userInfo(pool_id, address(this));
        return amount;
    }
    
    /// @param self config of PancakeSwap.
    /// @param pool_id Id of the PancakeSwap pool.
    /// @dev Gets pending reward for the syrup pool.
    function getPendingPoolRewards(PancakeSwapConfig memory self, uint pool_id) public view returns (uint) {
        
        return MasterChef(self.masterchef).pendingCake(pool_id, address(this));
    }
    
    /// @param self config of PancakeSwap.
    /// @param pool_id Id of the PancakeSwap pool.
    /// @param stake_amount amount of CAKE tokens to stake.
    /// @dev Adds 'stake_amount' of coins into the syrup pools.
    function stakePool(PancakeSwapConfig memory self, uint pool_id, uint stake_amount) public returns (bool) {
        MasterChef(self.masterchef).deposit(pool_id, stake_amount);
        return true;
    }
    
    /// @param self config of PancakeSwap.
    /// @param pool_id Id of the PancakeSwap pool.
    /// @param unstake_amount amount of CAKE tokens to unstake.
    /// @dev Removes 'unstake_amount' of coins into the syrup pools.
    function unstakePool(PancakeSwapConfig memory self, uint pool_id, uint unstake_amount) public returns (bool) {
        MasterChef(self.masterchef).withdraw(pool_id, unstake_amount);
        return true;
    }

    function splitTokensEvenly(uint token_a_bal, uint token_b_bal, uint pair_price, uint price_decimals) public pure returns (uint, uint) {
        uint temp = SafeMath.mul(1, 10**price_decimals);
        uint a_amount_required = SafeMath.div(SafeMath.mul(token_b_bal, temp), pair_price);
        uint b_amount_required = SafeMath.div(SafeMath.mul(token_a_bal, temp), pair_price);
        if (token_a_bal > a_amount_required) {
            return (a_amount_required, token_b_bal);
        } else if (token_b_bal > b_amount_required) {
            return (token_a_bal, b_amount_required);
        } else {
            return (0, 0);
        }
    }

    function getPairDecimals(address pair_address) public pure returns (uint) {
        
        return IPancakePair(pair_address).decimals();
    }
    
}