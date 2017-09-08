const contract = require('truffle-contract');
const ContributionABI = require('./build/contracts/Contribution.json');
const Contribution = contract(ContributionABI);
const Web3 = require('web3');
var web3 = new Web3(new Web3.providers.HttpProvider('http://localhost:8549'));

const ADDRESSES = require('./ARRAY_OF_ADDRESSES.js')();
const CONTRIBUTION_ADDRESS = '0x2215ea9f19f977dda6a7a7003bd04aabd0c2822e';
const UNLOCKED_CONTROLLER_CONTRIBUTION = web3.eth.accounts[0];

Contribution.setProvider(web3.currentProvider);
let instance;

Contribution.at(CONTRIBUTION_ADDRESS).then((i)=> {
  instance = i;
  return i.whitelistAddresses(ADDRESSES,
   0, true, {from: UNLOCKED_CONTROLLER_CONTRIBUTION, gas: 4000000})
  
}).then((txConfirmation) => {
  console.log('GAS USED', txConfirmation.receipt.gasUsed);
  return instance.isWhitelisted(ADDRESSES[ADDRESSES.length - 1], 0, {from: UNLOCKED_CONTROLLER_CONTRIBUTION});
}).then((isWhitelisted) => {
  console.log(isWhitelisted);
})