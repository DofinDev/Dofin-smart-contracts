// SPDX-License-Identifier: MIT
pragma solidity >=0.8;

contract FakeUnitroller {

  function getAllMarkets() public returns(address[] memory) {
    address[] memory address_array;
    address_array[0] = address(0);
    address_array[1] = msg.sender;
    return address_array;
  }

}