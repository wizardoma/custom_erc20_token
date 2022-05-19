pragma solidity ^0.8.4;

import "./Bets.sol";
contract BetsFactory {
    mapping (address => address[]) userBets;

    event BetCreated(address better, address eventAddress, address marketAddress, address poolAddress, uint stake);

    function createBet(uint _stake, address _marketAddress, address _eventAddress, address _poolAddress) external returns(address) {
        Bets bet = Bets(_eventAddress, _marketAddress,_poolAddress, _stake);
        userBets[msg.sender].push[address(bet)];
        emit BetCreated(msg.sender, _eventAddress, _marketAddress, _poolAddress, _stake);
        return address(bet);
    }


    function getAllBetsByAddress(address _address) external returns (address[] memory){
        return userBets[_address];
    } 

}