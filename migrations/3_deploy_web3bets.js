const Web3Bets = artifacts.require("Web3Bets");
const BetsFactory = artifacts.require("BetsFactory");
const EventFactory = artifacts.require("EventFactory");
const PoolsFactory = artifacts.require("PoolsFactory");
const MarketFactory = artifacts.require("MarketFactory");

module.exports = function (deployer) {
  deployer.deploy(Web3Bets).then(function () {
    return deployer.deploy(BetsFactory).then(function () {
      return deployer
        .deploy(PoolsFactory, BetsFactory.address)
        .then(function () {
          return deployer
            .deploy(MarketFactory, PoolsFactory.address, Web3Bets.address)
            .then(function () {
              return deployer.deploy(EventFactory, MarketFactory.address);
            });
        });
    });
  });
};
