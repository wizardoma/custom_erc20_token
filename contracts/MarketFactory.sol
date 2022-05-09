// SPDX-License-Identifier: MIT
pragma solidity >0.4.23 <0.9.0;
import "./Markets.sol";
contract MarketFactory {
    mapping (address => Market[]) eventMarkets;

    Market[] private _markets;
    function createMarket(
        string memory marketName, string memory marketDescription, bytes32 marketId, address eventAddress
    ) public returns(address) {
        Market market = new Market(marketId, marketName, marketDescription, eventAddress);
        
        eventMarkets[eventAddress].push(market);

        return address(market);
    }


    function getMarketsByEvent(address eventAddress)
        public
        view
        returns (Market[] memory markets)
    {
        return eventMarkets[eventAddress];

    }
}