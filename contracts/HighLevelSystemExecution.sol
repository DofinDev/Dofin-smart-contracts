// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

import "./token/BEP20/IBEP20.sol";
import "./math/SafeMath.sol";
import "./utils/BasicContract.sol";
import { PancakeSwapExecution } from "./libs/PancakeSwapExecution.sol";
import { CreamExecution } from "./libs/CreamExecution.sol";
import { LinkBSCOracle } from "./libs/LinkBSCOracle.sol";

/// @title High level system execution
/// @author Andrew FU
/// @dev All functions haven't finished unit test
contract HighLevelSystem is BasicContract {
    // Chainlink
    address private link_oracle;

    // Cream
    address private constant cream_oracle = 0xab548FFf4Db8693c999e98551C756E6C2948C408;
    address private constant cream_troller = 0x589DE0F0Ccf905477646599bb3E5C622C84cC0BA;
    address private constant crWBNB = 0x15CC701370cb8ADA2a2B6f4226eC5CF6AA93bC67;
    address private constant crBNB = 0x1Ffe17B99b439bE0aFC831239dDECda2A790fF3A;
    address private constant crUSDC = 0xD83C88DB3A6cA4a32FFf1603b0f7DDce01F5f727;

    // PancakeSwap
    address private constant FACTORY = 0xcA143Ce32Fe78f1f7019d7d551a6402fC5350c73;
    address private constant ROUTER = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    address private constant MASTERCHEF = 0x73feaa1eE314F8c655E354234017bE2193C9E24E;
    
    // StableCoin
    address private constant WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address private constant BNB = 0xcA143Ce32Fe78f1f7019d7d551a6402fC5350c73;
    address private constant USDT = 0x55d398326f99059fF775485246999027B3197955;
    address private constant TUSD = 0x14016E85a25aeb13065688cAFB43044C2ef86784;
    address private constant BUSD = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;
    address private constant USDC = 0x8AC76a51cc950d9822D68b83fE1Ad97B32Cd580d;
    
    // Position
    uint private pool_id;
    uint private a_amount;
    uint private b_amount;
    address private token_a_address;
    address private token_b_address;
    address private lp_address;
    address private CrTokenAAddress;
    address private CrTokenBAddress;
    uint private max_amount_per_position;
    
    constructor(uint _poolId, address[] memory _addrs, uint[] memory _amounts) {
        pool_id = _poolId;
        
        a_amount = _amounts[0];
        b_amount = _amounts[1];
        
        token_a_address = _addrs[0];
        token_b_address = _addrs[1];
        lp_address = _addrs[2];
        CrTokenAAddress = _addrs[3];
        CrTokenBAddress = _addrs[4];
        link_oracle = _addrs[5];
    }
    
    function readExistingPositions() public onlyOwner view returns (uint) {
        
        return pool_id;
    }
    
    function enter() public returns (bool) {
        // add liquidity
        addLiquidity();
        
        // stake
        stakeLP();
        
        return true;
    }
    
    function isStableCoin(address _token) public pure returns (bool) {
        if (_token == USDT) {
            return true;
        }
        else if (_token == TUSD) {
            return true;
        }
        else if (_token == BUSD) {
            return true;
        }
        else if (_token == USDC) {
            return true;
        }
        else {
            return false;
        }
    }
    
    function getPrice(address _token_a, address _token_b, address _crtoken_a, address _crtoken_b) public view returns (uint) {
        if (_token_a == WBNB) {
            _token_a = BNB;
        }
        if (_token_b == WBNB) {
            _token_b = BNB;
        }
        if (isStableCoin(_token_a) && isStableCoin(_token_b)) {
            return 1;
        }

        // check if we can get data from chainlink
        uint price;
        if (link_oracle != address(0)) {
            price = uint(LinkBSCOracle.getPrice(link_oracle));
            return price;
        }

        // check if we can get data from cream
        if (_crtoken_a != address(0) && _crtoken_b != address(0)) {
            uint price_a = CreamExecution.getUSDPrice(cream_oracle, _crtoken_a, crUSDC, USDC);
            uint price_b = CreamExecution.getUSDPrice(cream_oracle, _crtoken_b, crUSDC, USDC);
            return SafeMath.div(price_a, price_b);
        }

        // check if we can get data from pancake
        price = PancakeSwapExecution.getAmountsOut(ROUTER, FACTORY, _token_a, _token_b);
        return price;
    }

    // function checkBorrowLiquidity() public view returns (bool) {
    //     uint available_a = CreamExecution.getAvailableBorrow(CrTokenAAddress);
    //     uint available_b = CreamExecution.getAvailableBorrow(CrTokenBAddress);

    //     if (available_a > a_amount && available_b > b_amount) {
    //         return true;
    //     } else {
    //         return false;
    //     }
    // }

    // function getLPUSDValue(uint lp_constituient_0, uint lp_constituient_1, address _lp_token) public view returns (uint) {
    //     (address token_0, address token_1) = PancakeSwapExecution.getLPTokenAddresses(_lp_token);

    //     uint token_0_exch_rate = getPrice(token_0, USDC);
    //     uint token_1_exch_rate = getPrice(token_1, USDC);

    //     uint usd_value_0 = SafeMath.mul(token_0_exch_rate, lp_constituient_0);
    //     uint usd_value_1 = SafeMath.mul(token_1_exch_rate, lp_constituient_1);

    //     return usd_value_0 + usd_value_1;
    // }
    
    function exit() public returns (bool) {
        // unstake
        unstakeLP();

        // remove liquidity
        removeLiquidity();
        
        return true;
    }

    // function getTotalBorrowAmount() public view returns (uint, uint) {
    //     uint crtoken_a_borrow_amount = CreamExecution.getBorrowAmount(CrTokenAAddress, crWBNB);
    //     uint crtoken_b_borrow_amount = CreamExecution.getBorrowAmount(CrTokenBAddress, crWBNB);
    //     return (crtoken_a_borrow_amount, crtoken_b_borrow_amount);
    // }

    // function getTotalCakePendingRewards() public view returns (uint) {
    //     uint cake_amnt = PancakeSwapExecution.getPendingFarmRewards(MASTERCHEF, pool_id);
    //     return cake_amnt;
    // }

    // function supplyCream(address _crtoken, uint _amount) public returns (uint) {
    //     uint exchange_rate = CreamExecution.getExchangeRate(_crtoken);
    //     uint crtoken_amount = SafeMath.div(_amount, exchange_rate);
    //     return CreamExecution.supply(_crtoken, crtoken_amount);
    // }

    function getFreeCash() public returns (uint) {
        uint current_supply_amount = CreamExecution.getUserTotalSupply(crUSDC);
        uint position_a_amnt = CreamExecution.getBorrowAmount(CrTokenAAddress, crWBNB);
        uint position_b_amnt = CreamExecution.getBorrowAmount(CrTokenBAddress, crWBNB);
        uint current_borrow_amount = SafeMath.add(position_a_amnt, position_b_amnt);
        uint free_cash = SafeMath.sub(SafeMath.div(SafeMath.mul(current_supply_amount, 75), 100), current_borrow_amount);

        return free_cash;
    }

    function splitUnits(uint dollar_amount, address _token_a, address _token_b, address _crtoken_a, address _crtoken_b) public view returns (uint, uint) {
        uint half_amount = SafeMath.div(dollar_amount, 2);
        uint price_a = getPrice(_token_a, USDT, _crtoken_a, crUSDC);
        uint price_b = getPrice(_token_b, USDT, _crtoken_b, crUSDC);
        
        uint units_a = SafeMath.div(half_amount, price_a);
        uint units_b = SafeMath.div(half_amount, price_b);

        return (units_a, units_b);
    }

    function calculateEntryAmounts() public returns (uint, uint) {
        (uint max_position_size_a, uint max_position_size_b) = splitUnits(max_amount_per_position, token_a_address, token_b_address, CrTokenAAddress, CrTokenBAddress);
        uint max_borrow_limit = checkPotentialBorrowLimit(max_position_size_a, max_position_size_b);
        max_borrow_limit = SafeMath.mul(max_borrow_limit, 100);
        // TODO need to < 0.75
        if (max_borrow_limit < 75) {
            return (max_position_size_a, max_position_size_b);
        }

        uint free_cash = getFreeCash();
        (uint min_position_size_a, uint min_position_size_b) = splitUnits(free_cash, token_a_address, token_b_address, CrTokenAAddress, CrTokenBAddress);
        uint min_borrow_limit = checkPotentialBorrowLimit(min_position_size_a, min_position_size_b);
        min_borrow_limit = SafeMath.mul(min_borrow_limit, 100);
        // TODO need to < 0.75
        if (min_borrow_limit < 75) {
            return (min_position_size_a, min_position_size_b);
        }

        // cannot enter position
        return (0, 0);
    }

    // function generatePosition() public {
    //     (uint amount_a, uint amount_b) = calculateEntryAmounts();
    //     a_amount = amount_a;
    //     b_amount = amount_b;
    // }

    function enterPosition() public {
        // Borrowing position
        borrowPosition();

        // Entering position
        enter();
    }

    function exitPosition() public {
        // Exiting position
        exit();

        // Returning borrow
        returnBorrow();
    }

    function returnBorrow() public {
        uint borrowed_a = CreamExecution.getBorrowAmount(CrTokenAAddress, crWBNB);
        uint borrowed_b = CreamExecution.getBorrowAmount(CrTokenBAddress, crWBNB);

        uint current_a_balance = CreamExecution.getTokenBalance(token_a_address);
        uint current_b_balance = CreamExecution.getTokenBalance(token_b_address);

        uint a_repay_amount;
        uint b_repay_amount;

        if (borrowed_a < current_a_balance) {
            a_repay_amount = borrowed_a;
        } else {
            a_repay_amount = current_a_balance;
        }
        if (borrowed_b < current_b_balance) {
            b_repay_amount = borrowed_b;
        } else {
            b_repay_amount = current_b_balance;
        }

        // CrTokenAddress issue
        uint _isWBNB = isWBNB(token_a_address, token_b_address);
        if (_isWBNB == 2) {
            CreamExecution.repay(CrTokenAAddress, a_repay_amount);
            CreamExecution.repay(CrTokenBAddress, b_repay_amount);
        } else if (_isWBNB == 1) {
            CreamExecution.repayETH(CrTokenAAddress, a_repay_amount);
            CreamExecution.repay(CrTokenBAddress, b_repay_amount);
        } else if (_isWBNB == 0)  {
            CreamExecution.repay(CrTokenAAddress, a_repay_amount);
            CreamExecution.repayETH(CrTokenBAddress, b_repay_amount);
        }

    }

    function borrowPosition() public {
        CreamExecution.borrow(CrTokenAAddress, a_amount);
        CreamExecution.borrow(CrTokenBAddress, b_amount);
    }

    function isWBNB(address _token_a, address _token_b) public pure returns (uint) {
        if (_token_a == WBNB && _token_b == WBNB) {
            return 2;
        } else if (_token_a == WBNB) {
            return 1;
        } else if (_token_b == WBNB) {
            return 0;
        } else {
            return 2;
        }
    }

    // function getBorrowedCreamTokens() public view returns (address, address) {
        
    //     return (CrTokenAAddress, CrTokenBAddress);
    // }

    function checkCurrentBorrowLimit() public returns (uint) {
        uint crtoken_a_supply_amount = CreamExecution.getUserTotalSupply(CrTokenAAddress);
        uint crtoken_a_borrow_amount = CreamExecution.getBorrowAmount(CrTokenAAddress, crWBNB);
        uint crtoken_a_limit = CreamExecution.getBorrowLimit(cream_oracle, CrTokenAAddress, crUSDC, USDC, crtoken_a_supply_amount, crtoken_a_borrow_amount);

        uint crtoken_b_supply_amount = CreamExecution.getUserTotalSupply(CrTokenBAddress);
        uint crtoken_b_borrow_amount = CreamExecution.getBorrowAmount(CrTokenBAddress, crWBNB);
        uint crtoken_b_limit = CreamExecution.getBorrowLimit(cream_oracle, CrTokenBAddress, crUSDC, USDC, crtoken_b_supply_amount, crtoken_b_borrow_amount);
        return crtoken_a_limit + crtoken_b_limit;
    }

    function checkPotentialBorrowLimit(uint new_amount_a, uint new_amount_b) public returns (uint) {
        uint current_borrow_limit = checkCurrentBorrowLimit();

        uint crtoken_a_supply_amount = CreamExecution.getUserTotalSupply(CrTokenAAddress);
        uint borrow_limit_a = CreamExecution.getBorrowLimit(cream_oracle, CrTokenAAddress, crUSDC, USDC, crtoken_a_supply_amount, new_amount_a);
        
        uint crtoken_b_supply_amount = CreamExecution.getUserTotalSupply(CrTokenBAddress);
        uint borrow_limit_b = CreamExecution.getBorrowLimit(cream_oracle, CrTokenBAddress, crUSDC, USDC, crtoken_b_supply_amount, new_amount_b);

        return current_borrow_limit + borrow_limit_a + borrow_limit_b;
    }

    function addLiquidity() public returns (uint) {
        uint pair_price = getPrice(token_a_address, token_b_address, CrTokenAAddress, CrTokenBAddress);
        uint price_decimals = PancakeSwapExecution.getPairDecimals(PancakeSwapExecution.getPair(FACTORY, token_a_address, token_b_address));

        // make sure if one of the tokens is WBNB => have a minimum of 0.3 BNB in the wallet at all times
        // get a 50:50 split of the tokens in USD and make sure the two tokens are in correct order
        (uint max_available_staking_a, uint max_available_staking_b) = PancakeSwapExecution.splitTokensEvenly(a_amount, b_amount, pair_price, price_decimals);

        // todo check the lineups => amount for tokens a and tokens b is off
        (max_available_staking_a, max_available_staking_b) = PancakeSwapExecution.lineUpPairs(token_a_address, token_b_address, max_available_staking_a, max_available_staking_b, lp_address);
        (address token_a, address token_b) = PancakeSwapExecution.getLPTokenAddresses(lp_address);

        uint bnb_check = isWBNB(token_a, token_b);
        if (bnb_check != 2) {
            if (bnb_check == 1) {
                return PancakeSwapExecution.addLiquidityETH(ROUTER, token_a, max_available_staking_b, max_available_staking_a);
            } else {
                return PancakeSwapExecution.addLiquidityETH(ROUTER, token_b, max_available_staking_a, max_available_staking_b);
            }
        } else {
            return PancakeSwapExecution.addLiquidity(ROUTER, token_a, token_b, max_available_staking_a, max_available_staking_b);
        }
    }

    function removeLiquidity() public returns (bool) {
        // check how much (token0 and token1) we have in the current farm
        //this function already sorts the token orders according to the contract
        uint lp_balance = this.balanceOf(lp_address, address(this));
        (uint token_a_amnt, uint token_b_amnt) = PancakeSwapExecution.getLPConstituients(lp_balance, lp_address);

        (address token_a, address token_b) = PancakeSwapExecution.getLPTokenAddresses(lp_address);
        uint bnb_check = isWBNB(token_a, token_b);

        if (bnb_check != 2) {
            if (bnb_check == 1) {
                PancakeSwapExecution.removeLiquidityETH(ROUTER, lp_address, token_a, lp_balance, token_a_amnt, token_b_amnt);
            } else {
                PancakeSwapExecution.removeLiquidityETH(ROUTER, lp_address, token_b, lp_balance, token_b_amnt, token_a_amnt);
            }
        } else {
            PancakeSwapExecution.removeLiquidity(ROUTER, lp_address, token_a, token_b, lp_balance, token_a_amnt, token_b_amnt);
        }

        return true;
    }

    function stakeLP() public returns (bool) {
        uint lp_balance = this.balanceOf(lp_address, address(this));
        return PancakeSwapExecution.stakeLP(MASTERCHEF, pool_id, lp_balance);
    }

    function unstakeLP() public returns (bool) {
        uint lp_balance = PancakeSwapExecution.getStakedLP(MASTERCHEF, pool_id);
        return PancakeSwapExecution.unstakeLP(MASTERCHEF, pool_id, lp_balance);
    }

}





