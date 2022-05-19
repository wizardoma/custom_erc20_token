// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;
import "./IBaseInterface.sol";

interface IWeb3BetsPoolsV1 is IBaseInterface{
    function bet() payable external;

}