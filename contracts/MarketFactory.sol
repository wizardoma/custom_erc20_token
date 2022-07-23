// SPDX-License-Identifier: MIT
pragma solidity >0.4.23 <0.9.0;
import "./Markets.sol";

contract MarketFactory {
    mapping (address => address[]) public eventMarkets;

    event MarketCreated(address marketAddress, address eventAddress, string marketName);

    address[] private _markets;

    address public web3betsAddress;

    address public poolsFactoryAddress;


    constructor(
        address _poolsFactoryAddress, address _web3betsAddress
    ){
        web3betsAddress = _web3betsAddress;
        poolsFactoryAddress = _poolsFactoryAddress;
    }



    function createMarket(
        string memory _name, address _eventAddress) public returns(address) {
        
        Market _market = new Market(_name, _eventAddress, poolsFactoryAddress, web3betsAddress);

        eventMarkets[_eventAddress].push(address(_market));

        _markets.push(address(_market));

        emit MarketCreated(address(_market), _eventAddress, _name);
        return address(_market);
    }

    function getMarketsByEvent(address eventAddress)
        public
        view
        returns (address[] memory markets)
    {
        return eventMarkets[eventAddress];

    }

    function getTotalMarkets() external view returns (uint) {
        return _markets.length;
    }

    function getAllMarkets() external view returns (address[] memory){
        return _markets;
    }

}
