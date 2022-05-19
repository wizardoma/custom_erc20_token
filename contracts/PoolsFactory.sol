// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./Pools.sol";

contract PoolsFactory {
    // All market address with their list of pools
    mapping (address => address[]) marketPools;

    event PoolCreated(string name, address marketAddress, address eventAddress);
    
    function createPool(string memory _name, address _eventAddress, address _marketAddress) external returns (address) {
        Pool pool = new Pool(_name, _eventAddress, _marketAddress);
        marketPools[marketAddress].push(address(pool));

        emit PoolCreated(_name, _marketAddress, _eventAddress);

        return address(pool);
    }

    function getPoolsOfMarket(address _marketAddress) external view returns(address[]){
        return marketPools[_marketAddress];
    }
    
}