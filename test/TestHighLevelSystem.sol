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

    Position = HighLevelSystem.Position({
      pool_id: 10,
      token_amount: 10,
      token_a_amount: 10,
      token_b_amount: 10,
      lp_token_amount: 10,
      crtoken_amount: 10,
      supply_crtoken_amount: 10,
      token: FakeIBEP20Address,
      token_a: FakeIBEP20Address,
      token_b: FakeIBEP20Address,
      lp_token: FakePancakePairAddress,
      supply_crtoken: FakeCErc20DelegatorAddress,
      borrowed_crtoken_a: FakeCErc20DelegatorAddress,
      borrowed_crtoken_b: FakeCErc20DelegatorAddress,
      supply_funds_percentage: 95,
      total_depts: 0
    });
  }

  // function testSupplyCream() public {

  //   HighLevelSystem.Position memory result_1 = HighLevelSystem._supplyCream(Position);
  //   HighLevelSystem.Position memory expected_1 = HighLevelSystem.Position({
  //     pool_id: 10,
  //     token_amount: 10,
  //     token_a_amount: 10,
  //     token_b_amount: 10,
  //     lp_token_amount: 10,
  //     crtoken_amount: 1000000000000000000000,
  //     supply_crtoken_amount: 0,
  //     token: FakeIBEP20Address,
  //     token_a: FakeIBEP20Address,
  //     token_b: FakeIBEP20Address,
  //     lp_token: FakePancakePairAddress,
  //     supply_crtoken: FakeCErc20DelegatorAddress,
  //     borrowed_crtoken_a: FakeCErc20DelegatorAddress,
  //     borrowed_crtoken_b: FakeCErc20DelegatorAddress,
  //     supply_funds_percentage: 95,
  //     total_depts: 0
  //   });
    
  //   Assert.equal(result_1.pool_id, expected_1.pool_id, "It should get the type1 of position data pool_id.");
  //   Assert.equal(result_1.token_amount, expected_1.token_amount, "It should get the type1 of position data token_amount.");
  //   Assert.equal(result_1.token_a_amount, expected_1.token_a_amount, "It should get the type1 of position data token_a_amount.");
  //   Assert.equal(result_1.token_b_amount, expected_1.token_b_amount, "It should get the type1 of position data token_b_amount.");
  //   Assert.equal(result_1.lp_token_amount, expected_1.lp_token_amount, "It should get the type1 of position data lp_token_amount.");
  //   Assert.equal(result_1.crtoken_amount, expected_1.crtoken_amount, "It should get the type1 of position data crtoken_amount.");
  //   Assert.equal(result_1.supply_crtoken_amount, expected_1.supply_crtoken_amount, "It should get the type1 of position data supply_crtoken_amount.");
  //   Assert.equal(result_1.token, expected_1.token, "It should get the type1 of position data token.");
  //   Assert.equal(result_1.token_a, expected_1.token_a, "It should get the type1 of position data token_a.");
  //   Assert.equal(result_1.token_b, expected_1.token_b, "It should get the type1 of position data token_b.");
  //   Assert.equal(result_1.lp_token, expected_1.lp_token, "It should get the type1 of position data lp_token.");
  //   Assert.equal(result_1.supply_crtoken, expected_1.supply_crtoken, "It should get the type1 of position data supply_crtoken.");
  //   Assert.equal(result_1.borrowed_crtoken_a, expected_1.borrowed_crtoken_a, "It should get the type1 of position data borrowed_crtoken_a.");
  //   Assert.equal(result_1.borrowed_crtoken_b, expected_1.borrowed_crtoken_b, "It should get the type1 of position data borrowed_crtoken_b.");
  //   Assert.equal(result_1.supply_funds_percentage, expected_1.supply_funds_percentage, "It should get the type1 of position data supply_funds_percentage.");
  //   Assert.equal(result_1.total_depts, expected_1.total_depts, "It should get the type1 of position data total_depts.");
  // }

  // function testBorrow() public {

  //   HighLevelSystem.Position memory result_1 = HighLevelSystem._borrow(HLSConfig, Position);
  //   HighLevelSystem.Position memory expected_1 = HighLevelSystem.Position({
  //     pool_id: 10,
  //     token_amount: 10,
  //     token_a_amount: 10,
  //     token_b_amount: 10,
  //     lp_token_amount: 10,
  //     crtoken_amount: 10,
  //     supply_crtoken_amount: 10,
  //     token: FakeIBEP20Address,
  //     token_a: FakeIBEP20Address,
  //     token_b: FakeIBEP20Address,
  //     lp_token: FakePancakePairAddress,
  //     supply_crtoken: FakeCErc20DelegatorAddress,
  //     borrowed_crtoken_a: FakeCErc20DelegatorAddress,
  //     borrowed_crtoken_b: FakeCErc20DelegatorAddress,
  //     supply_funds_percentage: 95,
  //     total_depts: 0
  //   });
    
  //   Assert.equal(result_1.pool_id, expected_1.pool_id, "It should get the type1 of position data pool_id.");
  //   Assert.equal(result_1.token_amount, expected_1.token_amount, "It should get the type1 of position data token_amount.");
  //   Assert.equal(result_1.token_a_amount, expected_1.token_a_amount, "It should get the type1 of position data token_a_amount.");
  //   Assert.equal(result_1.token_b_amount, expected_1.token_b_amount, "It should get the type1 of position data token_b_amount.");
  //   Assert.equal(result_1.lp_token_amount, expected_1.lp_token_amount, "It should get the type1 of position data lp_token_amount.");
  //   Assert.equal(result_1.crtoken_amount, expected_1.crtoken_amount, "It should get the type1 of position data crtoken_amount.");
  //   Assert.equal(result_1.supply_crtoken_amount, expected_1.supply_crtoken_amount, "It should get the type1 of position data supply_crtoken_amount.");
  //   Assert.equal(result_1.token, expected_1.token, "It should get the type1 of position data token.");
  //   Assert.equal(result_1.token_a, expected_1.token_a, "It should get the type1 of position data token_a.");
  //   Assert.equal(result_1.token_b, expected_1.token_b, "It should get the type1 of position data token_b.");
  //   Assert.equal(result_1.lp_token, expected_1.lp_token, "It should get the type1 of position data lp_token.");
  //   Assert.equal(result_1.supply_crtoken, expected_1.supply_crtoken, "It should get the type1 of position data supply_crtoken.");
  //   Assert.equal(result_1.borrowed_crtoken_a, expected_1.borrowed_crtoken_a, "It should get the type1 of position data borrowed_crtoken_a.");
  //   Assert.equal(result_1.borrowed_crtoken_b, expected_1.borrowed_crtoken_b, "It should get the type1 of position data borrowed_crtoken_b.");
  //   Assert.equal(result_1.supply_funds_percentage, expected_1.supply_funds_percentage, "It should get the type1 of position data supply_funds_percentage.");
  //   Assert.equal(result_1.total_depts, expected_1.total_depts, "It should get the type1 of position data total_depts.");
  // }

  // function testAddLiquidity() public {

  //   HighLevelSystem.Position memory result_1 = HighLevelSystem._addLiquidity(HLSConfig, Position);
  //   HighLevelSystem.Position memory expected_1 = HighLevelSystem.Position({
  //     pool_id: 10,
  //     token_amount: 10,
  //     token_a_amount: 10,
  //     token_b_amount: 10,
  //     lp_token_amount: 10,
  //     crtoken_amount: 10,
  //     supply_crtoken_amount: 10,
  //     token: FakeIBEP20Address,
  //     token_a: FakeIBEP20Address,
  //     token_b: FakeIBEP20Address,
  //     lp_token: FakePancakePairAddress,
  //     supply_crtoken: FakeCErc20DelegatorAddress,
  //     borrowed_crtoken_a: FakeCErc20DelegatorAddress,
  //     borrowed_crtoken_b: FakeCErc20DelegatorAddress,
  //     supply_funds_percentage: 95,
  //     total_depts: 0
  //   });
    
  //   Assert.equal(result_1.pool_id, expected_1.pool_id, "It should get the type1 of position data pool_id.");
  //   Assert.equal(result_1.token_amount, expected_1.token_amount, "It should get the type1 of position data token_amount.");
  //   Assert.equal(result_1.token_a_amount, expected_1.token_a_amount, "It should get the type1 of position data token_a_amount.");
  //   Assert.equal(result_1.token_b_amount, expected_1.token_b_amount, "It should get the type1 of position data token_b_amount.");
  //   Assert.equal(result_1.lp_token_amount, expected_1.lp_token_amount, "It should get the type1 of position data lp_token_amount.");
  //   Assert.equal(result_1.crtoken_amount, expected_1.crtoken_amount, "It should get the type1 of position data crtoken_amount.");
  //   Assert.equal(result_1.supply_crtoken_amount, expected_1.supply_crtoken_amount, "It should get the type1 of position data supply_crtoken_amount.");
  //   Assert.equal(result_1.token, expected_1.token, "It should get the type1 of position data token.");
  //   Assert.equal(result_1.token_a, expected_1.token_a, "It should get the type1 of position data token_a.");
  //   Assert.equal(result_1.token_b, expected_1.token_b, "It should get the type1 of position data token_b.");
  //   Assert.equal(result_1.lp_token, expected_1.lp_token, "It should get the type1 of position data lp_token.");
  //   Assert.equal(result_1.supply_crtoken, expected_1.supply_crtoken, "It should get the type1 of position data supply_crtoken.");
  //   Assert.equal(result_1.borrowed_crtoken_a, expected_1.borrowed_crtoken_a, "It should get the type1 of position data borrowed_crtoken_a.");
  //   Assert.equal(result_1.borrowed_crtoken_b, expected_1.borrowed_crtoken_b, "It should get the type1 of position data borrowed_crtoken_b.");
  //   Assert.equal(result_1.supply_funds_percentage, expected_1.supply_funds_percentage, "It should get the type1 of position data supply_funds_percentage.");
  //   Assert.equal(result_1.total_depts, expected_1.total_depts, "It should get the type1 of position data total_depts.");
  // }

  // function testStake() public {

  //   HighLevelSystem.Position memory result_1 = HighLevelSystem._stake(HLSConfig, Position);
  //   HighLevelSystem.Position memory expected_1 = HighLevelSystem.Position({
  //     pool_id: 10,
  //     token_amount: 10,
  //     token_a_amount: 10,
  //     token_b_amount: 10,
  //     lp_token_amount: 10,
  //     crtoken_amount: 10,
  //     supply_crtoken_amount: 10,
  //     token: FakeIBEP20Address,
  //     token_a: FakeIBEP20Address,
  //     token_b: FakeIBEP20Address,
  //     lp_token: FakePancakePairAddress,
  //     supply_crtoken: FakeCErc20DelegatorAddress,
  //     borrowed_crtoken_a: FakeCErc20DelegatorAddress,
  //     borrowed_crtoken_b: FakeCErc20DelegatorAddress,
  //     supply_funds_percentage: 95,
  //     total_depts: 0
  //   });

  //   Assert.equal(result_1.pool_id, expected_1.pool_id, "It should get the type1 of position data pool_id.");
  //   Assert.equal(result_1.token_amount, expected_1.token_amount, "It should get the type1 of position data token_amount.");
  //   Assert.equal(result_1.token_a_amount, expected_1.token_a_amount, "It should get the type1 of position data token_a_amount.");
  //   Assert.equal(result_1.token_b_amount, expected_1.token_b_amount, "It should get the type1 of position data token_b_amount.");
  //   Assert.equal(result_1.lp_token_amount, expected_1.lp_token_amount, "It should get the type1 of position data lp_token_amount.");
  //   Assert.equal(result_1.crtoken_amount, expected_1.crtoken_amount, "It should get the type1 of position data crtoken_amount.");
  //   Assert.equal(result_1.supply_crtoken_amount, expected_1.supply_crtoken_amount, "It should get the type1 of position data supply_crtoken_amount.");
  //   Assert.equal(result_1.token, expected_1.token, "It should get the type1 of position data token.");
  //   Assert.equal(result_1.token_a, expected_1.token_a, "It should get the type1 of position data token_a.");
  //   Assert.equal(result_1.token_b, expected_1.token_b, "It should get the type1 of position data token_b.");
  //   Assert.equal(result_1.lp_token, expected_1.lp_token, "It should get the type1 of position data lp_token.");
  //   Assert.equal(result_1.supply_crtoken, expected_1.supply_crtoken, "It should get the type1 of position data supply_crtoken.");
  //   Assert.equal(result_1.borrowed_crtoken_a, expected_1.borrowed_crtoken_a, "It should get the type1 of position data borrowed_crtoken_a.");
  //   Assert.equal(result_1.borrowed_crtoken_b, expected_1.borrowed_crtoken_b, "It should get the type1 of position data borrowed_crtoken_b.");
  //   Assert.equal(result_1.supply_funds_percentage, expected_1.supply_funds_percentage, "It should get the type1 of position data supply_funds_percentage.");
  //   Assert.equal(result_1.total_depts, expected_1.total_depts, "It should get the type1 of position data total_depts.");
  // }

  // function testRedeemCream() public {

  //   HighLevelSystem.Position memory result_1 = HighLevelSystem._redeemCream(Position);
  //   HighLevelSystem.Position memory expected_1 = HighLevelSystem.Position({
  //     pool_id: 10,
  //     token_amount: 10,
  //     token_a_amount: 10,
  //     token_b_amount: 10,
  //     lp_token_amount: 10,
  //     crtoken_amount: 1000000000000000000000,
  //     supply_crtoken_amount: 0,
  //     token: FakeIBEP20Address,
  //     token_a: FakeIBEP20Address,
  //     token_b: FakeIBEP20Address,
  //     lp_token: FakePancakePairAddress,
  //     supply_crtoken: FakeCErc20DelegatorAddress,
  //     borrowed_crtoken_a: FakeCErc20DelegatorAddress,
  //     borrowed_crtoken_b: FakeCErc20DelegatorAddress,
  //     supply_funds_percentage: 95,
  //     total_depts: 0
  //   });
    
  //   Assert.equal(result_1.pool_id, expected_1.pool_id, "It should get the type1 of position data pool_id.");
  //   Assert.equal(result_1.token_amount, expected_1.token_amount, "It should get the type1 of position data token_amount.");
  //   Assert.equal(result_1.token_a_amount, expected_1.token_a_amount, "It should get the type1 of position data token_a_amount.");
  //   Assert.equal(result_1.token_b_amount, expected_1.token_b_amount, "It should get the type1 of position data token_b_amount.");
  //   Assert.equal(result_1.lp_token_amount, expected_1.lp_token_amount, "It should get the type1 of position data lp_token_amount.");
  //   Assert.equal(result_1.crtoken_amount, expected_1.crtoken_amount, "It should get the type1 of position data crtoken_amount.");
  //   Assert.equal(result_1.supply_crtoken_amount, expected_1.supply_crtoken_amount, "It should get the type1 of position data supply_crtoken_amount.");
  //   Assert.equal(result_1.token, expected_1.token, "It should get the type1 of position data token.");
  //   Assert.equal(result_1.token_a, expected_1.token_a, "It should get the type1 of position data token_a.");
  //   Assert.equal(result_1.token_b, expected_1.token_b, "It should get the type1 of position data token_b.");
  //   Assert.equal(result_1.lp_token, expected_1.lp_token, "It should get the type1 of position data lp_token.");
  //   Assert.equal(result_1.supply_crtoken, expected_1.supply_crtoken, "It should get the type1 of position data supply_crtoken.");
  //   Assert.equal(result_1.borrowed_crtoken_a, expected_1.borrowed_crtoken_a, "It should get the type1 of position data borrowed_crtoken_a.");
  //   Assert.equal(result_1.borrowed_crtoken_b, expected_1.borrowed_crtoken_b, "It should get the type1 of position data borrowed_crtoken_b.");
  //   Assert.equal(result_1.supply_funds_percentage, expected_1.supply_funds_percentage, "It should get the type1 of position data supply_funds_percentage.");
  //   Assert.equal(result_1.total_depts, expected_1.total_depts, "It should get the type1 of position data total_depts.");
  // }

  // function testRepay() public {

  //   HighLevelSystem.Position memory result_1 = HighLevelSystem._repay(Position);
  //   HighLevelSystem.Position memory expected_1 = HighLevelSystem.Position({
  //     pool_id: 10,
  //     token_amount: 10,
  //     token_a_amount: 10,
  //     token_b_amount: 10,
  //     lp_token_amount: 10,
  //     crtoken_amount: 10,
  //     supply_crtoken_amount: 10,
  //     token: FakeIBEP20Address,
  //     token_a: FakeIBEP20Address,
  //     token_b: FakeIBEP20Address,
  //     lp_token: FakePancakePairAddress,
  //     supply_crtoken: FakeCErc20DelegatorAddress,
  //     borrowed_crtoken_a: FakeCErc20DelegatorAddress,
  //     borrowed_crtoken_b: FakeCErc20DelegatorAddress,
  //     supply_funds_percentage: 95,
  //     total_depts: 0
  //   });
    
  //   Assert.equal(result_1.pool_id, expected_1.pool_id, "It should get the type1 of position data pool_id.");
  //   Assert.equal(result_1.token_amount, expected_1.token_amount, "It should get the type1 of position data token_amount.");
  //   Assert.equal(result_1.token_a_amount, expected_1.token_a_amount, "It should get the type1 of position data token_a_amount.");
  //   Assert.equal(result_1.token_b_amount, expected_1.token_b_amount, "It should get the type1 of position data token_b_amount.");
  //   Assert.equal(result_1.lp_token_amount, expected_1.lp_token_amount, "It should get the type1 of position data lp_token_amount.");
  //   Assert.equal(result_1.crtoken_amount, expected_1.crtoken_amount, "It should get the type1 of position data crtoken_amount.");
  //   Assert.equal(result_1.supply_crtoken_amount, expected_1.supply_crtoken_amount, "It should get the type1 of position data supply_crtoken_amount.");
  //   Assert.equal(result_1.token, expected_1.token, "It should get the type1 of position data token.");
  //   Assert.equal(result_1.token_a, expected_1.token_a, "It should get the type1 of position data token_a.");
  //   Assert.equal(result_1.token_b, expected_1.token_b, "It should get the type1 of position data token_b.");
  //   Assert.equal(result_1.lp_token, expected_1.lp_token, "It should get the type1 of position data lp_token.");
  //   Assert.equal(result_1.supply_crtoken, expected_1.supply_crtoken, "It should get the type1 of position data supply_crtoken.");
  //   Assert.equal(result_1.borrowed_crtoken_a, expected_1.borrowed_crtoken_a, "It should get the type1 of position data borrowed_crtoken_a.");
  //   Assert.equal(result_1.borrowed_crtoken_b, expected_1.borrowed_crtoken_b, "It should get the type1 of position data borrowed_crtoken_b.");
  //   Assert.equal(result_1.supply_funds_percentage, expected_1.supply_funds_percentage, "It should get the type1 of position data supply_funds_percentage.");
  //   Assert.equal(result_1.total_depts, expected_1.total_depts, "It should get the type1 of position data total_depts.");
  // }

  // function testRemoveLiquidity() public {

  //   HighLevelSystem.Position memory result_1 = HighLevelSystem._removeLiquidity(HLSConfig, Position);
  //   HighLevelSystem.Position memory expected_1 = HighLevelSystem.Position({
  //     pool_id: 10,
  //     token_amount: 10,
  //     token_a_amount: 10,
  //     token_b_amount: 10,
  //     lp_token_amount: 10,
  //     crtoken_amount: 10,
  //     supply_crtoken_amount: 10,
  //     token: FakeIBEP20Address,
  //     token_a: FakeIBEP20Address,
  //     token_b: FakeIBEP20Address,
  //     lp_token: FakePancakePairAddress,
  //     supply_crtoken: FakeCErc20DelegatorAddress,
  //     borrowed_crtoken_a: FakeCErc20DelegatorAddress,
  //     borrowed_crtoken_b: FakeCErc20DelegatorAddress,
  //     supply_funds_percentage: 95,
  //     total_depts: 0
  //   });
    
  //   Assert.equal(result_1.pool_id, expected_1.pool_id, "It should get the type1 of position data pool_id.");
  //   Assert.equal(result_1.token_amount, expected_1.token_amount, "It should get the type1 of position data token_amount.");
  //   Assert.equal(result_1.token_a_amount, expected_1.token_a_amount, "It should get the type1 of position data token_a_amount.");
  //   Assert.equal(result_1.token_b_amount, expected_1.token_b_amount, "It should get the type1 of position data token_b_amount.");
  //   Assert.equal(result_1.lp_token_amount, expected_1.lp_token_amount, "It should get the type1 of position data lp_token_amount.");
  //   Assert.equal(result_1.crtoken_amount, expected_1.crtoken_amount, "It should get the type1 of position data crtoken_amount.");
  //   Assert.equal(result_1.supply_crtoken_amount, expected_1.supply_crtoken_amount, "It should get the type1 of position data supply_crtoken_amount.");
  //   Assert.equal(result_1.token, expected_1.token, "It should get the type1 of position data token.");
  //   Assert.equal(result_1.token_a, expected_1.token_a, "It should get the type1 of position data token_a.");
  //   Assert.equal(result_1.token_b, expected_1.token_b, "It should get the type1 of position data token_b.");
  //   Assert.equal(result_1.lp_token, expected_1.lp_token, "It should get the type1 of position data lp_token.");
  //   Assert.equal(result_1.supply_crtoken, expected_1.supply_crtoken, "It should get the type1 of position data supply_crtoken.");
  //   Assert.equal(result_1.borrowed_crtoken_a, expected_1.borrowed_crtoken_a, "It should get the type1 of position data borrowed_crtoken_a.");
  //   Assert.equal(result_1.borrowed_crtoken_b, expected_1.borrowed_crtoken_b, "It should get the type1 of position data borrowed_crtoken_b.");
  //   Assert.equal(result_1.supply_funds_percentage, expected_1.supply_funds_percentage, "It should get the type1 of position data supply_funds_percentage.");
  //   Assert.equal(result_1.total_depts, expected_1.total_depts, "It should get the type1 of position data total_depts.");
  // }

  // function testUnstake() public {

  //   HighLevelSystem.Position memory result_1 = HighLevelSystem._unstake(HLSConfig, Position);
  //   HighLevelSystem.Position memory expected_1 = HighLevelSystem.Position({
  //     pool_id: 10,
  //     token_amount: 10,
  //     token_a_amount: 10,
  //     token_b_amount: 10,
  //     lp_token_amount: 10,
  //     crtoken_amount: 10,
  //     supply_crtoken_amount: 10,
  //     token: FakeIBEP20Address,
  //     token_a: FakeIBEP20Address,
  //     token_b: FakeIBEP20Address,
  //     lp_token: FakePancakePairAddress,
  //     supply_crtoken: FakeCErc20DelegatorAddress,
  //     borrowed_crtoken_a: FakeCErc20DelegatorAddress,
  //     borrowed_crtoken_b: FakeCErc20DelegatorAddress,
  //     supply_funds_percentage: 95,
  //     total_depts: 0
  //   });

  //   Assert.equal(result_1.pool_id, expected_1.pool_id, "It should get the type1 of position data pool_id.");
  //   Assert.equal(result_1.token_amount, expected_1.token_amount, "It should get the type1 of position data token_amount.");
  //   Assert.equal(result_1.token_a_amount, expected_1.token_a_amount, "It should get the type1 of position data token_a_amount.");
  //   Assert.equal(result_1.token_b_amount, expected_1.token_b_amount, "It should get the type1 of position data token_b_amount.");
  //   Assert.equal(result_1.lp_token_amount, expected_1.lp_token_amount, "It should get the type1 of position data lp_token_amount.");
  //   Assert.equal(result_1.crtoken_amount, expected_1.crtoken_amount, "It should get the type1 of position data crtoken_amount.");
  //   Assert.equal(result_1.supply_crtoken_amount, expected_1.supply_crtoken_amount, "It should get the type1 of position data supply_crtoken_amount.");
  //   Assert.equal(result_1.token, expected_1.token, "It should get the type1 of position data token.");
  //   Assert.equal(result_1.token_a, expected_1.token_a, "It should get the type1 of position data token_a.");
  //   Assert.equal(result_1.token_b, expected_1.token_b, "It should get the type1 of position data token_b.");
  //   Assert.equal(result_1.lp_token, expected_1.lp_token, "It should get the type1 of position data lp_token.");
  //   Assert.equal(result_1.supply_crtoken, expected_1.supply_crtoken, "It should get the type1 of position data supply_crtoken.");
  //   Assert.equal(result_1.borrowed_crtoken_a, expected_1.borrowed_crtoken_a, "It should get the type1 of position data borrowed_crtoken_a.");
  //   Assert.equal(result_1.borrowed_crtoken_b, expected_1.borrowed_crtoken_b, "It should get the type1 of position data borrowed_crtoken_b.");
  //   Assert.equal(result_1.supply_funds_percentage, expected_1.supply_funds_percentage, "It should get the type1 of position data supply_funds_percentage.");
  //   Assert.equal(result_1.total_depts, expected_1.total_depts, "It should get the type1 of position data total_depts.");
  // }

  // function testGetCreamUserTotalSupply() public {

  //   // Params
  //   address _crtoken = FakeCErc20DelegatorAddress;
  //   // Testing
  //   uint result_1 = HighLevelSystem.getCreamUserTotalSupply(_crtoken);
  //   uint expected_1 = 100000000000000;

  //   Assert.equal(result_1, expected_1, "It should get the value 100000000000000.");
  // }

  // function testGetChainLinkValues() public {

  //   // Params
  //   uint token_a_amount = 10;
  //   uint token_b_amount = 10;
  //   // Testing
  //   (uint result_1, uint result_2) = HighLevelSystem.getChainLinkValues(HLSConfig, token_a_amount, token_b_amount);
  //   uint expected_1 = 10;
  //   uint expected_2 = 10;

  //   Assert.equal(result_1, expected_1, "It should get the value 10 of result_1.");
  //   Assert.equal(result_2, expected_2, "It should get the value 10 of result_2.");
  // }

  // function testGetCakeChainLinkValue() public {

  //   // Params
  //   uint cake_amount = 10;
  //   // Testing
  //   uint result_1 = HighLevelSystem.getCakeChainLinkValue(HLSConfig, cake_amount);
  //   uint expected_1 = 10;

  //   Assert.equal(result_1, expected_1, "It should get the value 10.");
  // }

  // function testGetTotalBorrowAmount() public {

  //   // Params
  //   address _crtoken_a = FakeCErc20DelegatorAddress;
  //   address _crtoken_b = FakeCErc20DelegatorAddress;
  //   // Testing
  //   (uint result_1, uint result_2) = HighLevelSystem.getTotalBorrowAmount(_crtoken_a, _crtoken_b);
  //   uint expected_1 = 10;
  //   uint expected_2 = 10;

  //   Assert.equal(result_1, expected_1, "It should get the value 10 of result_1.");
  //   Assert.equal(result_2, expected_2, "It should get the value 10 of result_2.");
  // }

  // function testgetStakedTokens() public {

  //   // Testing
  //   (uint result_1, uint result_2) = HighLevelSystem.getStakedTokens(Position);
  //   uint expected_1 = 10;
  //   uint expected_2 = 10;

  //   Assert.equal(result_1, expected_1, "It should get the value 10 of result_1.");
  //   Assert.equal(result_2, expected_2, "It should get the value 10 of result_2.");
  // }

  function testGetTotalDebts() public {

    // Testing
    uint result_1 = HighLevelSystem.getTotalDebts(HLSConfig, Position);
    uint expected_1 = 100000000000010;

    Assert.equal(result_1, expected_1, "It should get the value 100000000000010.");
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
      supply_crtoken_amount: 9500000000000000000,
      token: FakeIBEP20Address,
      token_a: FakeIBEP20Address,
      token_b: FakeIBEP20Address,
      lp_token: FakePancakePairAddress,
      supply_crtoken: FakeCErc20DelegatorAddress,
      borrowed_crtoken_a: FakeCErc20DelegatorAddress,
      borrowed_crtoken_b: FakeCErc20DelegatorAddress,
      supply_funds_percentage: 95,
      total_depts: 100000000000010
    });
    HighLevelSystem.Position memory expected_2 = HighLevelSystem.Position({
      pool_id: 10,
      token_amount: 10,
      token_a_amount: 100000000000000000000,
      token_b_amount: 100000000000000000000,
      lp_token_amount: 10,
      crtoken_amount: 10,
      supply_crtoken_amount: 10,
      token: FakeIBEP20Address,
      token_a: FakeIBEP20Address,
      token_b: FakeIBEP20Address,
      lp_token: FakePancakePairAddress,
      supply_crtoken: FakeCErc20DelegatorAddress,
      borrowed_crtoken_a: FakeCErc20DelegatorAddress,
      borrowed_crtoken_b: FakeCErc20DelegatorAddress,
      supply_funds_percentage: 95,
      total_depts: 100000000000010
    });
    HighLevelSystem.Position memory expected_3 = HighLevelSystem.Position({
      pool_id: 10,
      token_amount: 10,
      token_a_amount: 100000000000000000000,
      token_b_amount: 100000000000000000000,
      lp_token_amount: 10,
      crtoken_amount: 10,
      supply_crtoken_amount: 10,
      token: FakeIBEP20Address,
      token_a: FakeIBEP20Address,
      token_b: FakeIBEP20Address,
      lp_token: FakePancakePairAddress,
      supply_crtoken: FakeCErc20DelegatorAddress,
      borrowed_crtoken_a: FakeCErc20DelegatorAddress,
      borrowed_crtoken_b: FakeCErc20DelegatorAddress,
      supply_funds_percentage: 95,
      total_depts: 100000000000010
    });

    Assert.equal(result_1.pool_id, expected_1.pool_id, "It should get the type1 of position data pool_id.");
    Assert.equal(result_1.token_amount, expected_1.token_amount, "It should get the type1 of position data token_amount.");
    Assert.equal(result_1.token_a_amount, expected_1.token_a_amount, "It should get the type1 of position data token_a_amount.");
    Assert.equal(result_1.token_b_amount, expected_1.token_b_amount, "It should get the type1 of position data token_b_amount.");
    Assert.equal(result_1.lp_token_amount, expected_1.lp_token_amount, "It should get the type1 of position data lp_token_amount.");
    Assert.equal(result_1.crtoken_amount, expected_1.crtoken_amount, "It should get the type1 of position data crtoken_amount.");
    Assert.equal(result_1.supply_crtoken_amount, expected_1.supply_crtoken_amount, "It should get the type1 of position data supply_crtoken_amount.");
    Assert.equal(result_1.token, expected_1.token, "It should get the type1 of position data token.");
    Assert.equal(result_1.token_a, expected_1.token_a, "It should get the type1 of position data token_a.");
    Assert.equal(result_1.token_b, expected_1.token_b, "It should get the type1 of position data token_b.");
    Assert.equal(result_1.lp_token, expected_1.lp_token, "It should get the type1 of position data lp_token.");
    Assert.equal(result_1.supply_crtoken, expected_1.supply_crtoken, "It should get the type1 of position data supply_crtoken.");
    Assert.equal(result_1.borrowed_crtoken_a, expected_1.borrowed_crtoken_a, "It should get the type1 of position data borrowed_crtoken_a.");
    Assert.equal(result_1.borrowed_crtoken_b, expected_1.borrowed_crtoken_b, "It should get the type1 of position data borrowed_crtoken_b.");
    Assert.equal(result_1.supply_funds_percentage, expected_1.supply_funds_percentage, "It should get the type1 of position data supply_funds_percentage.");
    Assert.equal(result_1.total_depts, expected_1.total_depts, "It should get the type1 of position data total_depts.");

    Assert.equal(result_2.pool_id, expected_2.pool_id, "It should get the type2 of position data pool_id.");
    Assert.equal(result_2.token_amount, expected_2.token_amount, "It should get the type2 of position data token_amount.");
    Assert.equal(result_2.token_a_amount, expected_2.token_a_amount, "It should get the type2 of position data token_a_amount.");
    Assert.equal(result_2.token_b_amount, expected_2.token_b_amount, "It should get the type2 of position data token_b_amount.");
    Assert.equal(result_2.lp_token_amount, expected_2.lp_token_amount, "It should get the type2 of position data lp_token_amount.");
    Assert.equal(result_2.crtoken_amount, expected_2.crtoken_amount, "It should get the type2 of position data crtoken_amount.");
    Assert.equal(result_2.supply_crtoken_amount, expected_2.supply_crtoken_amount, "It should get the type2 of position data supply_crtoken_amount.");
    Assert.equal(result_2.token, expected_2.token, "It should get the type2 of position data token.");
    Assert.equal(result_2.token_a, expected_2.token_a, "It should get the type2 of position data token_a.");
    Assert.equal(result_2.token_b, expected_2.token_b, "It should get the type2 of position data token_b.");
    Assert.equal(result_2.lp_token, expected_2.lp_token, "It should get the type2 of position data lp_token.");
    Assert.equal(result_2.supply_crtoken, expected_2.supply_crtoken, "It should get the type2 of position data supply_crtoken.");
    Assert.equal(result_2.borrowed_crtoken_a, expected_2.borrowed_crtoken_a, "It should get the type2 of position data borrowed_crtoken_a.");
    Assert.equal(result_2.borrowed_crtoken_b, expected_2.borrowed_crtoken_b, "It should get the type2 of position data borrowed_crtoken_b.");
    Assert.equal(result_2.supply_funds_percentage, expected_2.supply_funds_percentage, "It should get the type2 of position data supply_funds_percentage.");
    Assert.equal(result_2.total_depts, expected_2.total_depts, "It should get the type2 of position data total_depts.");

    Assert.equal(result_3.pool_id, expected_3.pool_id, "It should get the type3 of position data pool_id.");
    Assert.equal(result_3.token_amount, expected_3.token_amount, "It should get the type3 of position data token_amount.");
    Assert.equal(result_3.token_a_amount, expected_3.token_a_amount, "It should get the type3 of position data token_a_amount.");
    Assert.equal(result_3.token_b_amount, expected_3.token_b_amount, "It should get the type3 of position data token_b_amount.");
    Assert.equal(result_3.lp_token_amount, expected_3.lp_token_amount, "It should get the type3 of position data lp_token_amount.");
    Assert.equal(result_3.crtoken_amount, expected_3.crtoken_amount, "It should get the type3 of position data crtoken_amount.");
    Assert.equal(result_3.supply_crtoken_amount, expected_3.supply_crtoken_amount, "It should get the type3 of position data supply_crtoken_amount.");
    Assert.equal(result_3.token, expected_3.token, "It should get the type3 of position data token.");
    Assert.equal(result_3.token_a, expected_3.token_a, "It should get the type3 of position data token_a.");
    Assert.equal(result_3.token_b, expected_3.token_b, "It should get the type3 of position data token_b.");
    Assert.equal(result_3.lp_token, expected_3.lp_token, "It should get the type3 of position data lp_token.");
    Assert.equal(result_3.supply_crtoken, expected_3.supply_crtoken, "It should get the type3 of position data supply_crtoken.");
    Assert.equal(result_3.borrowed_crtoken_a, expected_3.borrowed_crtoken_a, "It should get the type3 of position data borrowed_crtoken_a.");
    Assert.equal(result_3.borrowed_crtoken_b, expected_3.borrowed_crtoken_b, "It should get the type3 of position data borrowed_crtoken_b.");
    Assert.equal(result_3.supply_funds_percentage, expected_3.supply_funds_percentage, "It should get the type3 of position data supply_funds_percentage.");
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
      supply_crtoken_amount: 0,
      token: FakeIBEP20Address,
      token_a: FakeIBEP20Address,
      token_b: FakeIBEP20Address,
      lp_token: FakePancakePairAddress,
      supply_crtoken: FakeCErc20DelegatorAddress,
      borrowed_crtoken_a: FakeCErc20DelegatorAddress,
      borrowed_crtoken_b: FakeCErc20DelegatorAddress,
      supply_funds_percentage: 95,
      total_depts: 100000000000010
    });
    HighLevelSystem.Position memory expected_2 = HighLevelSystem.Position({
      pool_id: 10,
      token_amount: 10,
      token_a_amount: 100000000000000000000,
      token_b_amount: 100000000000000000000,
      lp_token_amount: 10,
      crtoken_amount: 10,
      supply_crtoken_amount: 10,
      token: FakeIBEP20Address,
      token_a: FakeIBEP20Address,
      token_b: FakeIBEP20Address,
      lp_token: FakePancakePairAddress,
      supply_crtoken: FakeCErc20DelegatorAddress,
      borrowed_crtoken_a: FakeCErc20DelegatorAddress,
      borrowed_crtoken_b: FakeCErc20DelegatorAddress,
      supply_funds_percentage: 95,
      total_depts: 100000000000010
    });
    HighLevelSystem.Position memory expected_3 = HighLevelSystem.Position({
      pool_id: 10,
      token_amount: 10,
      token_a_amount: 100000000000000000000,
      token_b_amount: 100000000000000000000,
      lp_token_amount: 10,
      crtoken_amount: 10,
      supply_crtoken_amount: 10,
      token: FakeIBEP20Address,
      token_a: FakeIBEP20Address,
      token_b: FakeIBEP20Address,
      lp_token: FakePancakePairAddress,
      supply_crtoken: FakeCErc20DelegatorAddress,
      borrowed_crtoken_a: FakeCErc20DelegatorAddress,
      borrowed_crtoken_b: FakeCErc20DelegatorAddress,
      supply_funds_percentage: 95,
      total_depts: 100000000000010
    });

    Assert.equal(result_1.pool_id, expected_1.pool_id, "It should get the type1 of position data pool_id.");
    Assert.equal(result_1.token_amount, expected_1.token_amount, "It should get the type1 of position data token_amount.");
    Assert.equal(result_1.token_a_amount, expected_1.token_a_amount, "It should get the type1 of position data token_a_amount.");
    Assert.equal(result_1.token_b_amount, expected_1.token_b_amount, "It should get the type1 of position data token_b_amount.");
    Assert.equal(result_1.lp_token_amount, expected_1.lp_token_amount, "It should get the type1 of position data lp_token_amount.");
    Assert.equal(result_1.crtoken_amount, expected_1.crtoken_amount, "It should get the type1 of position data crtoken_amount.");
    Assert.equal(result_1.supply_crtoken_amount, expected_1.supply_crtoken_amount, "It should get the type1 of position data supply_crtoken_amount.");
    Assert.equal(result_1.token, expected_1.token, "It should get the type1 of position data token.");
    Assert.equal(result_1.token_a, expected_1.token_a, "It should get the type1 of position data token_a.");
    Assert.equal(result_1.token_b, expected_1.token_b, "It should get the type1 of position data token_b.");
    Assert.equal(result_1.lp_token, expected_1.lp_token, "It should get the type1 of position data lp_token.");
    Assert.equal(result_1.supply_crtoken, expected_1.supply_crtoken, "It should get the type1 of position data supply_crtoken.");
    Assert.equal(result_1.borrowed_crtoken_a, expected_1.borrowed_crtoken_a, "It should get the type1 of position data borrowed_crtoken_a.");
    Assert.equal(result_1.borrowed_crtoken_b, expected_1.borrowed_crtoken_b, "It should get the type1 of position data borrowed_crtoken_b.");
    Assert.equal(result_1.supply_funds_percentage, expected_1.supply_funds_percentage, "It should get the type1 of position data supply_funds_percentage.");
    Assert.equal(result_1.total_depts, expected_1.total_depts, "It should get the type1 of position data total_depts.");

    Assert.equal(result_2.pool_id, expected_2.pool_id, "It should get the type2 of position data pool_id.");
    Assert.equal(result_2.token_amount, expected_2.token_amount, "It should get the type2 of position data token_amount.");
    Assert.equal(result_2.token_a_amount, expected_2.token_a_amount, "It should get the type2 of position data token_a_amount.");
    Assert.equal(result_2.token_b_amount, expected_2.token_b_amount, "It should get the type2 of position data token_b_amount.");
    Assert.equal(result_2.lp_token_amount, expected_2.lp_token_amount, "It should get the type2 of position data lp_token_amount.");
    Assert.equal(result_2.crtoken_amount, expected_2.crtoken_amount, "It should get the type2 of position data crtoken_amount.");
    Assert.equal(result_2.supply_crtoken_amount, expected_2.supply_crtoken_amount, "It should get the type2 of position data supply_crtoken_amount.");
    Assert.equal(result_2.token, expected_2.token, "It should get the type2 of position data token.");
    Assert.equal(result_2.token_a, expected_2.token_a, "It should get the type2 of position data token_a.");
    Assert.equal(result_2.token_b, expected_2.token_b, "It should get the type2 of position data token_b.");
    Assert.equal(result_2.lp_token, expected_2.lp_token, "It should get the type2 of position data lp_token.");
    Assert.equal(result_2.supply_crtoken, expected_2.supply_crtoken, "It should get the type2 of position data supply_crtoken.");
    Assert.equal(result_2.borrowed_crtoken_a, expected_2.borrowed_crtoken_a, "It should get the type2 of position data borrowed_crtoken_a.");
    Assert.equal(result_2.borrowed_crtoken_b, expected_2.borrowed_crtoken_b, "It should get the type2 of position data borrowed_crtoken_b.");
    Assert.equal(result_2.supply_funds_percentage, expected_2.supply_funds_percentage, "It should get the type2 of position data supply_funds_percentage.");
    Assert.equal(result_2.total_depts, expected_2.total_depts, "It should get the type2 of position data total_depts.");

    Assert.equal(result_3.pool_id, expected_3.pool_id, "It should get the type3 of position data pool_id.");
    Assert.equal(result_3.token_amount, expected_3.token_amount, "It should get the type3 of position data token_amount.");
    Assert.equal(result_3.token_a_amount, expected_3.token_a_amount, "It should get the type3 of position data token_a_amount.");
    Assert.equal(result_3.token_b_amount, expected_3.token_b_amount, "It should get the type3 of position data token_b_amount.");
    Assert.equal(result_3.lp_token_amount, expected_3.lp_token_amount, "It should get the type3 of position data lp_token_amount.");
    Assert.equal(result_3.crtoken_amount, expected_3.crtoken_amount, "It should get the type3 of position data crtoken_amount.");
    Assert.equal(result_3.supply_crtoken_amount, expected_3.supply_crtoken_amount, "It should get the type3 of position data supply_crtoken_amount.");
    Assert.equal(result_3.token, expected_3.token, "It should get the type3 of position data token.");
    Assert.equal(result_3.token_a, expected_3.token_a, "It should get the type3 of position data token_a.");
    Assert.equal(result_3.token_b, expected_3.token_b, "It should get the type3 of position data token_b.");
    Assert.equal(result_3.lp_token, expected_3.lp_token, "It should get the type3 of position data lp_token.");
    Assert.equal(result_3.supply_crtoken, expected_3.supply_crtoken, "It should get the type3 of position data supply_crtoken.");
    Assert.equal(result_3.borrowed_crtoken_a, expected_3.borrowed_crtoken_a, "It should get the type3 of position data borrowed_crtoken_a.");
    Assert.equal(result_3.borrowed_crtoken_b, expected_3.borrowed_crtoken_b, "It should get the type3 of position data borrowed_crtoken_b.");
    Assert.equal(result_3.supply_funds_percentage, expected_3.supply_funds_percentage, "It should get the type3 of position data supply_funds_percentage.");
    Assert.equal(result_3.total_depts, expected_3.total_depts, "It should get the type3 of position data total_depts.");
  }

}
