# Smart Contracts
This page provides links or locations for Dofin's smart contracts.

## Data structure

### HLSConfig
- **token_oracle**  
	+ Address of ChainLink oracle contract.  
- **token_a_oracle**  
	+ Address of ChainLink oracle contract.  
- **token_b_oracle**  
	+ Address of ChainLink oracle contract.  
- **router**  
	+ Address of PancakeSwap router contract.  
- **factory**  
	+ Address of PancakeSwap factory contract.  
- **masterchef**  
	+ Address of PancakeSwap masterchef contract.  
- **CAKE**  
	+ Address of CAKE BEP20 contract.  
- **comptroller**  
	+ Address of Cream comptroller contract.  
	
### Position
- **pool_id**  
	+ Farm pool id which we will stake.  
- **token_amount**  
	+ Amount of Bunker token balance.  
- **token_a_amount**  
	+ Amount of Bunker token a balance.  
- **token_b_amount**  
	+ Amount of Bunker token b balance.  
- **lp_token_amount**  
	+ Amount of Bunker lp token balance.  
- **crtoken_amount**  
	+ Amount of Bunker cream token balance.  
- **supply_amount**  
	+ Amount of Bunker supply token to Cream.  
- **liquidity_a**  
	+ Amount of Bunker add liquidity token a to PancakeSwap pool.  
- **liquidity_b**  
	+ Amount of Bunker add liquidity token b to PancakeSwap pool.  
- **borrowed_token_a_amount**  
	+ Amount of Bunker borrowed token a from Cream.  
- **borrowed_token_b_amount**  
	+ Amount of Bunker borrowed token b from Cream.  
- **token**  
	+ Address of token contract.  
- **token_a**  
	+ Address of token a contract.  
- **token_b**  
	+ Address of token b contract.  
- **lp_token**  
	+ Address of lp token contract.  
- **supply_crtoken**  
	+ Address of Cream token contract.  
- **borrowed_crtoken_a**  
	+ Address of Cream token contract.  
- **borrowed_crtoken_b**  
	+ Address of Cream token contract.  
- **funds_percentage**  
	+ Percentage of enter funds for position.  
- **total_depts**  
	+ Amount of total assets out of Bunker.  

## Main contracts
The following links will take you to the BscScan page for Dofin's main smart contracts.

