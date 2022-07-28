const Web3Bets = artifacts.require("Web3Bets");
const EventFactory = artifacts.require("EventFactory");
const MarketFactory = artifacts.require("MarketFactory");
const Events = artifacts.require("Events");
const Market = artifacts.require("Markets");
const Pools = artifacts.require("Pools");
const truffleAssert = require("truffle-assertions");

contract("Bet Owner Flow", (accounts) => {
  it("Confirm better user flow", async function () {
    this.timeout(100000);
    let accounts = await web3.eth.getAccounts();
    let eventFactory = await EventFactory.deployed();
    let better = accounts[7];

    assert.equal(better === accounts[5],true)
  });
});
