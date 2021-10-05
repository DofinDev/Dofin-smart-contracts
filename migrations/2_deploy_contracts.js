var SimpleStorage = artifacts.require("./SimpleStorage.sol");
// Fake contracts
var FakeIBEP20 = artifacts.require("./fake/FakeIBEP20.sol");
var FakeLinkBSCOracle = artifacts.require("./fake/chainlink/FakeLinkBSCOracle.sol");
var FakeCErc20Delegator = artifacts.require("./fake/cream/FakeCErc20Delegator.sol");
var FakeInterestRateModel = artifacts.require("./fake/cream/FakeInterestRateModel.sol");
var FakePriceOracleProxy = artifacts.require("./fake/cream/FakePriceOracleProxy.sol");
var FakePancakePair = artifacts.require("./fake/pancakeswap/FakePancakePair.sol");
var FakePancakeFactory = artifacts.require("./fake/pancakeswap/FakePancakeFactory.sol");
var FakeMasterChef = artifacts.require("./fake/pancakeswap/FakeMasterChef.sol");
var FakePancakeRouter = artifacts.require("./fake/pancakeswap/FakePancakeRouter.sol");
// Librarys
var LinkBSCOracle = artifacts.require("./libs/LinkBSCOracle.sol");
var CreamExecution = artifacts.require("./libs/CreamExecution.sol");
var PancakeSwapExecution = artifacts.require("./libs/PancakeSwapExecution.sol");
var HighLevelSystem = artifacts.require("./libs/HighLevelSystem.sol");

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
  await deployer.deploy(FakePancakePair, FakeIBEP20.address, FakeIBEP20.address);
  await deployer.deploy(FakePancakeFactory, FakePancakePair.address);
  await deployer.deploy(FakeMasterChef);
  await deployer.deploy(FakePancakeRouter);

  // testing librarys
  await deployer.deploy(LinkBSCOracle);
  await deployer.deploy(CreamExecution);
  await deployer.deploy(PancakeSwapExecution);

  // testing high level system library
  await deployer.link(LinkBSCOracle, HighLevelSystem);
  await deployer.link(CreamExecution, HighLevelSystem);
  await deployer.link(PancakeSwapExecution, HighLevelSystem);
  await deployer.deploy(HighLevelSystem);
};
