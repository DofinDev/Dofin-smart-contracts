// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

import "../interfaces/chainlink/AggregatorInterface.sol";

library LinkBSCOracle {
    
    // Addresss of Link.
    struct LinkConfig {
        address token_oracle; // Address of Link oracle contract.
        address token_a_oracle; // Address of Link oracle contract.
        address token_b_oracle; // Address of Link oracle contract.
    }
    
    function getPrice(address _chain_link_addr) public view returns(int256) {
        
        return AggregatorInterface(_chain_link_addr).latestAnswer();
    }
    
    function getDecimals(address _chain_link_addr) public view returns(uint8) {
        
        return AggregatorInterface(_chain_link_addr).decimals();
    }
    
}