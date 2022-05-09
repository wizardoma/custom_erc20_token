// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

import './interface/IWeb3BetsEventsV1.sol';
import './library/Structs.sol';
import "./MarketFactory.sol";

import "@openzeppelin/contracts/utils/Strings.sol";

contract Events is IWeb3BetsEventV1{

    address public eventOwner;

    Market[] markets;

    mapping (address => uint) winners;

    struct Market {
        bytes32 id;
        string name;
        address marketAddress;
        string description;
        MarketStatus status;
    }


    constructor(string memory eventName, string memory eventDescription) {

    }

    enum MarketStatus {
        PENDING,
        FINISHED
    }

    modifier onlyOwner {
        require(msg.sender == eventOwner, "Event operations only applicable to owner");
    
    _;
    }

    function createMarket(string memory name, string memory description) override onlyOwner external{
        bytes32 id = keccak256(abi.encodePacked(name,Strings.toString(block.timestamp)));
        address marketAddress = MarketFactory.createMarket();

        Market memory market = Market({
            id: id,
            description: description,
            name: name,
            status: MarketStatus.PENDING,
            marketAdress: marketAddress
        });

        markets.push(market);


    }

    function cancelEvent() override onlyOwner external{}

    function settleEvent() override onlyOwner external{}

    // Allows callers to redeem their events in the case of a canceled event
    function redeemStake(uint marketId, uint poolId) override external{}

    // Allows callers to take their winnings in the case where their pool won
    function takeBetWinnings(uint marketId, uint poolId) override external{}







}