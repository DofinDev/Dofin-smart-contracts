// SPDX-License-Identifier: MIT
pragma solidity >=0.8;

import "./BoostedBunker.sol";
import "./utils/BasicContract.sol";
import { HighLevelSystem } from "./libs/HighLevelSystem.sol";

/// @title BoostedBunkerFactory
/// @author Andrew FU
contract BoostedBunkerFactory is BasicContract {
    
    uint256 public BunkerId;
    uint256 public BunkersLength;
    mapping (address => uint256) public BunkerToId;
    mapping (uint256 => address) public IdToBunker;

    function createBunker (uint256[2] memory _uints, address[4] memory _addrs, string memory _name, string memory _symbol, uint8 _decimals) external onlyOwner returns(address) {
        BunkerId++;
        BunkersLength++;
        BoostedBunker newBunker = new BoostedBunker(_uints, _addrs, _name, _symbol, _decimals);
        BunkerToId[address(newBunker)] = BunkerId;
        IdToBunker[BunkerId] = address(newBunker);
        return address(newBunker);
    }

    function delBunker (uint256[] memory _ids) external onlyOwner returns(bool) {
        BunkersLength = BunkersLength - _ids.length;
        for (uint i = 0; i < _ids.length; i++) {
            delete IdToBunker[_ids[i]];
        }
        return true;
    }

    function setTagBunkers (uint256[] memory _ids, bool _tag) external onlyOwner returns(bool) {
        for (uint i = 0; i < _ids.length; i++) {
            BoostedBunker bunker = BoostedBunker(IdToBunker[_ids[i]]);
            bunker.setTag(_tag);
        }
        return true;
    }

    function setConfigBunker (uint256 _id, address[8] memory _config, address _dofin, uint256 _deposit_limit) external onlyOwner returns(bool) {
        BoostedBunker bunker = BoostedBunker(IdToBunker[_id]);
        bunker.setConfig(_config, _dofin, _deposit_limit);
        return true;
    }

    function getTotalAssetsBunkers (uint256[] memory _ids) external view returns(uint256[] memory) {
        uint256[] memory BunkersTotalAssets = new uint256[] (BunkersLength);
        uint256 temp;
        for (uint i = 0; i < _ids.length; i++) {
            BoostedBunker bunker = BoostedBunker(IdToBunker[_ids[i]]);
            temp = bunker.getTotalAssets();
            BunkersTotalAssets[i] = temp;
        }
        return BunkersTotalAssets;
    }

    function getPositionBunkers (uint256[] memory _ids) external view returns(HighLevelSystem.Position[] memory) {
        HighLevelSystem.Position[] memory BunkersPosition = new HighLevelSystem.Position[] (_ids.length);
        HighLevelSystem.Position memory temp;
        BoostedBunker bunker;
        for (uint i = 0; i < _ids.length; i++) {
            bunker = BoostedBunker(IdToBunker[_ids[i]]);
            temp = bunker.getPosition();
            BunkersPosition[i] = temp;
        }
        return BunkersPosition;
    }

    function rebalanceWithoutRepayBunker (uint256[] memory _ids) external onlyOwner returns(bool) {
        for (uint i = 0; i < _ids.length; i++) {
            BoostedBunker bunker = BoostedBunker(IdToBunker[_ids[i]]);
            bunker.rebalanceWithoutRepay();
        }
        return true;
    }

    function enterBunker (uint256[] memory _ids) external onlyOwner returns(bool) {
        for (uint i = 0; i < _ids.length; i++) {
            BoostedBunker bunker = BoostedBunker(IdToBunker[_ids[i]]);
            bunker.enter();
        }
        return true;
    }

    function exitBunker (uint256[] memory _ids) external onlyOwner returns(bool) {
        for (uint i = 0; i < _ids.length; i++) {
            BoostedBunker bunker = BoostedBunker(IdToBunker[_ids[i]]);
            bunker.exit();
        }
        return true;
    }

}