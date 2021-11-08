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
    deployer.link(HighLevelSystem, ChargedBunkersFactory);
    deployer.deploy(ChargedBunkersFactory);

    // testing BoostedBunkersFactory contract
    deployer.link(HighLevelSystem, BoostedBunkersFactory);
    deployer.deploy(BoostedBunkersFactory);

    // testing FixedBunker contract
    deployer.link(HighLevelSystem, FixedBunker);
    deployer.deploy(FixedBunker);

    // testing ChargedBunker contract
    deployer.link(HighLevelSystem, ChargedBunker);
    deployer.deploy(ChargedBunker);

    // testing BoostedBunker contract
    deployer.link(HighLevelSystem, BoostedBunker);
    deployer.deploy(BoostedBunker);

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
  
  } else if (network == "BSCMainnet") {
    // testing HighLevelSystem library
    deployer.deploy(HighLevelSystem);

    // testing FixedBunkersFactory contract
    // deployer.link(HighLevelSystem, FixedBunkersFactory);
    // deployer.deploy(FixedBunkersFactory);

    // testing ChargedBunkersFactory contract
    // deployer.link(HighLevelSystem, ChargedBunkersFactory);
    // deployer.deploy(ChargedBunkersFactory);

    // testing BoostedBunkersFactory contract
    // deployer.link(HighLevelSystem, BoostedBunkersFactory);
    // deployer.deploy(BoostedBunkersFactory);

    // testing FixedBunker contract
    deployer.link(HighLevelSystem, FixedBunker);
    deployer.deploy(FixedBunker);

    // testing ChargedBunker contract
    deployer.link(HighLevelSystem, ChargedBunker);
    deployer.deploy(ChargedBunker);

    // testing BoostedBunker contract
    deployer.link(HighLevelSystem, BoostedBunker);
    deployer.deploy(BoostedBunker);

  } else if (network == "BSCForkMainnet") {
    // high level system library
    deployer.deploy(HighLevelSystem);

    // BoostedBunker contract
    deployer.link(HighLevelSystem, FixedBunker);
    deployer.deploy(FixedBunker);

    // ChargedBunker contract
    deployer.link(HighLevelSystem, ChargedBunker);
    deployer.deploy(ChargedBunker);

    // BoostedBunker contract
    deployer.link(HighLevelSystem, BoostedBunker);
    deployer.deploy(BoostedBunker);
  }
};
