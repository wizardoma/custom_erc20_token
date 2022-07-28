const Web3Bets = artifacts.require("Web3Bets");
const EventFactory = artifacts.require("EventFactory");
const MarketFactory = artifacts.require("MarketFactory");
const Events = artifacts.require("Events");

const truffleAssert = require("truffle-assertions");

let eventFactory;
let marketFactory;
let web3bets;
let testEvent2;
let eventOwner;
let demoEvent;

before(async () => {
  web3bets = await Web3Bets.deployed();
  accounts = await web3.eth.getAccounts();
  eventOwner = accounts[1];

  eventFactory = await EventFactory.deployed();
  await eventFactory.createEvent("Man U v Villa", 2, { from: eventOwner });
  let events = await eventFactory.getAllEvents();

  testEvent2 = events[events.length - 1];
  demoEvent = await Events.at(testEvent2);

  marketFactory = await MarketFactory.deployed();
});

contract("Events", (accounts) => {
it("Initialized Event is a valid event", async () => {
  assert.equal(web3.utils.isAddress(testEvent2), true);
});

it("Can be able to create market", async () => {
  let eventMarkets = await demoEvent.getMarkets();
  let marketName = "Paribet";

  await demoEvent.createMarket(marketName, 1, { from: eventOwner });
  let newEventsMarkets = await demoEvent.getMarkets();
  assert.equal(newEventsMarkets.length - eventMarkets.length === 1, true);
});

it("Can be able to cancel events", async () => {
  await truffleAssert.passes(demoEvent.cancelEvent({ from: eventOwner }));
});

it("Only event owner can cancel event", async () => {
  console.log(testEvent2);
  await truffleAssert.reverts(demoEvent.cancelEvent({ from: accounts[2] }));
});

it("Only event owner can create market", async () => {
  await truffleAssert.reverts(
    demoEvent.createMarket("market", 1, { from: accounts[2] })
  );
});

it("can retrieve address that created event", async () => {
  let address = await demoEvent.getEventOwner();
  assert.equal(web3.utils.isAddress(address), true);
  assert.equal(address === eventOwner, true);
});
});