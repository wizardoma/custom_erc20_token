const Web3Bets = artifacts.require("Web3Bets");
const EventFactory = artifacts.require("EventFactory");
const MarketFactory = artifacts.require("MarketFactory");

const truffleAssert = require("truffle-assertions");

let eventFactory;
let marketFactory;
let web3bets;
let testEvent1;
let testEvent2;
let wAddress;

beforeEach(async () => {
  web3bets = await Web3Bets.deployed();

  accounts = await web3.eth.getAccounts();

  eventFactory = await EventFactory.deployed();
  await eventFactory.createEvent("Man U v Villa", 2);
  let events = await eventFactory.getAllEvents();
  testEvent1 = events[0]

  marketFactory = await MarketFactory.deployed();
});

it("Should have no markets on initialization", async () => {

    let markets = await marketFactory.getAllMarkets();
    console.log("Market ",markets)

    assert.equal(markets.length == 0, true);
  });

it("Should be able to create a market", async () => {

//   await eventFactory.createEvent("Man U v Chelsea", 2);
//   let events = await eventFactory.getAllEvents();
await marketFactory.createMarket("Paribet", testEvent1,1)
let markets = await marketFactory.getAllMarkets();
  assert.equal(markets.length == 1, true);
});

it("Should get markets of an event", async () => {

    let markets =await marketFactory.getMarketsByEvent(testEvent1);
    
  assert.equal(markets.length == 1, true);
});


