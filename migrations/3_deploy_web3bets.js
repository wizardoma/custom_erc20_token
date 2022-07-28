const Web3Bets = artifacts.require("Web3Bets");
const BetsFactory = artifacts.require("BetsFactory");
const EventFactory = artifacts.require("EventFactory");
const PoolsFactory = artifacts.require("PoolsFactory");
const MarketFactory = artifacts.require("MarketFactory");
const Bet = artifacts.require("Bets");
const Market = artifacts.require("Markets");
const Event = artifacts.require("Events");
const Pool = artifacts.require("Pools");

module.exports = function (deployer) {
  deployer.deploy(Web3Bets).then(function () {
    return deployer.deploy(BetsFactory).then(function () {
      return deployer
        .deploy(PoolsFactory, BetsFactory.address)
        .then(function () {
          return deployer
            .deploy(MarketFactory, PoolsFactory.address, Web3Bets.address)
            .then(function () {
              return deployer
                .deploy(EventFactory, MarketFactory.address)
                .then(function () {
                  let minimumStake = 2000;
                  return deployer.deploy(Event,"Alex", MarketFactory.address,minimumStake).then(function () {
                    return deployer.deploy(Market,"Alex", Event.address,PoolsFactory.address,Web3Bets.address,minimumStake).then(function () {
                      return deployer.deploy(Pool, "Alex",Event.address,Market.address,BetsFactory.address,minimumStake).then(function () {
                        return deployer.deploy(Bet, Event.address,Market.address,Pool.address,minimumStake,Pool.address);
                      });
                    });
                  });
                });
            });
        });
    });
  });
};
