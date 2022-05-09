// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

contract Web3Bets {
    address public ecosystemAddress;
    address public holdersAddress;
    uint256 public holdersVig = 25;
    uint256 public ecosystemVig = 50;
    uint256 public eventOwnersVig = 25;
    uint256 public vigPercentage = 10;
    address[] eventOwnerAddresses;
    mapping(address => uint256) eventOwnersMapping;

    error ExistingEventOwner(string message);

    constructor() {
        holdersAddress = msg.sender;
    }

    modifier onlyUser() {
        require(
            msg.sender == holdersAddress,
            "You have no privilege to run this function"
        );
        _;
    }

    modifier uniqueEventOwner(address eventOwner) {
        if (eventOwnersMapping[eventOwner] == 0) {
            revert ExistingEventOwner({
                message: "This address is already an event owner"
            });
        }

        _;
    }

    function setHoldersAddress(address holder)
        public
        onlyUser
        returns (string memory)
    {
        holdersAddress = holder;

        return "Address set successfully";
    }

    function setEcosystemAddress(address holder)
        public
        onlyUser
        returns (string memory)
    {
        ecosystemAddress = holder;

        return "Address set successfully";
    }

    function setVigPercentage(uint256 percentage)
        public
        onlyUser
        returns (string memory)
    {
        require(
            percentage < 100,
            "Vig percentage must be expressed in 0 to 100 percentage. Example: 10"
        );
        vigPercentage = percentage;
        return "Vig percentage set successfully";
    }

    function setVigPercentageShares(
        uint256 hVig,
        uint256 eVig,
        uint256 eoVig
    ) public returns (string memory) {
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

        return "Vig percentage shares set successfully";
    }

    function addEventOwner(address eventOwner)
        public
        onlyUser
        uniqueEventOwner(eventOwner)
        returns (string memory)
    {
        eventOwnersMapping[eventOwner] = eventOwnerAddresses.length;
        eventOwnerAddresses.push(eventOwner);

        return "EventOwner added";
    }
}
