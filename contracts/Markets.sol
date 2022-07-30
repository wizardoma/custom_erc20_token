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
    string[] public poolNames;
    address[] public poolAddresses;
    bool public hasSetWinningPool;
    address public winningPoolAddress;
    bool public isSettled = false;
    
    mapping(address => uint256) public winningPoolAddresses;

    modifier onlyEventOwner() {
        IWeb3BetsEventV1 poolEvent = IWeb3BetsEventV1(eventAddress);
        address eventOwner = poolEvent.getEventOwner();
        require(msg.sender == eventOwner, "Only event owners set winning pool");
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

        address[] memory _poolAddresses = poolAddresses;
        for (uint256 i = 0; i < _poolAddresses.length; i++) {
            if (_poolAddresses[i] == _poolAddress) {
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

        address[] memory _poolAddresses = poolAddresses;
        if (address(this).balance == 0) {
            for (uint256 i = 0; i < _poolAddresses.length; i++) {
                if (_poolAddresses[i] == _poolAddress) {
                    winningPoolAddress = _poolAddress;
                    hasSetWinningPool = true;
                    break;
                }
            }
            if (!hasSetWinningPool) {
                revert("No Pool Address was found");
            } else {
                return;
            }
        }

        // Initialize the Web3Bets address
        IWeb3Bets web3Bets = IWeb3Bets(web3BetsAddress);
        uint256 vigPercentage = web3Bets.getVigPercentage();

        // Get total stake and transfer to market
        uint256 vigShare = address(this).balance * (vigPercentage / 100);

        // send money to vig holders
        web3Bets.shareBetEarnings{value: vigShare}();
        
        uint256 poolLength = _poolAddresses.length;
        for (uint256 i = 0; i < poolLength; i++) {
            if (_poolAddresses[i] == _poolAddress) {
                if (!hasSetWinningPool) {
                    winningPoolAddress = _poolAddress;
                    hasSetWinningPool = true;
                }
                IWeb3BetsPoolsV1 pool = IWeb3BetsPoolsV1(_poolAddresses[i]);
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

    function isWinningPoolSet() external view override returns (bool) {
        if (poolAddresses.length == 0){
            return true;
        }
        
        return hasSetWinningPool;
    }

    function getPoolNames() external view returns (string[] memory) {
        return poolNames;
    }

    function getPoolAddresses() external view returns (address[] memory) {
        return poolAddresses;
    }

    function getBalance() external view returns (uint256) {
        return address(this).balance;
    }

    function isWinningPool(address pool) external view returns(bool){
        return hasSetWinningPool ? winningPoolAddress == pool : false;
    }

    function cancelMarket() external {
        if (isSettled){
            return;
        }
        if (!hasSetWinningPool){
            for (uint i = 0; i<poolAddresses.length; i++){
                IWeb3BetsPoolsV1 poolsV1 = IWeb3BetsPoolsV1(poolAddresses[i]);
                address[] memory betAddresses =poolsV1.getBets();
                for (uint j; j<betAddresses.length;j++){
                    IWeb3BetsBetsV1 betV1 = IWeb3BetsBetsV1(betAddresses[j]);
                    payable(betAddresses[j]).transfer(betV1.getBetStake());
                }
                
            }

            isSettled = true;

        }
        else {
            isSettled = true;
        }
    }

    // Function to receive Ether. msg.data must be empty
    receive() external payable {}

    // Fallback function is called when msg.data is not empty
    fallback() external payable {}

    function settleWinningPool() private {

    }
}


