const Web3Bets = artifacts.require("Web3Bets");
const BetsFactory = artifacts.require("BetsFactory");
const EventFactory = artifacts.require("EventFactory");
const PoolsFactory = artifacts.require("PoolsFactory");
const MarketFactory = artifacts.require("MarketFactory");

module.exports = function (deployer) {
  deployer.deploy(Web3Bets);
  deployer.deploy(BetsFactory);
  deployer.deploy(PoolsFactory);
  deployer.deploy(MarketFactory).then(function(){
    return deployer.deploy(EventFactory, MarketFactory.address)
});
};
