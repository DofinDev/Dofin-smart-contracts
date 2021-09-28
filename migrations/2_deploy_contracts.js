var SimpleStorage = artifacts.require("./SimpleStorage.sol");
var FakeLinkBSCOracle = artifacts.require("./fake/FakeLinkBSCOracle.sol");
var LinkBSCOracle = artifacts.require("./libs/LinkBSCOracle.sol");

module.exports = function(deployer) {
  deployer.deploy(SimpleStorage);
  deployer.deploy(FakeLinkBSCOracle);
  deployer.deploy(LinkBSCOracle);
};
