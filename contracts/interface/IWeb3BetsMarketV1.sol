// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

interface IWeb3BetsMarketV1{

    function createMarketPool(string memory name, string memory description) external;

// Setting a winning pool marks a market as finished and cannot be undone
    function setWinningPool(uint poolId) external;

}