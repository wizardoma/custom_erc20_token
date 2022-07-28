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
let demoPool;
let defaultStake = 1;

before(async function () {
  this.timeout(20000);

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
  await marketEvent.createMarket(marketName, defaultStake, {
    from: eventOwner,
  });
  let markets = await marketEvent.getMarkets();
  demoMarketAddress = markets[markets.length - 1];
  demoMarket = await Market.at(demoMarketAddress);
  await demoMarket.createMarketPool("1X", { from: eventOwner });
  let marketPools = await demoMarket.getPoolAddresses();
  demoPool = await Pools.at(marketPools[marketPools.length - 1]);
});

it("Newly initialized have correct minimum stake", async () => {
  let minimumStake = await demoPool.minimumStake();
  assert.equal(minimumStake.toNumber() === defaultStake, true);
});

it("zero totalStake is expected on pool creation", async () => {
  let totalStake = await demoPool.getTotalStake();

  assert.equal(totalStake["words"][0] === 0, true);
});

it("Valid pool address on initialization", async () => {
  let address = await demoPool.address;
  assert.equal(web3.utils.isAddress(address), true);
});

it("any user can create a bet", async () => {
  let bets = await demoPool.getBets();
  let marketBalance = await demoMarket.getBalance();
  console.log("Market balance",marketBalance);
  let value = web3.utils.toWei("2", "ether");
  await demoPool.bet({ from: accounts[4], value: value });
  let newBets = await demoPool.getBets();
  let marketBalance1 = await demoMarket.getBalance();
  console.log("Market Balance 1 ", marketBalance1);
  let diff = web3.utils.fromWei(marketBalance1.toString(),"ether")- web3.utils.fromWei(marketBalance.toString(),"ether");
  console.log("Difference ", diff);
  console.log("Value ", value);
  // assert.equal(diff === value, true);
  assert.equal(newBets.length - bets.length === 1, true);
});

it("Bet stake must be higher or equal to minimum stake of the event", async () => {
  let minimumStake = await demoPool.minimumStake();
  // console.log("Minimum Stake", web3.utils.toWei(minimumStake.toNumber().toString(),'ether'))
  // console.log("Minimum Stake 2" , web3.utils.toWei('0.5','ether'))
  await truffleAssert.reverts(
    demoPool.bet({ from: accounts[4], value: web3.utils.toWei("0.5", "wei") }),
    "",
    "You can not bet below the minimum stake of event"
  );
});
