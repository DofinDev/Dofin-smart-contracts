pragma solidity >=0.4.15 <0.9.0;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/libs/LinkBSCOracle.sol";
// import "../contracts/fake/FakeLinkBSCOracle.sol";

contract TestLinkBSCOracle {

  function testGetPriceFunction() public {
    address FakeLinkBSCOracleAddress = DeployedAddresses.FakeLinkBSCOracle();

    LinkBSCOracle.LinkConfig memory linkConfig = LinkBSCOracle.LinkConfig({oracle: FakeLinkBSCOracleAddress});

    int256 result = LinkBSCOracle.getPrice(linkConfig);
    int256 expected = 10;

    Assert.equal(result, expected, "It should get the value 10 of price.");
  }

  function testGetDecimalsFunction() public {
    address FakeLinkBSCOracleAddress = DeployedAddresses.FakeLinkBSCOracle();

    LinkBSCOracle.LinkConfig memory linkConfig = LinkBSCOracle.LinkConfig({oracle: FakeLinkBSCOracleAddress});

    uint8 result = LinkBSCOracle.getDecimals(linkConfig);
    uint8 expected = 10;

    Assert.equal(result, expected, "It should get the value 10 of decimals.");
  }

}
