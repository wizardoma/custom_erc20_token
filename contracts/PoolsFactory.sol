// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./Pools.sol";

contract PoolsFactory {
    // All market address with their list of pools
    mapping (address => address[]) public marketPools;

    address public betsFactoryAddress;
    address[] _pools;

    event PoolCreated(string name, address marketAddress, address eventAddress);
    
    constructor(address _betsFactoryAddress){
        betsFactoryAddress = _betsFactoryAddress;
    }
    function createPool(string memory _name, address _eventAddress, address _marketAddress, uint _minimumStake) external returns (address) {
        Pool pool = new Pool(_name, _eventAddress, _marketAddress, betsFactoryAddress, _minimumStake);
        marketPools[_marketAddress].push(address(pool));
        _pools.push(address(pool));
        emit PoolCreated(_name, _marketAddress, _eventAddress);

        return address(pool);
    }

    function getPoolsOfMarket(address _marketAddress) external view returns(address[] memory){
        return marketPools[_marketAddress];
    }

    function getTotalPools() external view returns (uint){
        return _pools.length;
    }

    
}