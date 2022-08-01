const Web3Bets = artifacts.require("Web3Bets");
const EventFactory = artifacts.require("EventFactory");
const MarketFactory = artifacts.require("MarketFactory");
const Events = artifacts.require("Events");
const Markets = artifacts.require("Markets");
const Pools = artifacts.require("Pools");
const truffleAssert = require("truffle-assertions");

contract("Event Owner Flow", (accounts) => {
  let eventOwner = accounts[1];
  
  it("Confirm event owner user flow", async function () {
    let minimumStake = web3.utils.toWei("1","microether")

    this.timeout(100000);
    let accounts = await web3.eth.getAccounts();

    let eventOwner = accounts[8];
    
    await web3bets.addEventOwner(eventOwner);

    let eventFactory = await EventFactory.deployed();

    // confirm event owner
    assert.equal(web3.utils.isAddress(eventOwner), true);
    let ownerEvents = await eventFactory.getEventsByAddress(eventOwner);

    // confirm event owner has no initial event
    assert.equal(ownerEvents.length === 0, true);

    // create an event
    await eventFactory.createEvent("Man U v Villa", minimumStake, {
      from: eventOwner,
    });
    ownerEvents = await eventFactory.getEventsByAddress(eventOwner);

    //confirm a single event have been created
    assert.equal(ownerEvents.length === 1, true);

    // add aditional events
    for (let i = 0; i < 3; i++) {
      await eventFactory.createEvent(`Event ${i}`, minimumStake, { from: eventOwner });
    }

    ownerEvents = await eventFactory.getEventsByAddress(eventOwner);

    // confirm event owner can create multiple events
    assert.equal(ownerEvents.length === 4, true);

    let allEventsIsOwner = true;
    for (let j = 0; j < ownerEvents.length; j++) {
      let event = await Events.at(ownerEvents[j]);
      let ownerAddress = await event.getEventOwner();
      allEventsIsOwner = ownerAddress === eventOwner;
    }

    // confirm all created event belongs to owner
    assert.equal(allEventsIsOwner, true);

    let event1 = await Events.at(ownerEvents[0]);

    let eventMarkets = await event1.getMarkets();

    //confirm that new event has no market
    assert.equal(eventMarkets.length === 0, true);

    await event1.createMarket("Paribet", {
      from: eventOwner,
    });

    eventMarkets = await event1.getMarkets();

    //confirm event owner can create a market
    assert.equal(eventMarkets.length === 1, true);

    // add aditional markets
    for (let i = 0; i < 3; i++) {
      await event1.createMarket(`Market ${i}`, {
        from: eventOwner,
      });
    }

    eventMarkets = await event1.getMarkets();

    // confirm event owner can create multiple markets
    assert.equal(eventMarkets.length === 4, true);

    let allMarketsIsEvents = true;
    for (let j = 0; j < eventMarkets.length; j++) {
      let market = await Markets.at(eventMarkets[j]);
      let marketOwner = await market.getEventAddress();
      allMarketsIsEvents = marketOwner === ownerEvents[0];
    }

    // confirm all new markets are owned by event
    assert.equal(allMarketsIsEvents, true);

    let market1 = await Markets.at(eventMarkets[0]);

    let marketPools = await market1.getPoolAddresses();

    //confirm that new market has no pools
    assert.equal(marketPools.length === 0, true);

    await market1.createPool("1x", {
      from: eventOwner,
    });

    marketPools = await market1.getPoolAddresses();

    //confirm event owner can create a market
    assert.equal(marketPools.length === 1, true);

    // add aditional markets
    for (let i = 0; i < 3; i++) {
      await market1.createPool(`Pool ${i}`, {
        from: eventOwner,
      });
    }

    marketPools = await market1.getPoolAddresses();

    // confirm event owner can create multiple markets
    assert.equal(marketPools.length === 4, true);

    let hasSetWinningPool = await market1.isWinningPoolSet();

    // confirm no winning pool is set on market creation
    assert.equal(hasSetWinningPool, false);

    // fail on invalid contract setup
    await truffleAssert.reverts(
      market1.setWinningPool(eventMarkets[0], { from: eventOwner })
    );

    // contract can set winning pool with no bets
    await truffleAssert.passes(
      market1.setWinningPool(marketPools[0], { from: eventOwner })
    );

    // setting winning pool is final
    await truffleAssert.reverts(
      market1.setWinningPool(marketPools[0], { from: eventOwner })
    );

    // cannot set winning pool with other winning poool addresses
    await truffleAssert.reverts(
      market1.setWinningPool(marketPools[1], { from: eventOwner })
    );

    // owners can start event
    await truffleAssert.passes(event1.startEvent({from: eventOwner}));

    // cannot start service again
    await truffleAssert.reverts(event1.startEvent({from: eventOwner}));

    let eventStarted = await event1.status();

    console.log(eventStarted);

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
  });
});
