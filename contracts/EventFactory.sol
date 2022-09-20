// SPDX-License-Identifier: MIT
pragma solidity >0.4.23 <0.9.0;
import "./Events.sol";


contract EventFactory {
    mapping (address => address[]) public userEvents;

    event EventCreated(address eventOwner, string name, address eventAddress);

    address[] public events;

    address public marketFactoryAddress;

    address public web3betsAddress;

    constructor(address _marketFactoryAddress, address _web3betsAddress){
        marketFactoryAddress = _marketFactoryAddress;
        web3betsAddress = _web3betsAddress;

    }

    function createEvent(
        string memory _name,
        uint _minimumStake
    ) public returns(address) {
        IWeb3Bets web3bets = IWeb3Bets(web3betsAddress);
        bool isEventOwner = web3bets.isEventOwner(msg.sender);
        require(isEventOwner, "Only event owners can ceeate events");
        Events wEvent = new Events(_name, marketFactoryAddress, _minimumStake);
        
        userEvents[msg.sender].push(address(wEvent));
        events.push(address(wEvent));
        
        emit EventCreated(msg.sender, _name, address(wEvent));
        return address(wEvent);
    }

    function getEventsByAddress(address userAddress) public view returns(address[] memory){
        return userEvents[userAddress];
    }

    function getAllEvents() public view returns(address[] memory){
        return events;
    }
}