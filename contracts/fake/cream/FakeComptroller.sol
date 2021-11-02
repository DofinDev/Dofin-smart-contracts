// SPDX-License-Identifier: MIT
pragma solidity >=0.8;

contract FakeComptroller {

  function enterMarkets(address[] calldata cTokens) public returns(uint[] memory) {
    uint[] memory a = new uint[] (2);
    a[0] = 10;
    a[1] = 10;
    return a;
  }

  function exitMarket(address cToken) public returns(uint) {

    return 10;
  }

}