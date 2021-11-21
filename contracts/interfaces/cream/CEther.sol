// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0;

interface CEther {
    /**
     * @notice Sender repays their own borrow
     * @dev Reverts upon any failure
     */
    function repayBorrow() external payable;
}