// SPDX-License-Identifier: MIT
pragma solidity >=0.8;

contract FakeCErc20Delegator {

  address public underlying;

  constructor(address _underlying) public {
      underlying = _underlying;
  }

  function borrow(uint256 borrowAmount) public returns(uint256) {

    return 0;
  }

  function approve(address spender, uint256 amount) public returns(bool) {

    return true;
  }

  function getCash() public returns(uint256) {

    return 10;
  }

  function totalBorrows() public returns(uint256) {

    return 10;
  }

  function totalReserves() public returns(uint256) {

    return 10;
  }

  function decimals() public returns(uint8) {

    return 10;
  }

  function reserveFactorMantissa() public returns(uint256) {

    return 10;
  }

  function borrowBalanceStored(address account) public returns(uint256) {

    return 10;
  }

  function balanceOfUnderlying(address account) public returns(uint256) {

    return 100;
  }

  function exchangeRateStored() public returns(uint256) {

    return 10000000000000000000;
  }

  function balanceOf(address owner) public returns(uint256) {

    return 1000000000000000000000;
  }

  function repayBorrow(uint256 repayAmount) public returns(uint256) {

    return 0;
  }

  function mint(uint256 mintAmount) public returns(uint256) {

    return 0;
  }

  function setUnderlying(address _underlying) public {

    underlying = _underlying;
  }

  function redeem(uint256 redeemAmount) public returns (uint256) {

    return 0;
  }
  
  function redeemUnderlying(uint256 redeemAmount) public returns (uint256) {

    return 0;
  }

  function borrowBalanceCurrent(address account) external returns (uint256) {

    return 0;
  }



}