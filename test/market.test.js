const Web3Bets = artifacts.require("Web3Bets");
const EventFactory = artifacts.require("EventFactory");
const MarketFactory = artifacts.require("MarketFactory");
const Events = artifacts.require("Events");
const Market = artifacts.require("Markets");
const Pools = artifacts.require("Pools");
const truffleAssert = require("truffle-assertions");

let eventFactory;
let marketFactory;
let web3bets;
let marketEventAddress;
let eventOwner;
let marketEvent;
let demoMarket;
let marketName;

before(async () => {
  web3bets = await Web3Bets.deployed();
  accounts = await web3.eth.getAccounts();
  eventOwner = accounts[1];

  eventFactory = await EventFactory.deployed();
  marketFactory = await MarketFactory.deployed();

  await eventFactory.createEvent("Man U v Villa", 2, { from: eventOwner });
  let events = await eventFactory.getAllEvents();
  marketEventAddress = events[events.length - 1];
  marketEvent = await Events.at(marketEventAddress);
  marketName = "Paribet";
});

contract("Market", (accounts) => {
  it("Confirm validity of initialized market", async () => {
    await marketEvent.createMarket(marketName, 2, { from: eventOwner });
    let markets = await marketEvent.getMarkets();
    let demoMarketAddress = markets[markets.length - 1];
    let demoMarket = await Market.at(demoMarketAddress);
    assert.equal(web3.utils.isAddress(demoMarket.address), true);
    let dMarketName = await demoMarket.getName();
    assert.equal(dMarketName === marketName, true);
  });

  it("Can create a pool", async function () {
    this.timeout(20000);

    await marketEvent.createMarket(marketName, 2, { from: eventOwner });
    let markets = await marketEvent.getMarkets();
    let demoMarketAddress = markets[markets.length - 1];
    let demoMarket = await Market.at(demoMarketAddress);
    let marketPools = await demoMarket.getPoolAddresses();
    await demoMarket.createMarketPool("1X", { from: eventOwner });
    let newMarketPools = await demoMarket.getPoolAddresses();

    assert.equal(newMarketPools.length - marketPools.length === 1, true);
  });

  it("Winning pool cannot be true on newCreated pool", async function () {
    this.timeout(20000);
    await marketEvent.createMarket(marketName, 2, { from: eventOwner });
    let markets = await marketEvent.getMarkets();
    let demoMarketAddress = markets[markets.length - 1];
    let demoMarket = await Market.at(demoMarketAddress);
    await demoMarket.createMarketPool("1X", { from: eventOwner });
    let newMarketPools = await demoMarket.getPoolAddresses();
    console.log(newMarketPools);
    let isWinningPool = await demoMarket.isWinningPoolSet();

    assert.equal(isWinningPool, false);
  });
});
