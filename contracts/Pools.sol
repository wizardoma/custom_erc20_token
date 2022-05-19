pragma solidity ^0.8.4;
import "./interface/IWeb3BetsPoolsV1.sol";
import "./interface/IWeb3BetsEventsV1.sol";
import "./Bets.sol";

import "./BetsFactory.sol";

/// @author Ibekason Alexander Onyebuchi
/// @title Pool Contract
/// @notice Contain function signatures for creating pools in a
/// market

contract Pool is IWeb3BetsPoolsV1 {
    string public name;

    uint256 public totalStake;

    address public betsFactoryAddress;

    mapping(address => uint256) userStakes;

    address private eventAddress;

    address private marketAddress;

    modifier aboveMinimumStake() {
        IWeb3BetsEventV1 poolEvent = IWeb3BetsEventV1(eventAddress);
        require(
            msg.value >= poolEvent.getMinimumStake(),
            "You can not bet below the minimum stake of event"
        );
        _;
    }

    constructor(
        string memory _name,
        address _eventAddress,
        address _marketAddress
    ) {
        name = _name;
        eventAddress = _eventAddress;
        marketAddress = _marketAddress;
    }

    function bet() public payable override aboveMinimumStake {
        BetsFactory betsFactory = BetsFactory(betsFactoryAddress);
        Bets bet = betsFactory.createBet(
            msg.value,
            marketAddress,
            eventAddress,
            poolAddress
        );
        totalStake += msg.value;
        userStakes[msg.sender] = msg.value;
    }

    function getName() external view override returns (string memory) {
        return name;
    }
}
