// SPDX-License-Identifier: MIT
pragma solidity >=0.4.15 <0.9.0;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/ChargedBunker.sol";
import { HighLevelSystem } from "../contracts/libs/HighLevelSystem.sol";

contract TestChargedBunker {

	address private FakeIBEP20Address = DeployedAddresses.FakeIBEP20();
	address private FakeCErc20DelegatorAddress = DeployedAddresses.FakeCErc20Delegator();
	address private FakePancakePairAddress = DeployedAddresses.FakePancakePair();

	address private FakeLinkBSCOracleAddress = DeployedAddresses.FakeLinkBSCOracle();
	address private FakePancakeFactoryAddress = DeployedAddresses.FakePancakeFactory();
	address private FakeMasterChefAddress = DeployedAddresses.FakeMasterChef();
	address private FakePancakeRouterAddress = DeployedAddresses.FakePancakeRouter();
	address public FakeComptrollerAddress = DeployedAddresses.FakeComptroller();

	ChargedBunker public chargedbunker = ChargedBunker(DeployedAddresses.ChargedBunker());

	function beforeAll() public {
		address[] memory _config = new address[] (9);
		_config[0] = FakeLinkBSCOracleAddress;
		_config[1] = FakeLinkBSCOracleAddress;
		_config[2] = FakeLinkBSCOracleAddress;
		_config[3] = FakeLinkBSCOracleAddress;
		_config[4] = FakePancakeRouterAddress;
		_config[5] = FakePancakeFactoryAddress;
		_config[6] = FakeMasterChefAddress;
		_config[7] = FakeIBEP20Address;
		_config[8] = FakeComptrollerAddress;
		chargedbunker.setConfig(_config);
	}

	function testGetPosition() public {
		// Testing
		HighLevelSystem.Position memory result = chargedbunker.getPosition();
		HighLevelSystem.Position memory expected = HighLevelSystem.Position({
		  pool_id: 10,
		  token_amount: 0,
		  token_a_amount: 0,
		  token_b_amount: 0,
		  lp_token_amount: 0,
		  crtoken_amount: 0,
		  supply_crtoken_amount: 0,
		  token: FakeIBEP20Address,
		  token_a: FakeIBEP20Address,
		  token_b: FakeIBEP20Address,
		  lp_token: FakePancakePairAddress,
		  supply_crtoken: FakeCErc20DelegatorAddress,
		  borrowed_crtoken_a: FakeCErc20DelegatorAddress,
		  borrowed_crtoken_b: FakeCErc20DelegatorAddress,
		  supply_funds_percentage: 10,
		  total_depts: 0
		});

		Assert.equal(result.pool_id, expected.pool_id, "It should get the position data of pool_id.");
		Assert.equal(result.token_amount, expected.token_amount, "It should get the position data of token_amount.");
		Assert.equal(result.token_a_amount, expected.token_a_amount, "It should get the position data of token_a_amount.");
		Assert.equal(result.token_b_amount, expected.token_b_amount, "It should get the position data of token_b_amount.");
		Assert.equal(result.lp_token_amount, expected.lp_token_amount, "It should get the position data of lp_token_amount.");
		Assert.equal(result.crtoken_amount, expected.crtoken_amount, "It should get the position data of crtoken_amount.");
		Assert.equal(result.supply_crtoken_amount, expected.supply_crtoken_amount, "It should get the position data of supply_crtoken_amount.");
		Assert.equal(result.token, expected.token, "It should get the position data of token.");
		Assert.equal(result.token_a, expected.token_a, "It should get the position data of token_a.");
		Assert.equal(result.token_b, expected.token_b, "It should get the position data of token_b.");
		Assert.equal(result.lp_token, expected.lp_token, "It should get the position data of lp_token.");
		Assert.equal(result.supply_crtoken, expected.supply_crtoken, "It should get the position data of supply_crtoken.");
		Assert.equal(result.borrowed_crtoken_a, expected.borrowed_crtoken_a, "It should get the position data of borrowed_crtoken_a.");
		Assert.equal(result.borrowed_crtoken_b, expected.borrowed_crtoken_b, "It should get the position data of borrowed_crtoken_b.");
		Assert.equal(result.supply_funds_percentage, expected.supply_funds_percentage, "It should get the position data of supply_funds_percentage.");
		Assert.equal(result.total_depts, expected.total_depts, "It should get the position data of total_depts.");
	}

	function testRebalanceWithRepay() public {
		// Testing
		chargedbunker.rebalanceWithRepay();
	}

	function testRebalanceWithoutRepay() public {
		// Testing
		chargedbunker.rebalanceWithoutRepay();
	}

	function testRebalance() public {
		// Testing
		chargedbunker.rebalance();
	}

	function testCheckAddNewFunds() public {
		// Testing
		uint result = chargedbunker.checkAddNewFunds();
		uint expected = 0;

		Assert.equal(result, expected, "It should get the value 0 of CheckAddNewFunds signal.");
	}

	function testExit1() public {
		// Testing
		chargedbunker.exit(1);
	}

	function testExit2() public {
		// Testing
		chargedbunker.exit(2);
	}

	function testExit3() public {
		// Testing
		chargedbunker.exit(3);
	}

	function testEnter1() public {
		// Testing
		chargedbunker.enter(1);
	}

	function testEnter2() public {
		// Testing
		chargedbunker.enter(2);
	}

	function testEnter3() public {
		// Testing
		chargedbunker.enter(3);
	}

	function testTotalSupply() public {
		// Testing
		uint result = chargedbunker.totalSupply();
		uint expected = 0;

		Assert.equal(result, expected, "It should get the value 0 of Total Supply.");
	}

	function testBalanceOf() public {
		// Params
		address account = address(this);
		// Testing
		uint result = chargedbunker.balanceOf(account);
		uint expected = 0;

		Assert.equal(result, expected, "It should get the value 0 of proof token balance.");
	}

	function testTransfer() public {
		// Params
		address recipient = address(this);
		uint amount = 0;
		// Testing
		bool result = chargedbunker.transfer(recipient, amount);
		bool expected = true;

		Assert.equal(result, expected, "It should get the bool of true.");
	}

	function testApprove() public {
		// Params
		address spender = address(this);
		uint amount = 0;
		// Testing
		bool result = chargedbunker.approve(spender, amount);
		bool expected = true;

		Assert.equal(result, expected, "It should get the bool of true.");
	}

	function testAllowance() public {
		// Params
		address owner = address(this);
		address spender = address(this);
		// Testing
		uint result = chargedbunker.allowance(owner, spender);
		uint expected = 0;

		Assert.equal(result, expected, "It should get the value 0 of allowance  amount.");
	}

	function testTransferFrom() public {
		// Params
		address owner = address(this);
		address buyer = address(this);
		uint numTokens = 0;
		// Testing
		bool result = chargedbunker.transferFrom(owner, buyer, numTokens);
		bool expected = true;

		Assert.equal(result, expected, "It should get the bool of true.");
	}

	function testGetTotalAssets() public {
		// Testing
		uint result = chargedbunker.getTotalAssets();
		uint expected = 110000000000000000010;

		Assert.equal(result, expected, "It should get the value 110000000000000000010 of total assets.");
	}

	function testGetDepositAmountOut() public {
		// Params
		uint _deposit_amount = 10;
		// Testing
		uint result = chargedbunker.getDepositAmountOut(_deposit_amount);
		uint expected = 10;

		Assert.equal(result, expected, "It should get the value 10 of Deposit Amount Out.");
	}

	function testDeposit() public {
		// Params
		uint _deposit_amount = 10;
		// Testing
		bool result = chargedbunker.deposit(_deposit_amount);
		bool expected = true;

		Assert.equal(result, expected, "It should get the bool of true.");
	}

	function testGetWithdrawAmount() public {
		// Params
		uint _ptoken_amount = 10;
		// Testing
		uint result = chargedbunker.getWithdrawAmount(_ptoken_amount);
		uint expected = 88000000000000000008;

		Assert.equal(result, expected, "It should get the value 88000000000000000008 of withdraw amount.");
	}

	function testWithdraw() public {
		// Params
		uint _withdraw_amount = 10;
		// Testing
		bool result = chargedbunker.withdraw(_withdraw_amount);
		bool expected = true;

		Assert.equal(result, expected, "It should get the bool of true.");
	}

}
