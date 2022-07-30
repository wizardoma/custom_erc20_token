// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

import "./interface/IWeb3Bets.sol";

contract Web3Bets is IWeb3Bets {
    address public contractOwner;
    address public ecosystemAddress;
    address public holdersAddress;
    uint256 public holdersVig = 25;
    uint256 public ecosystemVig = 50;
    uint256 public eventOwnersVig = 25;
    uint256 public vigPercentage = 10;
    address[] public eventOwnerAddresses;
    mapping(address => address) public eventOwnersMapping;

    error ExistingEventOwner(string message);


    constructor() {
        contractOwner = msg.sender;
    }

    modifier onlyUser() {
        require(
            msg.sender == contractOwner,
            "You have no privilege to run this function"
        );
        _;
    }

    modifier uniqueEventOwner(address _eventOwner) {
        if (eventOwnersMapping[_eventOwner] != address(0)) {
            revert("This address is already an event owner");
        }
        _;
    }

    function setHoldersAddress(address holder) public onlyUser {
        holdersAddress = holder;
    }

    function setEcosystemAddress(address holder) public onlyUser {
        ecosystemAddress = holder;
    }

    function setVigPercentage(uint256 percentage) public onlyUser {
        require(
            percentage < 100,
            "Vig percentage must be expressed in 0 to 100 percentage. Example: 10"
        );
        vigPercentage = percentage;
    }

    function setVigPercentageShares(
        uint256 hVig,
        uint256 eVig,
        uint256 eoVig
    ) public onlyUser {
        require(
            hVig <= 100 && eVig <= 100 && eoVig <= 100,
            "Vig percentages shares must be expressed in a  0 to 100 ratio. Example: 30"
        );
        require(
            hVig + eVig + eoVig == 100,
            "The sum of all Vig percentage shares must be equal to 100"
        );

        holdersVig = hVig;
        ecosystemVig = eVig;
        eventOwnersVig = eoVig;
    }

    function addEventOwner(address _eventOwner)
        public
        onlyUser
        uniqueEventOwner(_eventOwner)
    {
        eventOwnerAddresses.push(_eventOwner);
        eventOwnersMapping[_eventOwner] = _eventOwner;

    }

    function deleteEventOwner(address _eventOwner)
    public 
    onlyUser{
        if (eventOwnersMapping[_eventOwner] == address(0)){
            revert("Invalid event owner");
        }

        else {
            delete eventOwnersMapping[_eventOwner];
        
        for (uint i = 0; i< eventOwnerAddresses.length; i++){
            if (eventOwnerAddresses[i] == _eventOwner){
                delete eventOwnerAddresses[i];
                break;
            }
        }
        }
    }

    function shareBetEarnings() external payable override {
        require(msg.value > 0, "bet earnings must be greater than 0");
        uint256 holdersShare = msg.value * (holdersVig / 100);
        uint256 ecosystemShare = msg.value * (ecosystemVig / 100);
        uint256 eventOwnersShare = msg.value * (eventOwnersVig / 100);
        address payable eventOwner = payable(msg.sender);

        (bool isSentEventOwner, ) = eventOwner.call{value: eventOwnersShare}(
            ""
        );

        (bool isSentEcosystem, ) = ecosystemAddress.call{value: ecosystemShare}(
            ""
        );

        (bool isSentHoldersAddress, ) = holdersAddress.call{
            value: holdersShare
        }("");
    }

    function getVigPercentage() external view override returns (uint256) {
        return vigPercentage;
    }

    function isEventOwner(address _owner) external view returns (bool) {
        return eventOwnersMapping[_owner] != address(0);
    }

    function getAllEventOwners() external view returns (address[] memory)
{
    return eventOwnerAddresses;
}
}
