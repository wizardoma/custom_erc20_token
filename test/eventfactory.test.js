const Web3Bets = artifacts.require("Web3Bets");
const EventFactory = artifacts.require("EventFactory");
const MarketFactory = artifacts.require("MarketFactory");
const truffleAssert = require("truffle-assertions");

let web3bets;
let eventFactory;
let marketFactory;
let marketFactoryAddress;
let accounts;

beforeEach(async () => {
    web3bets = await Web3Bets.deployed();
  
    accounts = await web3.eth.getAccounts();

    marketFactory = await MarketFactory.deployed();

    marketFactoryAddress = await marketFactory.address;
  
    eventFactory = await EventFactory.deployed();
});  

contract("EventFactory", (accounts) => {

    it("Should have no events on initialization", async () => {
        let events= await eventFactory.getAllEvents();

        assert.equal(events.length,0)
    });

    it("Should be able to create to create an event", async () => {
        let allEvents= await eventFactory.getAllEvents();

        let event = await eventFactory.createEvent("Man U vs Aston Villa",1);

        console.log(event);

        // check length of eventFactory
        let newEvents =  await eventFactory.getAllEvents();
        assert.equal(newEvents.length - allEvents.length === 1,true)
        
    });

})
