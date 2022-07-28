const Web3Bets = artifacts.require("Web3Bets");
const EventFactory = artifacts.require("EventFactory");
const truffleAssert = require("truffle-assertions");

let eventFactory;
let web3bets;
let wAddress;

before(async () => {

  web3bets = Web3Bets.deployed();

  wAddress = await web3bets.address;

  accounts = await web3.eth.getAccounts();

  eventFactory = await EventFactory.deployed();
});

contract("EventFactory", (accounts) => {
  let eventOwner = accounts[1];


  it("Should be able to create to create an event", async () => {
    let allEvents = await eventFactory.getAllEvents({ from: eventOwner });

    let event = await eventFactory.createEvent("Man U vs Aston Villa", 1, {
      from: eventOwner,
    });

    // check length of eventFactory
    let newEvents = await eventFactory.getAllEvents({ from: eventOwner });
    assert.equal(newEvents.length - allEvents.length === 1, true);
  });


  it("Event owner should only get events they created", async () => {
    
    let eventName1 = "Man U vs Aston Villa";
    let eventName2= "Man U vs Chelsea";

    let ownerEvents = await eventFactory.getEventsByAddress(eventOwner);
    let otherEvents = await eventFactory.getEventsByAddress(accounts[0]);

    await eventFactory.createEvent( eventName1,1, {
      from: eventOwner,
    });

    await eventFactory.createEvent(eventName2, 1, {
      from: accounts[0],
    });

    let newOwnerEvents = await eventFactory.getEventsByAddress(eventOwner);
    let newOtherEvents = await eventFactory.getEventsByAddress(accounts[0]);


    assert.equal(newOtherEvents.length - otherEvents.length ===1 && newOwnerEvents.length - ownerEvents.length === 1, true)

  });
});
