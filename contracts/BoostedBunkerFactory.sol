// SPDX-License-Identifier: MIT
pragma solidity >=0.8;

import "./BoostedBunker.sol";
import "./utils/BasicContract.sol";
// import { HighLevelSystem } from "./libs/HighLevelSystem.sol";

/// @title BoostedBunkerFactory
/// @author Andrew FU
contract BoostedBunkerFactory is BasicContract {
    
    address[] public BoostedBunkers;

    function createBunker (uint256[2] memory _uints, address[4] memory _addrs, string memory _name, string memory _symbol, uint8 _decimals) external onlyOwner returns(address) {
        BoostedBunker newBunker = new BoostedBunker(_uints, _addrs, _name, _symbol, _decimals);
        BoostedBunkers.push(address(newBunker));
        return address(newBunker);
    }

    function setTagAllBunkers (bool _tag) external onlyOwner returns(bool) {
        for (uint i = 0; i < BoostedBunkers.length; i++) {
            BoostedBunker bunker = BoostedBunker(BoostedBunkers[i]);
            bunker.setTag(_tag);
        }
        return true;
    }

    function getTotalAssetsAllBunkers () external view returns(uint256[] memory) {
        uint256[] memory BunkersTotalAssets = new uint256[] (BoostedBunkers.length);
        uint256 temp;
        for (uint i = 0; i < BoostedBunkers.length; i++) {
            BoostedBunker bunker = BoostedBunker(BoostedBunkers[i]);
            temp = bunker.getTotalAssets();
            BunkersTotalAssets[i] = temp;
        }
        return BunkersTotalAssets;
    }

}