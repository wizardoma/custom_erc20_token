const Web3Bets = artifacts.require("Web3Bets");
const EventFactory = artifacts.require("EventFactory");
const MarketFactory = artifacts.require("MarketFactory");

const truffleAssert = require("truffle-assertions");

let eventFactory;
let marketFactory;
let testEvent1;
let eventOwner;

before(async function () {
  this.timeout(20000)

  eventOwner = accounts[1];

  web3bets = await Web3Bets.deployed();
  let minimumStake = web3.utils.toWei("1","microether")


  accounts = await web3.eth.getAccounts();

  eventFactory = await EventFactory.deployed();
  await eventFactory.createEvent("Man U v Villa", minimumStake,{from: eventOwner});
  let events = await eventFactory.getAllEvents();
  testEvent1 = events[0];

  marketFactory = await MarketFactory.deployed();
});

contract("MarketFactory", (accounts) => {
  it("Should be able to create a market", async () => {
    let allMarkets = await marketFactory.getAllMarkets();
    await marketFactory.createMarket("Paribet", testEvent1);
    let markets = await marketFactory.getAllMarkets();
    assert.equal(markets.length - allMarkets.length === 1, true);
  });

  it("Should get markets of an event", async () => {
    await truffleAssert.passes(marketFactory.getMarketsByEvent(testEvent1));
  });
});
