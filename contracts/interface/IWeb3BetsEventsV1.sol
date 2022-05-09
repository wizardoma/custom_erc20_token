// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IWeb3BetsEventV1 {
    function createMarket(string memory name, string memory description) external;

    function cancelEvent() external;

    function settleEvent() external;

    // Allows callers to redeem their events in the case of a canceled event
    function redeemStake(uint marketId, uint poolId) external;

    // Allows callers to take their winnings in the case where their pool won
    function takeBetWinnings(uint marketId, uint poolId) external;

    
}