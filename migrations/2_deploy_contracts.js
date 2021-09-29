var SimpleStorage = artifacts.require("./SimpleStorage.sol");
// Fake contracts
var FakeIBEP20 = artifacts.require("./fake/FakeIBEP20.sol");
var FakeLinkBSCOracle = artifacts.require("./fake/chainlink/FakeLinkBSCOracle.sol");
var FakeCErc20Delegator = artifacts.require("./fake/cream/FakeCErc20Delegator.sol");
var FakeInterestRateModel = artifacts.require("./fake/cream/FakeInterestRateModel.sol");
var FakePriceOracleProxy = artifacts.require("./fake/cream/FakePriceOracleProxy.sol");
// Librarys
var LinkBSCOracle = artifacts.require("./libs/LinkBSCOracle.sol");
var CreamExecution = artifacts.require("./libs/CreamExecution.sol");

module.exports = async function(deployer, network, accounts) {
  await deployer.deploy(SimpleStorage);

  await deployer.deploy(FakeIBEP20);
  // chainlink fake contracts
  await deployer.deploy(FakeLinkBSCOracle);
  // cream fake contracts
  await deployer.deploy(FakeInterestRateModel);
  await deployer.deploy(FakePriceOracleProxy);
  await deployer.deploy(FakeCErc20Delegator, FakeInterestRateModel.address, FakeIBEP20.address);
  // pancakeswap fake contracts

  await deployer.deploy(LinkBSCOracle);
  await deployer.deploy(CreamExecution);
};
