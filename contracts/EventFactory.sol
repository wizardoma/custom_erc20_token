// SPDX-License-Identifier: MIT
pragma solidity >0.4.23 <0.9.0;
import "./Events.sol";


contract EventFactory {
    mapping (address => address[]) userEvents;


    event EventCreated(address eventOwner, string name, address eventAddress);

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
        _events.push(address(wEvent));
        
        emit EventCreated(msg.sender, _name, address(wEvent));
        return address(wEvent);
    }

    function getEventDetails(address eventAddress) public returns(string memory, string memory, address) {

        Events singleEvent = Events(eventAddress);

        // TODO: Add fetching single event
        return ("","",msg.sender);
    }


    function getMarketsByEvent(address eventAddress)
        public
        view
        returns (address[] memory markets)
    {
        return userEvents[eventAddress];

    }


    function getEventsByAddress(address userAddress) public view returns(address[] memory){
        return userEvents[userAddress];
    }

    function getAllEvents() public view returns(address[] memory){
        return _events;
    }
}