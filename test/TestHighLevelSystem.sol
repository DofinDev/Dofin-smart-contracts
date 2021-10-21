// SPDX-License-Identifier: MIT
pragma solidity >=0.4.15 <0.9.0;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/libs/HighLevelSystem.sol";

contract TestHighLevelSystem {

  address public FakeFakeIBEP20Address = DeployedAddresses.FakeIBEP20();
  address public FakeCErc20DelegatorAddress = DeployedAddresses.FakeCErc20Delegator();
  address public FakePancakePairAddress = DeployedAddresses.FakePancakePair();

  address public FakeLinkBSCOracleAddress = DeployedAddresses.FakeLinkBSCOracle();
  address public FakePriceOracleProxyAddress = DeployedAddresses.FakePriceOracleProxy();
  address public FakePancakeFactoryAddress = DeployedAddresses.FakePancakeFactory();
  address public FakeMasterChefAddress = DeployedAddresses.FakeMasterChef();
  address public FakePancakeRouterAddress = DeployedAddresses.FakePancakeRouter();

  HighLevelSystem.HLSConfig private HLSConfig;
  HighLevelSystem.CreamToken private CreamToken;
  HighLevelSystem.StableCoin private StableCoin;
  HighLevelSystem.Position private Position;

  function beforeEach() public {
    HLSConfig.LinkConfig.token_oracle = FakeLinkBSCOracleAddress;
    HLSConfig.LinkConfig.token_a_oracle = FakeLinkBSCOracleAddress;
    HLSConfig.LinkConfig.token_b_oracle = FakeLinkBSCOracleAddress;
    HLSConfig.LinkConfig.cake_oracle = FakeLinkBSCOracleAddress;
    HLSConfig.CreamConfig.oracle = FakePriceOracleProxyAddress;
    HLSConfig.PancakeSwapConfig.router = FakePancakeRouterAddress;
    HLSConfig.PancakeSwapConfig.factory = FakePancakeFactoryAddress;
    HLSConfig.PancakeSwapConfig.masterchef = FakeMasterChefAddress;

    CreamToken = HighLevelSystem.CreamToken({
      crWBNB: address(0),
      crBNB: address(0),
      crUSDC: FakeCErc20DelegatorAddress
    });

    StableCoin = HighLevelSystem.StableCoin({
      WBNB: address(0),
      CAKE: address(0),
      USDT: FakeFakeIBEP20Address,
      TUSD: address(0),
      BUSD: address(0),
      USDC: FakeFakeIBEP20Address
    });

    Position = HighLevelSystem.Position({
      pool_id: 10,
      token_amount: 10,
      token_a_amount: 10,
      token_b_amount: 10,
      lp_token_amount: 10,
      crtoken_amount: 10,
      supply_crtoken_amount: 10,
      token: FakeFakeIBEP20Address,
      token_a: FakeFakeIBEP20Address,
      token_b: FakeFakeIBEP20Address,
      lp_token: FakePancakePairAddress,
      supply_crtoken: FakeCErc20DelegatorAddress,
      borrowed_crtoken_a: FakeCErc20DelegatorAddress,
      borrowed_crtoken_b: FakeCErc20DelegatorAddress,
      max_amount_per_position: 10,
      supply_funds_percentage: 95
    });
  }

  function testEnter() public {
    // Testing
    bool result = HighLevelSystem.enter(HLSConfig, CreamToken, StableCoin, Position);
    bool expected = true;

    Assert.equal(result, expected, "It should get the bool true.");
  }

  function testGetChainLinkValues() public {
    // Parms
    uint token_a_amount = 10;
    uint token_b_amount = 10;
    // Testing
    (uint result_1, uint result_2) = HighLevelSystem.getChainLinkValues(HLSConfig, token_a_amount, token_b_amount);
    uint expected = 10;

    Assert.equal(result_1, expected, "It should get the value 10 of amount out.");
    Assert.equal(result_2, expected, "It should get the value 10 of amount out.");
  }

  function testGetCakeChainLinkValue() public {
    // Parms
    uint cake_amount = 10;
    // Testing
    uint result = HighLevelSystem.getCakeChainLinkValue(HLSConfig, cake_amount);
    uint expected = 10;

    Assert.equal(result, expected, "It should get the value 10 of amount out.");
  }

  function testGetPancakeSwapAmountOut() public {
    // Parms
    address _token_a = FakeFakeIBEP20Address;
    address _token_b = FakeFakeIBEP20Address;
    uint _amountIn = 10;
    // Testing
    uint result = HighLevelSystem.getPancakeSwapAmountOut(HLSConfig, _token_a, _token_b, _amountIn);
    uint expected = 10;

    Assert.equal(result, expected, "It should get the value 10 of amount out.");
  }

  function testExit() public {
    // Testing
    bool result = HighLevelSystem.exit(HLSConfig, StableCoin, Position);
    bool expected = true;

    Assert.equal(result, expected, "It should get the bool of true.");
  }

  function testGetTotalBorrowAmount() public {
    // Parms
    address _crtoken_a = FakeCErc20DelegatorAddress;
    address _crtoken_b = FakeCErc20DelegatorAddress;
    // Testing
    (uint result_1, uint result_2) = HighLevelSystem.getTotalBorrowAmount(CreamToken, _crtoken_a, _crtoken_b);
    uint expected_1 = 10;
    uint expected_2 = 10;

    Assert.equal(result_1, expected_1, "It should get the value 10 of borrow amount.");
    Assert.equal(result_2, expected_2, "It should get the value 10 of borrow amount.");
  }

  function testGetTotalCakePendingRewards() public {
    // Parms
    uint _pool_id = 10;
    // Testing
    uint result = HighLevelSystem.getTotalCakePendingRewards(HLSConfig, _pool_id);
    uint expected = 10;

    Assert.equal(result, expected, "It should get the value 10 of total cake rewards.");
  }

  function testSupplyCream() public {
    // Parms
    address _crtoken = FakeCErc20DelegatorAddress;
    uint _amount = 10;
    // Testing
    uint result = HighLevelSystem.supplyCream(_crtoken, _amount);
    uint expected = 10;

    Assert.equal(result, expected, "It should get the value 10 of supply amount.");
  }

  function testRedeemCream() public {
    // Parms
    address _crtoken = FakeCErc20DelegatorAddress;
    uint _amount = 10;
    // Testing
    uint result = HighLevelSystem.redeemCream(_crtoken, _amount);
    uint expected = 10;

    Assert.equal(result, expected, "It should get the value 10 of redeem amount.");
  }

  function testEnterPosition() public {
    // Testing
    HighLevelSystem.Position memory  result_1 = HighLevelSystem.enterPosition(HLSConfig, CreamToken, StableCoin, Position, 1);
    HighLevelSystem.Position memory  result_2 = HighLevelSystem.enterPosition(HLSConfig, CreamToken, StableCoin, Position, 2);
    HighLevelSystem.Position memory  result_3 = HighLevelSystem.enterPosition(HLSConfig, CreamToken, StableCoin, Position, 3);
    HighLevelSystem.Position memory expected_1 = HighLevelSystem.Position({
      pool_id: 10,
      token_amount: 10,
      token_a_amount: 10,
      token_b_amount: 10,
      lp_token_amount: 10,
      crtoken_amount: 1000000000000000000000,
      supply_crtoken_amount: 10,
      token: FakeFakeIBEP20Address,
      token_a: FakeFakeIBEP20Address,
      token_b: FakeFakeIBEP20Address,
      lp_token: FakePancakePairAddress,
      supply_crtoken: FakeCErc20DelegatorAddress,
      borrowed_crtoken_a: FakeCErc20DelegatorAddress,
      borrowed_crtoken_b: FakeCErc20DelegatorAddress,
      max_amount_per_position: 10,
      supply_funds_percentage: 95
    });
    HighLevelSystem.Position memory expected_2 = HighLevelSystem.Position({
      pool_id: 10,
      token_amount: 10,
      token_a_amount: 10,
      token_b_amount: 10,
      lp_token_amount: 10,
      crtoken_amount: 10,
      supply_crtoken_amount: 10,
      token: FakeFakeIBEP20Address,
      token_a: FakeFakeIBEP20Address,
      token_b: FakeFakeIBEP20Address,
      lp_token: FakePancakePairAddress,
      supply_crtoken: FakeCErc20DelegatorAddress,
      borrowed_crtoken_a: FakeCErc20DelegatorAddress,
      borrowed_crtoken_b: FakeCErc20DelegatorAddress,
      max_amount_per_position: 10,
      supply_funds_percentage: 95
    });
    HighLevelSystem.Position memory expected_3 = HighLevelSystem.Position({
      pool_id: 10,
      token_amount: 10,
      token_a_amount: 10,
      token_b_amount: 10,
      lp_token_amount: 10,
      crtoken_amount: 10,
      supply_crtoken_amount: 10,
      token: FakeFakeIBEP20Address,
      token_a: FakeFakeIBEP20Address,
      token_b: FakeFakeIBEP20Address,
      lp_token: FakePancakePairAddress,
      supply_crtoken: FakeCErc20DelegatorAddress,
      borrowed_crtoken_a: FakeCErc20DelegatorAddress,
      borrowed_crtoken_b: FakeCErc20DelegatorAddress,
      max_amount_per_position: 10,
      supply_funds_percentage: 95
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
    Assert.equal(result_1.max_amount_per_position, expected_1.max_amount_per_position, "It should get the type1 of position data max_amount_per_position.");
    Assert.equal(result_1.supply_funds_percentage, expected_1.supply_funds_percentage, "It should get the type1 of position data supply_funds_percentage.");

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
    Assert.equal(result_2.max_amount_per_position, expected_2.max_amount_per_position, "It should get the type2 of position data max_amount_per_position.");
    Assert.equal(result_2.supply_funds_percentage, expected_2.supply_funds_percentage, "It should get the type2 of position data supply_funds_percentage.");

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
    Assert.equal(result_3.max_amount_per_position, expected_3.max_amount_per_position, "It should get the type3 of position data max_amount_per_position.");
    Assert.equal(result_3.supply_funds_percentage, expected_3.supply_funds_percentage, "It should get the type3 of position data supply_funds_percentage.");
  }

  function testExitPosition() public {
    // Testing
    HighLevelSystem.exitPosition(HLSConfig, CreamToken, StableCoin, Position, 1);
    HighLevelSystem.exitPosition(HLSConfig, CreamToken, StableCoin, Position, 2);
    HighLevelSystem.exitPosition(HLSConfig, CreamToken, StableCoin, Position, 3);
  }

  function testReturnBorrow() public {
    // Testing
    HighLevelSystem.returnBorrow(CreamToken, StableCoin, Position);
  }

  function testBorrowPosition() public {
    // Testing
    HighLevelSystem.borrowPosition(Position);
  }

  function testIsWBNB() public {
    // Parms
    address _token_a = FakeFakeIBEP20Address;
    address _token_b = FakeFakeIBEP20Address;
    // Testing
    uint result = HighLevelSystem.isWBNB(StableCoin, _token_a, _token_a);
    uint expected = 2;

    Assert.equal(result, expected, "It should get the value 1 if is WBNB.");
  }

  function testCheckCurrentBorrowLimit() public {
    // Testing
    uint result = HighLevelSystem.checkCurrentBorrowLimit(HLSConfig, CreamToken, StableCoin, Position);
    uint expected = 0;

    Assert.equal(result, expected, "It should get the value 0 of current borrow limit.");
  }

  function testGetCreamUserTotalSupply() public {
    // Parms
    address _crtoken = FakeCErc20DelegatorAddress;
    // Testing
    uint result = HighLevelSystem.getCreamUserTotalSupply(_crtoken);
    uint expected = 100000000000000;

    Assert.equal(result, expected, "It should get the value 100000000000000 of user total supply.");
  }

  function testAddLiquidity() public {
    // Testing
    uint result = HighLevelSystem.addLiquidity(HLSConfig, CreamToken, StableCoin, Position);
    uint expected = 10;

    Assert.equal(result, expected, "It should get the value 10 of potential borrow limit.");
  }

  function testRemoveLiquidity() public {
    // Testing
    bool result = HighLevelSystem.removeLiquidity(HLSConfig, StableCoin, Position);
    bool expected = true;

    Assert.equal(result, expected, "It should get the bool of true.");
  }

  function testStakeLP() public {
    // Testing
    bool result = HighLevelSystem.stakeLP(HLSConfig, Position);
    bool expected = true;

    Assert.equal(result, expected, "It should get the bool of true.");
  }

  function testUnstakeLP() public {
    // Testing
    bool result = HighLevelSystem.unstakeLP(HLSConfig, Position);
    bool expected = true;

    Assert.equal(result, expected, "It should get the bool of true.");
  }

  function testGetStakedTokens() public {
    // Testing
    (uint result_1, uint result_2) = HighLevelSystem.getStakedTokens(HLSConfig, Position);
    uint expected_1 = 10;
    uint expected_2 = 10;

    Assert.equal(result_1, expected_1, "It should get the value 10 of staked token 1.");
    Assert.equal(result_2, expected_2, "It should get the value 10 of staked token 2.");
  }

}
