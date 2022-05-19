// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./interface/IWeb3BetsMarketV1.sol";
import "./interface/IWeb3BetsEventsV1.sol";
import "./interface/IWeb3BetsPoolsV1.sol";
import "./PoolsFactory.sol";

contract Market is IWeb3BetsMarketV1 {
    address public owner;
    string public name;
    address public eventAddress;
    address public poolFactoryAddress;
    address public web3BetsAddress;
    mapping(string => address) pools;
    string[] poolNames;

    modifier onlyEventOwner() {
        IWeb3BetsEventV1 poolEvent = IWeb3BetsEventV1(eventAddress);
        require(
            msg.sender == poolEvent.getEventOwner(),
            "Only event owners set winning pool"
        );
        _;
    }

    modifier uniqueName(string value) {
        value = _toLower(value);
        bool isNotEqual = true;
        uint32 poolNamesLength = poolNames.length;
        for (uint32 i = 0; i < poolNamesLength; i++) {
            if (value == poolNames[i]) {
                isNotEqual = false;
                break;
            }
        }
        require(isNotEqual);

        _;
    }

    //  verify if winning pool is valid in current market
    modifier validWinningPool(address _poolAddress) {
        bool found = false;
        uint256 poolLength = pools.length;
        require(
            poolLength > 0,
            "Cannot set winning pool on market with no pool"
        );
        for (uint256 i = 0; i < poolLength; i++) {
            if (pools[i] == _poolAddress) {
                found = true;
                break;
            }
        }
        require(found, "Invalid pool address");

        _;
    }

    constructor(string memory _name, address _eventAddress) {
        owner = msg.sender;
        name = _name;
        eventAddress = _eventAddress;
    }

    function createMarketPool(string memory _name)
        external
        onlyEventOwner
        uniqueName(_name)
    {
        PoolsFactory poolsFactory = new PoolsFactory(poolFactoryAddress);
        address poolAddress = poolsFactory.createPool(
            _name,
            eventAddress,
            address(this)
        );
        pools[_name] = poolAddress;
        poolNames.push(_name);
    }

    function setWinningPool(address _poolAddress)
        external
        onlyEventOwner
        validWinningPool(poolAddress)
    {
        

    }

    function getEventName() external override returns (string memory) {
        IWeb3BetsEventV1 marketEvent = IWeb3BetsEventV1(eventAddress);
        return marketEvent.getName();
    }

    function getEventAddress() external view override returns (address) {
        return eventAddress;
    }

    function getName() external view override returns (string memory) {
        return name;
    }

    function _toLower(string str) internal returns (string) {
        bytes memory bStr = bytes(str);
        bytes memory bLower = new bytes(bStr.length);
        for (uint256 i = 0; i < bStr.length; i++) {
            // Uppercase character...
            if ((bStr[i] >= 65) && (bStr[i] <= 90)) {
                // So we add 32 to make it lowercase
                bLower[i] = bytes1(int256(bStr[i]) + 32);
            } else {
                bLower[i] = bStr[i];
            }
        }
        return string(bLower);
    }
}
