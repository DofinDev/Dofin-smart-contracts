// Fake contracts
var FakeIBEP20 = artifacts.require("./fake/FakeIBEP20.sol");
var FakeLinkBSCOracle = artifacts.require("./fake/chainlink/FakeLinkBSCOracle.sol");
var FakeCErc20Delegator = artifacts.require("./fake/cream/FakeCErc20Delegator.sol");
var FakeComptroller = artifacts.require("./fake/cream/FakeComptroller.sol");
var FakePancakePair = artifacts.require("./fake/pancakeswap/FakePancakePair.sol");
var FakePancakeFactory = artifacts.require("./fake/pancakeswap/FakePancakeFactory.sol");
var FakeMasterChef = artifacts.require("./fake/pancakeswap/FakeMasterChef.sol");
var FakePancakeRouter = artifacts.require("./fake/pancakeswap/FakePancakeRouter.sol");
// Library
var HighLevelSystem = artifacts.require("./libs/HighLevelSystem.sol");
// Bunker
var FixedBunker = artifacts.require("./FixedBunker.sol");
var ChargedBunker = artifacts.require("./ChargedBunker.sol");
var BoostedBunker = artifacts.require("./BoostedBunker.sol");
// Bunker Factory
var FixedBunkersFactory = artifacts.require("./FixedBunkersFactory.sol");
var ChargedBunkersFactory = artifacts.require("./ChargedBunkersFactory.sol");
var BoostedBunkersFactory = artifacts.require("./BoostedBunkersFactory.sol");

module.exports = function(deployer, network, accounts) {
  if (network == "develop" || network == "test") {
    deployer.deploy(FakeIBEP20);
    // chainlink fake contracts
    deployer.deploy(FakeLinkBSCOracle);
    // cream fake contracts
    deployer.deploy(FakeCErc20Delegator, FakeIBEP20.address);
    deployer.deploy(FakeComptroller);
    // pancakeswap fake contracts
    deployer.deploy(FakePancakePair, FakeIBEP20.address, FakeIBEP20.address);
    deployer.deploy(FakePancakeFactory, FakePancakePair.address);
    deployer.deploy(FakeMasterChef);
    deployer.deploy(FakePancakeRouter);

    // testing high level system library
    deployer.deploy(HighLevelSystem);

    // testing FixedBunker contract
    deployer.link(HighLevelSystem, FixedBunker);
    deployer.deploy(FixedBunker);

    // testing ChargedBunker contract
    deployer.link(HighLevelSystem, ChargedBunker);
    deployer.deploy(ChargedBunker);

    // testing BoostedBunker contract
    deployer.link(HighLevelSystem, BoostedBunker);
    deployer.deploy(BoostedBunker);
  
  } else if (network == "BSCTestnet") {
    // testing HighLevelSystem library
    deployer.deploy(HighLevelSystem);

    // testing FixedBunkersFactory contract
    deployer.link(HighLevelSystem, FixedBunkersFactory);
    deployer.deploy(FixedBunkersFactory);

    // testing ChargedBunkersFactory contract
    // deployer.link(HighLevelSystem, ChargedBunkersFactory);
    // deployer.deploy(ChargedBunkersFactory);

    // testing BoostedBunkersFactory contract
    // deployer.link(HighLevelSystem, BoostedBunkersFactory);
    // deployer.deploy(BoostedBunkersFactory);

    // deployer.deploy(FakeIBEP20);
    // chainlink fake contracts
    // deployer.deploy(FakeLinkBSCOracle);
    // cream fake contracts
    // deployer.deploy(FakeCErc20Delegator, FakeIBEP20.address);
    // deployer.deploy(FakeComptroller);
    // pancakeswap fake contracts
    // deployer.deploy(FakePancakePair, FakeIBEP20.address, FakeIBEP20.address);
    // deployer.deploy(FakePancakeFactory, FakePancakePair.address);
    // deployer.deploy(FakeMasterChef);
    // deployer.deploy(FakePancakeRouter);

    // testing FixedBunker contract
    // deployer.link(HighLevelSystem, ChargedBunker);
    // var _uints = [10];
    // var _addrs = [FakeIBEP20.address, FakeIBEP20.address, FakeIBEP20.address, FakeCErc20Delegator.address, FakeCErc20Delegator.address, FakeCErc20Delegator.address];
    // var _name = 'Proof Token';
    // var _symbol = 'pFakeToken';
    // var _decimals = 10;
    // deployer.deploy(ChargedBunker, _uints, _addrs, _name, _symbol, _decimals);

    // testing ChargedBunker contract
    // deployer.link(HighLevelSystem, ChargedBunker);
    // var _uints = [10, 10];
    // var _addrs = [FakeIBEP20.address, FakeIBEP20.address, FakeIBEP20.address, FakePancakePair.address, FakeCErc20Delegator.address, FakeCErc20Delegator.address, FakeCErc20Delegator.address];
    // var _name = 'Proof Token';
    // var _symbol = 'pFakeToken';
    // var _decimals = 10;
    // deployer.deploy(ChargedBunker, _uints, _addrs, _name, _symbol, _decimals);

    // testing BoostedBunker contract
    // deployer.link(HighLevelSystem, BoostedBunker);
    // var _uints = [10, 10];
    // var _addrs = [FakeIBEP20.address, FakeIBEP20.address, FakeIBEP20.address, FakePancakePair.address];
    // var _name = 'Proof Token';
    // var _symbol = 'pFakeToken';
    // var _decimals = 10;
    // deployer.deploy(BoostedBunker, _uints, _addrs, _name, _symbol, _decimals);
  
  } else if (network == "BSCMainnet") {
    // high level system library
    deployer.deploy(HighLevelSystem);

    // ChargedBunker contract
    deployer.link(HighLevelSystem, ChargedBunker);
    deployer.deploy(ChargedBunker, _uints, _addrs, _name, _symbol, _decimals);

  } else if (network == "BSCForkMainnet") {
    // high level system library
    deployer.deploy(HighLevelSystem);

    // ChargedBunker contract
    deployer.link(HighLevelSystem, ChargedBunker);
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
    var _name = 'Proof Token';
    var _symbol = 'pUSDC';
    var _decimals = 18;
    deployer.deploy(ChargedBunker, _uints, _addrs, _name, _symbol, _decimals);

    // BoostedBunker contract
    deployer.link(HighLevelSystem, BoostedBunker);
    var _uints = [258, 90];
    // _addrs = [token, token_a, token_b, lp_token]
    // _addrs = [USDC, CAKE, BUSD, CAKE-BUSD]
    var _addrs = [
      '0x8AC76a51cc950d9822D68b83fE1Ad97B32Cd580d',
      '0x55d398326f99059fF775485246999027B3197955',
      '0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56',
      '0x7EFaEf62fDdCCa950418312c6C91Aef321375A00'
    ];
    var _name = 'Proof Token';
    var _symbol = 'pUSDC';
    var _decimals = 18;
    deployer.deploy(BoostedBunker, _uints, _addrs, _name, _symbol, _decimals);
  }
};
