const MiniMeTokenFactory = artifacts.require("MiniMeTokenFactory");
const CND = artifacts.require("CND");
const Contribution = artifacts.require("Contribution");
const MultiSigWallet = artifacts.require("MultiSigWallet");
const Tier = artifacts.require("Tier");
const abiEncoder = require('ethereumjs-abi');

function latestTime() {
  return web3.eth.getBlock('latest').timestamp;
}
const BigNumber = web3.BigNumber;

function toFixed(x) {
  if (Math.abs(x) < 1.0) {
    var e = parseInt(x.toString().split('e-')[1]);
    if (e) {
        x *= Math.pow(10,e-1);
        x = '0.' + (new Array(e)).join('0') + x.toString().substring(2);
    }
  } else {
    var e = parseInt(x.toString().split('+')[1]);
    if (e > 20) {
        e -= 20;
        x /= Math.pow(10,e);
        x += (new Array(e+1)).join('0');
    }
  }
  return x;
}


const duration = {
  seconds: function(val) { return val},
  minutes: function(val) { return val * this.seconds(60) },
  hours:   function(val) { return val * this.minutes(60) },
  days:    function(val) { return val * this.hours(24) },
  weeks:   function(val) { return val * this.days(7) },
  years:   function(val) { return val * this.days(365)} 
};

module.exports = function(deployer, chain, accounts) {
  return deployer.deploy(MiniMeTokenFactory).then(async () => {
    const tokenFactory = await MiniMeTokenFactory.deployed();
    const encodedParamsCND = abiEncoder.rawEncode(['address'], [tokenFactory.address]);
    await deployer.deploy(CND, tokenFactory.address);
    console.log('ENCODED PARAMS CND: \n', encodedParamsCND.toString('hex'));
    
    const cnd = await CND.deployed();
    
    await deployMultisig(deployer, accounts);
    const multiSig = await MultiSigWallet.deployed();
    
    await deployer.deploy(Contribution, cnd.address, multiSig.address);
    const encodedParamsContribution = abiEncoder.rawEncode(['address', 'address'], [cnd.address, multiSig.address]);
    console.log('CONTRIBUTION ENCODED: \n', encodedParamsContribution.toString('hex'));

    const contribution = await Contribution.deployed();
    await cnd.changeController(contribution.address);
    
    const totalCap = new BigNumber(10**18 * 2);
    const minimum = new BigNumber(10**18 * 0.01);
    const maxInvestorCap = new BigNumber(10**18 * 0.2);
    const exchangeRate = 10;
    const startTime = latestTime() + duration.minutes(5);
    const endTime = latestTime() + duration.weeks(5);
    
    await deployer.deploy(Tier, totalCap, minimum, maxInvestorCap, exchangeRate, startTime, endTime);
    const valuesTier1 = [totalCap.toString(10), minimum.toString(10), maxInvestorCap.toString(10), exchangeRate, startTime, endTime];
    const encodedParamsTier1 = abiEncoder.rawEncode(['uint256', 'uint256', 'uint256', 'uint256', 'uint256', 'uint256'], valuesTier1);
    console.log(encodedParamsTier1.toString('hex'));
    const tier1 = await Tier.deployed();
    await tier1.changeController(contribution.address);
    
    await deployer.deploy(Tier, totalCap, minimum, maxInvestorCap, exchangeRate, startTime, endTime);
    const tier2 = await Tier.deployed();

    await tier2.changeController(contribution.address);

    let tierNumber = 0;
    await contribution.initializeTier(tierNumber, tier1.address);
    await contribution.initializeTier(tierNumber + 1, tier2.address);
    

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