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
		address[3] memory _addrs;
		_addrs[0] = FakeIBEP20Address;
		_addrs[1] = FakeIBEP20Address;
		_addrs[2] = FakePancakePairAddress;
		string memory _name = 'Proof Token';
		string memory _symbol = 'pFakeToken';
		uint8 _decimals = 10;
		boostedbunker.initialize(_uints, _addrs, _name, _symbol, _decimals);

		address[3] memory _config;
		_config[0] = FakePancakeRouterAddress;
		_config[1] = FakePancakeFactoryAddress;
		_config[2] = FakeMasterChefAddress;
		address dofin = address(0x0000000000000000000000000000000000000000);
		uint256[4] memory deposit_limit;
		deposit_limit[0] = 1000;
		deposit_limit[1] = 1000;
		deposit_limit[2] = 100000000000;
		deposit_limit[3] = 100000000000;
		address[] memory _rtokens = new address[](1);
		_rtokens[0] = address(0);
		boostedbunker.setConfig(_config, _rtokens, dofin, deposit_limit);
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
		  supply_amount: 0,
		  liquidity_a: 0,
    	  liquidity_b: 0,
    	  borrowed_token_a_amount: 0,
    	  borrowed_token_b_amount: 0,
		  token: address(0),
		  token_a: FakeIBEP20Address,
		  token_b: FakeIBEP20Address,
		  lp_token: FakePancakePairAddress,
		  supply_crtoken: address(0),
		  borrowed_crtoken_a: address(0),
		  borrowed_crtoken_b: address(0),
		  funds_percentage: 10,
		  total_depts: 0
		});

		Assert.equal(result.pool_id, expected.pool_id, "It should get the position data of pool_id.");
		Assert.equal(result.token_amount, expected.token_amount, "It should get the position data of token_amount.");
		Assert.equal(result.token_a_amount, expected.token_a_amount, "It should get the position data of token_a_amount.");
		Assert.equal(result.token_b_amount, expected.token_b_amount, "It should get the position data of token_b_amount.");
		Assert.equal(result.lp_token_amount, expected.lp_token_amount, "It should get the position data of lp_token_amount.");
		Assert.equal(result.crtoken_amount, expected.crtoken_amount, "It should get the position data of crtoken_amount.");
		Assert.equal(result.supply_amount, expected.supply_amount, "It should get the position data of supply_amount.");
		Assert.equal(result.liquidity_a, expected.liquidity_a, "It should get the position data of liquidity_a.");
		Assert.equal(result.liquidity_b, expected.liquidity_b, "It should get the position data of liquidity_b.");
		Assert.equal(result.borrowed_token_a_amount, expected.borrowed_token_a_amount, "It should get the position data of borrowed_token_a_amount.");
		Assert.equal(result.borrowed_token_b_amount, expected.borrowed_token_b_amount, "It should get the position data of borrowed_token_b_amount.");
		Assert.equal(result.token, expected.token, "It should get the position data of token.");
		Assert.equal(result.token_a, expected.token_a, "It should get the position data of token_a.");
		Assert.equal(result.token_b, expected.token_b, "It should get the position data of token_b.");
		Assert.equal(result.lp_token, expected.lp_token, "It should get the position data of lp_token.");
		Assert.equal(result.supply_crtoken, expected.supply_crtoken, "It should get the position data of supply_crtoken.");
		Assert.equal(result.borrowed_crtoken_a, expected.borrowed_crtoken_a, "It should get the position data of borrowed_crtoken_a.");
		Assert.equal(result.borrowed_crtoken_b, expected.borrowed_crtoken_b, "It should get the position data of borrowed_crtoken_b.");
		Assert.equal(result.funds_percentage, expected.funds_percentage, "It should get the position data of funds_percentage.");
		Assert.equal(result.total_depts, expected.total_depts, "It should get the position data of total_depts.");
	}

	function testCheckAddNewFunds() public {
		// Testing
		uint result = boostedbunker.checkAddNewFunds();
		uint expected = 1;

		Assert.equal(result, expected, "It should get the value 1 of CheckAddNewFunds signal.");
	}

	function testAutoCompound() public {
		// Params
		address[] memory _path = new address[] (2);
		_path[0] = FakeIBEP20Address;
		_path[1] = FakeIBEP20Address;
		uint256 _amountIn = 10000000000000;
		uint256 _wrapType = 1;
		// Testing
		boostedbunker.autoCompound(_amountIn, _path, _wrapType);
	}

	function testExit() public {
		// Testing
		boostedbunker.exit();
	}

	function testEnter() public {
		// Testing
		boostedbunker.enter();
	}

	function testRebalanceWithoutRepay() public {
		// Testing
		boostedbunker.rebalanceWithoutRepay();
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
		uint expected = 100000000000000000010;

		Assert.equal(result, expected, "It should get the value 100000000000000000010 of total assets.");
	}

	function testGetDepositAmountOut() public {
		// Params
		uint _token_a_amount = 100;
		uint _token_b_amount = 0;
		// Testing
		(uint result_1, uint result_2, uint result_3, uint result_4) = boostedbunker.getDepositAmountOut(_token_a_amount, _token_b_amount);
		uint expected_1 = 100;
		uint expected_2 = 10;
		uint expected_3 = 10;
		uint expected_4 = 10;

		Assert.equal(result_1, expected_1, "It should get the value 100 of Deposit Amount Out 1.");
		Assert.equal(result_2, expected_2, "It should get the value 10 of Deposit Amount Out 2.");
		Assert.equal(result_3, expected_3, "It should get the value 200 of Deposit Amount Out 3.");
		Assert.equal(result_4, expected_4, "It should get the value 200 of Deposit Amount Out 4.");
	}

	function testDeposit() public {
		// Params
		uint _token_a_amount = 100;
		uint _token_b_amount = 0;
		// Testing
		bool result = boostedbunker.deposit(_token_a_amount, _token_b_amount);
		bool expected = true;

		Assert.equal(result, expected, "It should get the bool of true.");
	}

	function testGetWithdrawAmount() public {
		// Testing
		(uint result_1, uint result_2) = boostedbunker.getWithdrawAmount();
		uint expected_1 = 800000000000000000100000000000000000000;
		uint expected_2 = 800000000000000000100000000000000000000;

		Assert.equal(result_1, expected_1, "It should get the value 800000000000000000100000000000000000000 of withdraw amount 1.");
		Assert.equal(result_2, expected_2, "It should get the value 800000000000000000100000000000000000000 of withdraw amount 2.");
	}

	function testWithdraw() public {
		// Testing
		bool result = boostedbunker.withdraw();
		bool expected = true;

		Assert.equal(result, expected, "It should get the bool of true.");
	}

}
