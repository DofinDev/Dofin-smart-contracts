// SPDX-License-Identifier: MIT
pragma solidity >=0.8;

import "./ChargedBunker.sol";
import "./utils/BasicContract.sol";

/// @title ChargedBunkerFactory
/// @author Andrew FU
contract ChargedBunkersFactory is BasicContract {
    
    uint256 private BunkerId;
    uint256 public BunkersLength;
    mapping (uint256 => address) public IdToBunker;

    function createBunker (uint256[2] memory _uints, address[7] memory _addrs, string memory _name, string memory _symbol, uint8 _decimals) external onlyOwner returns(uint256, address) {
        BunkerId++;
        BunkersLength++;
        ChargedBunker newBunker = new ChargedBunker();
        newBunker.initialize(_uints, _addrs, _name, _symbol, _decimals);
        IdToBunker[BunkerId] = address(newBunker);
        return (BunkerId, address(newBunker));
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
            ChargedBunker bunker = ChargedBunker(IdToBunker[_ids[i]]);
            bunker.setTag(_tag);
        }
        return true;
    }

    function setConfigBunker (uint256 _id, address[9] memory _config, address _dofin, uint256 _deposit_limit) external onlyOwner returns(bool) {
        ChargedBunker bunker = ChargedBunker(IdToBunker[_id]);
        bunker.setConfig(_config, _dofin, _deposit_limit);
        return true;
    }

    function rebalanceBunker (uint256[] memory _ids) external onlyOwner returns(bool) {
        for (uint i = 0; i < _ids.length; i++) {
            ChargedBunker bunker = ChargedBunker(IdToBunker[_ids[i]]);
            bunker.rebalance();
        }
        return true;
    }

    function rebalanceWithRepayBunker (uint256[] memory _ids) external onlyOwner returns(bool) {
        for (uint i = 0; i < _ids.length; i++) {
            ChargedBunker bunker = ChargedBunker(IdToBunker[_ids[i]]);
            bunker.rebalanceWithRepay();
        }
        return true;
    }

    function rebalanceWithoutRepayBunker (uint256[] memory _ids) external onlyOwner returns(bool) {
        for (uint i = 0; i < _ids.length; i++) {
            ChargedBunker bunker = ChargedBunker(IdToBunker[_ids[i]]);
            bunker.rebalanceWithoutRepay();
        }
        return true;
    }

    function enterBunker (uint256[] memory _ids, uint256[] memory _types) external onlyOwner returns(bool) {
        require(_ids.length == _types.length, "Two length different");
        for (uint i = 0; i < _ids.length; i++) {
            ChargedBunker bunker = ChargedBunker(IdToBunker[_ids[i]]);
            bunker.enter(_types[i]);
        }
        return true;
    }

    function exitBunker (uint256[] memory _ids, uint256[] memory _types) external onlyOwner returns(bool) {
        require(_ids.length == _types.length, "Two length different");
        for (uint i = 0; i < _ids.length; i++) {
            ChargedBunker bunker = ChargedBunker(IdToBunker[_ids[i]]);
            bunker.exit(_types[i]);
        }
        return true;
    }

}