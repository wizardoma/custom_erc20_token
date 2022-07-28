const Web3Bets = artifacts.require("Web3Bets");
const EventFactory = artifacts.require("EventFactory");
const MarketFactory = artifacts.require("MarketFactory");
const Events = artifacts.require("Events");
const Market = artifacts.require("Markets");
const Pools = artifacts.require("Pools");
const truffleAssert = require("truffle-assertions");

contract("Event Owner Flow", (accounts) => {
it("Confirm event owner user flow", async function () {
  this.timeout(100000);
  let accounts = await web3.eth.getAccounts();
  let eventFactory = await EventFactory.deployed();
  let eventOwner = accounts[8];

  // confirm event owner
  assert.equal(web3.utils.isAddress(eventOwner), true);
  let ownerEvents = await eventFactory.getEventsByAddress(eventOwner);

  // confirm event owner has no initial event
  assert.equal(ownerEvents.length === 0, true);

  // create an event
  await eventFactory.createEvent("Man U v Villa", 2, { from: eventOwner });
  ownerEvents = await eventFactory.getEventsByAddress(eventOwner);

  //confirm a single event have been created
  assert.equal(ownerEvents.length === 1, true);

  // add aditional events
  for (let i = 0; i < 3; i++) {
    await eventFactory.createEvent(`Event ${i}`, 2, { from: eventOwner });
  }

  ownerEvents = await eventFactory.getEventsByAddress(eventOwner);

  // confirm event owner can create multiple events
  assert.equal(ownerEvents.length === 4, true);

  let allBelongsToOwner = true;
  for (let j = 0; j < ownerEvents.length; j++) {
    let event = await Events.at(ownerEvents[j]);
    let ownerAddress = await event.getEventOwner();
    allBelongsToOwner = ownerAddress === eventOwner;
  }

  // confirm all created event belongs to owner
  assert.equal(allBelongsToOwner, true);

  // let events = await eventFactory.getAllEvents();
  // let marketEventAddress = events[events.length - 1];
  // let marketEvent = await Events.at(marketEventAddress);
  // let marketName = "Paribet";
  // await marketEvent.createMarket(marketName, 2, { from: eventOwner });
  // let dMarketName = await demoMarket.getName();
  // await marketEvent.createMarket(marketName, 2, { from: eventOwner });
  // let markets = await marketEvent.getMarkets();
  // let demoMarketAddress = markets[markets.length - 1];
  // let demoMarket = await Market.at(demoMarketAddress);
  // let marketPools = await demoMarket.getPoolAddresses();
  // await demoMarket.createMarketPool("1X", { from: eventOwner });
  // let newMarketPools = await demoMarket.getPoolAddresses();
})

});
