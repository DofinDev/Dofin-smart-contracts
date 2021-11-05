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

module.exports = async function(deployer, network, accounts) {
  if (network == "develop" || network == "test") {
    await deployer.deploy(FakeIBEP20);
    // chainlink fake contracts
    await deployer.deploy(FakeLinkBSCOracle);
    // cream fake contracts
    await deployer.deploy(FakeCErc20Delegator, FakeIBEP20.address);
    await deployer.deploy(FakeComptroller);
    // pancakeswap fake contracts
    await deployer.deploy(FakePancakePair, FakeIBEP20.address, FakeIBEP20.address);
    await deployer.deploy(FakePancakeFactory, FakePancakePair.address);
    await deployer.deploy(FakeMasterChef);
    await deployer.deploy(FakePancakeRouter);

    // testing high level system library
    await deployer.deploy(HighLevelSystem);

    // testing ChargedBunker contract
    await deployer.link(HighLevelSystem, ChargedBunker);
    var _uints = [10, 10];
    var _addrs = [FakeIBEP20.address, FakeIBEP20.address, FakeIBEP20.address, FakePancakePair.address, FakeCErc20Delegator.address, FakeCErc20Delegator.address, FakeCErc20Delegator.address];
    var _name = 'Proof Token';
    var _symbol = 'pFakeToken';
    var _decimals = 10;
    await deployer.deploy(ChargedBunker, _uints, _addrs, _name, _symbol, _decimals);

    // testing BoostedBunker contract
    await deployer.link(HighLevelSystem, BoostedBunker);
    var _uints = [10, 10];
    var _addrs = [FakeIBEP20.address, FakeIBEP20.address, FakeIBEP20.address, FakePancakePair.address];
    var _name = 'Proof Token';
    var _symbol = 'pFakeToken';
    var _decimals = 10;
    await deployer.deploy(BoostedBunker, _uints, _addrs, _name, _symbol, _decimals);

    // testing FixedBunker contract
    await deployer.link(HighLevelSystem, FixedBunker);
    var _uints = [10];
    var _addrs = [FakeIBEP20.address, FakeIBEP20.address, FakeIBEP20.address, FakeCErc20Delegator.address, FakeCErc20Delegator.address, FakeCErc20Delegator.address];
    var _name = 'Proof Token';
    var _symbol = 'pFakeToken';
    var _decimals = 10;
    await deployer.deploy(FixedBunker, _uints, _addrs, _name, _symbol, _decimals);
  
  } else if (network == "BSCTestnet") {
    // testing HighLevelSystem library
    await deployer.deploy(HighLevelSystem);

    // testing FixedBunkersFactory contract
    await deployer.link(HighLevelSystem, FixedBunkersFactory);
    await deployer.deploy(FixedBunkersFactory);

    // testing ChargedBunkersFactory contract
    // await deployer.link(HighLevelSystem, ChargedBunkersFactory);
    // await deployer.deploy(ChargedBunkersFactory);

    // testing BoostedBunkersFactory contract
    // await deployer.link(HighLevelSystem, BoostedBunkersFactory);
    // await deployer.deploy(BoostedBunkersFactory);

    // await deployer.deploy(FakeIBEP20);
    // chainlink fake contracts
    // await deployer.deploy(FakeLinkBSCOracle);
    // cream fake contracts
    // await deployer.deploy(FakeCErc20Delegator, FakeIBEP20.address);
    // await deployer.deploy(FakeComptroller);
    // pancakeswap fake contracts
    // await deployer.deploy(FakePancakePair, FakeIBEP20.address, FakeIBEP20.address);
    // await deployer.deploy(FakePancakeFactory, FakePancakePair.address);
    // await deployer.deploy(FakeMasterChef);
    // await deployer.deploy(FakePancakeRouter);

    // testing FixedBunker contract
    // await deployer.link(HighLevelSystem, ChargedBunker);
    // var _uints = [10];
    // var _addrs = [FakeIBEP20.address, FakeIBEP20.address, FakeIBEP20.address, FakeCErc20Delegator.address, FakeCErc20Delegator.address, FakeCErc20Delegator.address];
    // var _name = 'Proof Token';
    // var _symbol = 'pFakeToken';
    // var _decimals = 10;
    // await deployer.deploy(ChargedBunker, _uints, _addrs, _name, _symbol, _decimals);

    // testing ChargedBunker contract
    // await deployer.link(HighLevelSystem, ChargedBunker);
    // var _uints = [10, 10];
    // var _addrs = [FakeIBEP20.address, FakeIBEP20.address, FakeIBEP20.address, FakePancakePair.address, FakeCErc20Delegator.address, FakeCErc20Delegator.address, FakeCErc20Delegator.address];
    // var _name = 'Proof Token';
    // var _symbol = 'pFakeToken';
    // var _decimals = 10;
    // await deployer.deploy(ChargedBunker, _uints, _addrs, _name, _symbol, _decimals);

    // testing BoostedBunker contract
    // await deployer.link(HighLevelSystem, BoostedBunker);
    // var _uints = [10, 10];
    // var _addrs = [FakeIBEP20.address, FakeIBEP20.address, FakeIBEP20.address, FakePancakePair.address];
    // var _name = 'Proof Token';
    // var _symbol = 'pFakeToken';
    // var _decimals = 10;
    // await deployer.deploy(BoostedBunker, _uints, _addrs, _name, _symbol, _decimals);
  
  } else if (network == "BSCMainnet") {
    // high level system library
    await deployer.deploy(HighLevelSystem);

    // ChargedBunker contract
    await deployer.link(HighLevelSystem, ChargedBunker);
    // _uints = [pool_id, supply_funds_percentage]
    var _uints = [389, 90];
    // _addrs = [token, token_a, token_b, lp_token, supply_crtoken, borrowed_crtoken_a, borrowed_crtoken_b]
    // _addrs = [USDC, CAKE, BUSD, CAKE-BUSD, crUSDC, crCAKE, crBUSD]
    var _addrs = [
      '0x8AC76a51cc950d9822D68b83fE1Ad97B32Cd580d',
      '0x0E09FaBB73Bd3Ade0a17ECC321fD13a19e81cE82',
      '0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56',
      '0x804678fa97d91B974ec2af3c843270886528a9E6',
      '0xD83C88DB3A6cA4a32FFf1603b0f7DDce01F5f727',
      '0xBf9B95b78bc42F6CF53FF2A0ce19D607cFe1ff82',
      '0x2Bc4eb013DDee29D37920938B96d353171289B7C'
    ];
    var _name = 'Proof Token';
    var _symbol = 'pUSDC';
    var _decimals = 18;
    await deployer.deploy(ChargedBunker, _uints, _addrs, _name, _symbol, _decimals);

  } else if (network == "BSCForkMainnet") {
    // high level system library
    await deployer.deploy(HighLevelSystem);

    // ChargedBunker contract
    await deployer.link(HighLevelSystem, ChargedBunker);
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
    await deployer.deploy(ChargedBunker, _uints, _addrs, _name, _symbol, _decimals);

    // BoostedBunker contract
    await deployer.link(HighLevelSystem, BoostedBunker);
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
    await deployer.deploy(BoostedBunker, _uints, _addrs, _name, _symbol, _decimals);
  }
};
