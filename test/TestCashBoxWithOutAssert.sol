// SPDX-License-Identifier: MIT
pragma solidity >=0.4.15 <0.9.0;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/CashBox.sol";
import { HighLevelSystem } from "../contracts/libs/HighLevelSystem.sol";

contract TestCashBoxWithOutAssert {

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
		address[] memory _config = new address[] (8);
		_config[0] = FakeLinkBSCOracleAddress;
		_config[1] = FakeLinkBSCOracleAddress;
		_config[2] = FakeLinkBSCOracleAddress;
		_config[3] = FakeLinkBSCOracleAddress;
		_config[4] = FakePriceOracleProxyAddress;
		_config[5] = FakePancakeRouterAddress;
		_config[6] = FakePancakeFactoryAddress;
		_config[7] = FakeMasterChefAddress;
		cashBox.setConfig(_config);

		address[] memory _creamtokens = new address[] (2);
		_creamtokens[0] = address(0);
		_creamtokens[1] = FakeCErc20DelegatorAddress;
		cashBox.setCreamTokens(_creamtokens);

		address[] memory _stablecoins = new address[] (3);
		_stablecoins[0] = FakeIBEP20Address;
		_stablecoins[1] = FakeIBEP20Address;
		_stablecoins[2] = FakeIBEP20Address;
		cashBox.setStableCoins(_stablecoins);
	}

	function testGetPosition() public {
		// Testing
		HighLevelSystem.Position memory result = cashBox.getPosition();
	}

	function testRebalanceWithRepay() public {
		// Testing
		cashBox.rebalanceWithRepay();
	}

	function testRebalanceWithoutRepay() public {
		// Testing
		cashBox.rebalanceWithoutRepay();
	}

	function testRebalance() public {
		// Testing
		cashBox.rebalance();
	}

	function testCheckAddNewFunds() public {
		// Testing
		cashBox.checkAddNewFunds();
	}

	function testExit1() public {
		// Testing
		cashBox.exit(1);
	}

	function testExit2() public {
		// Testing
		cashBox.exit(2);
	}

	function testExit3() public {
		// Testing
		cashBox.exit(3);
	}

	function testEnter1() public {
		// Testing
		cashBox.enter(1);
	}

	function testEnter2() public {
		// Testing
		cashBox.enter(2);
	}

	function testEnter3() public {
		// Testing
		cashBox.enter(3);
	}

	function testCheckCurrentBorrowLimit() public {
		// Testing
		uint result = cashBox.checkCurrentBorrowLimit();
	}

	function testTotalSupply() public {
		// Testing
		uint result = cashBox.totalSupply();
	}

	function testBalanceOf() public {
		// Params
		address account = address(this);
		// Testing
		uint result = cashBox.balanceOf(account);
	}

	function testTransfer() public {
		// Params
		address recipient = address(this);
		uint amount = 0;
		// Testing
		bool result = cashBox.transfer(recipient, amount);
	}

	function testApprove() public {
		// Params
		address spender = address(this);
		uint amount = 0;
		// Testing
		bool result = cashBox.approve(spender, amount);
	}

	function testAllowance() public {
		// Params
		address owner = address(this);
		address spender = address(this);
		// Testing
		uint result = cashBox.allowance(owner, spender);
	}

	function testTransferFrom() public {
		// Params
		address owner = address(this);
		address buyer = address(this);
		uint numTokens = 0;
		// Testing
		bool result = cashBox.transferFrom(owner, buyer, numTokens);
	}

	function testGetTotalAssets() public {
		// Testing
		uint result = cashBox.getTotalAssets();
	}

	function testGetDepositAmountOut() public {
		// Params
		uint _deposit_amount = 10;
		// Testing
		uint result = cashBox.getDepositAmountOut(_deposit_amount);
	}

	function testDeposit() public {
		// Params
		address _token = FakeIBEP20Address;
		uint _deposit_amount = 10;
		// Testing
		bool result = cashBox.deposit(_token, _deposit_amount);
	}

	function testGetWithdrawAmount() public {
		// Params
		uint _ptoken_amount = 10;
		// Testing
		uint result = cashBox.getWithdrawAmount(_ptoken_amount);
	}

	function testWithdraw() public {
		// Params
		uint _withdraw_amount = 10;
		// Testing
		bool result = cashBox.withdraw(_withdraw_amount);
	}

}
