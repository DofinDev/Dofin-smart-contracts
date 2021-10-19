// SPDX-License-Identifier: MIT
pragma solidity >=0.4.15 <0.9.0;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/libs/LinkBSCOracle.sol";

contract TestLinkBSCOracle {

  function testGetPriceFunction() public {
    address FakeLinkBSCOracleAddress = DeployedAddresses.FakeLinkBSCOracle();

    address _chain_link_addr = FakeLinkBSCOracleAddress;

    int256 result = LinkBSCOracle.getPrice(_chain_link_addr);
    int256 expected = 10;

    Assert.equal(result, expected, "It should get the value 10 of price.");
  }

  function testGetDecimalsFunction() public {
    address FakeLinkBSCOracleAddress = DeployedAddresses.FakeLinkBSCOracle();

    address _chain_link_addr = FakeLinkBSCOracleAddress;

    uint8 result = LinkBSCOracle.getDecimals(_chain_link_addr);
    uint8 expected = 10;

    Assert.equal(result, expected, "It should get the value 10 of decimals.");
  }

}
