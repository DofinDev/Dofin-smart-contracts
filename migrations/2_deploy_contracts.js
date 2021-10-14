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
  if (network == "develop" || network == "BSCTestnet" || network == "test") {
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
    await deployer.deploy(CashBox, _uints, _addrs, _dofin, _deposit_limit);
  
  } else if (network == "BSCMainnet") {
    // librarys
    await deployer.deploy(LinkBSCOracle);
    await deployer.deploy(CreamExecution);
    await deployer.deploy(PancakeSwapExecution);

    // high level system library
    await deployer.link(LinkBSCOracle, HighLevelSystem);
    await deployer.link(CreamExecution, HighLevelSystem);
    await deployer.link(PancakeSwapExecution, HighLevelSystem);
    await deployer.deploy(HighLevelSystem);

    // CashBox contract
    await deployer.link(HighLevelSystem, CashBox);
    // _uints = [pool_id, max_amount_per_position, supply_funds_percentage]
    var _uints = [306, 500, 90];
    // _addrs = [token, token_a, token_b, lp_token, supply_crtoken, borrowed_crtoken_a, borrowed_crtoken_b]
    // _addrs = [USDC, SUSHI, ETH, SUSHI-ETH, crUSDC, crSUSHI, crETH]
    var _addrs = ['0x8AC76a51cc950d9822D68b83fE1Ad97B32Cd580d',
      '0x947950BcC74888a40Ffa2593C5798F11Fc9124C4',
      '0x2170Ed0880ac9A755fd29B2688956BD959F933F8',
      '0x16aFc4F2Ad82986bbE2a4525601F8199AB9c832D',
      '0xD83C88DB3A6cA4a32FFf1603b0f7DDce01F5f727',
      '0x9B53e7D5e3F6Cc8694840eD6C9f7fee79e7Bcee5',
      '0xb31f5d117541825D6692c10e4357008EDF3E2BCD'];
    var _dofin = '0x503cF1B6253b02575bAf33E83000ff9209243784';
    // _deposit_limit will be same as max_amount_per_position
    var _deposit_limit = 500;
    await deployer.deploy(CashBox, _uints, _addrs, _dofin, _deposit_limit);
  }
};
