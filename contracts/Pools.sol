pragma solidity ^0.8.4;
import "./interface/IWeb3BetsPoolsV1.sol";
import "./interface/IWeb3BetsEventsV1.sol";
// SPDX-License-Identifier: MIT
import "./Bets.sol";

import "./BetsFactory.sol";

/// @author Ibekason Alexander Onyebuchi
/// @title Pool Contract
/// @notice Contain function signatures for creating pools in a
/// market

contract Pool is IWeb3BetsPoolsV1 {
    string public name;

    uint256 public totalStake;

    address public betsFactoryAddress;

    mapping(address => uint256) public userStakes;

    address[] public betAddresses;

    address private eventAddress;

    address private marketAddress;

    uint256 public minimumStake;

    modifier aboveMinimumStake() {
        require(
            msg.value >= 1 ether * minimumStake,
            "You can not bet below the minimum stake of event"
        );
        _;
    }

    constructor(
        string memory _name,
        address _eventAddress,
        address _marketAddress,
        address _betsFactoryAddress,
        uint256 _minimumStake
    ) {
        name = _name;
        eventAddress = _eventAddress;
        marketAddress = _marketAddress;
        betsFactoryAddress = _betsFactoryAddress;
        minimumStake = _minimumStake;
    }

    function bet() public payable override aboveMinimumStake {
        BetsFactory betsFactory = BetsFactory(betsFactoryAddress);
        address betAddress = betsFactory.createBet(
            marketAddress,
            eventAddress,
            address(this),
            msg.value,
            msg.sender
        );
        totalStake += msg.value;
        userStakes[msg.sender] = msg.value;
        betAddresses.push(betAddress);
        (bool sentBetFundToMarket, ) = marketAddress.call{value: msg.value}("");

        if (!sentBetFundToMarket) {
            revert("An Error occurred in transaction");
        }
    }

    fallback() external payable {
        totalStake += msg.value;

        userStakes[msg.sender] += msg.value;
    }

    function getName() external view override returns (string memory) {
        return name;
    }

    function getBalance() external view returns (uint256) {
        return address(this).balance;
    }

    function getTotalStake() external view returns (uint256) {
        return totalStake;
    }

    function getBets() external view override returns (address[] memory) {
        return betAddresses;
    }

    function getUserStake(address user) external view returns (uint256) {
        return userStakes[user];
    }
}
