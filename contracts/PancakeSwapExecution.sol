// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

import "./token/BEP20/IBEP20.sol";
import "./math/SafeMath.sol";
import "./utils/BasicContract.sol";
import "./interfaces/pancakeswap/IPancakePair.sol";
import "./interfaces/pancakeswap/IPancakeFactory.sol";
import "./interfaces/pancakeswap/MasterChef.sol";
import "./interfaces/pancakeswap/IPancakeRouter02.sol";

contract PancakeSwapExecution is BasicContract {
    
    // Info of each pool.
    struct PoolInfo {
        address lpToken;           // Address of LP token contract.
        uint allocPoint;       // How many allocation points assigned to this pool. CAKEs to distribute per block.
        uint lastRewardBlock;  // Last block number that CAKEs distribution occurs.
        uint accCakePerShare; // Accumulated CAKEs per share, times 1e12. See below.
    }
    
    address private constant FACTORY = 0xcA143Ce32Fe78f1f7019d7d551a6402fC5350c73;
    address private constant ROUTER = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    address private constant MASTERCHEF = 0x73feaa1eE314F8c655E354234017bE2193C9E24E;
    address private constant BNB = 0xcA143Ce32Fe78f1f7019d7d551a6402fC5350c73;
    
    // StableCoin
    address private constant USDT = 0x55d398326f99059fF775485246999027B3197955;
    address private constant TUSD = 0x14016E85a25aeb13065688cAFB43044C2ef86784;
    address private constant BUSD = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;
    address private constant USDC = 0x8AC76a51cc950d9822D68b83fE1Ad97B32Cd580d;
    
    uint public PoolId;
    // PoolInfo[] poolsInfo;
    
    constructor(uint _PoolId) {
        PoolId = _PoolId;
        
        emit IntLog("PoolId", PoolId);
    }
    
    function setPoolId(uint _PoolId) public onlyOwner returns (bool) {
        PoolId = _PoolId;
        emit IntLog("PoolId", PoolId);
        return true;
    }
    
    function getBalanceBNB(address wallet_address) public view returns (uint) {
        return IBEP20(BNB).balanceOf(wallet_address);
    }
    
    function getLPTokenAddresses(address lp_token_address) public view returns (address, address) {
        return (IPancakePair(lp_token_address).token0(), IPancakePair(lp_token_address).token1());
    }
    
    function getLPTokenSymbols(address lp_token_address) public view returns (string memory, string memory) {
        (address token0, address token1) = getLPTokenAddresses(lp_token_address);
        return (IBEP20(token0).symbol(), IBEP20(token1).symbol());
    }
    
    function getPoolInfo(uint pool_id) public view returns (address, uint, uint, uint) {
        return MasterChef(MASTERCHEF).poolInfo(pool_id);
    }
    
    function getPoolId() public view returns (uint) {
        return PoolId;
    }
    
    function getReserves(address lp_token_address) public view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast) {
        return IPancakePair(lp_token_address).getReserves();
    }
    
    function getAllPoolInfo() public view returns (PoolInfo[] memory poolsInfo) {
        uint pool_length = MasterChef(MASTERCHEF).poolLength();
        
        for(uint i = 0; i <= pool_length ; i++) {
            (address _lpToken, uint _allocPoint, uint _lastRewardBlock, uint _accCakePerShare) = MasterChef(MASTERCHEF).poolInfo(i);
            poolsInfo[i] = PoolInfo({
                lpToken: _lpToken,
                allocPoint: _allocPoint,
                lastRewardBlock: _lastRewardBlock,
                accCakePerShare: _accCakePerShare
            });
        }
        
        return poolsInfo;
    }
    
    function getPair(address token_a_addr, address token_b_addr) public view returns (address) {
        return IPancakeFactory(FACTORY).getPair(token_a_addr, token_b_addr);
    }
    
    function lineUpPairs(address[] memory user_token_assumptions, address[] memory data, address lp_token_address) public view returns (address[] memory) {
        address contract_token_0_address = IPancakePair(lp_token_address).token0();
        address contract_token_1_address = IPancakePair(lp_token_address).token1();
        
        if (contract_token_0_address == user_token_assumptions[0]) {
            return data;
        } else {
            address[] memory pair;
            pair[0] = contract_token_0_address;
            pair[1] = contract_token_1_address;
            return pair;
        }
    }
    
    function getLPConstituients(uint lp_token_amnt, address lp_token_addr) public view returns (uint, uint, uint) {
        (uint reserve0, uint reserve1, uint blockTimestampLast) = getReserves(lp_token_addr);
        uint total_supply = IPancakePair(lp_token_addr).totalSupply();
        
        uint token_a_amnt = SafeMath.div(SafeMath.mul(reserve0, lp_token_amnt), total_supply);
        uint token_b_amnt = SafeMath.div(SafeMath.mul(reserve1, lp_token_amnt), total_supply);
        return (token_a_amnt, token_b_amnt, blockTimestampLast);
    }
    
    function getPendingStakedCake(uint pool_id) public view returns (uint) {
        return MasterChef(MASTERCHEF).pendingCake(pool_id, msg.sender);
    }
    
    function addLiquidityETH(address token_addr, uint token_amnt, uint eth_amnt) public returns (uint) {
        IBEP20(token_addr).approve(ROUTER, token_amnt);
        
        // min amount will be 97% amount
        uint min_token_amnt = SafeMath.div(SafeMath.mul(token_amnt, 97), 100);
        uint min_eth_amnt = SafeMath.div(SafeMath.mul(eth_amnt, 97), 100);
        (uint amountToken, uint amountETH, uint amountLP) = IPancakeRouter02(ROUTER).addLiquidityETH(token_addr, token_amnt, min_token_amnt, min_eth_amnt, address(this), block.timestamp);
        
        emit IntLog("addLiquidityETH amountToken", amountToken);
        emit IntLog("addLiquidityETH amountETH", amountETH);
        emit IntLog("addLiquidityETH amountLP", amountLP);
        
        return amountLP;
    }
    
    function addLiquidity(address token_a_addr, address token_b_addr, uint a_amnt, uint b_amnt) public returns (uint){
        
        IBEP20(token_a_addr).approve(ROUTER, a_amnt);
        IBEP20(token_b_addr).approve(ROUTER, b_amnt);
        
        // min amount will be 97% amount
        uint min_a_amnt = SafeMath.div(SafeMath.mul(a_amnt, 97), 100);
        uint min_b_amnt = SafeMath.div(SafeMath.mul(b_amnt, 97), 100);
        (uint amountA, uint amountB, uint amountLP) = IPancakeRouter02(ROUTER).addLiquidity(token_a_addr, token_b_addr, a_amnt, b_amnt, min_a_amnt, min_b_amnt, address(this), block.timestamp);
        
        emit IntLog("addLiquidity amountA", amountA);
        emit IntLog("addLiquidity amountB", amountB);
        emit IntLog("addLiquidity amountLP", amountLP);
        
        return amountLP;
    }
    
    function removeLiquidity(address lp_contract_addr, address token_a_addr, address token_b_addr, uint liquidity, uint a_amnt, uint b_amnt) public {
        
        IBEP20(lp_contract_addr).approve(ROUTER, liquidity);
        (uint amountA, uint amountB) = IPancakeRouter02(ROUTER).removeLiquidity(token_a_addr, token_b_addr, liquidity, a_amnt, b_amnt, address(this), block.timestamp);
        
        emit IntLog("removeLiquidity amountA", amountA);
        emit IntLog("removeLiquidity amountB", amountB);
    }
    
    function removeLiquidityETH(address lp_contract_addr, address token_a_addr, address token_b_addr, uint liquidity, uint a_amnt, uint b_amnt) public {
        
        IBEP20(lp_contract_addr).approve(ROUTER, liquidity);
        (uint amountA, uint amountB) = IPancakeRouter02(ROUTER).removeLiquidityETH(token_a_addr, liquidity, a_amnt, b_amnt, address(this), block.timestamp);
        
        emit IntLog("removeLiquidity amountA", amountA);
        emit IntLog("removeLiquidity amountB", amountB);
    }
    
    function getAmountsOut(address token_a_address, address token_b_address) public view returns (uint, uint) {
        uint token_a_decimals = IBEP20(token_a_address).decimals();
        uint min_amountIn = SafeMath.mul(1, 10**token_a_decimals);
        address pair = IPancakeFactory(FACTORY).getPair(token_a_address, token_b_address);
        (uint reserve0, uint reserve1, uint blockTimestampLast) = IPancakePair(pair).getReserves();
        uint price = IPancakeRouter02(ROUTER).getAmountOut(min_amountIn, reserve0, reserve1);
        
        return (price, blockTimestampLast);
    }
    
    function getPairPrice(address lp_token_address) public view returns (uint) {
        (uint reserve0, uint reserve1, uint blockTimestampLast) = IPancakePair(lp_token_address).getReserves();
        return reserve0 + reserve1;
    }
    
    function getStakedLP(uint pool_id) public view returns (uint) {
        (uint amount, uint rewardDebt) = MasterChef(MASTERCHEF).userInfo(pool_id, address(this));
        return SafeMath.div(amount, rewardDebt);
    }
    
    function unstakeLP(uint pool_id, uint unstake_amount) public returns (bool) {
        MasterChef(MASTERCHEF).withdraw(pool_id, unstake_amount);
        return true;
    }
    
    function getTokenPriceUSD(address token_address) public view returns (uint) {
        uint token_decimals = IBEP20(token_address).decimals();
        uint min_amountIn = SafeMath.mul(1, 10**token_decimals);
        address pair = IPancakeFactory(FACTORY).getPair(token_address, USDT);
        (uint reserve0, uint reserve1, uint blockTimestampLast) = IPancakePair(pair).getReserves();
        uint price = IPancakeRouter02(ROUTER).getAmountOut(min_amountIn, reserve0, reserve1);
        return price;
    }
    
    function stakeLP(uint pool_id, uint stake_amount) public returns (bool) {
        MasterChef(MASTERCHEF).deposit(pool_id, stake_amount);
        return true;
    }
    
    function enablePool(address token_addr, address stake_contract_addr, uint amount) public returns (bool) {
        IBEP20(token_addr).approve(stake_contract_addr, amount);
        return true;
    }
    
    function getStakedPoolTokens(uint pool_id) public view returns (uint) {
        (uint amount, uint rewardDebt) = MasterChef(MASTERCHEF).userInfo(pool_id, address(this));
        return amount;
    }
    
    function getPendingPoolRewards(uint pool_id) public view returns (uint) {
        return MasterChef(MASTERCHEF).pendingCake(pool_id, address(this));
    }
    
    function stakePool(uint pool_id, uint stake_amount, address stake_pool_addr) public returns (bool) {
        MasterChef(stake_pool_addr).deposit(pool_id, stake_amount);
        return true;
    }
    
    function unstakePool(uint pool_id, uint unstake_amount, address stake_pool_addr) public returns (bool) {
        MasterChef(stake_pool_addr).withdraw(pool_id, unstake_amount);
        return true;
    }
    
}