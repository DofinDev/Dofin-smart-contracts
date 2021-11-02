// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0;

interface ComptrollerInterface {

    function enterMarkets(address[] calldata cTokens) external returns (uint[] memory);

    function exitMarket(address cToken) external returns (uint);
}