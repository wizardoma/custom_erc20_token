pragma solidity ^0.8.4;

import "./interface/IWeb3BetsMarketV1.sol";
import "./interface/IWeb3BetsEventsV1.sol";

contract Market is IWeb3BetsMarketV1{

    address public owner;
    string public name;
    address public eventAddress;
    address marketFactoryAddress;

    address[] pools;

    modifier onlyEventOwner {
        IWeb3BetsEventV1 poolEvent = IWeb3BetsEventV1(eventAddress);
        require(msg.sender == poolEvent.getEventOwner(), "Only event owners set winning pool");
        _;
    }

//  Modifier to verify if winning pool is valid in market
    modifier validWinningPool(address poolAddress) {
        bool found = false;
        uint poolLength = pools.length;
        require(poolLength> 0, "Cannot set winning pool on market with no pool");
        for (uint i = 0; i< poolLength; i++){
            if (pools[i] == poolAddress){
                found =true;
                break;
            }
        }
        require(found, "Invalid pool address");

        _;
    }
    
    constructor(string memory _name, address _eventAddress) {
        owner = msg.sender;
        name = _name;
        eventAddress = _eventAddress;
    }

    function createMarketPool(string memory _name) external {

    }

    function setWinningPool(address poolAddress) external onlyEventOwner validWinningPool(poolAddress) {

    } 

    function getEventName() override external returns (string memory){
        IWeb3BetsEventV1 marketEvent = IWeb3BetsEventV1(eventAddress);
        return marketEvent.getName();
    }

    function getEventAddress() override external view returns (address){
        return eventAddress;
    } 

    function getName() override external view returns(string memory){
        return name;
    }

}