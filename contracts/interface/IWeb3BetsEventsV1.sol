// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./IBaseInterface.sol";

interface IWeb3BetsEventV1 is IBaseInterface{
    function createMarket(string memory name, uint minimumStake) external;

    function cancelEvent() external;

    function getMarkets() external returns (address[] memory);

    function getMinimumStake() external returns (uint256);

    function getEventOwner() external returns (address);

    function getEventStatus() external returns (uint);

}
