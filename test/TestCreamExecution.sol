pragma solidity >=0.4.15 <0.9.0;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/libs/CreamExecution.sol";

contract TestCreamExecution {

  function testGetAvailableBorrow() public {
    address FakeCErc20DelegatorAddress = DeployedAddresses.FakeCErc20Delegator();

    // Parms
    address crtoken_address = FakeCErc20DelegatorAddress;
    // Testing
    uint result = CreamExecution.getAvailableBorrow(crtoken_address);
    uint expected = 10;

    Assert.equal(result, expected, "It should get the value 10 of available borrow.");
  }

  function testGetBorrowRate() public {
    address FakeCErc20DelegatorAddress = DeployedAddresses.FakeCErc20Delegator();
    address FakeInterestRateModelAddress = DeployedAddresses.FakeInterestRateModel();

    // Parms
    address crtoken_address = FakeCErc20DelegatorAddress;
    // Testing
    uint result = CreamExecution.getBorrowRate(crtoken_address);
    uint expected = 10;

    Assert.equal(result, expected, "It should get the value 10 of borrow rate.");
  }

  function testGetSupplyRate() public {
    address FakeCErc20DelegatorAddress = DeployedAddresses.FakeCErc20Delegator();
    address FakeInterestRateModelAddress = DeployedAddresses.FakeInterestRateModel();
    
    // Parms
    address crtoken_address = FakeCErc20DelegatorAddress;
    // Testing
    uint result = CreamExecution.getSupplyRate(crtoken_address);
    uint expected = 10;

    Assert.equal(result, expected, "It should get the value 10 of supply rate.");
  }

  function testGetBorrowAmount() public {
    address FakeCErc20DelegatorAddress = DeployedAddresses.FakeCErc20Delegator();

    // Parms
    address crtoken_address = FakeCErc20DelegatorAddress;
    address crWBNB_address = address(0);
    // Testing
    uint result = CreamExecution.getBorrowAmount(crtoken_address, crWBNB_address);
    uint expected = 10;

    Assert.equal(result, expected, "It should get the value 10 of borrow amount.");
  }

  function testGetUserTotalSupply() public {
    address FakeCErc20DelegatorAddress = DeployedAddresses.FakeCErc20Delegator();

    // Parms
    address crtoken_address = FakeCErc20DelegatorAddress;
    // Testing
    uint result = CreamExecution.getUserTotalSupply(crtoken_address);
    uint expected = 10;

    Assert.equal(result, expected, "It should get the value 10 of user total supply.");
  }

  function testGetUSDCBNBPrice() public {
    address FakeCErc20DelegatorAddress = DeployedAddresses.FakeCErc20Delegator();
    address FakePriceOracleProxyAddress = DeployedAddresses.FakePriceOracleProxy();

    // Parms
    address crtoken_address = FakeCErc20DelegatorAddress;
    CreamExecution.CreamConfig memory creamConfig = CreamExecution.CreamConfig({
      oracle: FakePriceOracleProxyAddress,
      troller: address(0)
    });
    // Testing
    uint result = CreamExecution.getUSDCBNBPrice(creamConfig, crtoken_address);
    uint expected = 10;

    Assert.equal(result, expected, "It should get the value 10 of USDC BNB Price.");
  }

  function testGetTokenPrice() public {
    address FakeCErc20DelegatorAddress = DeployedAddresses.FakeCErc20Delegator();
    address FakePriceOracleProxyAddress = DeployedAddresses.FakePriceOracleProxy();

    // Parms
    address crtoken_address = FakeCErc20DelegatorAddress;
    CreamExecution.CreamConfig memory creamConfig = CreamExecution.CreamConfig({
      oracle: FakePriceOracleProxyAddress,
      troller: address(0)
    });
    // Testing
    uint result = CreamExecution.getCrTokenBalance(creamConfig, crtoken_address);
    uint expected = 10;

    Assert.equal(result, expected, "It should get the value 10 of CrToken Balance.");
  }

  function testGetCrTokenBalance() public {
    address FakeCErc20DelegatorAddress = DeployedAddresses.FakeCErc20Delegator();
    address FakePriceOracleProxyAddress = DeployedAddresses.FakePriceOracleProxy();

    // Parms
    address crtoken_address = FakeCErc20DelegatorAddress;
    CreamExecution.CreamConfig memory creamConfig = CreamExecution.CreamConfig({
      oracle: FakePriceOracleProxyAddress,
      troller: address(0)
    });
    // Testing
    uint result = CreamExecution.getTokenPrice(creamConfig, crtoken_address);
    uint expected = 10;

    Assert.equal(result, expected, "It should get the value 10 of CrToken Balance.");
  }

  function testGetExchangeRate() public {
    address FakeCErc20DelegatorAddress = DeployedAddresses.FakeCErc20Delegator();

    // Parms
    address crtoken_address = FakeCErc20DelegatorAddress;
    // Testing
    uint result = CreamExecution.getExchangeRate(crtoken_address);
    uint expected = 10;

    Assert.equal(result, expected, "It should get the value 10 of Exchange Rate.");
  }

  function testGetBorrowLimit() public {
    address FakeCErc20DelegatorAddress = DeployedAddresses.FakeCErc20Delegator();
    address FakePriceOracleProxyAddress = DeployedAddresses.FakePriceOracleProxy();
    address FakeIBEP20Address = DeployedAddresses.FakeIBEP20();

    // Parms
    address borrow_crtoken_address = FakeCErc20DelegatorAddress;
    address crUSDC_address = FakeCErc20DelegatorAddress;
    address USDC_address = FakeIBEP20Address;
    uint supply_amount = 7500000000;
    uint borrow_amount = 10;
    CreamExecution.CreamConfig memory creamConfig = CreamExecution.CreamConfig({
      oracle: FakePriceOracleProxyAddress,
      troller: address(0)
    });
    // Testing
    uint result = CreamExecution.getBorrowLimit(creamConfig, borrow_crtoken_address, crUSDC_address, USDC_address, supply_amount, borrow_amount);
    uint expected = 10;

    Assert.equal(result, expected, "It should get the value 10 of borrow limit.");
  }

  function testGetWalletAmount() public {
    address FakeCErc20DelegatorAddress = DeployedAddresses.FakeCErc20Delegator();

    // Parms
    address crtoken_address = FakeCErc20DelegatorAddress;
    // Testing
    uint result = CreamExecution.getWalletAmount(crtoken_address);
    uint expected = 10;

    Assert.equal(result, expected, "It should get the value 10 of wallet amount.");
  }

  function testBorrow() public {
    address FakeCErc20DelegatorAddress = DeployedAddresses.FakeCErc20Delegator();

    // Parms
    address crtoken_address = FakeCErc20DelegatorAddress;
    uint borrow_amount = 10;
    // Testing
    uint result = CreamExecution.borrow(crtoken_address, borrow_amount);
    uint expected = 10;

    Assert.equal(result, expected, "It should get the value 10 of borrow amount.");
  }

  function testGetUnderlyingAddress() public {
    address FakeCErc20DelegatorAddress = DeployedAddresses.FakeCErc20Delegator();
    address FakeIBEP20Address = DeployedAddresses.FakeIBEP20();

    // Parms
    address crtoken_address = FakeCErc20DelegatorAddress;
    // Testing
    address result = CreamExecution.getUnderlyingAddress(crtoken_address);
    address expected = FakeIBEP20Address;

    Assert.equal(result, expected, "It should get the address msg sender of Underlying token.");
  }

  function testGetUSDPrice() public {
    address FakeCErc20DelegatorAddress = DeployedAddresses.FakeCErc20Delegator();
    address FakePriceOracleProxyAddress = DeployedAddresses.FakePriceOracleProxy();
    address FakeIBEP20Address = DeployedAddresses.FakeIBEP20();

    // Parms
    address crtoken_address = FakeCErc20DelegatorAddress;
    address crUSDC_address = FakeCErc20DelegatorAddress;
    address USDC_address = FakeIBEP20Address;
    CreamExecution.CreamConfig memory creamConfig = CreamExecution.CreamConfig({
      oracle: FakePriceOracleProxyAddress,
      troller: address(0)
    });
    // Testing
    uint result = CreamExecution.getUSDPrice(creamConfig, crtoken_address, crUSDC_address, USDC_address);
    uint expected = 10**10;

    Assert.equal(result, expected, "It should get the value 10 power of 10 of USD Price.");
  }

  function testRepay() public {
    address FakeCErc20DelegatorAddress = DeployedAddresses.FakeCErc20Delegator();
    address FakeIBEP20Address = DeployedAddresses.FakeIBEP20();

    // Parms
    address crtoken_address = FakeCErc20DelegatorAddress;
    uint repay_amount = 10;
    // Testing
    uint result = CreamExecution.repay(crtoken_address, repay_amount);
    uint expected = 10;

    Assert.equal(result, expected, "It should get the value 10 of repay amount.");
  }

  function testRepayETH() public {
    address FakeCErc20DelegatorAddress = DeployedAddresses.FakeCErc20Delegator();

    // Parms
    address crBNB_address = FakeCErc20DelegatorAddress;
    uint repay_amount = 10;
    // Testing
    uint result = CreamExecution.repayETH(crBNB_address, repay_amount);
    uint expected = 10;

    Assert.equal(result, expected, "It should get the value 10 of repayETH amount.");
  }

  function testRepayAll() public {
    address FakeCErc20DelegatorAddress = DeployedAddresses.FakeCErc20Delegator();
    address FakeIBEP20Address = DeployedAddresses.FakeIBEP20();

    // Parms
    address token_addr = FakeIBEP20Address;
    address crtoken_address = FakeCErc20DelegatorAddress;
    address crWBNB_address = address(0);
    // Testing
    bool result = CreamExecution.repayAll(token_addr, crtoken_address, crWBNB_address);
    bool expected = true;

    Assert.equal(result, expected, "It should get the bool true of repayALL.");
  }

  function testSupply() public {
    address FakeCErc20DelegatorAddress = DeployedAddresses.FakeCErc20Delegator();

    // Parms
    address crtoken_address = FakeCErc20DelegatorAddress;
    uint amount = 10;
    // Testing
    uint result = CreamExecution.supply(crtoken_address, amount);
    uint expected = 10;

    Assert.equal(result, expected, "It should get the value 10 of supply amount.");
  }

  function testGetTokenBalance() public {
    address FakeIBEP20Address = DeployedAddresses.FakeIBEP20();

    // Parms
    address token_address = FakeIBEP20Address;
    // Testing
    uint result = CreamExecution.getTokenBalance(token_address);
    uint expected = 10;

    Assert.equal(result, expected, "It should get the value 10 of token balance.");
  }

}
