// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./interface/IWeb3BetsBetsV1.sol";
import "./interface/IWeb3BetsMarketV1.sol";
import "./interface/IWeb3BetsEventsV1.sol";
import "./interface/IWeb3BetsPoolsV1.sol";

/// @author Ibekason Alexander Onyebuchi
/// @title Bet Contract
/// @notice Contain function signatures for creating bets in a
/// pool

contract Bets is IWeb3BetsBetsV1 {
    address public better;

    address public eventAddress;

    address public marketAddress;

    address public poolAddress;

    BetStatus betStatus = BetStatus.PENDING;

    uint256 public stake;

    enum BetStatus {
        PENDING,
        WON,
        LOST
    }

    constructor(
        address _eventAddress,
        address _marketAddress,
        address _poolAddress,
        uint256 _stake
    ) {
        eventAddress = _eventAddress;
        marketAddress = _marketAddress;
        stake = _stake;
        better = msg.sender;
        poolAddress = _poolAddress;
    }

    // function getBetDetails() public returns (string memory, string memory, string memory, uint) {
    //     IWeb3BetsEventV1 betEvent= IWeb3BetsEventV1(eventAddress);
    //     IWeb3BetsMarketV1 betMarket= IWeb3BetsMarketV1(marketAddress);
    //     IWeb3BetsPoolsV1 pool = IWeb3BetsPoolsV1(poolAddress);

    //     Bet memory bet = Bet({
    //         eventName:  betEvent.getName(),
    //         marketName: betMarket.getName(),
    //         stake: stake,
    //         poolName: pool.getName()
    //     });

    //     return bet;
    // }

    function getStatus() external view returns (uint256) {
        return uint256(betStatus);
    }

    function getBetStake() external view returns (uint256) {
        return stake;
    }

    function getBetStaker() external view returns (address) {
        return better;
    }

    function getBetPoolAddress() external view returns (address) {
        return poolAddress;
    }

    function getBetMarketAddress() external view returns (address) {
        return marketAddress;
    }

    function getBetEventAddress() external view returns (address) {
        return eventAddress;
    }
}
