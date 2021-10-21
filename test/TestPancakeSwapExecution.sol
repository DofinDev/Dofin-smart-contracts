// SPDX-License-Identifier: MIT
pragma solidity >=0.4.15 <0.9.0;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/libs/PancakeSwapExecution.sol";

contract TestPancakeSwapExecution {

  function testGetLPBalance() public {
    address FakePancakePairAddress = DeployedAddresses.FakePancakePair();

    // Parms
    address lp_token = FakePancakePairAddress;
    // Testing
    uint result = PancakeSwapExecution.getLPBalance(lp_token);
    uint expected = 10;

    Assert.equal(result, expected, "It should get the value 10 of LP token balance.");
  }

  function testGetLPTokenAddresses() public {
    address FakeFakeIBEP20Address = DeployedAddresses.FakeIBEP20();
    address FakePancakePairAddress = DeployedAddresses.FakePancakePair();

    // Parms
    address lp_token_address = FakePancakePairAddress;
    // Testing
    (address result_1, address result_2) = PancakeSwapExecution.getLPTokenAddresses(lp_token_address);
    address expected_1 = FakeFakeIBEP20Address;
    address expected_2 = FakeFakeIBEP20Address;

    Assert.equal(result_1, expected_1, "It should get the address of token0.");
    Assert.equal(result_2, expected_2, "It should get the address of token1.");
  }

  function testGetLPConstituients() public {
    address FakePancakePairAddress = DeployedAddresses.FakePancakePair();

    // Parms
    uint lp_token_amnt = 10;
    address lp_token_addr = FakePancakePairAddress;
    // Testing
    (uint result_1, uint result_2) = PancakeSwapExecution.getLPConstituients(lp_token_amnt, lp_token_addr);
    uint expected_1 = 10;
    uint expected_2 = 10;

    Assert.equal(result_1, expected_1, "It should get the value 10 of token0 amount.");
    Assert.equal(result_2, expected_2, "It should get the value 10 of token1 amount.");
  }

  function testAddLiquidityETH() public {
    address FakeFakeIBEP20Address = DeployedAddresses.FakeIBEP20();
    address FakePancakeFactoryAddress = DeployedAddresses.FakePancakeFactory();
    address FakePancakeRouterAddress = DeployedAddresses.FakePancakeRouter();

    // Parms
    address token_addr = FakeFakeIBEP20Address;
    address eth_addr = FakeFakeIBEP20Address;
    uint token_amnt = 10;
    uint eth_amnt = 0;
    PancakeSwapExecution.PancakeSwapConfig memory pancakeSwapConfig = PancakeSwapExecution.PancakeSwapConfig({
      router: FakePancakeRouterAddress,
      factory: FakePancakeFactoryAddress,
      masterchef: address(0)
    });
    // Testing
    uint result = PancakeSwapExecution.addLiquidityETH(pancakeSwapConfig, token_addr, eth_addr, token_amnt, eth_amnt);
    uint expected = 10;

    Assert.equal(result, expected, "It should get the value 10 of liquidity.");
  }

  function testAddLiquidity() public {
    address FakeFakeIBEP20Address = DeployedAddresses.FakeIBEP20();
    address FakePancakeFactoryAddress = DeployedAddresses.FakePancakeFactory();
    address FakePancakeRouterAddress = DeployedAddresses.FakePancakeRouter();

    // Parms
    address token_a_addr = FakeFakeIBEP20Address;
    address token_b_addr = FakeFakeIBEP20Address;
    uint a_amnt = 10;
    uint b_amnt = 10;
    PancakeSwapExecution.PancakeSwapConfig memory pancakeSwapConfig = PancakeSwapExecution.PancakeSwapConfig({
      router: FakePancakeRouterAddress,
      factory: FakePancakeFactoryAddress,
      masterchef: address(0)
    });
    // Testing
    uint result = PancakeSwapExecution.addLiquidity(pancakeSwapConfig, token_a_addr, token_b_addr, a_amnt, b_amnt);
    uint expected = 10;

    Assert.equal(result, expected, "It should get the value 10 of liquidity.");
  }

  function testRemoveLiquidity() public {
    address FakeFakeIBEP20Address = DeployedAddresses.FakeIBEP20();
    address FakePancakePairAddress = DeployedAddresses.FakePancakePair();
    address FakePancakeRouterAddress = DeployedAddresses.FakePancakeRouter();

    // Parms
    address lp_contract_addr = FakePancakePairAddress;
    address token_a_addr = FakeFakeIBEP20Address;
    address token_b_addr = FakeFakeIBEP20Address;
    uint liquidity = 10;
    uint a_amnt = 10;
    uint b_amnt = 10;
    PancakeSwapExecution.PancakeSwapConfig memory pancakeSwapConfig = PancakeSwapExecution.PancakeSwapConfig({
      router: FakePancakeRouterAddress,
      factory: address(0),
      masterchef: address(0)
    });
    // Testing
    PancakeSwapExecution.removeLiquidity(pancakeSwapConfig, lp_contract_addr, token_a_addr, token_b_addr, liquidity, a_amnt, b_amnt);
  }

  function testRemoveLiquidityETH() public {
    address FakeFakeIBEP20Address = DeployedAddresses.FakeIBEP20();
    address FakePancakePairAddress = DeployedAddresses.FakePancakePair();
    address FakePancakeRouterAddress = DeployedAddresses.FakePancakeRouter();

    // Parms
    address lp_contract_addr = FakePancakePairAddress;
    address token_addr = FakeFakeIBEP20Address;
    uint liquidity = 10;
    uint a_amnt = 10;
    uint b_amnt = 10;
    PancakeSwapExecution.PancakeSwapConfig memory pancakeSwapConfig = PancakeSwapExecution.PancakeSwapConfig({
      router: FakePancakeRouterAddress,
      factory: address(0),
      masterchef: address(0)
    });
    // Testing
    PancakeSwapExecution.removeLiquidityETH(pancakeSwapConfig, lp_contract_addr, token_addr, liquidity, a_amnt, b_amnt);
  }

  function testGetAmountsOut() public {
    address FakeFakeIBEP20Address = DeployedAddresses.FakeIBEP20();
    address FakePancakeFactoryAddress = DeployedAddresses.FakePancakeFactory();
    address FakePancakeRouterAddress = DeployedAddresses.FakePancakeRouter();

    // Parms
    address token_a_address = FakeFakeIBEP20Address;
    address token_b_address = FakeFakeIBEP20Address;
    uint amountIn = 10;
    PancakeSwapExecution.PancakeSwapConfig memory pancakeSwapConfig = PancakeSwapExecution.PancakeSwapConfig({
      router: FakePancakeRouterAddress,
      factory: FakePancakeFactoryAddress,
      masterchef: address(0)
    });
    // Testing
    uint result = PancakeSwapExecution.getAmountsOut(pancakeSwapConfig, token_a_address, token_b_address, amountIn);
    uint expected = 10;

    Assert.equal(result, expected, "It should get the value 10 of amountOut.");
  }

  function testGetStakedLP() public {
    address FakeMasterChefAddress = DeployedAddresses.FakeMasterChef();

    // Parms
    uint pool_id = 10;
    PancakeSwapExecution.PancakeSwapConfig memory pancakeSwapConfig = PancakeSwapExecution.PancakeSwapConfig({
      router: address(0),
      factory: address(0),
      masterchef: FakeMasterChefAddress
    });
    // Testing
    uint result = PancakeSwapExecution.getStakedLP(pancakeSwapConfig, pool_id);
    uint expected = 10;

    Assert.equal(result, expected, "It should get the value 10 of Staked LPtoken amount.");
  }

  function testGetPendingFarmRewards() public {
    address FakeMasterChefAddress = DeployedAddresses.FakeMasterChef();

    // Parms
    uint pool_id = 10;
    PancakeSwapExecution.PancakeSwapConfig memory pancakeSwapConfig = PancakeSwapExecution.PancakeSwapConfig({
      router: address(0),
      factory: address(0),
      masterchef: FakeMasterChefAddress
    });
    // Testing
    uint result = PancakeSwapExecution.getPendingFarmRewards(pancakeSwapConfig, pool_id);
    uint expected = 10;

    Assert.equal(result, expected, "It should get the value 10 of Pending Farm Rewards.");
  }

  function testUnstakeLP() public {
    address FakeMasterChefAddress = DeployedAddresses.FakeMasterChef();

    // Parms
    uint pool_id = 10;
    uint unstake_amount = 10;
    PancakeSwapExecution.PancakeSwapConfig memory pancakeSwapConfig = PancakeSwapExecution.PancakeSwapConfig({
      router: address(0),
      factory: address(0),
      masterchef: FakeMasterChefAddress
    });
    // Testing
    bool result = PancakeSwapExecution.unstakeLP(pancakeSwapConfig, pool_id, unstake_amount);
    bool expected = true;

    Assert.equal(result, expected, "It should get the bool true.");
  }

  function testStakeLP() public {
    address FakeMasterChefAddress = DeployedAddresses.FakeMasterChef();

    // Parms
    uint pool_id = 10;
    uint stake_amount = 10;
    PancakeSwapExecution.PancakeSwapConfig memory pancakeSwapConfig = PancakeSwapExecution.PancakeSwapConfig({
      router: address(0),
      factory: address(0),
      masterchef: FakeMasterChefAddress
    });
    // Testing
    bool result = PancakeSwapExecution.stakeLP(pancakeSwapConfig, pool_id, stake_amount);
    bool expected = true;

    Assert.equal(result, expected, "It should get the bool true.");
  }

}
