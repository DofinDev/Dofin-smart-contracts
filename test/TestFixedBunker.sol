// SPDX-License-Identifier: MIT
pragma solidity >=0.4.15 <0.9.0;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/FixedBunker.sol";
import { HighLevelSystem } from "../contracts/libs/HighLevelSystem.sol";

contract TestFixedBunker {

	address private FakeIBEP20Address = DeployedAddresses.FakeIBEP20();
	address private FakeCErc20DelegatorAddress = DeployedAddresses.FakeCErc20Delegator();

	address private FakeLinkBSCOracleAddress = DeployedAddresses.FakeLinkBSCOracle();
	address public FakeComptrollerAddress = DeployedAddresses.FakeComptroller();

	FixedBunker public fixedbunker = FixedBunker(DeployedAddresses.FixedBunker());

	function beforeAll() public {
		uint256[1] memory _uints;
		_uints[0] = 10;
		address[2] memory _addrs;
		_addrs[0] = FakeIBEP20Address;
		_addrs[1] = FakeCErc20DelegatorAddress;
		string memory _name = 'Proof Token';
		string memory _symbol = 'pFakeToken';
		uint8 _decimals = 10;
		fixedbunker.initialize(_uints, _addrs, _name, _symbol, _decimals);

		address[1] memory _config;
		_config[0] = FakeLinkBSCOracleAddress;
		address dofin = address(0);
		uint256[2] memory deposit_limit;
		deposit_limit[0] = 1000;
		deposit_limit[1] = 100000000000;
		address[] memory _rtokens = new address[](1);
		_rtokens[0] = address(0);
		fixedbunker.setConfig(_config, _rtokens, dofin, deposit_limit, true);
	}

	function testGetPosition() public {
		// Testing
		HighLevelSystem.Position memory result = fixedbunker.getPosition();
		HighLevelSystem.Position memory expected = HighLevelSystem.Position({
		  pool_id: 0,
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
		  token: FakeIBEP20Address,
		  token_a: address(0),
		  token_b: address(0),
		  lp_token: address(0),
		  supply_crtoken: FakeCErc20DelegatorAddress,
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

	function testRebalance() public {
		// Testing
		fixedbunker.rebalance();
	}

	function testCheckAddNewFunds() public {
		// Testing
		uint result = fixedbunker.checkAddNewFunds();
		uint expected = 0;

		Assert.equal(result, expected, "It should get the value 0 of CheckAddNewFunds signal.");
	}

	function testExit() public {
		// Testing
		fixedbunker.exit();
	}

	function testEnter() public {
		// Testing
		fixedbunker.enter();
	}

	function testTotalSupply() public {
		// Testing
		uint result = fixedbunker.totalSupply();
		uint expected = 0;

		Assert.equal(result, expected, "It should get the value 0 of Total Supply.");
	}

	function testBalanceOf() public {
		// Params
		address account = address(this);
		// Testing
		uint result = fixedbunker.balanceOf(account);
		uint expected = 0;

		Assert.equal(result, expected, "It should get the value 0 of proof token balance.");
	}

	function testTransfer() public {
		// Params
		address recipient = address(this);
		uint amount = 0;
		// Testing
		bool result = fixedbunker.transfer(recipient, amount);
		bool expected = true;

		Assert.equal(result, expected, "It should get the bool of true.");
	}

	function testApprove() public {
		// Params
		address spender = address(this);
		uint amount = 0;
		// Testing
		bool result = fixedbunker.approve(spender, amount);
		bool expected = true;

		Assert.equal(result, expected, "It should get the bool of true.");
	}

	function testAllowance() public {
		// Params
		address owner = address(this);
		address spender = address(this);
		// Testing
		uint result = fixedbunker.allowance(owner, spender);
		uint expected = 0;

		Assert.equal(result, expected, "It should get the value 0 of allowance  amount.");
	}

	function testTransferFrom() public {
		// Params
		address owner = address(this);
		address buyer = address(this);
		uint numTokens = 0;
		// Testing
		bool result = fixedbunker.transferFrom(owner, buyer, numTokens);
		bool expected = true;

		Assert.equal(result, expected, "It should get the bool of true.");
	}

	function testGetTotalAssets() public {
		// Testing
		uint result = fixedbunker.getTotalAssets();
		uint expected = 110000000000000000000;

		Assert.equal(result, expected, "It should get the value 110000000000000000000 of total assets.");
	}

	function testGetDepositAmountOut() public {
		// Params
		uint _deposit_amount = 10;
		// Testing
		uint result = fixedbunker.getDepositAmountOut(_deposit_amount);
		uint expected = 10;

		Assert.equal(result, expected, "It should get the value 10 of Deposit Amount Out.");
	}

	function testDeposit() public {
		// Params
		uint _deposit_amount = 10;
		// Testing
		bool result = fixedbunker.deposit(_deposit_amount);
		bool expected = true;

		Assert.equal(result, expected, "It should get the bool of true.");
	}

	function testGetWithdrawAmount() public {
		// Testing
		uint result = fixedbunker.getWithdrawAmount();
		uint expected = 88000000000000000002;

		Assert.equal(result, expected, "It should get the value 88000000000000000002 of withdraw amount.");
	}

	function testWithdraw() public {
		// Testing
		bool result = fixedbunker.withdraw();
		bool expected = true;

		Assert.equal(result, expected, "It should get the bool of true.");
	}

}
