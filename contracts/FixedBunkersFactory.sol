// SPDX-License-Identifier: MIT
pragma solidity >=0.8;

import "./FixedBunker.sol";
import "./utils/BasicContract.sol";
import { HighLevelSystem } from "./libs/HighLevelSystem.sol";

/// @title FixedBunkersFactory
/// @author Andrew FU
contract FixedBunkersFactory is BasicContract {
    
    uint256 public BunkerId;
    uint256 public BunkersLength;
    mapping (address => uint256) public BunkerToId;
    mapping (uint256 => address) public IdToBunker;

    function createBunker (uint256[1] memory _uints, address[6] memory _addrs, string memory _name, string memory _symbol, uint8 _decimals) external onlyOwner returns(address) {
        BunkerId++;
        BunkersLength++;
        FixedBunker newBunker = new FixedBunker(_uints, _addrs, _name, _symbol, _decimals);
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
            FixedBunker bunker = FixedBunker(IdToBunker[_ids[i]]);
            bunker.setTag(_tag);
        }
        return true;
    }

    function setConfigBunker (uint256 _id, address[4] memory _config, address _dofin, uint256 _deposit_limit) external onlyOwner returns(bool) {
        FixedBunker bunker = FixedBunker(IdToBunker[_id]);
        bunker.setConfig(_config, _dofin, _deposit_limit);
        return true;
    }

    function getTotalAssetsBunkers (uint256[] memory _ids) external view returns(uint256[] memory) {
        uint256[] memory BunkersTotalAssets = new uint256[] (_ids.length);
        uint256 temp;
        for (uint i = 0; i < _ids.length; i++) {
            FixedBunker bunker = FixedBunker(IdToBunker[_ids[i]]);
            temp = bunker.getTotalAssets();
            BunkersTotalAssets[i] = temp;
        }
        return BunkersTotalAssets;
    }

    function getPositionBunkers (uint256[] memory _ids) external view returns(HighLevelSystem.Position[] memory) {
        HighLevelSystem.Position[] memory BunkersPosition = new HighLevelSystem.Position[] (_ids.length);
        HighLevelSystem.Position memory temp;
        FixedBunker bunker;
        for (uint i = 0; i < _ids.length; i++) {
            bunker = FixedBunker(IdToBunker[_ids[i]]);
            temp = bunker.getPosition();
            BunkersPosition[i] = temp;
        }
        return BunkersPosition;
    }

    function rebalanceBunker (uint256[] memory _ids) external onlyOwner returns(bool) {
        for (uint i = 0; i < _ids.length; i++) {
            FixedBunker bunker = FixedBunker(IdToBunker[_ids[i]]);
            bunker.rebalance();
        }
        return true;
    }

    function rebalanceWithRepayBunker (uint256[] memory _ids) external onlyOwner returns(bool) {
        for (uint i = 0; i < _ids.length; i++) {
            FixedBunker bunker = FixedBunker(IdToBunker[_ids[i]]);
            bunker.rebalanceWithRepay();
        }
        return true;
    }

    function enterBunker (uint256[] memory _ids, uint256[] memory _types) external onlyOwner returns(bool) {
        require(_ids.length == _types.length, "Two length different");
        for (uint i = 0; i < _ids.length; i++) {
            FixedBunker bunker = FixedBunker(IdToBunker[_ids[i]]);
            bunker.enter(_types[i]);
        }
        return true;
    }

    function exitBunker (uint256[] memory _ids, uint256[] memory _types) external onlyOwner returns(bool) {
        require(_ids.length == _types.length, "Two length different");
        for (uint i = 0; i < _ids.length; i++) {
            FixedBunker bunker = FixedBunker(IdToBunker[_ids[i]]);
            bunker.exit(_types[i]);
        }
        return true;
    }

}