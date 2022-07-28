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

    uint private statusSetCount = 0;

    address public poolAddress;

    BetStatus betStatus = BetStatus.PENDING;

    uint256 public stake;

    modifier onlyEventOwner {
        IWeb3BetsEventV1 betEvent = IWeb3BetsEventV1(eventAddress);
        require(tx.origin == betEvent.getEventOwner(), "Only bet owners can apply this function");
        
        _;
    }

    modifier onlyBetter {
        require(tx.origin == better, "Only event better can call this function");
        _;
    }

    modifier withdrawable {
        require(betStatus == BetStatus.WON || betStatus == BetStatus.CANCELLED, "Bet must be won or cancelled to withdraw");
        _;
    }

    enum BetStatus {
        PENDING,
        CANCELLED,
        WON,
        LOST
    }

    constructor(
        address _eventAddress,
        address _marketAddress,
        address _poolAddress,
        uint256 _stake,
        address _better
    ) {
        eventAddress = _eventAddress;
        marketAddress = _marketAddress;
        stake = _stake;
        better = _better;
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

    function getStatus() override external view returns (uint256) {
        return uint256(betStatus);
    }

    function getBetStake() override external view returns (uint256) {
        return stake;
    }

    function getBetter() override external view returns (address) {
        return better;
    }

    function getBetPoolAddress() override external view returns (address) {
        return poolAddress;
    }

    function getBetMarketAddress() override external view returns (address) {
        return marketAddress;
    }

    function getBetEventAddress() override external view returns (address) {
        return eventAddress;
    }

    function setBetStatus(uint status) override external onlyEventOwner{
        require(statusSetCount == 0, "You can not modify bet status more than once");
        betStatus = getStatus(status);
        statusSetCount =1;
    }

    function getStatus(uint status) private pure returns (BetStatus){
        if (status == 0){
            return BetStatus.PENDING;
        }

        else if (status == 1){
            return BetStatus.CANCELLED;
        }

        else if (status == 2){
            return BetStatus.WON;
        }

        else if (status == 3){
            return BetStatus.LOST;
        }
        else {
            return BetStatus.PENDING;
        }
    }

    function withdraw() override external payable onlyBetter withdrawable {
        require(address(this).balance > 0, "This bet has no funds");

        payable(msg.sender).transfer(address(this).balance);
    }


    
}
