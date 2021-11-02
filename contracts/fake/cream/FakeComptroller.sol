// SPDX-License-Identifier: MIT
pragma solidity >=0.8;

contract FakeComptroller {

  function enterMarkets(address[] calldata cTokens) public returns(uint[] memory) {

    return 10;
  }

  function exitMarket(address cToken) public returns(uint) {

    return 10;
  }

}