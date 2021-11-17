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
		uint256[2] memory _uints;
		_uints[0] = 10;
		_uints[1] = 10;
		address[7] memory _addrs;
		_addrs[0] = FakeIBEP20Address;
		_addrs[1] = FakeIBEP20Address;
		_addrs[2] = FakeIBEP20Address;
		_addrs[3] = FakePancakePairAddress;
		_addrs[4] = FakeCErc20DelegatorAddress;
		_addrs[5] = FakeCErc20DelegatorAddress;
		_addrs[6] = FakeCErc20DelegatorAddress;
		string memory _name = 'Proof Token';
		string memory _symbol = 'pFakeToken';
		uint8 _decimals = 10;
		chargedbunker.initialize(_uints, _addrs, _name, _symbol, _decimals);

		address[8] memory _config;
		_config[0] = FakeLinkBSCOracleAddress;
		_config[1] = FakeLinkBSCOracleAddress;
		_config[2] = FakeLinkBSCOracleAddress;
		_config[3] = FakeLinkBSCOracleAddress;
		_config[4] = FakePancakeRouterAddress;
		_config[5] = FakePancakeFactoryAddress;
		_config[6] = FakeMasterChefAddress;
		_config[7] = FakeComptrollerAddress;
		address dofin = address(0x0000000000000000000000000000000000000000);
		uint256[2] memory deposit_limit;
		deposit_limit[0] = 1000;
		deposit_limit[1] = 100000000000;
		chargedbunker.setConfig(_config, dofin, deposit_limit, true);
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
		  supply_amount: 0,
  		  liquidity_a: 0,
      	  liquidity_b: 0,
      	  borrowed_token_a_amount: 0,
    	  borrowed_token_b_amount: 0,
		  token: FakeIBEP20Address,
		  token_a: FakeIBEP20Address,
		  token_b: FakeIBEP20Address,
		  lp_token: FakePancakePairAddress,
		  supply_crtoken: FakeCErc20DelegatorAddress,
		  borrowed_crtoken_a: FakeCErc20DelegatorAddress,
		  borrowed_crtoken_b: FakeCErc20DelegatorAddress,
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

	function testAutoCompound() public {
		// Params
		address[] memory _path = new address[] (2);
		_path[0] = FakeIBEP20Address;
		_path[1] = FakeIBEP20Address;
		uint256 _amountIn = 10000000000000;
		uint256 _wrapType = 1;
		// Testing
		chargedbunker.autoCompound(_amountIn, _path, _wrapType);
	}

	function testExit() public {
		// Testing
		chargedbunker.exit(1);
	}

	function testEnter() public {
		// Testing
		chargedbunker.enter(1);
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
		// Testing
		uint result = chargedbunker.getWithdrawAmount();
		uint expected = 88000000000000000010;

		Assert.equal(result, expected, "It should get the value 88000000000000000010 of withdraw amount.");
	}

	function testWithdraw() public {
		// Testing
		bool result = chargedbunker.withdraw();
		bool expected = true;

		Assert.equal(result, expected, "It should get the bool of true.");
	}

}
