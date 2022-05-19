// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

/// @author Ibekason Alexander Onyebuchi
/// @title Web3Bets Version 1 Bet Interface


interface IWeb3BetsBetsV1 {

    function getStatus() external returns(uint);

    function getBetStake() external returns(uint);

    function getBetStaker() external returns(address);

    function getBetPoolAddress() external returns (address);

    function getBetMarketAddress() external returns (address);

    function getBetEventAddress() external returns (address);
}