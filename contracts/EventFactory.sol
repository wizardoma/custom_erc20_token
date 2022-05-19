// SPDX-License-Identifier: MIT
pragma solidity >0.4.23 <0.9.0;
import "./Events.sol";


contract EventFactory {
    mapping (address => address[]) userEvents;


    event EventCreated(address eventOwner, string name, address, eventAddress);

    struct EventDetail {
        string name;
        mapping(string => MarketDetail[]) markets;
    }

    struct MarketDetail {
        string name;
        mapping(string => PoolDetail[]) pool;
    }

    struct PoolDetail {
        string name;
        uint noOfStakes;
        uint totalStake;
    }

    address[] private _events;

    address public marketFactoryAddress;

    function createEvent(
        string memory _name
    ) public returns(address) {
        Events wEvent = new Events(_name, marketFactoryAddress);
        
        userEvents[msg.sender].push(address(wEvent));
        _events.push[wEvent];

        emit EventCreated(msg.sender, name, _name, address(wEvent));
        return address(wEvent);
    }

    function getEventDetails(address eventAddress) public returns(string , string, address) {

        Events singleEvent = Events(eventAddress);

        // TODO: Add fetching single event
        return ("","",msg.sender);
    }


    function getMarketsByEvent(bytes32 eventAddress)
        public
        view
        returns (Market[] memory markets)
    {
        return eventMarkets[eventAddress];

    }


    function getEventsByAddress(address userAddress) public returns(address[]){
        return userEvents[userAddress];
    }

    function getAllEvents() public view returns(address[]){
        return _events;
    }
}