// Fake contracts
var FakeIBEP20 = artifacts.require("./fake/FakeIBEP20.sol");
var FakeLinkBSCOracle = artifacts.require("./fake/chainlink/FakeLinkBSCOracle.sol");
var FakeCErc20Delegator = artifacts.require("./fake/cream/FakeCErc20Delegator.sol");
var FakePancakePair = artifacts.require("./fake/pancakeswap/FakePancakePair.sol");
var FakePancakeFactory = artifacts.require("./fake/pancakeswap/FakePancakeFactory.sol");
var FakeMasterChef = artifacts.require("./fake/pancakeswap/FakeMasterChef.sol");
var FakePancakeRouter = artifacts.require("./fake/pancakeswap/FakePancakeRouter.sol");
// Library
var HighLevelSystem = artifacts.require("./libs/HighLevelSystem.sol");
// Contract
var CashBox = artifacts.require("./CashBox.sol");

module.exports = async function(deployer, network, accounts) {
  if (network == "develop" || network == "test") {
    await deployer.deploy(FakeIBEP20);
    // chainlink fake contracts
    await deployer.deploy(FakeLinkBSCOracle);
    // cream fake contracts
    await deployer.deploy(FakeCErc20Delegator, FakeIBEP20.address);
    // pancakeswap fake contracts
    await deployer.deploy(FakePancakePair, FakeIBEP20.address, FakeIBEP20.address);
    await deployer.deploy(FakePancakeFactory, FakePancakePair.address);
    await deployer.deploy(FakeMasterChef);
    await deployer.deploy(FakePancakeRouter);

    // testing high level system library
    await deployer.deploy(HighLevelSystem);

    // testing CashBox contract
    await deployer.link(HighLevelSystem, CashBox);
    var _uints = [10, 10, 10];
    var _addrs = [FakeIBEP20.address, FakeIBEP20.address, FakeIBEP20.address, FakePancakePair.address, FakeCErc20Delegator.address, FakeCErc20Delegator.address, FakeCErc20Delegator.address];
    var _dofin = '0x0000000000000000000000000000000000000000';
    var _deposit_limit = 100000;
    await deployer.deploy(CashBox, _uints, _addrs, _dofin, _deposit_limit);
  
  } else if (network == "BSCTestnet") {
    await deployer.deploy(FakeIBEP20);
    // chainlink fake contracts
    await deployer.deploy(FakeLinkBSCOracle);
    // cream fake contracts
    await deployer.deploy(FakeCErc20Delegator, FakeIBEP20.address);
    // pancakeswap fake contracts
    await deployer.deploy(FakePancakePair, FakeIBEP20.address, FakeIBEP20.address);
    await deployer.deploy(FakePancakeFactory, FakePancakePair.address);
    await deployer.deploy(FakeMasterChef);
    await deployer.deploy(FakePancakeRouter);

    // testing high level system library
    await deployer.deploy(HighLevelSystem);

    // testing CashBox contract
    await deployer.link(HighLevelSystem, CashBox);
    var _uints = [10, 10, 10];
    var _addrs = [FakeIBEP20.address, FakeIBEP20.address, FakeIBEP20.address, FakePancakePair.address, FakeCErc20Delegator.address, FakeCErc20Delegator.address, FakeCErc20Delegator.address];
    var _dofin = '0x0000000000000000000000000000000000000000';
    var _deposit_limit = 100000;
    await deployer.deploy(CashBox, _uints, _addrs, _dofin, _deposit_limit);
  
  } else if (network == "BSCMainnet") {
    // high level system library
    await deployer.deploy(HighLevelSystem);

    // CashBox contract
    await deployer.link(HighLevelSystem, CashBox);
    // _uints = [pool_id, supply_funds_percentage]
    var _uints = [362, 90];
    // _addrs = [token, token_a, token_b, lp_token, supply_crtoken, borrowed_crtoken_a, borrowed_crtoken_b]
    // _addrs = [USDC, ALPHA, BUSD, ALPHA-BUSD, crUSDC, crALPHA, crBUSD]
    var _addrs = ['0x8AC76a51cc950d9822D68b83fE1Ad97B32Cd580d',
      '0x8F0528cE5eF7B51152A59745bEfDD91D97091d2F',
      '0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56',
      '0x7752e1FA9F3a2e860856458517008558DEb989e3',
      '0xD83C88DB3A6cA4a32FFf1603b0f7DDce01F5f727',
      '0x264Bc4Ea2F45cF6331AD6C3aC8d7257Cf487FcbC',
      '0x2Bc4eb013DDee29D37920938B96d353171289B7C'];
    var _dofin = '0x503cF1B6253b02575bAf33E83000ff9209243784';
    var _deposit_limit = 500;
    await deployer.deploy(CashBox, _uints, _addrs, _dofin, _deposit_limit);

  } else if (network == "BSCForkMainnet") {
    // high level system library
    await deployer.deploy(HighLevelSystem);

    // CashBox contract
    await deployer.link(HighLevelSystem, CashBox);
    // _uints = [pool_id, supply_funds_percentage]
    var _uints = [258, 90];
    // _addrs = [token, token_a, token_b, lp_token, supply_crtoken, borrowed_crtoken_a, borrowed_crtoken_b]
    // _addrs = [USDC, USDT, BUSD, USDT-BUSD, crUSDC, crUSDT, crBUSD]
    var _addrs = [
      '0x8AC76a51cc950d9822D68b83fE1Ad97B32Cd580d',
      '0x55d398326f99059fF775485246999027B3197955',
      '0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56',
      '0x7EFaEf62fDdCCa950418312c6C91Aef321375A00',
      '0xD83C88DB3A6cA4a32FFf1603b0f7DDce01F5f727',
      '0xEF6d459FE81C3Ed53d292c936b2df5a8084975De',
      '0x2Bc4eb013DDee29D37920938B96d353171289B7C'
    ];
    var _dofin = '0x3A7fE75F2b42Ead96D604fC8c9919e5592F7Fa86';
    var _deposit_limit = 1000;
    await deployer.deploy(CashBox, _uints, _addrs, _dofin, _deposit_limit);
  }
};
