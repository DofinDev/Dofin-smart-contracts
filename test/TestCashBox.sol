// SPDX-License-Identifier: MIT
pragma solidity >=0.4.15 <0.9.0;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/CashBox.sol";
import { HighLevelSystem } from "../contracts/libs/HighLevelSystem.sol";

contract TestCashBox {

	address private FakeIBEP20Address = DeployedAddresses.FakeIBEP20();
	address private FakeCErc20DelegatorAddress = DeployedAddresses.FakeCErc20Delegator();
	address private FakePancakePairAddress = DeployedAddresses.FakePancakePair();

	address private FakeLinkBSCOracleAddress = DeployedAddresses.FakeLinkBSCOracle();
	address private FakePriceOracleProxyAddress = DeployedAddresses.FakePriceOracleProxy();
	address private FakePancakeFactoryAddress = DeployedAddresses.FakePancakeFactory();
	address private FakeMasterChefAddress = DeployedAddresses.FakeMasterChef();
	address private FakePancakeRouterAddress = DeployedAddresses.FakePancakeRouter();

	CashBox public cashBox = CashBox(DeployedAddresses.CashBox());

	function beforeAll() public {
		address[] memory _config = new address[] (5);
		_config[0] = FakeLinkBSCOracleAddress;
		_config[1] = FakePriceOracleProxyAddress;
		_config[2] = FakePancakeRouterAddress;
		_config[3] = FakePancakeFactoryAddress;
		_config[4] = FakeMasterChefAddress;
		cashBox.setConfig(_config);

		address[] memory _creamtokens = new address[] (3);
		_creamtokens[0] = address(0);
		_creamtokens[1] = FakeCErc20DelegatorAddress;
		_creamtokens[2] = FakeCErc20DelegatorAddress;
		cashBox.setCreamTokens(_creamtokens);

		address[] memory _stablecoins = new address[] (6);
		_stablecoins[0] = FakeIBEP20Address;
		_stablecoins[1] = FakeIBEP20Address;
		_stablecoins[2] = FakeIBEP20Address;
		_stablecoins[3] = FakeIBEP20Address;
		_stablecoins[4] = FakeIBEP20Address;
		_stablecoins[5] = FakeIBEP20Address;
		cashBox.setStableCoins(_stablecoins);
	}

	function testGetPosition() public {
		// Testing
		HighLevelSystem.Position memory result = cashBox.getPosition();
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
		  max_amount_per_position: 10,
		  supply_funds_percentage: 10
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
		Assert.equal(result.max_amount_per_position, expected.max_amount_per_position, "It should get the position data of max_amount_per_position.");
		Assert.equal(result.supply_funds_percentage, expected.supply_funds_percentage, "It should get the position data of supply_funds_percentage.");
	}

	function testReblanceWithRepay() public {
		// Testing
		cashBox.reblanceWithRepay();
	}

	function testReblanceWithoutRepay() public {
		// Testing
		cashBox.reblanceWithoutRepay();
	}

	function testReblance() public {
		// Testing
		cashBox.reblance();
	}

	function testCheckAddNewFunds() public {
		// Testing
		cashBox.checkAddNewFunds();
	}

	function testCheckEntry() public {
		// Testing
		cashBox.checkEntry();
	}

	function testCheckCurrentBorrowLimit() public {
		// Testing
		uint result = cashBox.checkCurrentBorrowLimit();
		uint expected = 1503759398;

		Assert.equal(result, expected, "It should get the value 10 of Current Borrow Limit.");
	}

	function testTotalSupply() public {
		// Testing
		uint result = cashBox.totalSupply();
		uint expected = 0;

		Assert.equal(result, expected, "It should get the value 0 of Total Supply.");
	}

	function testBalanceOf() public {
		// Params
		address account = address(this);
		// Testing
		uint result = cashBox.balanceOf(account);
		uint expected = 0;

		Assert.equal(result, expected, "It should get the value 0 of proof token balance.");
	}

	function testTransfer() public {
		// Params
		address recipient = address(this);
		uint amount = 0;
		// Testing
		bool result = cashBox.transfer(recipient, amount);
		bool expected = true;

		Assert.equal(result, expected, "It should get the bool of true.");
	}

	function testApprove() public {
		// Params
		address spender = address(this);
		uint amount = 0;
		// Testing
		bool result = cashBox.approve(spender, amount);
		bool expected = true;

		Assert.equal(result, expected, "It should get the bool of true.");
	}

	function testAllowance() public {
		// Params
		address owner = address(this);
		address spender = address(this);
		// Testing
		uint result = cashBox.allowance(owner, spender);
		uint expected = 0;

		Assert.equal(result, expected, "It should get the value 0 of allowance  amount.");
	}

	function testTransferFrom() public {
		// Params
		address owner = address(this);
		address buyer = address(this);
		uint numTokens = 0;
		// Testing
		bool result = cashBox.transferFrom(owner, buyer, numTokens);
		bool expected = true;

		Assert.equal(result, expected, "It should get the bool of true.");
	}

	function testGetTotalAssets() public {
		// Testing
		uint result = cashBox.getTotalAssets();
		uint expected = 20;

		Assert.equal(result, expected, "It should get the value 20 of total assets.");
	}

	function testDeposit() public {
		// Params
		address _token = FakeIBEP20Address;
		uint _deposit_amount = 10;
		// Testing
		bool result = cashBox.deposit(_token, _deposit_amount);
		bool expected = true;

		Assert.equal(result, expected, "It should get the bool of true.");
	}

	function testGetWithdrawAmount() public {
		// Params
		uint _ptoken_amount = 10;
		// Testing
		uint result = cashBox.getWithdrawAmount(_ptoken_amount);
		uint expected = 16;

		Assert.equal(result, expected, "It should get the value 0 of total assets.");
	}

	function testWithdraw() public {
		// Params
		uint _withdraw_amount = 10;
		// Testing
		bool result = cashBox.withdraw(_withdraw_amount);
		bool expected = true;

		Assert.equal(result, expected, "It should get the bool of true.");
	}

}
