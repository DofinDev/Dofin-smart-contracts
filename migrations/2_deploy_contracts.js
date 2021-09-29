var SimpleStorage = artifacts.require("./SimpleStorage.sol");
// Fake contracts
var FakeIBEP20 = artifacts.require("./fake/FakeIBEP20.sol");
var FakeLinkBSCOracle = artifacts.require("./fake/chainlink/FakeLinkBSCOracle.sol");
var FakeCErc20Delegator = artifacts.require("./fake/cream/FakeCErc20Delegator.sol");
var FakeInterestRateModel = artifacts.require("./fake/cream/FakeInterestRateModel.sol");
var FakePriceOracleProxy = artifacts.require("./fake/cream/FakePriceOracleProxy.sol");
var FakeUnitroller = artifacts.require("./fake/cream/FakeUnitroller.sol");
// Librarys
var LinkBSCOracle = artifacts.require("./libs/LinkBSCOracle.sol");
var CreamExecution = artifacts.require("./libs/CreamExecution.sol");

module.exports = function(deployer) {
  deployer.deploy(SimpleStorage);

  deployer.deploy(FakeIBEP20);
  // chainlink fake contracts
  deployer.deploy(FakeLinkBSCOracle);
  // cream fake contracts
  deployer.deploy(FakeCErc20Delegator);
  deployer.deploy(FakeInterestRateModel);
  deployer.deploy(FakePriceOracleProxy);
  deployer.deploy(FakeUnitroller);
  // pancakeswap fake contracts

  deployer.deploy(LinkBSCOracle);
  deployer.deploy(CreamExecution);
};
