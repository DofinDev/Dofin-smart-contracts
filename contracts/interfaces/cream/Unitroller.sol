// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0;


interface Unitroller {

    function allMarkets(uint) external view returns (address);
    function getAllMarkets() external view returns (address[] memory);
    
}