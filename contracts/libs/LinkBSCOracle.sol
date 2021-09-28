// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

import "../interfaces/chainlink/AggregatorInterface.sol";

library LinkBSCOracle {
    
    // Addresss of Link.
    struct LinkConfig {
        address oracle; // Address of Link oracle contract.
    }
    
    function getPrice(LinkConfig memory self) public view returns(int256) {
        
        return AggregatorInterface(self.oracle).latestAnswer();
    }
    
    function getDecimals(LinkConfig memory self) public view returns(uint8) {
        
        return AggregatorInterface(self.oracle).decimals();
    }
    
}