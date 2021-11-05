// SPDX-License-Identifier: MIT
pragma solidity >=0.8;

import "./FixedBunker.sol";
import "./utils/BasicContract.sol";
// import { HighLevelSystem } from "./libs/HighLevelSystem.sol";

/// @title FixedBunkersFactory
/// @author Andrew FU
contract FixedBunkersFactory is BasicContract {
    
    address[] public FixedBunkers;

    function createFixedBunker (uint256[1] memory _uints, address[6] memory _addrs, string memory _name, string memory _symbol, uint8 _decimals) external onlyOwner returns(address) {
        FixedBunker newBunker = new FixedBunker(_uints, _addrs, _name, _symbol, _decimals);
        FixedBunkers.push(address(newBunker));
        return address(newBunker);
    }

    function setTagAllFixedBunker (bool _tag) external onlyOwner returns(bool) {
        for (uint i = 0; i < FixedBunkers.length; i++) {
            FixedBunker bunker = FixedBunker(FixedBunkers[i]);
            bunker.setTag(_tag);
        }
        return true;
    }

    function getTotalAssetsAllFixedBunker () external view returns(uint256[] memory) {
        uint256[] memory BunkersTotalAssets = new uint256[] (FixedBunkers.length);
        uint256 temp;
        for (uint i = 0; i < FixedBunkers.length; i++) {
            FixedBunker bunker = FixedBunker(FixedBunkers[i]);
            temp = bunker.getTotalAssets();
            BunkersTotalAssets[i] = temp;
        }
        return BunkersTotalAssets;
    }

}