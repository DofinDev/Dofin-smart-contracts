// SPDX-License-Identifier: MIT
pragma solidity >=0.8;

import "./FixedBunker.sol";

/// @title FixedBunkersFactory
/// @author Andrew FU
contract FixedBunkersFactory {
    
    address private _owner;
    uint256 private BunkerId;
    uint256 public BunkersLength;
    mapping (uint256 => address) public IdToBunker;

    constructor() {
    	_owner = msg.sender;
    }

    function transferOwnership(address newOwner) external {
        require(msg.sender == _owner, "Only Owner can call this function");
        require(newOwner != address(0), 'New owner is the zero address');
        _owner = newOwner;
    }

    function createBunker (uint256[1] memory _uints, address[6] memory _addrs, string memory _name, string memory _symbol, uint8 _decimals) external returns(uint256, address) {
        require(msg.sender == _owner, "Only Owner can call this function");
        BunkerId++;
        BunkersLength++;
        FixedBunker newBunker = new FixedBunker();
        newBunker.initialize(_uints, _addrs, _name, _symbol, _decimals);
        IdToBunker[BunkerId] = address(newBunker);
        return (BunkerId, address(newBunker));
    }

    function delBunker (uint256[] memory _ids) external returns(bool) {
        require(msg.sender == _owner, "Only Owner can call this function");
        BunkersLength = BunkersLength - _ids.length;
        for (uint i = 0; i < _ids.length; i++) {
            delete IdToBunker[_ids[i]];
        }
        return true;
    }

    function setTagBunkers (uint256[] memory _ids, bool _tag) external returns(bool) {
        require(msg.sender == _owner, "Only Owner can call this function");
        for (uint i = 0; i < _ids.length; i++) {
            FixedBunker bunker = FixedBunker(IdToBunker[_ids[i]]);
            bunker.setTag(_tag);
        }
        return true;
    }

    function setConfigBunker (uint256 _id, address[4] memory _config, address _dofin, uint256 _deposit_limit) external returns(bool) {
        require(msg.sender == _owner, "Only Owner can call this function");
        FixedBunker bunker = FixedBunker(IdToBunker[_id]);
        bunker.setConfig(_config, _dofin, _deposit_limit);
        return true;
    }

    function rebalanceBunker (uint256[] memory _ids) external returns(bool) {
        require(msg.sender == _owner, "Only Owner can call this function");
        for (uint i = 0; i < _ids.length; i++) {
            FixedBunker bunker = FixedBunker(IdToBunker[_ids[i]]);
            bunker.rebalance();
        }
        return true;
    }

    function rebalanceWithRepayBunker (uint256[] memory _ids) external returns(bool) {
        require(msg.sender == _owner, "Only Owner can call this function");
        for (uint i = 0; i < _ids.length; i++) {
            FixedBunker bunker = FixedBunker(IdToBunker[_ids[i]]);
            bunker.rebalanceWithRepay();
        }
        return true;
    }

    function enterBunker (uint256[] memory _ids, uint256[] memory _types) external returns(bool) {
        require(msg.sender == _owner, "Only Owner can call this function");
        require(_ids.length == _types.length, "Two length different");
        for (uint i = 0; i < _ids.length; i++) {
            FixedBunker bunker = FixedBunker(IdToBunker[_ids[i]]);
            bunker.enter(_types[i]);
        }
        return true;
    }

    function exitBunker (uint256[] memory _ids, uint256[] memory _types) external returns(bool) {
        require(msg.sender == _owner, "Only Owner can call this function");
        require(_ids.length == _types.length, "Two length different");
        for (uint i = 0; i < _ids.length; i++) {
            FixedBunker bunker = FixedBunker(IdToBunker[_ids[i]]);
            bunker.exit(_types[i]);
        }
        return true;
    }

}