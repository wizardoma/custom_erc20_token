// SPDX-License-Identifier: MIT
pragma solidity >0.4.23 <0.9.0;
import "./Markets.sol";

contract MarketFactory {

    mapping (address => address[]) eventMarkets;

    event MarketCreated(address marketAddress, address eventAddress, string marketName);

    address public poolFactoryAddress;

    Market[] private _markets;

    function createMarket(
        string memory _name, address _eventAddress) public returns(address) {
        
        Market market = new Market(_name, _eventAddress);

        eventMarkets[_eventAddress].push(address(market));
        emit MarketCreated(address(market), _eventAddress, _name);
        return address(market);
    }

    function getMarketsByEvent(address eventAddress)
        public
        view
        returns (address[] memory markets)
    {
        return eventMarkets[eventAddress];

    }

}
