// SPDX-License-Identifier: MIT
pragma solidity >=0.8;

import "./libs/IBEP20.sol";
import "./libs/SafeMath.sol";
import "./utils/ProofToken.sol";
import { HighLevelSystem } from "./libs/HighLevelSystem.sol";

/// @title ChargedBunker
/// @author Andrew FU
contract ChargedBunker is ProofToken {

    struct User {
        uint256 depositPtokenAmount;
        uint256 depositTokenAmount;
        uint256 depositBlockTimestamp;
    }

    HighLevelSystem.HLSConfig private HLSConfig;
    HighLevelSystem.Position private Position;
    
    using SafeMath for uint256;

    uint256 public total_deposit_limit;
    uint256 public deposit_limit;
    uint256 private temp_free_funds;
    bool public TAG = false;
    address private dofin = address(0);
    address private factory = address(0);
    address[] public rtokens;

    mapping (address => User) private users;
    event Received(address, uint);

    function sendFees() external payable {
        
        emit Received(msg.sender, msg.value);
    }

    function feesBack() external {
        require(checkCaller() == true, "Only factory or dofin can call this function");
        uint256 contract_balance = payable(address(this)).balance;
        payable(address(msg.sender)).transfer(contract_balance);
    }

    function checkCaller() public view returns (bool) {
        if (msg.sender == factory || msg.sender == dofin) {
            return true;
        }
        return false;
    }

    function initialize(uint256[2] memory _uints, address[7] memory _addrs, string memory _name, string memory _symbol, uint8 _decimals) external {
        if (dofin!=address(0) && factory!=address(0)) {
            require(checkCaller() == true, "Only factory or dofin can call this function");
        }
        Position = HighLevelSystem.Position({
            pool_id: _uints[0],
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
            token: _addrs[0],
            token_a: _addrs[1],
            token_b: _addrs[2],
            lp_token: _addrs[3],
            supply_crtoken: _addrs[4],
            borrowed_crtoken_a: _addrs[5],
            borrowed_crtoken_b: _addrs[6],
            funds_percentage: _uints[1],
            total_depts: 0
        });
        initializeToken(_name, _symbol, _decimals);
        factory = msg.sender;
    }
    
    function setConfig(address[8] memory _config, address[] memory _rtokens, address _dofin, uint256[2] memory _deposit_limit) external {
        if (dofin!=address(0) && factory!=address(0)) {
            require(checkCaller() == true, "Only factory or dofin can call this function");
        }
        HLSConfig.token_oracle = _config[0];
        HLSConfig.token_a_oracle = _config[1];
        HLSConfig.token_b_oracle = _config[2];
        HLSConfig.cake_oracle = _config[3];
        HLSConfig.router = _config[4];
        HLSConfig.factory = _config[5];
        HLSConfig.masterchef = _config[6];
        HLSConfig.comptroller = _config[7];

        rtokens = _rtokens;
        dofin = _dofin;
        deposit_limit = _deposit_limit[0];
        total_deposit_limit = _deposit_limit[1];

        // Set Tag
        setTag(true);
    }

    function setTag(bool _tag) public {
        require(checkCaller() == true, "Only factory or dofin can call this function");
        TAG = _tag;
        if (_tag == true) {
            address[] memory crtokens = new address[] (3);
            crtokens[0] = address(0x0000000000000000000000000000000000000020);
            crtokens[1] = address(0x0000000000000000000000000000000000000001);
            crtokens[2] = Position.supply_crtoken;
            HighLevelSystem.enterMarkets(HLSConfig.comptroller, crtokens);
        } else {
            HighLevelSystem.exitMarket(HLSConfig.comptroller, Position.supply_crtoken);
        }
    }

    function getConfig() external view returns(HighLevelSystem.HLSConfig memory) {
        
        return HLSConfig;
    }
    
    function getPosition() external view returns(HighLevelSystem.Position memory) {
        
        return Position;
    }

    function getUser(address _account) external view returns (User memory) {
        
        return users[_account];
    }

    function rebalanceWithRepay() external {
        require(checkCaller() == true, "Only factory or dofin can call this function");
        require(TAG == true, 'TAG ERROR.');
        Position = HighLevelSystem.exitPosition(HLSConfig, Position, 2);
        Position = HighLevelSystem.enterPosition(HLSConfig, Position, 2);
        temp_free_funds = IBEP20(Position.token).balanceOf(address(this));
    }
    
    function rebalanceWithoutRepay() external {
        require(checkCaller() == true, "Only factory or dofin can call this function");
        require(TAG == true, 'TAG ERROR.');
        Position = HighLevelSystem.exitPosition(HLSConfig, Position, 3);
        Position = HighLevelSystem.enterPosition(HLSConfig, Position, 3);
        temp_free_funds = IBEP20(Position.token).balanceOf(address(this));
    }
    
    function rebalance() external {
        require(checkCaller() == true, "Only factory or dofin can call this function");
        require(TAG == true, 'TAG ERROR.');
        Position = HighLevelSystem.exitPosition(HLSConfig, Position, 1);
        Position = HighLevelSystem.enterPosition(HLSConfig, Position, 1);
        temp_free_funds = IBEP20(Position.token).balanceOf(address(this));
    }
    
    function checkAddNewFunds() external view returns (uint256) {
        uint256 free_funds = IBEP20(Position.token).balanceOf(address(this));
        if (free_funds > temp_free_funds) {
            if (Position.token_a_amount == 0 && Position.token_b_amount == 0) {
                // Need to enter
                return 1;
            } else {
                // Need to rebalance
                return 2;
            }
        }
        return 0;
    }

    function autoCompound(uint256 _amountIn, address[] calldata _path, uint256 _wrapType) external {
        require(checkCaller() == true, "Only factory or dofin can call this function");
        require(TAG == true, 'TAG ERROR.');
        HighLevelSystem.autoCompound(HLSConfig, _amountIn, _path, _wrapType);
        Position.token_amount = IBEP20(Position.token).balanceOf(address(this));
        Position.token_a_amount = IBEP20(Position.token_a).balanceOf(address(this));
        Position.token_b_amount = IBEP20(Position.token_b).balanceOf(address(this));
    }
    
    function enter(uint256 _type) external {
        require(checkCaller() == true, "Only factory or dofin can call this function");
        require(TAG == true, 'TAG ERROR.');
        Position = HighLevelSystem.enterPosition(HLSConfig, Position, _type);
        temp_free_funds = IBEP20(Position.token).balanceOf(address(this));
    }

    function exit(uint256 _type) external {
        require(checkCaller() == true, "Only factory or dofin can call this function");
        require(TAG == true, 'TAG ERROR.');
        Position = HighLevelSystem.exitPosition(HLSConfig, Position, _type);
    }

    function getTotalAssets() public view returns (uint256) {
        // Free funds amount
        uint256 freeFunds = IBEP20(Position.token).balanceOf(address(this));
        // Total Debts amount from Cream, PancakeSwap
        uint256 totalDebts = Position.total_depts;
        
        return freeFunds.add(totalDebts);
    }

    function getDepositAmountOut(uint256 _deposit_amount) public view returns (uint256) {
        require(_deposit_amount <= deposit_limit.mul(10**IBEP20(Position.token).decimals()), "Deposit too much!");
        require(_deposit_amount > 0, "Deposit amount must bigger than 0.");
        uint256 totalAssets = getTotalAssets();
        require(total_deposit_limit.mul(10**IBEP20(Position.token).decimals()) >= totalAssets.add(_deposit_amount), "Deposit get limited");
        uint256 shares;
        if (totalSupply_ > 0) {
            shares = _deposit_amount.mul(totalSupply_).div(totalAssets, "Bunker Div error checkpoint 0");
        } else {
            shares = _deposit_amount;
        }
        return shares;
    }
    
    function deposit(uint256 _deposit_amount) external returns (bool) {
        require(TAG == true, 'TAG ERROR.');
        // Calculation of pToken amount need to mint
        uint256 shares = getDepositAmountOut(_deposit_amount);
        
        // Record user deposit amount
        User memory user = users[msg.sender];
        user.depositPtokenAmount = user.depositPtokenAmount.add(shares);
        user.depositTokenAmount = user.depositTokenAmount.add(_deposit_amount);
        user.depositBlockTimestamp = block.timestamp;
        users[msg.sender] = user;

        // Mint pToken and transfer Token to cashbox
        mint(msg.sender, shares);
        IBEP20(Position.token).transferFrom(msg.sender, address(this), _deposit_amount);
        
        return true;
    }
    
    function getWithdrawAmount() external view returns (uint256) {
        uint256 totalAssets = getTotalAssets();
        uint256 withdraw_amount = balanceOf(msg.sender);
        uint256 value = withdraw_amount.mul(totalAssets).div(totalSupply_, "Bunker Div error checkpoint 1");
        User memory user = users[msg.sender];
        if (withdraw_amount > user.depositPtokenAmount) {
            return 0;
        }
        uint256 dofin_value;
        uint256 user_value;
        if (value > user.depositTokenAmount) {
            dofin_value = value.sub(user.depositTokenAmount, "Bunker Sub error checkpoint 0").mul(20).div(100, "Bunker Div error checkpoint 2");
            user_value = value.sub(dofin_value, "Bunker Sub error checkpoint 1");
        } else {
            user_value = value;
        }
        
        return user_value;
    }
    
    function withdraw() external returns (bool) {
        require(TAG == true, 'TAG ERROR.');
        uint256 withdraw_amount = balanceOf(msg.sender);
        require(withdraw_amount > 0, "Proof token amount insufficient");
        uint256 totalAssets = getTotalAssets();
        uint256 value = withdraw_amount.mul(totalAssets).div(totalSupply_, "Bunker Div error checkpoint 3");
        User memory user = users[msg.sender];
        bool need_rebalance = false;
        require(withdraw_amount <= user.depositPtokenAmount, "Proof token amount incorrect");
        require(block.timestamp > user.depositBlockTimestamp, "Deposit and withdraw in same block");
        // If no enough amount of free funds can transfer will trigger exit position
        if (value > IBEP20(Position.token).balanceOf(address(this))) {
            Position = HighLevelSystem.exitPosition(HLSConfig, Position, 1);
            totalAssets = IBEP20(Position.token).balanceOf(address(this));
            value = withdraw_amount.mul(totalAssets).div(totalSupply_, "Bunker Div error checkpoint 4");
            need_rebalance = true;
        }
        // Will charge 20% fees
        burn(msg.sender, withdraw_amount);
        uint256 dofin_value;
        uint256 user_value;
        // TODO need double check
        if (value > user.depositTokenAmount.add(10**IBEP20(Position.token).decimals())) {
            dofin_value = value.sub(user.depositTokenAmount, "Bunker Sub error checkpoint 2").mul(20).div(100, "Bunker Div error checkpoint 5");
            user_value = value.sub(dofin_value, "Bunker Sub error checkpoint 3");
        } else {
            user_value = value;
        }
        // Modify user state data
        user.depositPtokenAmount = 0;
        user.depositTokenAmount = 0;
        user.depositBlockTimestamp = 0;
        users[msg.sender] = user;
        // Approve for withdraw
        IBEP20(Position.token).approve(address(this), user_value);
        IBEP20(Position.token).transferFrom(address(this), msg.sender, user_value);
        if (dofin_value > IBEP20(Position.token).balanceOf(address(this))) {
            dofin_value = IBEP20(Position.token).balanceOf(address(this));
            need_rebalance = false;
        }
        // Approve for withdraw
        IBEP20(Position.token).approve(address(this), dofin_value);
        IBEP20(Position.token).transferFrom(address(this), dofin, dofin_value);
        // Enter position again
        if (need_rebalance == true) {
            Position = HighLevelSystem.enterPosition(HLSConfig, Position, 1);
            temp_free_funds = IBEP20(Position.token).balanceOf(address(this));
        }
        
        return true;
    }

    function emergencyWithdrawal() external returns (bool) {
        require(TAG == false, 'NOT EMERGENCY');
        uint256 pTokenBalance = balanceOf(msg.sender);
        User memory user = users[msg.sender];
        require(pTokenBalance > 0,  "Incorrect quantity of Proof Token");
        require(user.depositPtokenAmount > 0, "Not depositor");

        // Approve for withdraw
        IBEP20(Position.token).approve(address(this), user.depositTokenAmount);
        IBEP20(Position.token).transferFrom(address(this), msg.sender, user.depositTokenAmount);
        
        return true;
    }
    
}