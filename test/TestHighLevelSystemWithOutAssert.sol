// SPDX-License-Identifier: MIT
pragma solidity >=0.4.15 <0.9.0;

import "truffle/DeployedAddresses.sol";
import "../contracts/libs/HighLevelSystem.sol";

contract TestHighLevelSystemWithOutAssert {

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
      liquidity_a: 0,
      liquidity_b: 0,
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

  function testGetTotalDebts() public {

    // Testing
    uint result_1 = HighLevelSystem.getTotalDebts(HLSConfig, Position);
  }

  function testEnterPosition1() public {
    // Testing
    HighLevelSystem.Position memory result_1 = HighLevelSystem.enterPosition(HLSConfig, Position, 1);
  }

  function testEnterPosition2() public {
    // Testing
    HighLevelSystem.Position memory result_2 = HighLevelSystem.enterPosition(HLSConfig, Position, 2);
  }

  function testEnterPosition3() public {
    // Testing
    HighLevelSystem.Position memory result_3 = HighLevelSystem.enterPosition(HLSConfig, Position, 3);
  }

  function testExitPosition1() public {
    // Testing
    HighLevelSystem.Position memory  result_1 = HighLevelSystem.exitPosition(HLSConfig, Position, 1);
  }

  function testExitPosition2() public {
    // Testing
    HighLevelSystem.Position memory  result_2 = HighLevelSystem.exitPosition(HLSConfig, Position, 2);
  }

  function testExitPosition3() public {
    // Testing
    HighLevelSystem.Position memory  result_3 = HighLevelSystem.exitPosition(HLSConfig, Position, 3);
  }

}
