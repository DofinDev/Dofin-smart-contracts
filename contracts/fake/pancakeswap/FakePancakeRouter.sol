// SPDX-License-Identifier: MIT
pragma solidity >=0.8;

contract FakePancakeRouter {

  function quote(uint amountA, uint reserveA, uint reserveB) public returns(uint) {

    return 10;
  }

  function addLiquidityETH(address token, uint amountTokenDesired, uint amountTokenMin, uint amountETHMin, address to, uint deadline) public payable returns(uint, uint, uint) {

    return (10, 10, 10);
  }

  function addLiquidity(address tokenA, address tokenB, uint amountADesired, uint amountBDesired, uint amountAMin, uint amountBMin, address to, uint deadline) public returns(uint, uint, uint) {

    return (10, 10, 10);
  }

  function removeLiquidity(address tokenA, address tokenB, uint liquidity, uint amountAMin, uint amountBMin, address to, uint deadline) public returns (uint, uint) {
    return (10, 10);
  }

  function removeLiquidityETH(address token, uint liquidity, uint amountAMin, uint amountBMin, address to, uint deadline) public returns (uint, uint) {
    return (10, 10);
  }

  function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) public returns (uint) {
    return 10;
  }

  function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts) {
    uint[] memory a = new uint[] (2);
    a[0] = uint(1);
    a[1] = uint(2);
    return a;
  }

  function swapExactTokensForTokens(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline) external returns (uint[] memory amounts) {
    uint[] memory a = new uint[] (2);
    a[0] = uint(1);
    a[1] = uint(2);
    return a;
  }

  function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline) external payable returns (uint[] memory amounts) {
    uint[] memory a = new uint[] (2);
    a[0] = uint(1);
    a[1] = uint(2);
    return a;
  }

  function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline) external payable returns (uint[] memory amounts) {
    uint[] memory a = new uint[] (2);
    a[0] = uint(1);
    a[1] = uint(2);
    return a;
  }

  function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline) external returns (uint[] memory amounts) {
    uint[] memory a = new uint[] (2);
    a[0] = uint(1);
    a[1] = uint(2);
    return a;
  }
  
}