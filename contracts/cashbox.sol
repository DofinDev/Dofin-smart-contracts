// SPDX-License-Identifier: MIT
pragma solidity >=0.8;

import "./token/BEP20/IBEP20.sol";
import "./math/SafeMath.sol";
import "./utils/BasicContract.sol";
import { HighLevelSystem } from "./libs/HighLevelSystemExecution.sol";

/// @title CashBox
/// @author Andrew FU
/// @dev All functions haven't finished unit test
contract CashBox is BasicContract {
     
    using SafeMath for uint;
    using HighLevelSystem for HighLevelSystem.HLSConfig;
    using HighLevelSystem for HighLevelSystem.CreamToken;
    using HighLevelSystem for HighLevelSystem.StableCoin;
    using HighLevelSystem for HighLevelSystem.Position;
    
    // Link
    // address private link_oracle;
    
    // Cream
    // address private constant cream_oracle = 0xab548FFf4Db8693c999e98551C756E6C2948C408;
    // address private constant cream_troller = 0x589DE0F0Ccf905477646599bb3E5C622C84cC0BA;
    
    // PancakeSwap
    // address private constant ROUTER = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    // address private constant FACTORY = 0xcA143Ce32Fe78f1f7019d7d551a6402fC5350c73;
    // address private constant MASTERCHEF = 0x73feaa1eE314F8c655E354234017bE2193C9E24E;
    
    // Cream token
    // address private constant crWBNB = 0x15CC701370cb8ADA2a2B6f4226eC5CF6AA93bC67;
    // address private constant crBNB = 0x1Ffe17B99b439bE0aFC831239dDECda2A790fF3A;
    // address private constant crUSDC = 0xD83C88DB3A6cA4a32FFf1603b0f7DDce01F5f727;
    
    // StableCoin
    // address private constant WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    // address private constant BNB = 0xcA143Ce32Fe78f1f7019d7d551a6402fC5350c73;
    // address private constant USDT = 0x55d398326f99059fF775485246999027B3197955;
    // address private constant TUSD = 0x14016E85a25aeb13065688cAFB43044C2ef86784;
    // address private constant BUSD = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;
    // address private constant USDC = 0x8AC76a51cc950d9822D68b83fE1Ad97B32Cd580d;
    
    HighLevelSystem.HLSConfig private HLSConfig;
    HighLevelSystem.CreamToken private CreamToken;
    HighLevelSystem.StableCoin private StableCoin;
    HighLevelSystem.Position private position;
    
    // Info of each user.
    struct UserInfo {
        uint amount;
        uint last_record_blocktimestamp;
    }
    
    mapping (address => UserInfo) public userInfo;
     
    constructor(address[] memory _config, address[] memory _creamtokens, address[] memory _stablecoins, uint _pool_id, uint[] memory _amounts, address[] memory _addrs, uint _max_amount_per_position) {
        setConfig(_config);
        setCreamTokens(_creamtokens);
        setStableCoins(_stablecoins);
        position = HighLevelSystem.Position({
            pool_id: _pool_id,
            a_amount: _amounts[0],
            b_amount: _amounts[1],
            token_a: _addrs[0],
            token_b: _addrs[1],
            lp_token: _addrs[2],
            crtoken_a: _addrs[3],
            crtoken_b: _addrs[4],
            max_amount_per_position: _max_amount_per_position
        });
    }
    
    function setConfig(address[] memory _config) public onlyOwner {
        HLSConfig.LinkConfig.oracle = _config[0];
        HLSConfig.CreamConfig.oracle = _config[1];
        HLSConfig.CreamConfig.troller = _config[2];
        HLSConfig.PancakeSwapConfig.router = _config[3];
        HLSConfig.PancakeSwapConfig.factory = _config[4];
        HLSConfig.PancakeSwapConfig.masterchef = _config[5];
    }
    
    function setCreamTokens(address[] memory _creamtokens) public onlyOwner {
        CreamToken.crWBNB = _creamtokens[0];
        CreamToken.crBNB = _creamtokens[1];
        CreamToken.crUSDC = _creamtokens[2];
    }
    
    function setStableCoins(address[] memory _stablecoins) public onlyOwner {
        StableCoin.WBNB = _stablecoins[0];
        StableCoin.BNB = _stablecoins[1];
        StableCoin.USDT = _stablecoins[2];
        StableCoin.TUSD = _stablecoins[3];
        StableCoin.BUSD = _stablecoins[4];
        StableCoin.USDC = _stablecoins[5];
    }
    
    function getPosition() public onlyOwner view returns(HighLevelSystem.Position memory) {
        
        return position;
    }
    
    function reblance() public onlyOwner {
        HighLevelSystem.exitPosition(HLSConfig, CreamToken, StableCoin, position);
        HighLevelSystem.enterPosition(HLSConfig, CreamToken, StableCoin, position);
    }
    
    function checkEntry() public onlyOwner {
        
        HighLevelSystem.checkEntry(HLSConfig, CreamToken, StableCoin, position);
    }
    
    function checkCurrentBorrowLimit() onlyOwner public returns (uint) {
        
        return HighLevelSystem.checkCurrentBorrowLimit(HLSConfig, CreamToken, StableCoin, position);
    }
    
    function getUserInfo() public view returns (UserInfo memory) {
        
        return userInfo[msg.sender];
    }
    
    // TODO only record
    function deposit(uint _amount) public {
        require(_amount > 0, "amount can not be 0.");
        
        UserInfo storage user = userInfo[msg.sender];
        user.amount = user.amount.add(_amount);
        user.last_record_blocktimestamp = block.timestamp;
    }
    
    // TODO only record
    function withdraw(uint _amount) public {
        require(_amount > 0, "amount can not be 0.");
        
        UserInfo storage user = userInfo[msg.sender];
        require(user.amount > 0, "No funds can withdraw.");
        
        user.amount = user.amount.sub(_amount);
        user.last_record_blocktimestamp = block.timestamp;    
    }
    
}