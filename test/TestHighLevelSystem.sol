// SPDX-License-Identifier: MIT
pragma solidity >=0.4.15 <0.9.0;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/libs/HighLevelSystem.sol";

contract TestHighLevelSystem {

  address public FakeIBEP20Address = DeployedAddresses.FakeIBEP20();
  address public FakeCErc20DelegatorAddress = DeployedAddresses.FakeCErc20Delegator();
  address public FakePancakePairAddress = DeployedAddresses.FakePancakePair();

  address public FakeLinkBSCOracleAddress = DeployedAddresses.FakeLinkBSCOracle();
  address public FakePancakeFactoryAddress = DeployedAddresses.FakePancakeFactory();
  address public FakeMasterChefAddress = DeployedAddresses.FakeMasterChef();
  address public FakePancakeRouterAddress = DeployedAddresses.FakePancakeRouter();
  address public FakeComptrollerAddress = DeployedAddresses.FakeComptroller();

  HighLevelSystem.HLSConfig private HLSConfig;
  HighLevelSystem.Position private Position;

  function beforeEach() public {
    HLSConfig.token_oracle = FakeLinkBSCOracleAddress;
    HLSConfig.token_a_oracle = FakeLinkBSCOracleAddress;
    HLSConfig.token_b_oracle = FakeLinkBSCOracleAddress;
    HLSConfig.cake_oracle = FakeLinkBSCOracleAddress;
    HLSConfig.router = FakePancakeRouterAddress;
    HLSConfig.factory = FakePancakeFactoryAddress;
    HLSConfig.masterchef = FakeMasterChefAddress;
    HLSConfig.CAKE = FakeIBEP20Address;
    HLSConfig.comptroller = FakeComptrollerAddress;

    Position = HighLevelSystem.Position({
      pool_id: 10,
      token_amount: 10,
      token_a_amount: 10,
      token_b_amount: 10,
      lp_token_amount: 10,
      crtoken_amount: 10,
      supply_amount: 10,
      liquidity_a: 10,
      liquidity_b: 10,
      borrowed_token_a_amount: 0,
      borrowed_token_b_amount: 0,
      token: FakeIBEP20Address,
      token_a: FakeIBEP20Address,
      token_b: FakeIBEP20Address,
      lp_token: FakePancakePairAddress,
      supply_crtoken: FakeCErc20DelegatorAddress,
      borrowed_crtoken_a: FakeCErc20DelegatorAddress,
      borrowed_crtoken_b: FakeCErc20DelegatorAddress,
      funds_percentage: 95,
      total_depts: 0
    });
  }

  function testEnterPosition() public {
    // Testing
    HighLevelSystem.Position memory result_1 = HighLevelSystem.enterPosition(HLSConfig, Position, 1);
    HighLevelSystem.Position memory result_2 = HighLevelSystem.enterPosition(HLSConfig, Position, 2);
    HighLevelSystem.Position memory result_3 = HighLevelSystem.enterPosition(HLSConfig, Position, 3);
    HighLevelSystem.Position memory expected_1 = HighLevelSystem.Position({
      pool_id: 10,
      token_amount: 100000000000000000000,
      token_a_amount: 100000000000000000000,
      token_b_amount: 100000000000000000000,
      lp_token_amount: 10,
      crtoken_amount: 1000000000000000000000,
      supply_amount: 95000000000000000000,
      liquidity_a: 10,
      liquidity_b: 10,
      borrowed_token_a_amount: 26718750000000000000,
      borrowed_token_b_amount: 26718750000000000000,
      token: FakeIBEP20Address,
      token_a: FakeIBEP20Address,
      token_b: FakeIBEP20Address,
      lp_token: FakePancakePairAddress,
      supply_crtoken: FakeCErc20DelegatorAddress,
      borrowed_crtoken_a: FakeCErc20DelegatorAddress,
      borrowed_crtoken_b: FakeCErc20DelegatorAddress,
      funds_percentage: 95,
      total_depts: 95000000000000000010
    });
    HighLevelSystem.Position memory expected_2 = HighLevelSystem.Position({
      pool_id: 10,
      token_amount: 10,
      token_a_amount: 100000000000000000000,
      token_b_amount: 100000000000000000000,
      lp_token_amount: 10,
      crtoken_amount: 10,
      supply_amount: 10,
      liquidity_a: 10,
      liquidity_b: 10,
      borrowed_token_a_amount: 2,
      borrowed_token_b_amount: 3,
      token: FakeIBEP20Address,
      token_a: FakeIBEP20Address,
      token_b: FakeIBEP20Address,
      lp_token: FakePancakePairAddress,
      supply_crtoken: FakeCErc20DelegatorAddress,
      borrowed_crtoken_a: FakeCErc20DelegatorAddress,
      borrowed_crtoken_b: FakeCErc20DelegatorAddress,
      funds_percentage: 95,
      total_depts: 20
    });
    HighLevelSystem.Position memory expected_3 = HighLevelSystem.Position({
      pool_id: 10,
      token_amount: 10,
      token_a_amount: 100000000000000000000,
      token_b_amount: 100000000000000000000,
      lp_token_amount: 10,
      crtoken_amount: 10,
      supply_amount: 10,
      liquidity_a: 10,
      liquidity_b: 10,
      borrowed_token_a_amount: 0,
      borrowed_token_b_amount: 0,
      token: FakeIBEP20Address,
      token_a: FakeIBEP20Address,
      token_b: FakeIBEP20Address,
      lp_token: FakePancakePairAddress,
      supply_crtoken: FakeCErc20DelegatorAddress,
      borrowed_crtoken_a: FakeCErc20DelegatorAddress,
      borrowed_crtoken_b: FakeCErc20DelegatorAddress,
      funds_percentage: 95,
      total_depts: 20
    });

    Assert.equal(result_1.pool_id, expected_1.pool_id, "It should get the type1 of position data pool_id.");
    Assert.equal(result_1.token_amount, expected_1.token_amount, "It should get the type1 of position data token_amount.");
    Assert.equal(result_1.token_a_amount, expected_1.token_a_amount, "It should get the type1 of position data token_a_amount.");
    Assert.equal(result_1.token_b_amount, expected_1.token_b_amount, "It should get the type1 of position data token_b_amount.");
    Assert.equal(result_1.lp_token_amount, expected_1.lp_token_amount, "It should get the type1 of position data lp_token_amount.");
    Assert.equal(result_1.crtoken_amount, expected_1.crtoken_amount, "It should get the type1 of position data crtoken_amount.");
    Assert.equal(result_1.supply_amount, expected_1.supply_amount, "It should get the type1 of position data supply_amount.");
    Assert.equal(result_1.liquidity_a, expected_1.liquidity_a, "It should get the type1 of position data liquidity_a.");
    Assert.equal(result_1.liquidity_b, expected_1.liquidity_b, "It should get the type1 of position data liquidity_b.");
    Assert.equal(result_1.borrowed_token_a_amount, expected_1.borrowed_token_a_amount, "It should get the type1 of position data borrowed_token_a_amount.");
    Assert.equal(result_1.borrowed_token_b_amount, expected_1.borrowed_token_b_amount, "It should get the type1 of position data borrowed_token_b_amount.");
    Assert.equal(result_1.token, expected_1.token, "It should get the type1 of position data token.");
    Assert.equal(result_1.token_a, expected_1.token_a, "It should get the type1 of position data token_a.");
    Assert.equal(result_1.token_b, expected_1.token_b, "It should get the type1 of position data token_b.");
    Assert.equal(result_1.lp_token, expected_1.lp_token, "It should get the type1 of position data lp_token.");
    Assert.equal(result_1.supply_crtoken, expected_1.supply_crtoken, "It should get the type1 of position data supply_crtoken.");
    Assert.equal(result_1.borrowed_crtoken_a, expected_1.borrowed_crtoken_a, "It should get the type1 of position data borrowed_crtoken_a.");
    Assert.equal(result_1.borrowed_crtoken_b, expected_1.borrowed_crtoken_b, "It should get the type1 of position data borrowed_crtoken_b.");
    Assert.equal(result_1.funds_percentage, expected_1.funds_percentage, "It should get the type1 of position data funds_percentage.");
    Assert.equal(result_1.total_depts, expected_1.total_depts, "It should get the type1 of position data total_depts.");

    Assert.equal(result_2.pool_id, expected_2.pool_id, "It should get the type2 of position data pool_id.");
    Assert.equal(result_2.token_amount, expected_2.token_amount, "It should get the type2 of position data token_amount.");
    Assert.equal(result_2.token_a_amount, expected_2.token_a_amount, "It should get the type2 of position data token_a_amount.");
    Assert.equal(result_2.token_b_amount, expected_2.token_b_amount, "It should get the type2 of position data token_b_amount.");
    Assert.equal(result_2.lp_token_amount, expected_2.lp_token_amount, "It should get the type2 of position data lp_token_amount.");
    Assert.equal(result_2.crtoken_amount, expected_2.crtoken_amount, "It should get the type2 of position data crtoken_amount.");
    Assert.equal(result_2.supply_amount, expected_2.supply_amount, "It should get the type2 of position data supply_amount.");
    Assert.equal(result_2.liquidity_a, expected_2.liquidity_a, "It should get the type2 of position data liquidity_a.");
    Assert.equal(result_2.liquidity_b, expected_2.liquidity_b, "It should get the type2 of position data liquidity_b.");
    Assert.equal(result_2.borrowed_token_a_amount, expected_2.borrowed_token_a_amount, "It should get the type2 of position data borrowed_token_a_amount.");
    Assert.equal(result_2.borrowed_token_b_amount, expected_2.borrowed_token_b_amount, "It should get the type2 of position data borrowed_token_b_amount.");
    Assert.equal(result_2.token, expected_2.token, "It should get the type2 of position data token.");
    Assert.equal(result_2.token_a, expected_2.token_a, "It should get the type2 of position data token_a.");
    Assert.equal(result_2.token_b, expected_2.token_b, "It should get the type2 of position data token_b.");
    Assert.equal(result_2.lp_token, expected_2.lp_token, "It should get the type2 of position data lp_token.");
    Assert.equal(result_2.supply_crtoken, expected_2.supply_crtoken, "It should get the type2 of position data supply_crtoken.");
    Assert.equal(result_2.borrowed_crtoken_a, expected_2.borrowed_crtoken_a, "It should get the type2 of position data borrowed_crtoken_a.");
    Assert.equal(result_2.borrowed_crtoken_b, expected_2.borrowed_crtoken_b, "It should get the type2 of position data borrowed_crtoken_b.");
    Assert.equal(result_2.funds_percentage, expected_2.funds_percentage, "It should get the type2 of position data funds_percentage.");
    Assert.equal(result_2.total_depts, expected_2.total_depts, "It should get the type2 of position data total_depts.");

    Assert.equal(result_3.pool_id, expected_3.pool_id, "It should get the type3 of position data pool_id.");
    Assert.equal(result_3.token_amount, expected_3.token_amount, "It should get the type3 of position data token_amount.");
    Assert.equal(result_3.token_a_amount, expected_3.token_a_amount, "It should get the type3 of position data token_a_amount.");
    Assert.equal(result_3.token_b_amount, expected_3.token_b_amount, "It should get the type3 of position data token_b_amount.");
    Assert.equal(result_3.lp_token_amount, expected_3.lp_token_amount, "It should get the type3 of position data lp_token_amount.");
    Assert.equal(result_3.crtoken_amount, expected_3.crtoken_amount, "It should get the type3 of position data crtoken_amount.");
    Assert.equal(result_3.supply_amount, expected_3.supply_amount, "It should get the type3 of position data supply_amount.");
    Assert.equal(result_3.liquidity_a, expected_3.liquidity_a, "It should get the type3 of position data liquidity_a.");
    Assert.equal(result_3.liquidity_b, expected_3.liquidity_b, "It should get the type3 of position data liquidity_b.");
    Assert.equal(result_3.borrowed_token_a_amount, expected_3.borrowed_token_a_amount, "It should get the type3 of position data borrowed_token_a_amount.");
    Assert.equal(result_3.borrowed_token_b_amount, expected_3.borrowed_token_b_amount, "It should get the type3 of position data borrowed_token_b_amount.");
    Assert.equal(result_3.token, expected_3.token, "It should get the type3 of position data token.");
    Assert.equal(result_3.token_a, expected_3.token_a, "It should get the type3 of position data token_a.");
    Assert.equal(result_3.token_b, expected_3.token_b, "It should get the type3 of position data token_b.");
    Assert.equal(result_3.lp_token, expected_3.lp_token, "It should get the type3 of position data lp_token.");
    Assert.equal(result_3.supply_crtoken, expected_3.supply_crtoken, "It should get the type3 of position data supply_crtoken.");
    Assert.equal(result_3.borrowed_crtoken_a, expected_3.borrowed_crtoken_a, "It should get the type3 of position data borrowed_crtoken_a.");
    Assert.equal(result_3.borrowed_crtoken_b, expected_3.borrowed_crtoken_b, "It should get the type3 of position data borrowed_crtoken_b.");
    Assert.equal(result_3.funds_percentage, expected_3.funds_percentage, "It should get the type3 of position data funds_percentage.");
    Assert.equal(result_3.total_depts, expected_3.total_depts, "It should get the type3 of position data total_depts.");
  }

  function testExitPosition() public {
    // Testing
    HighLevelSystem.Position memory  result_1 = HighLevelSystem.exitPosition(HLSConfig, Position, 1);
    HighLevelSystem.Position memory  result_2 = HighLevelSystem.exitPosition(HLSConfig, Position, 2);
    HighLevelSystem.Position memory  result_3 = HighLevelSystem.exitPosition(HLSConfig, Position, 3);
    HighLevelSystem.Position memory expected_1 = HighLevelSystem.Position({
      pool_id: 10,
      token_amount: 10,
      token_a_amount: 100000000000000000000,
      token_b_amount: 100000000000000000000,
      lp_token_amount: 10,
      crtoken_amount: 1000000000000000000000,
      supply_amount: 0,
      liquidity_a: 0,
      liquidity_b: 0,
      borrowed_token_a_amount: 0,
      borrowed_token_b_amount: 0,
      token: FakeIBEP20Address,
      token_a: FakeIBEP20Address,
      token_b: FakeIBEP20Address,
      lp_token: FakePancakePairAddress,
      supply_crtoken: FakeCErc20DelegatorAddress,
      borrowed_crtoken_a: FakeCErc20DelegatorAddress,
      borrowed_crtoken_b: FakeCErc20DelegatorAddress,
      funds_percentage: 95,
      total_depts: 10
    });
    HighLevelSystem.Position memory expected_2 = HighLevelSystem.Position({
      pool_id: 10,
      token_amount: 10,
      token_a_amount: 100000000000000000000,
      token_b_amount: 100000000000000000000,
      lp_token_amount: 10,
      crtoken_amount: 10,
      supply_amount: 10,
      liquidity_a: 0,
      liquidity_b: 0,
      borrowed_token_a_amount: 0,
      borrowed_token_b_amount: 0,
      token: FakeIBEP20Address,
      token_a: FakeIBEP20Address,
      token_b: FakeIBEP20Address,
      lp_token: FakePancakePairAddress,
      supply_crtoken: FakeCErc20DelegatorAddress,
      borrowed_crtoken_a: FakeCErc20DelegatorAddress,
      borrowed_crtoken_b: FakeCErc20DelegatorAddress,
      funds_percentage: 95,
      total_depts: 20
    });
    HighLevelSystem.Position memory expected_3 = HighLevelSystem.Position({
      pool_id: 10,
      token_amount: 10,
      token_a_amount: 100000000000000000000,
      token_b_amount: 100000000000000000000,
      lp_token_amount: 10,
      crtoken_amount: 10,
      supply_amount: 10,
      liquidity_a: 0,
      liquidity_b: 0,
      borrowed_token_a_amount: 0,
      borrowed_token_b_amount: 0,
      token: FakeIBEP20Address,
      token_a: FakeIBEP20Address,
      token_b: FakeIBEP20Address,
      lp_token: FakePancakePairAddress,
      supply_crtoken: FakeCErc20DelegatorAddress,
      borrowed_crtoken_a: FakeCErc20DelegatorAddress,
      borrowed_crtoken_b: FakeCErc20DelegatorAddress,
      funds_percentage: 95,
      total_depts: 20
    });

    Assert.equal(result_1.pool_id, expected_1.pool_id, "It should get the type1 of position data pool_id.");
    Assert.equal(result_1.token_amount, expected_1.token_amount, "It should get the type1 of position data token_amount.");
    Assert.equal(result_1.token_a_amount, expected_1.token_a_amount, "It should get the type1 of position data token_a_amount.");
    Assert.equal(result_1.token_b_amount, expected_1.token_b_amount, "It should get the type1 of position data token_b_amount.");
    Assert.equal(result_1.lp_token_amount, expected_1.lp_token_amount, "It should get the type1 of position data lp_token_amount.");
    Assert.equal(result_1.crtoken_amount, expected_1.crtoken_amount, "It should get the type1 of position data crtoken_amount.");
    Assert.equal(result_1.supply_amount, expected_1.supply_amount, "It should get the type1 of position data supply_amount.");
    Assert.equal(result_1.liquidity_a, expected_1.liquidity_a, "It should get the type1 of position data liquidity_a.");
    Assert.equal(result_1.liquidity_b, expected_1.liquidity_b, "It should get the type1 of position data liquidity_b.");
    Assert.equal(result_1.borrowed_token_a_amount, expected_1.borrowed_token_a_amount, "It should get the type1 of position data borrowed_token_a_amount.");
    Assert.equal(result_1.borrowed_token_b_amount, expected_1.borrowed_token_b_amount, "It should get the type1 of position data borrowed_token_b_amount.");
    Assert.equal(result_1.token, expected_1.token, "It should get the type1 of position data token.");
    Assert.equal(result_1.token_a, expected_1.token_a, "It should get the type1 of position data token_a.");
    Assert.equal(result_1.token_b, expected_1.token_b, "It should get the type1 of position data token_b.");
    Assert.equal(result_1.lp_token, expected_1.lp_token, "It should get the type1 of position data lp_token.");
    Assert.equal(result_1.supply_crtoken, expected_1.supply_crtoken, "It should get the type1 of position data supply_crtoken.");
    Assert.equal(result_1.borrowed_crtoken_a, expected_1.borrowed_crtoken_a, "It should get the type1 of position data borrowed_crtoken_a.");
    Assert.equal(result_1.borrowed_crtoken_b, expected_1.borrowed_crtoken_b, "It should get the type1 of position data borrowed_crtoken_b.");
    Assert.equal(result_1.funds_percentage, expected_1.funds_percentage, "It should get the type1 of position data funds_percentage.");
    Assert.equal(result_1.total_depts, expected_1.total_depts, "It should get the type1 of position data total_depts.");

    Assert.equal(result_2.pool_id, expected_2.pool_id, "It should get the type2 of position data pool_id.");
    Assert.equal(result_2.token_amount, expected_2.token_amount, "It should get the type2 of position data token_amount.");
    Assert.equal(result_2.token_a_amount, expected_2.token_a_amount, "It should get the type2 of position data token_a_amount.");
    Assert.equal(result_2.token_b_amount, expected_2.token_b_amount, "It should get the type2 of position data token_b_amount.");
    Assert.equal(result_2.lp_token_amount, expected_2.lp_token_amount, "It should get the type2 of position data lp_token_amount.");
    Assert.equal(result_2.crtoken_amount, expected_2.crtoken_amount, "It should get the type2 of position data crtoken_amount.");
    Assert.equal(result_2.supply_amount, expected_2.supply_amount, "It should get the type2 of position data supply_amount.");
    Assert.equal(result_2.liquidity_a, expected_2.liquidity_a, "It should get the type2 of position data liquidity_a.");
    Assert.equal(result_2.liquidity_b, expected_2.liquidity_b, "It should get the type2 of position data liquidity_b.");
    Assert.equal(result_2.borrowed_token_a_amount, expected_2.borrowed_token_a_amount, "It should get the type2 of position data borrowed_token_a_amount.");
    Assert.equal(result_2.borrowed_token_b_amount, expected_2.borrowed_token_b_amount, "It should get the type2 of position data borrowed_token_b_amount.");
    Assert.equal(result_2.token, expected_2.token, "It should get the type2 of position data token.");
    Assert.equal(result_2.token_a, expected_2.token_a, "It should get the type2 of position data token_a.");
    Assert.equal(result_2.token_b, expected_2.token_b, "It should get the type2 of position data token_b.");
    Assert.equal(result_2.lp_token, expected_2.lp_token, "It should get the type2 of position data lp_token.");
    Assert.equal(result_2.supply_crtoken, expected_2.supply_crtoken, "It should get the type2 of position data supply_crtoken.");
    Assert.equal(result_2.borrowed_crtoken_a, expected_2.borrowed_crtoken_a, "It should get the type2 of position data borrowed_crtoken_a.");
    Assert.equal(result_2.borrowed_crtoken_b, expected_2.borrowed_crtoken_b, "It should get the type2 of position data borrowed_crtoken_b.");
    Assert.equal(result_2.funds_percentage, expected_2.funds_percentage, "It should get the type2 of position data funds_percentage.");
    Assert.equal(result_2.total_depts, expected_2.total_depts, "It should get the type2 of position data total_depts.");

    Assert.equal(result_3.pool_id, expected_3.pool_id, "It should get the type3 of position data pool_id.");
    Assert.equal(result_3.token_amount, expected_3.token_amount, "It should get the type3 of position data token_amount.");
    Assert.equal(result_3.token_a_amount, expected_3.token_a_amount, "It should get the type3 of position data token_a_amount.");
    Assert.equal(result_3.token_b_amount, expected_3.token_b_amount, "It should get the type3 of position data token_b_amount.");
    Assert.equal(result_3.lp_token_amount, expected_3.lp_token_amount, "It should get the type3 of position data lp_token_amount.");
    Assert.equal(result_3.crtoken_amount, expected_3.crtoken_amount, "It should get the type3 of position data crtoken_amount.");
    Assert.equal(result_3.supply_amount, expected_3.supply_amount, "It should get the type3 of position data supply_amount.");
    Assert.equal(result_3.liquidity_a, expected_3.liquidity_a, "It should get the type3 of position data liquidity_a.");
    Assert.equal(result_3.liquidity_b, expected_3.liquidity_b, "It should get the type3 of position data liquidity_b.");
    Assert.equal(result_3.borrowed_token_a_amount, expected_3.borrowed_token_a_amount, "It should get the type3 of position data borrowed_token_a_amount.");
    Assert.equal(result_3.borrowed_token_b_amount, expected_3.borrowed_token_b_amount, "It should get the type3 of position data borrowed_token_b_amount.");
    Assert.equal(result_3.token, expected_3.token, "It should get the type3 of position data token.");
    Assert.equal(result_3.token_a, expected_3.token_a, "It should get the type3 of position data token_a.");
    Assert.equal(result_3.token_b, expected_3.token_b, "It should get the type3 of position data token_b.");
    Assert.equal(result_3.lp_token, expected_3.lp_token, "It should get the type3 of position data lp_token.");
    Assert.equal(result_3.supply_crtoken, expected_3.supply_crtoken, "It should get the type3 of position data supply_crtoken.");
    Assert.equal(result_3.borrowed_crtoken_a, expected_3.borrowed_crtoken_a, "It should get the type3 of position data borrowed_crtoken_a.");
    Assert.equal(result_3.borrowed_crtoken_b, expected_3.borrowed_crtoken_b, "It should get the type3 of position data borrowed_crtoken_b.");
    Assert.equal(result_3.funds_percentage, expected_3.funds_percentage, "It should get the type3 of position data funds_percentage.");
    Assert.equal(result_3.total_depts, expected_3.total_depts, "It should get the type3 of position data total_depts.");
  }

}
