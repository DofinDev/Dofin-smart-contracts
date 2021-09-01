// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

interface AggregatorInterface {
  function latestAnswer() external view returns (int256);
  function latestTimestamp() external view returns (uint256);
  function latestRound() external view returns (uint256);
  function getAnswer(uint256 roundId) external view returns (int256);
  function getTimestamp(uint256 roundId) external view returns (uint256);
  function decimals() external view returns (uint8);

  event AnswerUpdated(int256 indexed current, uint256 indexed roundId, uint256 updatedAt);
  event NewRound(uint256 indexed roundId, address indexed startedBy, uint256 startedAt);
}

library LinkBSCOracle {
    
    function getPrice(address OracleAddr) public view returns(int256) {
        
        return AggregatorInterface(OracleAddr).latestAnswer();
    }
    
    function getDecimals(address OracleAddr) public view returns(uint8) {
        
        return AggregatorInterface(OracleAddr).decimals();
    }
    
}