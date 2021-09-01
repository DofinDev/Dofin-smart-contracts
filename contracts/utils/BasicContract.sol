// SPDX-License-Identifier: MIT
pragma solidity >=0.8;

import "../token/BEP20/IBEP20.sol";
import "../access/Ownable.sol";

contract BasicContract is Ownable {
    
    event IntLog(string message, uint val);
    event StrLog(string message, string val);
    event AddrLog(string message, address val);
    
    function balanceOf(address _token, address _address) external view returns (uint) {
        return IBEP20(_token).balanceOf(_address);
    }
    
    function approveForContract(address _token, address _spender, uint _amount) private onlyOwner {
        IBEP20(_token).approve(_spender, _amount);
    }
    
    function allowance(address _token, address _owner, address _spender) external view returns (uint) {
        return IBEP20(_token).allowance(_owner, _spender);
    }
    
    function transferBack(address _token, uint _amount) external onlyOwner {
        IBEP20(_token).approve(address(this), _amount);
        IBEP20(_token).transferFrom(address(this), msg.sender, _amount);
    }

}