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
// Contract
var CashBox = artifacts.require("./CashBox.sol");

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

  // testing CashBox contract
  await deployer.link(HighLevelSystem, CashBox);
  var _uints = [10, 10, 10];
  var _addrs = [FakeIBEP20.address, FakeIBEP20.address, FakeIBEP20.address, FakePancakePair.address, FakeCErc20Delegator.address, FakeCErc20Delegator.address, FakeCErc20Delegator.address];
  var _dofin = '0x0000000000000000000000000000000000000000';
  var _deposit_limit = 100000;
  var _add_funds_condition = 100000;
  await deployer.deploy(CashBox, _uints, _addrs, _dofin, _deposit_limit, _add_funds_condition);
};
