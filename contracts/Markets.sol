// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

import "./interface/IWeb3BetsMarketV1.sol";
import "./interface/IWeb3BetsEventsV1.sol";
import "./interface/IWeb3BetsPoolsV1.sol";
import "./interface/IWeb3Bets.sol";
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

    modifier uniqueName(string memory value) {
        bool isNotEqual = true;
        uint poolNamesLength = poolNames.length;
        for (uint i = 0; i < poolNamesLength; i++) {
            if (keccak256(abi.encodePacked(value)) == keccak256(abi.encodePacked(poolNames[i]))) {
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
        uint256 poolLength = poolNames.length;
        require(
            poolLength > 0,
            "Cannot set winning pool on market with no pool"
        );
        for (uint256 i = 0; i < poolLength; i++) {
            if (pools[poolNames[i]] == _poolAddress) {
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
    override
        external
        onlyEventOwner
        uniqueName(_name)
    {
        PoolsFactory poolsFactory = PoolsFactory(poolFactoryAddress);
        address poolAddress = poolsFactory.createPool(
            _name,
            eventAddress,
            address(this)
        );
        pools[_name] = poolAddress;
        poolNames.push(_name);
    }

    function setWinningPool(address _poolAddress)
    override
        external
        onlyEventOwner
        validWinningPool(_poolAddress)
    {
        // Initialize the Web3Bets address
        IWeb3Bets web3Bets = IWeb3Bets(web3BetsAddress);
        uint vigPercentage = web3Bets.getVigPercentage();

        // Get total stake and transfer to market
        // TODO: discuss with client: formulate pragmatic algorithm for bet winnings
        uint poolLength = poolNames.length;
        for (uint i = 0; i < poolLength; i++){
            IWeb3BetsPoolsV1 pool = IWeb3BetsPoolsV1(pools[poolNames[i]]);
            
        }
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

    function getTotalStake() external override returns (uint) {

        uint totalStake;

        for (uint i = 0; i < poolNames.length; i++){
            IWeb3BetsPoolsV1 betsPool = IWeb3BetsPoolsV1(pools[poolNames[i]]);
            totalStake += betsPool.getTotalStake();
        }

        return totalStake;
    }

    // function _toLower(string memory str) internal returns (string memory) {
    //     bytes memory bStr = bytes(str);
    //     bytes memory bLower = new bytes(bStr.length);
    //     for (uint256 i = 0; i < bStr.length; i++) {
    //         // Uppercase character...
    //         if ((bStr[i] >= 0x65) && (bStr[i] <= 0x90)) {
    //             // So we add 32 to make it lowercase
    //             bLower[i] = bytes1(int256(bStr[i]) + 32);
    //         } else {
    //             bLower[i] = bStr[i];
    //         }
    //     }
    //     return string(bLower);
    // }
}
