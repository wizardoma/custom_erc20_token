const Web3Bets = artifacts.require("Web3Bets");
const EventFactory = artifacts.require("EventFactory");
const MarketFactory = artifacts.require("MarketFactory");
const PoolsFactory = artifacts.require("PoolsFactory");

const Events = artifacts.require("Events");
const Market = artifacts.require("Markets");
const Pools = artifacts.require("Pools");

const truffleAssert = require("truffle-assertions");

let eventFactory;
let marketFactory;
let poolFactory;
let web3bets;
let demoEventAddress;
let eventOwner;
let demoEvent;
let demoMarket;
let demoMarketAddress;
let marketName;

before(async function () {
  this.timeout(20000);
  web3bets = await Web3Bets.deployed();
  accounts = await web3.eth.getAccounts();
  eventOwner = accounts[1];

  eventFactory = await EventFactory.deployed();
  marketFactory = await MarketFactory.deployed();
  poolFactory = await PoolsFactory.deployed();

  await web3bets.addEventOwner(eventOwner);
  let minimumStake = web3.utils.toWei("1","microether")


  await eventFactory.createEvent("Man U v Villa", minimumStake, { from: eventOwner });
  let events = await eventFactory.getAllEvents();
  demoEventAddress = events[events.length - 1];
  demoEvent = await Events.at(demoEventAddress);
  marketName = "Paribet";
  await demoEvent.createMarket(marketName, { from: eventOwner });
  let newEventsMarkets = await demoEvent.getMarkets();
  demoMarketAddress = newEventsMarkets[newEventsMarkets.length - 1];
  demoMarket = await Market.at(demoMarketAddress);
});



contract("Pool Factory", (accounts) => {
  
  it("Can create a pool", async () => {
    let marketPools = await poolFactory.getPoolsOfMarket(demoMarketAddress);
    await poolFactory.createPool("12", demoEventAddress, demoMarketAddress);
    let newMarketPools = await poolFactory.getPoolsOfMarket(demoMarketAddress);

    assert.equal(newMarketPools.length - marketPools === 1, true);
  });
});
