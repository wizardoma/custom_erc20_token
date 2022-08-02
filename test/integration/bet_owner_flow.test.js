const Web3Bets = artifacts.require("Web3Bets");
const EventFactory = artifacts.require("EventFactory");
const MarketFactory = artifacts.require("MarketFactory");
const BetsFactory = artifacts.require("BetsFactory");
const Events = artifacts.require("Events");
const Market = artifacts.require("Markets");
const Pools = artifacts.require("Pools");
const Bets = artifacts.require("Bets");

const truffleAssert = require("truffle-assertions");

contract("Bet Owner Flow", (accounts) => {
  let minimumStake = web3.utils.toWei("1", "microether");
  let eventOwner = accounts[1];
  let betterAddress = accounts[5];

  let secondBetterAddress = accounts[6];
  let thirdBetterAddress = accounts[60];
  let fourthBetterAddress = accounts[61];
  let web3bets;
  let betFactory;
  let eventFactory;

  beforeEach(async () => {
    web3bets = await Web3Bets.deployed();
    await web3bets.setEcosystemAddress(accounts[30])
    await web3bets.setHoldersAddress(accounts[29])
  
    eventFactory = await EventFactory.deployed();
    betFactory = await BetsFactory.deployed();
  });

  it("Confirm better user flow", async function () {
    this.timeout(100000);
    await web3bets.addEventOwner(eventOwner);
    //bootstrap events
    await eventFactory.createEvent("Manchester Vs Chelsea", minimumStake, {
      from: eventOwner,
    });

    let eventAddresses = await eventFactory.getEventsByAddress(eventOwner);
    let event = await Events.at(eventAddresses[eventAddresses.length - 1]);
    await event.createMarket("3Way", { from: eventOwner });
    let markets = await event.getMarkets();
    let market = await Market.at(markets[0]);
    await market.createPool("1", { from: eventOwner });

    let pools = await market.getPoolAddresses();
    let pool = await Pools.at(pools[0]);

    let betterBalance = await web3.eth.getBalance(betterAddress);
    let betValue = web3.utils.toWei("1", "milliether");
    await truffleAssert.passes(
      pool.bet({ from: betterAddress, value: betValue })
    );

    let newBetterBalance = await web3.eth.getBalance(betterAddress);
    let betStake = await pool.getUserStake(betterAddress);
    betStake = web3.utils.fromWei(betStake.toString(), "wei");

    assert.equal(betStake === betValue, true);

    // confirm user can bet twice
    await truffleAssert.passes(
      pool.bet({ from: betterAddress, value: betValue * 2 })
    );

    let betStake2 = await pool.getUserStake(betterAddress);
    let bettersBets = await pool.getBettersBets(betterAddress);

    // confirm user indeed has two bets
    assert.equal(bettersBets.length == 2, true);
    betStake2 = web3.utils.fromWei(betStake2.toString(), "wei");

    // confirm user stake is actually double
    assert.equal(Number(betStake2) === Number(betValue * 3), true);

    // // confirm betStake  is equal to what is recorded on the blockchain
    // await event.startEvent({from: eventOwner});

    // // cannot add bet on started event
    // await truffleAssert.reverts(pool.bet({from: betterAddress, value: betValue}))

    let firstBet = await Bets.at(bettersBets[0]);

    let firstBetBetter = await firstBet.getBetter();

    let firstbetBalance = await web3.eth.getBalance(bettersBets[0]);

    // confirm empty balance on betted contract
    assert.equal(firstbetBalance.toString() === "0", true);

    // confirm bet address is betters address
    assert.equal(firstBetBetter === betterAddress, true);

    let firstBetStake = await firstBet.getBetStake();
    firstBetStake = web3.utils.fromWei(firstBetStake.toString(), "wei");

    //confirm initial bet stake equals first bet stake
    assert.equal(firstBetStake === betValue, true);

    // confirm only better can withdraw funds
    await truffleAssert.reverts(firstBet.withdraw({ from: accounts[2] }));

    // withdrawing funds do not work on event pending or start
    await truffleAssert.reverts(firstBet.withdraw({ from: betterAddress }));

    await truffleAssert.passes(
      pool.bet({ value: betValue, from: secondBetterAddress })
    );

    let secondBettersBet = await pool.getBettersBets(secondBetterAddress);

    let secondBet = await Bets.at(
      secondBettersBet[secondBettersBet.length - 1]
    );

    let secondBetBetter = await secondBet.getBetter();

    let secondbetBalance = await web3.eth.getBalance(secondBettersBet[0]);

    // confirm empty balance on betted contract
    assert.equal(secondbetBalance === "0", true);

    // confirm bet address is betters address
    assert.equal(secondBetBetter === secondBetterAddress, true);

    // // confirm betStake  is equal to what is recorded on the blockchain
    // await event.startEvent({ from: eventOwner });

    // await event.cancelEvent({ from: eventOwner });

    secondbetBalance = await web3.eth.getBalance(secondBettersBet[0]);

    // assert.equal(secondbetBalance === betValue, true);

    // create new pool
    await market.createPool("X", { from: eventOwner });

    await market.createPool("2", { from: eventOwner });

    pools = await market.getPoolAddresses();

    let secondPool = await Pools.at(pools[1]);

    await truffleAssert.passes(
      secondPool.bet({ from: thirdBetterAddress, value: betValue })
    );

    await truffleAssert.passes(
      secondPool.bet({ from: fourthBetterAddress, value: betValue })
    );

    let marketBalance = await web3.eth.getBalance(markets[0]);

    let etherMarketBalance = web3.utils.fromWei(
      marketBalance.toString(),
      "wei"
    );
    console.log("Market Balance", etherMarketBalance);

    let firstBetAddressStake = await firstBet.getBetStake();
    firstBetAddressStake = BigInt(firstBetAddressStake);

    console.log(
      "first betters stake",
      web3.utils.fromWei(String(firstBetAddressStake), "wei")
    );

    let poolTotalStake = await pool.getTotalStake();
    poolTotalStake = BigInt(poolTotalStake);

    let vigPercentage = await web3bets.getVigPercentage();

    vigPercentage = BigInt(vigPercentage);

    marketBalance = BigInt(marketBalance);

    let poolBets = await pool.getBets();
    let multiplier = BigInt(1000000);

    let poolEarnings = [];
    let vigShare = (marketBalance * vigPercentage) / BigInt(100);
    let mBalance = marketBalance - vigShare;
    let newMarketBalance = mBalance;

    console.log("mBalance ", mBalance);

    for (let k = 0; k < poolBets.length; k++) {
      console.log(`new market balance  ${k}`);
      let kBet = await Bets.at(poolBets[k]);
      let kBetStake = await kBet.getBetStake();
      kBetStake = BigInt(kBetStake);
      let kBetEarnings =
        (((kBetStake * multiplier) / poolTotalStake) * mBalance) / multiplier;

      let kBetBalance = await kBet.address;
      newMarketBalance = newMarketBalance - kBetEarnings;
      kBetBalance = await web3.eth.getBalance(kBetBalance);
      poolEarnings.push({
        earning: kBetEarnings,
        stake: kBetStake,
        balance: newMarketBalance,
        market: mBalance,
      });
    }

    console.log("Expected market balance", newMarketBalance.toString().length);

    console.log("Maximum bet earnings", poolEarnings);

    let firstBetEarnings =
      (((firstBetAddressStake * multiplier) / poolTotalStake) *
        (marketBalance - vigShare)) /
      multiplier;

    console.log("First bet balance", firstbetBalance);

    console.log("First bet stake", firstBetStake);

    console.log("vig share", vigShare);

    console.log("Pool stake", firstBetStake);

    console.log("Market balance", marketBalance - vigShare);

    console.log("Expected bet earnings", firstBetEarnings);

    let holdersAddress = await web3bets.holdersAddress();

    let ecoSystemAddress = await web3bets.holdersAddress();

    let currHoldAddressBalance = await web3.eth.getBalance(holdersAddress);
    let currEcoAddressBalance = await web3.eth.getBalance(ecoSystemAddress);

    let currEventOwnerBalance = await web3.eth.getBalance(eventOwner);
    console.log("old holder Address Balamce", currHoldAddressBalance);
    console.log("old ecosysm Address Balamce", currEcoAddressBalance);
    console.log("old event owner Address Balamce", currEventOwnerBalance);

    await truffleAssert.passes(
      market.setWinningPool(pools[0], { from: eventOwner })
    );


    let newHoldAddressBalance = await web3.eth.getBalance(holdersAddress);
    let newEcoAddressBalance = await web3.eth.getBalance(ecoSystemAddress);

    let newEventOwnerBalance = await web3.eth.getBalance(eventOwner);

    console.log("new holder Address Balamce", newHoldAddressBalance);
    console.log("new ecosysm Address Balamce", newEcoAddressBalance);
    console.log("new event owner Address Balamce", newEventOwnerBalance);

    assert.equal(newEcoAddressBalance > currEcoAddressBalance && newEventOwnerBalance > currEventOwnerBalance && newHoldAddressBalance > currHoldAddressBalance, true)
    firstbetBalance = await web3.eth.getBalance(bettersBets[0]);
    firstbetBalance = BigInt(firstbetBalance);

    marketBalance = await web3.eth.getBalance(markets[0]);

    console.log("new market balance", marketBalance.length);
    console.log("Expected bet earnings", firstBetEarnings.toString());

    let allAmounts = await market.allAmounts();
    console.log("allAmounts", allAmounts);
    firstBetEarnings = firstBetEarnings.toString();
    console.log("Actual bet earnings", firstBetEarnings);

    assert.equal(
      firstBetEarnings.toString() === firstbetBalance.toString(),
      true
    );

    assert.equal(
      newMarketBalance.toString() === marketBalance.toString(),
      true
    );

    let currentBettersBalance = await web3.eth.getBalance(firstBetBetter);
    firstBetAddressStake = await web3.eth.getBalance(bettersBets[0]);
    // await firstBet.withdraw();
    let tx = await firstBet.withdraw({ from: firstBetBetter });

    

    let newBettersBalance = await web3.eth.getBalance(firstBetBetter);
    newBettersBalance =
      Number(newBettersBalance) +
      Number(web3.utils.toWei(tx.receipt.gasUsed.toString(), "gwei"));
    firstBetAddressStake = await web3.eth.getBalance(bettersBets[0]);

    assert.equal(newBettersBalance > currentBettersBalance, true);

    let betFactoryAddresses = await betFactory.getAllBetsByAddress(betterAddress);
    console.log("betFactory Address", betFactoryAddresses)
    console.log("Betters Address", bettersBets)

    assert.equal(betFactoryAddresses.length === bettersBets.length, true);

  });
});
