// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

import "./interface/IWeb3BetsEventsV1.sol";
import "./MarketFactory.sol";

import "@openzeppelin/contracts/utils/Strings.sol";

contract Events is IWeb3BetsEventV1 {
    address public eventOwner;

    address public marketFactoryAddress;

    uint private minimumStake;

    Market[] markets;

    string public name;

    struct Market {
        string name;
        address marketAddress;
        MarketStatus status;
    }

    function getName() public view override returns (string memory) {
        return name;
    }

    constructor(
        string memory eventName,
        address _marketFactoryAddress
    ) {
        name = eventName;
        marketFactoryAddress = marketFactoryAddress;
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

        Market memory market = Market({
            name: name,
            status: MarketStatus.PENDING,
            marketAddress: marketAddress
        });

        markets.push(market);
    }

    function cancelEvent() external override onlyOwner {}

    function settleEvent() external override onlyOwner {}

    // Allows callers to redeem their events in the case of a canceled event
    function redeemStake(uint256 marketId, uint256 poolId) external override {}

    // Allows callers to take their winnings in the case where their pool won
    function takeBetWinnings(uint256 marketId, uint256 poolId)
        external
        override
    {}

    function getMarkets() external view override returns (address[] memory) {
        address[] memory marketAddresses;
        for (uint256 i = 0; i < getCount(); i++) {
            address marketAddress = markets[i].marketAddress;
            marketAddresses[i] = marketAddress;
        }

        return marketAddresses;
    }

    function getTotalStake() external override returns (uint256) {}

    function getCount() public view returns (uint256 count) {
        return markets.length;
    }

    function getEventOwner() external view returns (address){
        return eventOwner;
    }
}
