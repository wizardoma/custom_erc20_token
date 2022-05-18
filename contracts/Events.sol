// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

import './interface/IWeb3BetsEventsV1.sol';
import "./MarketFactory.sol";

import "@openzeppelin/contracts/utils/Strings.sol";

contract Events is IWeb3BetsEventV1{

    address public eventOwner;

    Market[] markets;

    string public name;

    string public description;

    address public marketFacoryAdress;

    mapping (address => uint) winners;

    struct Market {
        bytes32 id;
        string name;
        address marketAddress;
        string description;
        MarketStatus status;
    }


    constructor(string memory eventName, string memory eventDescription) {
        name= eventName;
        description = eventDescription;
    }

    enum MarketStatus {
        PENDING,
        FINISHED
    }

    modifier onlyOwner {
        require(msg.sender == eventOwner, "Event operations only applicable to owner");
    
    _;
    }

    function createMarket(string memory eName, string memory eDescription) override onlyOwner external{
        bytes32 id = keccak256(abi.encodePacked(eName,Strings.toString(block.timestamp)));
        MarketFactory factory = MarketFactory(au);
        address marketAddress = MarketFactory.createMarket(name, description,id,address(this));

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