- [FixedBunkersFactory](https://bscscan.com/address/0x0000000000000000000000000000000000000000)
- [ChargedBunkersFactory](https://bscscan.com/address/0x0000000000000000000000000000000000000000)
- [BoostedBunkersFactory](https://bscscan.com/address/0x0000000000000000000000000000000000000000)

## BunkersFactory contract
BunkersFactory contracts manage Bunker contract.  

### Contracts info
Contract name: FixedBunkersFactory  
Contract address: 0x0000000000000000000000000000000000000000  
View the [FixedBunkersFactory contract on BscScan](https://bscscan.com/address/0x0000000000000000000000000000000000000000)  

Contract name: ChargedBunkersFactory  
Contract address: 0x0000000000000000000000000000000000000000  
View the [ChargedBunkersFactory contract on BscScan](https://bscscan.com/address/0x0000000000000000000000000000000000000000)  

Contract name: BoostedBunkersFactory  
Contract address: 0x0000000000000000000000000000000000000000  
View the [BoostedBunkersFactory contract on BscScan](https://bscscan.com/address/0x0000000000000000000000000000000000000000)  

### Read functions
#### checkCaller
```solidity
function checkCaller() public view returns (bool);
```
Check transaction caller is owner or not.

### Write functions
#### transferOwnership
```solidity
function transferOwnership(address newOwner) external;
```
Transfer contract owner to new owner.  
##### Parameters

 | Name | Type |   |
 | -------- | ------- | ------- |
 | newOwner | address | New owner address. |

#### createBunker
```solidity
function createBunker (uint256[] memory _uints, address[] memory _addrs, string memory _name, string memory _symbol, uint8 _decimals) external returns(uint256, address);
```
Transfer contract owner to new owner.  
##### Parameters

 | Name | Type |   |
 | -------- | ------- | ------- |
 | uints | uint256[] | Bunker initialize uints parameters. |
 | addrs | address[] | Bunker initialize addresses parameters. |
 | name | string | Name of Bunker proof token. |
 | symbol | string | Symbol of Bunker proof token. |
 | decimals | uint8 | Decimals of Bunker proof token. |

##### Return

 | Type |   |
 | ------- | ------- |
 | uint256 | Bunker id. |
 | address | Bunker contract address. |

#### delBunker
```solidity
function delBunker (uint256[] memory _ids) external returns(bool);
```
Delete Bunker from BunkerFactory by bunker id.
##### Parameters

 | Name | Type |   |
 | -------- | ------- | ------- |
 | ids | uint256[] | Bunker id. |

##### Return

 | Type |   |
 | ------- | ------- |
 | bool | Return true if success. |

#### setTagBunkers
```solidity
function setTagBunkers (uint256[] memory _ids, bool _tag) external returns(bool);
```
Start/Stop Bunker by bunker id.
##### Parameters

 | Name | Type |   |
 | -------- | ------- | ------- |
 | ids | uint256[] | Bunker id. |
 | tag | bool | True to start bunker.<br>False to stop bunker. |

##### Return

 | Type |   |
 | ------- | ------- |
 | bool | Return true if success. |

#### setConfigBunker
```solidity
function setConfigBunker (uint256 _id, address[1] memory _config, address _dofin, uint256[2] memory _deposit_limit) external returns(bool);
```
Set Bunker config by bunker id.
##### Parameters

 | Name | Type |   |
 | -------- | ------- | ------- |
 | id | uint256 | Bunker id. |
 | config | address[] | Bunker initialize addresses parameters. |
 | dofin | address | Bunker initialize address parameter. |
 | depositlimit | uint256[] | Bunker initialize uint256 parameters. |

##### Return

 | Type |   |
 | ------- | ------- |
 | bool | Return true if success. |

#### rebalanceBunker
```solidity
function rebalanceBunker (uint256[] memory _ids) external returns(bool);
```
Rebalance Bunker by bunker id.
##### Parameters

 | Name | Type |   |
 | -------- | ------- | ------- |
 | ids | uint256[] | Bunker id. |

##### Return

 | Type |   |
 | ------- | ------- |
 | bool | Return true if success. |

#### enterBunker
```solidity
function enterBunker (uint256[] memory _ids) external returns(bool);
```
Enter Bunker position by bunker id.
##### Parameters

 | Name | Type |   |
 | -------- | ------- | ------- |
 | ids | uint256[] | Bunker id. |

##### Return

 | Type |   |
 | ------- | ------- |
 | bool | Return true if success. |

#### exitBunker
```solidity
function exitBunker (uint256[] memory _ids) external returns(bool);
```
Exit Bunker position by bunker id.
##### Parameters

 | Name | Type |   |
 | -------- | ------- | ------- |
 | ids | uint256[] | Bunker id. |

##### Return

 | Type |   |
 | ------- | ------- |
 | bool | Return true if success. |

## Bunker contract

### Read functions
#### checkCaller  
```solidity
function checkCaller() public view returns (bool);
```
Check transaction caller is owner or not.
##### Return

 | Type |   |
 | ------- | ------- |
 | bool | Return true if transaction caller is owner. |

#### getPosition
```solidity
function getPosition() external view returns(HighLevelSystem.Position memory);
```
Get Bunker position status data.
##### Return

 | Type |   |
 | ------- | ------- |
 | position | Bunker position status data. |

#### getUser
```solidity
function getUser(address _account) external view returns (User memory);
```
Get user status data.
##### Parameters

 | Name | Type |   |
 | -------- | ------- | ------- |
 | account | address | User address. |

##### Return

 | Type |   |
 | ------- | ------- |
 | User | User status data. |

#### checkAddNewFunds
```solidity
function checkAddNewFunds() external view returns (uint256);
```
Check Bunker need to add new funds or not.
##### Return

 | Type |   |
 | ------- | ------- |
 | uint256 | Return 1 if need add new funds for Bunker. |

#### getTotalAssets
```solidity
function getTotalAssets() public view returns (uint256);
```
Get total assets for Bunker.
##### Return

 | Type |   |
 | ------- | ------- |
 | uint256 | Total assets amount. |

#### getDepositAmountOut
```solidity
function getDepositAmountOut(uint256 _deposit_amount) public view returns (uint256);
```
According deposit amount to get proof token amount output.
##### Parameters

 | Name | Type |   |
 | -------- | ------- | ------- |
 | deposit amount | uint256 | Amount of deposit token. |

##### Return

 | Type |   |
 | ------- | ------- |
 | uint256 | Proof token amount. |

#### getWithdrawAmount
```solidity
function getWithdrawAmount() external view returns (uint256);
```
According proof token amount to get withdraw amount output.
##### Return

 | Type |   |
 | ------- | ------- |
 | uint256 | Amount of withdraw token. |

### Write functions
#### initialize  
```solidity
function initialize(uint256[1] memory _uints, address[2] memory _addrs, string memory _name, string memory _symbol, uint8 _decimals) external;
```
Initialize Bunker setting.
##### Parameters

 | Name | Type |   |
 | -------- | ------- | ------- |
 | uints | uint256[] | Bunker initialize uints parameters. |
 | addrs | address[] | Bunker initialize addresses parameters. |
 | name | string | Name of Bunker proof token. |
 | symbol | string | Symbol of Bunker proof token. |
 | decimals | uint8 | Decimals of Bunker proof token. |

#### setConfig
```solidity
function setConfig(address[1] memory _config, address _dofin, uint256[2] memory _deposit_limit) external;
```
Set Bunker config.
##### Parameters

 | Name | Type |   |
 | -------- | ------- | ------- |
 | config | address[] | Bunker initialize addresses parameters. |
 | dofin | address | Bunker initialize address parameter. |
 | depositlimit | uint256[] | Bunker initialize uint256 parameters. |

#### setTag
```solidity
function setTag(bool _tag) public;
```
Start/Stop Bunker with tag.
##### Parameters

 | Name | Type |   |
 | -------- | ------- | ------- |
 | tag | bool | True/False. |

#### rebalance
Note: Only FixedBunker, ChargedBunker.  
```solidity
function rebalance() external;
```
Rebalance Bunker funds.

#### rebalanceWithRepay
Note: Only ChargedBunker.  
```solidity
function rebalanceWithRepay() external;
```
Rebalance Bunker funds with repay to Cream.

#### rebalanceWithoutRepay
Note: Only ChargedBunker, BoostedBunker.  
```solidity
function rebalanceWithoutRepay() external;
```
Rebalance Bunker funds without repay to Cream.

#### autoCompound
Note: Only ChargedBunker, BoostedBunker.  
```solidity
function autoCompound(address[] calldata _path) external;
```
Compound Bunker reward.
##### Parameters

 | Name | Type |   |
 | -------- | ------- | ------- |
 | path | address[] | Swap path for PancakeSwap. |

#### enter
```solidity
function enter() external;
```
Enter Bunker position.

#### exit
```solidity
function exit() external;
```
Exit Bunker position.

#### deposit
```solidity
function deposit(uint256 _deposit_amount) external returns (bool);
```
User deposit funds to Bunker.
##### Parameters

 | Name | Type |   |
 | -------- | ------- | ------- |
 | deposit amount | uint256 | Amount of deposit token. |

##### Return

 | Type |   |
 | ------- | ------- |
 | bool | Return true if success. |

#### withdraw
```solidity
function withdraw() external returns (bool);
```
User withdraw funds from Bunker.
##### Return

 | Type |   |
 | ------- | ------- |
 | bool | Return true if success. |

#### emergencyWithdrawal
```solidity
function emergencyWithdrawal() external returns (bool);
```
Emergency withdraw when Bunker is stop working.
##### Return

 | Type |   |
 | ------- | ------- |
 | bool | Return true if success. |































