pragma solidity ^0.8.4;

contract Market {

    address public owner;
    string public name;
    string public description;
    bytes32 public id;
    address public eventAddress;
    
    constructor(bytes32 marketId, string memory marketName, string memory marketDescription, address eventAddr) {
        owner = msg.sender;
        name = marketName;
        id = marketId;
        eventAddress = eventAddr;
        description = marketDescription;
    }


}