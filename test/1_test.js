const Web3Bets = artifacts.require("Web3Bets");
const EventFactory = artifacts.require("EventFactory");
const MarketFactory = artifacts.require("MarketFactory");
const Events = artifacts.require("Events");
const Market = artifacts.require("Markets");


const truffleAssert = require("truffle-assertions");

let eventFactory;
let marketFactory;
let web3bets;
let demoEventAddress;
let eventOwner;
let demoEvent;

// const getDeployedWeb3 = () => {
    // return Web3Bets.deployed();
// }

// web3bets = await getDeployedWeb3();
// before(async () => {
//   console.log("event");
//   web3bets = await Web3Bets.deployed();

//   accounts = await web3.eth.getAccounts();
//   eventOwner = accounts[1];

//   eventFactory = await EventFactory.deployed();
//   await eventFactory.createEvent("Man U v Villa", 2, { from: eventOwner });
//   let events = await eventFactory.getAllEvents();

//   demoEventAddress = events[events.length - 1];
//   demoEvent = await Events.at(demoEventAddress);

//   marketFactory = await MarketFactory.deployed();
// });

// export default {
//     Web3Bets,
//     EventFactory,
//     MarketFactory,
//     Events,
//     Market,
//   web3bets,
//   accounts,
//   eventOwner,
//   eventFactory,
//   marketFactory,
//   demoEvent,
//   truffleAssert,
//   demoEventAddress,
// };


// export default {web3bets}
