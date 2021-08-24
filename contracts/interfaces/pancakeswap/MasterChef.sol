// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0;

interface MasterChef {

    function poolLength() external view returns (uint256);

    function updateStakingPool() external;

    // Migrate lp token to another lp contract. Can be called by anyone. We trust that migrator contract is good.
    function migrate(uint256 _pid) external;

    // Return reward multiplier over the given _from to _to block.
    function getMultiplier(uint256 _from, uint256 _to) external view returns (uint256);

    // View function to see pending CAKEs on frontend.
    function pendingCake(uint256 _pid, address _user) external view returns (uint256);

    // Update reward variables for all pools. Be careful of gas spending!
    function massUpdatePools() external;


    // Update reward variables of the given pool to be up-to-date.
    function updatePool(uint256 _pid) external;

    // Deposit LP tokens to MasterChef for CAKE allocation.
    function deposit(uint256 _pid, uint256 _amount) external;

    // Withdraw LP tokens from MasterChef.
    function withdraw(uint256 _pid, uint256 _amount) external;

    // Stake CAKE tokens to MasterChef
    function enterStaking(uint256 _amount) external;

    // Withdraw CAKE tokens from STAKING.
    function leaveStaking(uint256 _amount) external;

    // Withdraw without caring about rewards. EMERGENCY ONLY.
    function emergencyWithdraw(uint256 _pid) external;

    // Safe cake transfer function, just in case if rounding error causes pool to not have enough CAKEs.
    function safeCakeTransfer(address _to, uint256 _amount) external;

    // Update dev address by the previous dev.
    function dev(address _devaddr) external;
    
    function poolInfo(uint256) external view returns (address, uint256, uint256, uint256);
    
    function userInfo(uint256, address) external view returns (uint256, uint256);
}