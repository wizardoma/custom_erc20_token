const Web3Bets = artifacts.require("Web3Bets");
const EventFactory = artifacts.require("EventFactory");
const MarketFactory = artifacts.require("MarketFactory");
const Events = artifacts.require("Events");
const Market = artifacts.require("Markets");
const Pools = artifacts.require("Pools");
const Bets = artifacts.require("Bets");

const truffleAssert = require("truffle-assertions");

contract("Bet Owner Flow",  (accounts) => {
  let minimumStake = web3.utils.toWei("2", "wei");
  let eventOwner = accounts[1];
  let betterAddress = accounts[7];

  it("Confirm better user flow", async function () {
    this.timeout(100000);

    //bootstrap events
    let eventFactory = await EventFactory.deployed();
    await eventFactory.createEvent("Paribet",minimumStake, {from: eventOwner});
    let eventAddresses = await eventFactory.getEventsByAddress(eventOwner);
    let event = await Events.at(eventAddresses[eventAddresses.length - 1]);
    await event.createMarket("Paribet", minimumStake, {from: eventOwner});
    let markets = await event.getMarkets();
    let market = await Market.at(markets[markets.length - 1]);
    await market.createMarketPool("1X", {from: eventOwner});
    let pools = await market.getPoolAddresses();
    let pool = await Pools.at(pools[pools.length - 1]);


    let betterBalance = await web3.eth.getBalance(betterAddress);
    console.log("betterBalance ", betterBalance);
    let betValue = web3.utils.toWei("5","ether");
    await truffleAssert.passes(pool.bet({from: betterAddress, value: betValue}))
    let newBetterBalance = await web3.eth.getBalance(betterAddress);;
    console.log(newBetterBalance)
    let betStake = await pool.getUserStake(betterAddress);
    betStake = web3.utils.fromWei(betStake.toString(), "wei");
    console.log("Bet Stake ",betStake)
    console.log("Bet Value", betValue)

    assert.equal(betStake === betValue, true)

    // confirm user can bet twice
    await truffleAssert.passes(pool.bet({from: betterAddress, value: betValue}))
    
    let betStake2 = await pool.getUserStake(betterAddress);
    let bettersBets = await pool.getBettersBets(betterAddress);

    // confirm user indeed has two bets
    assert.equal(bettersBets.length == 2, true);
    betStake2 = web3.utils.fromWei(betStake2.toString(), "wei");

    console.log("betStake2", betStake2);

    console.log("betValue x 2", betValue * 2);

    // confirm user stake is actually double
    assert.equal(Number(betStake2)=== Number(betValue * 2), true)

    // confirm betStake  is equal to what is recorded on the blockchain
    await event.startEvent();

    // cannot add bet on started event
    await truffleAssert.reverts(pool.bet({from: betterAddress, value: betValue}))

    let firstBet = await Bets.at(bettersBets[0])

    let firstBetBetter = await firstBet.getBetter();

    // confirm bet address is betters address
    assert.equal(firstBetBetter === betterAddress, true)

    let firstBetStake = await firstBet.getBetStake();
    firstBetStake = web3.utils.fromWei(firstBetStake.toString(), "wei");

    assert.equal(firstBetStake === betValue, true);

    // confirm only better can withdraw funds
    await truffleAssert.reverts(firstBet.withdraw({from: accounts[2]}));

    // withdrawing funds do not work on event pending or start
    await truffleAssert.reverts(firstBet.withdraw({from: betterAddress}));


  });
});
