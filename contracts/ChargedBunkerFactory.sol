// SPDX-License-Identifier: MIT
pragma solidity >=0.8;

import "./ChargedBunker.sol";
// import "./BoostedBunker.sol";
import "./utils/BasicContract.sol";
// import { HighLevelSystem } from "./libs/HighLevelSystem.sol";

/// @title ChargedBunkerFactory
/// @author Andrew FU
contract ChargedBunkerFactory is BasicContract {
    
    address[] public ChargedBunkers;

    function createBunker (uint256[2] memory _uints, address[7] memory _addrs, string memory _name, string memory _symbol, uint8 _decimals) external onlyOwner returns(address) {
        ChargedBunker newBunker = new ChargedBunker(_uints, _addrs, _name, _symbol, _decimals);
        ChargedBunkers.push(address(newBunker));
        return address(newBunker);
    }

    function setTagAllBunkers (bool _tag) external onlyOwner returns(bool) {
        for (uint i = 0; i < ChargedBunkers.length; i++) {
            ChargedBunker bunker = ChargedBunker(ChargedBunkers[i]);
            bunker.setTag(_tag);
        }
        return true;
    }

    function getTotalAssetsAllBunkers () external view returns(uint256[] memory) {
        uint256[] memory BunkersTotalAssets = new uint256[] (ChargedBunkers.length);
        uint256 temp;
        for (uint i = 0; i < ChargedBunkers.length; i++) {
            ChargedBunker bunker = ChargedBunker(ChargedBunkers[i]);
            temp = bunker.getTotalAssets();
            BunkersTotalAssets[i] = temp;
        }
        return BunkersTotalAssets;
    }

}