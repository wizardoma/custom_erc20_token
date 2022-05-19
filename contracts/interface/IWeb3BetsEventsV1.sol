// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./IBaseInterface.sol";

interface IWeb3BetsEventV1 is IBaseInterface{
    function createMarket(string memory name) external;

    function cancelEvent() external;

    function settleEvent() external;

    // Allows callers to redeem their events in the case of a canceled event
    function redeemStake(uint256 marketId, uint256 poolId) external;

    // Allows callers to take their winnings in the case they are in a winning pool
    function takeBetWinnings(uint256 marketId, uint256 poolId) external;


    function getMarkets() external returns (address[] memory);

    function getTotalStake() external returns (uint256);

    function getMinimumStake() external returns (uint256);

    function getEventOwner() external returns (address);

}
