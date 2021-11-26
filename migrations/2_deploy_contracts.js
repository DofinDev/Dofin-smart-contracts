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
  if (network == "develop", network == "test") {
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

    // testing FixedBunker contract
    await deployer.link(HighLevelSystem, FixedBunker);
    await deployer.deploy(FixedBunker);

    // testing ChargedBunker contract
    await deployer.link(HighLevelSystem, ChargedBunker);
    await deployer.deploy(ChargedBunker);

    // testing BoostedBunker contract
    await deployer.link(HighLevelSystem, BoostedBunker);
    await deployer.deploy(BoostedBunker);
  
  } else if (network == "BSCTestnet") {
    // testing HighLevelSystem library
    await deployer.deploy(HighLevelSystem);

    // testing FixedBunkersFactory contract
    // await deployer.link(HighLevelSystem, FixedBunkersFactory);
    // await deployer.deploy(FixedBunkersFactory);

    // testing ChargedBunkersFactory contract
    // await deployer.link(HighLevelSystem, ChargedBunkersFactory);
    // await deployer.deploy(ChargedBunkersFactory);

    // testing BoostedBunkersFactory contract
    // await deployer.link(HighLevelSystem, BoostedBunkersFactory);
    // await deployer.deploy(BoostedBunkersFactory);

    // testing FixedBunker contract
    await deployer.link(HighLevelSystem, FixedBunker);
    await deployer.deploy(FixedBunker);

    // testing ChargedBunker contract
    await deployer.link(HighLevelSystem, ChargedBunker);
    await deployer.deploy(ChargedBunker);

    // testing BoostedBunker contract
    await deployer.link(HighLevelSystem, BoostedBunker);
    await deployer.deploy(BoostedBunker);

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
  
  } else if (network == "BSCMainnet") {
    // HighLevelSystem library
    await deployer.deploy(HighLevelSystem);

    // FixedBunkersFactory contract
    await deployer.link(HighLevelSystem, FixedBunkersFactory);
    await deployer.deploy(FixedBunkersFactory);

    // ChargedBunkersFactory contract
    // await deployer.link(HighLevelSystem, ChargedBunkersFactory);
    // await deployer.deploy(ChargedBunkersFactory);

    // BoostedBunkersFactory contract
    await deployer.link(HighLevelSystem, BoostedBunkersFactory);
    await deployer.deploy(BoostedBunkersFactory);

  } else if (network == "BSCForkMainnet") {
    // high level system library
    await deployer.deploy(HighLevelSystem);

    // testing FixedBunkersFactory contract
    await deployer.link(HighLevelSystem, FixedBunkersFactory);
    await deployer.deploy(FixedBunkersFactory);

    // testing ChargedBunkersFactory contract
    // await deployer.link(HighLevelSystem, ChargedBunkersFactory);
    // await deployer.deploy(ChargedBunkersFactory);

    // testing BoostedBunkersFactory contract
    await deployer.link(HighLevelSystem, BoostedBunkersFactory);
    await deployer.deploy(BoostedBunkersFactory);
  }
};
