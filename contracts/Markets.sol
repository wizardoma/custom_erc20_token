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
    uint256 public minimumStake;
    mapping(string => address) public pools;
    string[] public poolNames;
    address[] public poolAddresses;
    bool public hasSetWinningPool;
    address public winningPoolAddress;
    mapping(address => uint256) public winningPoolAddresses;

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
        uint256 poolNamesLength = poolNames.length;
        for (uint256 i = 0; i < poolNamesLength; i++) {
            if (
                keccak256(abi.encodePacked(value)) ==
                keccak256(abi.encodePacked(poolNames[i]))
            ) {
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

    constructor(
        string memory _name,
        address _eventAddress,
        address _poolFactoryAddress,
        address _web3betsAddress,
        uint256 _minimumStake
    ) {
        owner = tx.origin;
        name = _name;
        eventAddress = _eventAddress;
        poolFactoryAddress = _poolFactoryAddress;
        web3BetsAddress = _web3betsAddress;
        minimumStake = _minimumStake;
    }

    function createMarketPool(string memory _name)
        external
        override
        onlyEventOwner
        uniqueName(_name)
    {
        PoolsFactory poolsFactory = PoolsFactory(poolFactoryAddress);
        address poolAddress = poolsFactory.createPool(
            _name,
            eventAddress,
            address(this),
            minimumStake
        );
        pools[_name] = poolAddress;
        poolNames.push(_name);
        poolAddresses.push(poolAddress);
    }

    function setWinningPool(address _poolAddress)
        external
        override
        onlyEventOwner
        validWinningPool(_poolAddress)
    {
        if (hasSetWinningPool == true && winningPoolAddress != address(0)) {
            revert("Winning Pool already set");
        }
        if (address(this).balance == 0) {
            for (uint256 i = 0; i < poolAddresses.length; i++) {
                if (poolAddresses[i] == _poolAddress) {
                    winningPoolAddress = _poolAddress;
                    hasSetWinningPool = true;
                    break;
                }
            }

            revert("No Pool Address was found");
        }

        // Initialize the Web3Bets address
        IWeb3Bets web3Bets = IWeb3Bets(web3BetsAddress);
        uint256 vigPercentage = web3Bets.getVigPercentage();

        // Get total stake and transfer to market

        uint256 vigShare = address(this).balance * (vigPercentage / 100);

        // send money to vig holders
        web3Bets.shareBetEarnings{value: vigShare}();
        uint256 poolLength = poolAddresses.length;
        for (uint256 i = 0; i < poolLength; i++) {
            if (poolAddresses[i] == _poolAddress) {
                if (!hasSetWinningPool) {
                    winningPoolAddress = _poolAddress;
                    hasSetWinningPool = true;
                }
                IWeb3BetsPoolsV1 pool = IWeb3BetsPoolsV1(poolAddresses[i]);
                address[] memory winners = pool.getBets();
                for (uint256 j = 0; j < winners.length; j++) {
                    uint256 userStake = pool.getUserStake(winners[j]);
                    payable(winners[i]).transfer(
                        (((userStake / pool.getTotalStake()) * 100) / 100) *
                            address(this).balance
                    );
                }
                break;
            }
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

    function getTotalStake() external override returns (uint256) {
        uint256 totalStake;

        for (uint256 i = 0; i < poolNames.length; i++) {
            IWeb3BetsPoolsV1 betsPool = IWeb3BetsPoolsV1(pools[poolNames[i]]);
            totalStake += betsPool.getTotalStake();
        }

        return totalStake;
    }

    function isWinningPoolSet() external view override returns (bool) {
        return hasSetWinningPool;
    }

    function getPoolNames() external view returns (string[] memory) {
        return poolNames;
    }

    function getPoolAddresses() external view returns (address[] memory) {
        return poolAddresses;
    }

    function getPoolAddressFromName(string memory _name)
        external
        view
        returns (address)
    {
        return pools[_name];
    }

    function getBalance() external view returns (uint256) {
        return address(this).balance;
    }

    // Function to receive Ether. msg.data must be empty
    receive() external payable {}

    // Fallback function is called when msg.data is not empty
    fallback() external payable {}

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
