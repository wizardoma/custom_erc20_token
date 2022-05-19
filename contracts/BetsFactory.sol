// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./Bets.sol";
contract BetsFactory {
    mapping (address => address[]) userBets;

    event BetCreated(address better, address eventAddress, address marketAddress, address poolAddress, uint stake);

    function createBet(address _eventAddress, address _marketAddress, address _poolAddress, uint _stake) external returns(address) {
        Bets bet =new Bets(_eventAddress, _marketAddress,_poolAddress, _stake);
        userBets[msg.sender].push(address(bet));
        emit BetCreated(msg.sender, _eventAddress, _marketAddress, _poolAddress, _stake);
        return address(bet);
    }


    function getAllBetsByAddress(address _address) external view returns (address[] memory){
        return userBets[_address];
    } 

}