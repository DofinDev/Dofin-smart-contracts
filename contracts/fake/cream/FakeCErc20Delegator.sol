// SPDX-License-Identifier: MIT
pragma solidity >=0.8;

contract FakeCErc20Delegator {

  address public interestRateModel;
  address public underlying;

  function borrow() public returns(uint256) {

    return 10;
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

    return 10;
  }

  function exchangeRateStored() public returns(uint256) {

    return 10;
  }

  function balanceOf(address owner) public returns(uint256) {

    return 10;
  }

  function borrow(uint256 borrowAmount) public returns(uint256) {

    return 10;
  }

  function repayBorrow(uint256 repayAmount) public returns(uint256) {

    return 10;
  }

  function mint(uint256 mintAmount) public returns(uint256) {

    return 10;
  }

  function setUnderlying(address _underlying) public {

    underlying = _underlying;
  }

  function setInterestRateModel(address _InterestRateModel) public {

    interestRateModel = _InterestRateModel;
  }

}