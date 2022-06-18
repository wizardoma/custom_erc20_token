// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

import "./interface/IWeb3BetsEventsV1.sol";
import "./MarketFactory.sol";

import "@openzeppelin/contracts/utils/Strings.sol";

contract Events is IWeb3BetsEventV1 {
    address public eventOwner;

    address public marketFactoryAddress;

    uint private minimumStake;

    EventMarket[] markets;

    string public name;

    struct EventMarket {
        string marketName;
        address marketAddress;
        MarketStatus status;
    }

    function getName()  public view override returns (string memory) {
        return name;
    }

    constructor(
        string memory eventName,
        address _marketFactoryAddress
    ) {
        name = eventName;
        marketFactoryAddress = _marketFactoryAddress;
    }

    enum MarketStatus {
        PENDING,
        FINISHED
    }

    modifier onlyOwner() {
        require(
            msg.sender == eventOwner,
            "Event operations only applicable to owner"
        );
        _;
    }

    function createMarket(string memory _name) external override onlyOwner {
        // bytes32 marketId = keccak256(abi.encodePacked(eName,Strings.toString(block.timestamp)));

        MarketFactory factory = MarketFactory(marketFactoryAddress);
        address marketAddress = factory.createMarket(
            _name,
            address(this)
        );

        EventMarket memory market = EventMarket({
            marketName: name,
            status: MarketStatus.PENDING,
            marketAddress: marketAddress
        });

        markets.push(market);
    }

    function cancelEvent() external override onlyOwner {
        bool allMarketsAreSettled = false;
        for (uint i = 0; i< markets.length; i ++){
            IWeb3BetsMarketV1 marketv1 = IWeb3BetsMarketV1(markets[i].marketAddress);

        }
        
    }

    function settleEvent() external override onlyOwner {}

    function getMarkets() external view override returns (address[] memory) {
        address[] memory marketAddresses;
        for (uint256 i = 0; i < getCount(); i++) {
            address marketAddress = markets[i].marketAddress;
            marketAddresses[i] = marketAddress;
        }

        return marketAddresses;
    }

    function getTotalStake() external override returns (uint256) {
        uint _totalStake;

        for (uint i = 0; i< markets.length; i++){
            IWeb3BetsMarketV1 _betsMarket = IWeb3BetsMarketV1(markets[i].marketAddress);
               _totalStake += _betsMarket.getTotalStake();
            
        }

        return _totalStake;
    }

    function getMinimumStake() external view returns (uint){
        return minimumStake;
    }

    function getCount() internal view returns (uint256 count) {
        return markets.length;
    }

    function getEventOwner() override external view returns (address){
        return eventOwner;
    }
}
