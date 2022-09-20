// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;
import "./IBaseInterface.sol";

interface IWeb3BetsPoolsV1 is IBaseInterface {
    function bet() external payable;

    function getTotalStake() external returns (uint256);

    function getUserStake(address user) external returns (uint256);

    function getBets() external returns (address[] memory);

}
