// SPDX-License-Identifier: MIT
pragma solidity >=0.4.15 <0.9.0;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/BoostedBunker.sol";
import { HighLevelSystem } from "../contracts/libs/HighLevelSystem.sol";

contract TestBoostedBunker {

	address private FakeIBEP20Address = DeployedAddresses.FakeIBEP20();
	address private FakePancakePairAddress = DeployedAddresses.FakePancakePair();

	address private FakeLinkBSCOracleAddress = DeployedAddresses.FakeLinkBSCOracle();
	address private FakePancakeFactoryAddress = DeployedAddresses.FakePancakeFactory();
	address private FakeMasterChefAddress = DeployedAddresses.FakeMasterChef();
	address private FakePancakeRouterAddress = DeployedAddresses.FakePancakeRouter();

	BoostedBunker public boostedbunker = BoostedBunker(DeployedAddresses.BoostedBunker());

	function beforeAll() public {
		uint256[2] memory _uints;
		_uints[0] = 10;
		_uints[1] = 10;
		address[4] memory _addrs;
		_addrs[0] = FakeIBEP20Address;
		_addrs[1] = FakeIBEP20Address;
		_addrs[2] = FakeIBEP20Address;
		_addrs[3] = FakePancakePairAddress;
		string memory _name = 'Proof Token';
		string memory _symbol = 'pFakeToken';
		uint8 _decimals = 10;
		boostedbunker.initialize(_uints, _addrs, _name, _symbol, _decimals);

		address[8] memory _config;
		_config[0] = FakeLinkBSCOracleAddress;
		_config[1] = FakeLinkBSCOracleAddress;
		_config[2] = FakeLinkBSCOracleAddress;
		_config[3] = FakeLinkBSCOracleAddress;
		_config[4] = FakePancakeRouterAddress;
		_config[5] = FakePancakeFactoryAddress;
		_config[6] = FakeMasterChefAddress;
		_config[7] = FakeIBEP20Address;
		address dofin = address(0x0000000000000000000000000000000000000000);
		uint256 deposit_limit = 1000000;
		boostedbunker.setConfig(_config, dofin, deposit_limit);
	}

	function testGetPosition() public {
		// Testing
		HighLevelSystem.Position memory result = boostedbunker.getPosition();
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
		  supply_crtoken: address(0x0000000000000000000000000000000000000000),
		  borrowed_crtoken_a: address(0x0000000000000000000000000000000000000000),
		  borrowed_crtoken_b: address(0x0000000000000000000000000000000000000000),
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

	function testRebalanceWithoutRepay() public {
		// Testing
		boostedbunker.rebalanceWithoutRepay();
	}

	function testCheckAddNewFunds() public {
		// Testing
		uint result = boostedbunker.checkAddNewFunds();
		uint expected = 0;

		Assert.equal(result, expected, "It should get the value 1 of CheckAddNewFunds signal.");
	}

	function testAutoCompound() public {
		// Params
		address[] memory _token_a_path = new address[] (2);
		_token_a_path[0] = address(0);
		_token_a_path[1] = address(0);
		address[] memory _token_b_path = new address[] (2);
		_token_b_path[0] = address(0);
		_token_b_path[1] = address(0);
		// Testing
		boostedbunker.autoCompound(_token_a_path, _token_b_path);
	}

	function testExit() public {
		// Testing
		boostedbunker.exit();
	}

	function testEnter() public {
		// Testing
		boostedbunker.enter();
	}

	function testTotalSupply() public {
		// Testing
		uint result = boostedbunker.totalSupply();
		uint expected = 0;

		Assert.equal(result, expected, "It should get the value 0 of Total Supply.");
	}

	function testBalanceOf() public {
		// Params
		address account = address(this);
		// Testing
		uint result = boostedbunker.balanceOf(account);
		uint expected = 0;

		Assert.equal(result, expected, "It should get the value 0 of proof token balance.");
	}

	function testTransfer() public {
		// Params
		address recipient = address(this);
		uint amount = 0;
		// Testing
		bool result = boostedbunker.transfer(recipient, amount);
		bool expected = true;

		Assert.equal(result, expected, "It should get the bool of true.");
	}

	function testApprove() public {
		// Params
		address spender = address(this);
		uint amount = 0;
		// Testing
		bool result = boostedbunker.approve(spender, amount);
		bool expected = true;

		Assert.equal(result, expected, "It should get the bool of true.");
	}

	function testAllowance() public {
		// Params
		address owner = address(this);
		address spender = address(this);
		// Testing
		uint result = boostedbunker.allowance(owner, spender);
		uint expected = 0;

		Assert.equal(result, expected, "It should get the value 0 of allowance  amount.");
	}

	function testTransferFrom() public {
		// Params
		address owner = address(this);
		address buyer = address(this);
		uint numTokens = 0;
		// Testing
		bool result = boostedbunker.transferFrom(owner, buyer, numTokens);
		bool expected = true;

		Assert.equal(result, expected, "It should get the bool of true.");
	}

	function testGetTotalAssets() public {
		// Testing
		uint result = boostedbunker.getTotalAssets();
		uint expected = 200000000000000000030;

		Assert.equal(result, expected, "It should get the value 200000000000000000030 of total assets.");
	}

	function testGetDepositAmountOut() public {
		// Params
		uint _token_a_amount = 10;
		uint _token_b_amount = 10;
		// Testing
		(uint result_1, uint result_2, uint result_3, uint result_4) = boostedbunker.getDepositAmountOut(_token_a_amount, _token_b_amount);
		uint expected_1 = 10;
		uint expected_2 = 10;
		uint expected_3 = 20;
		uint expected_4 = 20;

		Assert.equal(result_1, expected_1, "It should get the value 20 of Deposit Amount Out 1.");
		Assert.equal(result_2, expected_2, "It should get the value 20 of Deposit Amount Out 2.");
		Assert.equal(result_3, expected_3, "It should get the value 20 of Deposit Amount Out 3.");
		Assert.equal(result_4, expected_4, "It should get the value 20 of Deposit Amount Out 4.");
	}

	function testDeposit() public {
		// Params
		uint _token_a_amount = 10;
		uint _token_b_amount = 10;
		// Testing
		bool result = boostedbunker.deposit(_token_a_amount, _token_b_amount);
		bool expected = true;

		Assert.equal(result, expected, "It should get the bool of true.");
	}

	function testGetWithdrawAmount() public {
		// Testing
		(uint result_1, uint result_2) = boostedbunker.getWithdrawAmount();
		uint expected_1 = 80000000000000000014;
		uint expected_2 = 80000000000000000014;

		Assert.equal(result_1, expected_1, "It should get the value 80000000000000000014 of withdraw amount 1.");
		Assert.equal(result_2, expected_2, "It should get the value 80000000000000000014 of withdraw amount 2.");
	}

	function testWithdraw() public {
		// Testing
		bool result = boostedbunker.withdraw();
		bool expected = true;

		Assert.equal(result, expected, "It should get the bool of true.");
	}

}
