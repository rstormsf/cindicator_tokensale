const MiniMeTokenFactory = artifacts.require("MiniMeTokenFactory");
const CND = artifacts.require("CND");
let Contribution = artifacts.require("Contribution");
const MultiSigWallet = artifacts.require("MultiSigWallet");
const Tier = artifacts.require("Tier");
const abiEncoder = require('ethereumjs-abi');
const assert = require('chai').assert;

function latestTime() {
  return web3.eth.getBlock('latest').timestamp;
}
const BigNumber = web3.BigNumber;

const duration = {
  seconds: function(val) { return val},
  minutes: function(val) { return val * this.seconds(60) },
  hours:   function(val) { return val * this.minutes(60) },
  days:    function(val) { return val * this.hours(24) },
  weeks:   function(val) { return val * this.days(7) },
  years:   function(val) { return val * this.days(365)} 
};


const FOUNDERS_WALLET_ADDRESS = "0x0039F22efB07A647557C7C5d17854CFD6D489eF3";
const ADVISORS_WALLET_ADDRESS = "0x456";
const BOUNTY_WALLET_ADDRESS = "0x321";
module.exports = function(deployer, chain, accounts) {
  if(chain === "debug") {
    let Contribution = artifacts.require("DebugContribution");
  }
  return deployer.deploy(MiniMeTokenFactory).then(async () => {
    const tokenFactory = await MiniMeTokenFactory.deployed();
    const encodedParamsCND = abiEncoder.rawEncode(['address'], [tokenFactory.address]);
    await deployer.deploy(CND, tokenFactory.address);
    console.log('ENCODED PARAMS CND: \n', encodedParamsCND.toString('hex'));
    
    const cnd = await CND.deployed();
    
    await deployMultisig(deployer, accounts);
    const contributionWallet = await MultiSigWallet.deployed();
    
    await deployer.deploy(Contribution, contributionWallet.address, FOUNDERS_WALLET_ADDRESS, ADVISORS_WALLET_ADDRESS, BOUNTY_WALLET_ADDRESS);
    const encodedParamsContribution = abiEncoder.rawEncode(['address', 'address', 'address', 'address'], [contributionWallet.address, FOUNDERS_WALLET_ADDRESS, ADVISORS_WALLET_ADDRESS, BOUNTY_WALLET_ADDRESS]);
    console.log('CONTRIBUTION ENCODED: \n', encodedParamsContribution.toString('hex'));

    const contribution = await Contribution.deployed();
    await cnd.changeController(contribution.address);
    await contribution.initializeToken(cnd.address);

    const tierCount = await contribution.tierCount();
    const paused = await contribution.paused();
    assert(tierCount.toNumber(10) == 0, 'tier count should be 0');
    assert(paused === false, 'paused should be false');
    
    const tier1 = {
      totalCap : new BigNumber(10**18 * 2),
      minimum : new BigNumber(10**18 * 0.01),
      maxInvestorCap : new BigNumber(10**18 * 0.2),
      exchangeRate : 1000,
      startTime : latestTime() + duration.minutes(5),
      endTime : latestTime() + duration.weeks(1),
      contributionAddress: contribution.address
    }
    const tier1Address = await deployTier(deployer, tier1);

    let tierNumber = 0;
    await contribution.initializeTier(tierNumber, tier1Address);
    const tiers1 = await contribution.tiers(0);
    assert(tiers1 === tier1Address, 'tier1 address wasnot initialized properly');
    
  });
};


async function deployMultisig(deployer, accounts) {
  const owner1 = accounts[0];
  const owner2 = accounts[1];
  const numRequiredSignatures = 1;

  const values = [[owner1, owner2], numRequiredSignatures];
  const encodedParams = abiEncoder.rawEncode(['address[]', 'uint256'], values);
  console.log('MULTISIG PARAMS : \n', encodedParams.toString('hex'));
  return deployer.deploy(MultiSigWallet, [owner1, owner2], 1);
}

async function deployTier(deployer, {
          totalCap, 
          minimum,
          maxInvestorCap, 
          exchangeRate, 
          startTime, 
          endTime,
          contributionAddress
         }) {


  await deployer.deploy(Tier, totalCap, minimum, maxInvestorCap, exchangeRate, startTime, endTime);
  const valuesTier = [totalCap.toString(10), minimum.toString(10), maxInvestorCap.toString(10), exchangeRate, startTime, endTime];
  const encodedParamsTier = abiEncoder.rawEncode(['uint256', 'uint256', 'uint256', 'uint256', 'uint256', 'uint256'], valuesTier);
  console.log(encodedParamsTier.toString('hex'));
  const tier = await Tier.deployed();
  await tier.changeController(contributionAddress);
  return tier.address;

}