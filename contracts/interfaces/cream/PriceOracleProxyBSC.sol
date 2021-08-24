// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0;


interface PriceOracleProxyBSC {

    function getUnderlyingPrice(address cToken) external view returns (uint256);
    
}