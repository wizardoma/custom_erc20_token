const Web3Bets = artifacts.require("Web3Bets");
const truffleAssert = require("truffle-assertions");

let web3bets;

beforeEach(async () => {

  web3bets = await Web3Bets.deployed();

});

contract("Web3Bets", (accounts) => {

  it("It should have a valid contract address", async () => {
    let dAddress = await web3bets.address;

    assert.equal(dAddress.startsWith("0x00"), false);
  });

  it("It should have a holdersVig stake of 25, ecosystem stake of 50 and eventOwnersVig of 25", async () => {
    const holdersVig = await web3bets.holdersVig();
    const ecosystemVig = await web3bets.ecosystemVig();
    const eventOwnersVig = await web3bets.eventOwnersVig();

    assert.equal(holdersVig, 25);
    assert.equal(ecosystemVig, 50);
    assert.equal(eventOwnersVig, 25);
  });

  it("It should update holders, ecosystem and eventOwnersVig", async () => {
    await web3bets.setVigPercentageShares(10, 20, 70);
    const holdersVig = await web3bets.holdersVig();
    const ecosystemVig = await web3bets.ecosystemVig();
    const eventOwnersVig = await web3bets.eventOwnersVig();

    assert.equal(holdersVig, 10);
    assert.equal(ecosystemVig, 20);
    assert.equal(eventOwnersVig, 70);
  });

  it("Throw an error when any vig are more than 100", async () => {
    await truffleAssert.reverts(web3bets.setVigPercentageShares(101, 0, 0));
  });

  it("Throw an error when the sum of vigs are more than 100", async () => {
    await truffleAssert.reverts(web3bets.setVigPercentageShares(79, 32, 22));
  });

  it("Only owner can update vig shares",async () => {
    await truffleAssert.reverts(web3bets.setVigPercentageShares(40,30,20, {from: accounts[2]}));
  });

  it("Only owner can add event owners",async () => {
    await truffleAssert.reverts(web3bets.addEventOwner(accounts[1], {from: accounts[2]}));
  });

  it("Can add event owners",async () => {
    let initialLength = await web3bets.getAllEventOwners();
    await web3bets.addEventOwner(accounts[1]); 
    let newLength = await web3bets.getAllEventOwners();
    
    // Cannot add duplicate accounts
    await truffleAssert.reverts(web3bets.addEventOwner(accounts[1], ));

    assert.equal(newLength.length - initialLength.length === 1, true)

  });

  it("Can delete event owners",async () => {
    let initialLength = await web3bets.getAllEventOwners();
    await web3bets.addEventOwner(accounts[3]); 

    // throw error on invalid deletion
    await truffleAssert.reverts(web3bets.deleteEventOwner(accounts[2]));


    // only event owners can delete
    await truffleAssert.reverts(web3bets.deleteEventOwner(accounts[1], {from: accounts[2]}));

    await web3bets.deleteEventOwner(accounts[3])

    let newLength = await web3bets.getAllEventOwners();
    // confirm new event owner was deleted
    assert.equal(newLength.includes(accounts[3]), false)

  });

});

