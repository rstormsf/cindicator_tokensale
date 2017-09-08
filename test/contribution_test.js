const Contribution = artifacts.require("./DebugContribution.sol");

const CND = artifacts.require("./CND.sol");
const MiniMeTokenFactory = artifacts.require("MiniMeTokenFactory");
const MiniMeToken = artifacts.require("MiniMeToken");
const MultiSigWallet = artifacts.require("MultiSigWallet");
const Tier = artifacts.require("Tier");
const BigNumber = web3.BigNumber;
const assert = require('chai')
  .use(require('chai-as-promised'))
  .use(require('chai-bignumber')(BigNumber))
  .assert;

function getTime() {
  return Math.floor(Date.now() / 1000);
}

function latestTime() {
  return web3.eth.getBlock('latest').timestamp;
}


const duration = {
  seconds: function (val) { return val },
  minutes: function (val) { return val * this.seconds(60) },
  hours: function (val) { return val * this.minutes(60) },
  days: function (val) { return val * this.hours(24) },
  weeks: function (val) { return val * this.days(7) },
  years: function (val) { return val * this.days(365) }
};

let cnd;
let contribution;
let tier1_params;
let tier1_deployed;

let tier2_params;
let tier2_deployed;

let tier3_params;
let tier3_deployed;

let tier4_params;
let tier4_deployed;

contract("Contribution", (
  [miner,
    owner,
    contributionWallet,
    foundersWallet,
    advisorsWallet,
    bountyWallet],
  network) => {

  describe('#contstructor', async function () {
    it("#constructor accepts MiniMe instance", async function () {
      const tokenFactory = await MiniMeTokenFactory.new();
      const cnd = await CND.new(tokenFactory.address);
      const contribution = await Contribution.new(
        contributionWallet,
        foundersWallet,
        advisorsWallet,
        bountyWallet
      );
      await cnd.changeController(contribution.address);
      await contribution.initializeToken(cnd.address);
      const miniMe = await contribution.cnd();
      const contributionWalletAddress = await contribution.contributionWallet();
      const foundersWalletAddress = await contribution.foundersWallet();
      const bountyWalletAddress = await contribution.bountyWallet();
      const advisorsWalletAddress = await contribution.advisorsWallet();
      assert.equal(
        miniMe,
        cnd.address,
        "== token address"
      );
      assert.equal(
        contributionWalletAddress,
        contributionWallet,
        "== contribution wallet address"
      );
      assert.equal(
        foundersWalletAddress,
        foundersWallet,
        "== founders wallet address"
      );
      assert.equal(
        bountyWalletAddress,
        bountyWallet,
        "== bounty wallet address"
      );
      assert.equal(
        advisorsWalletAddress,
        advisorsWallet,
        "== advisors wallet address"
      );
    });

    it('throws if cnd.controller is not contribution contract', async function(){
      const tokenFactory = await MiniMeTokenFactory.new();
      const cnd = await CND.new(tokenFactory.address);
      const contribution = await Contribution.new(
        contributionWallet,
        foundersWallet,
        advisorsWallet,
        bountyWallet
      );
      await shouldThrow(contribution.initializeToken, [cnd.address]);
    });

    it('throws if it is not CND based contract', async function(){
      const tokenFactory = await MiniMeTokenFactory.new();
      const genericMiniMe = await MiniMeToken.new(tokenFactory.address, '0x0', 0, "MiniMe", 18, "MMT", true);
      const contribution = await Contribution.new(
        contributionWallet,
        foundersWallet,
        advisorsWallet,
        bountyWallet
      );
      await shouldThrow(contribution.initializeToken, [genericMiniMe.address]);
    });
  })

  describe("#initializeTier", async function () {

    beforeEach(async function () {
      function unlockAccounts(password) {
        for (var i = 0; i < web3.eth.accounts.length; i++) {
          web3.personal.unlockAccount(`${web3.eth.accounts[i]}`, password, 100000);
        }
      }
      const networkId = web3.version.network;
      if (networkId !== '123' && networkId !== '321') {
        unlockAccounts('testtest');
      }

      const tokenFactory = await MiniMeTokenFactory.new();
      cnd = await CND.new(tokenFactory.address);
      contribution = await Contribution.new(
        contributionWallet,
        foundersWallet,
        advisorsWallet,
        bountyWallet
      );
      await cnd.changeController(contribution.address);
      tier1_params = {
        totalCap: new BigNumber(10 ** 18 * 2),
        minimum: new BigNumber(10 ** 18 * 0.5),
        maxInvestorCap: new BigNumber(10 ** 18 * 1.5),
        exchangeRate: 3,
        startTime: latestTime() + duration.minutes(5),
        endTime: latestTime() + duration.weeks(1),
        contributionAddress: contribution.address
      }
      tier1_deployed = await Tier.new(tier1_params.totalCap, tier1_params.minimum, tier1_params.maxInvestorCap, tier1_params.exchangeRate, tier1_params.startTime, tier1_params.endTime);
      await tier1_deployed.changeController(contribution.address);
    });

    it("can intialize 4 tiers", async function () {
      await contribution.initializeToken(cnd.address);
      await deployThreeTiers(contribution.address);
      await contribution.initializeTier(
        0, tier1_deployed.address
      );
      await contribution.initializeTier(
        1, tier2_deployed.address
      );
      await contribution.initializeTier(
        2, tier3_deployed.address
      );
      await contribution.initializeTier(
        3, tier4_deployed.address
      );

      const tier1_from_contribution_array = await contribution.tiers(0);
      assert.equal(tier1_from_contribution_array, tier1_deployed.address, "Contribution can't save tier");

      const tier2_from_contribution_array = await contribution.tiers(1);
      assert.equal(tier2_from_contribution_array, tier2_deployed.address, "Contribution can't save tier");

      const tier3_from_contribution_array = await contribution.tiers(2);
      assert.equal(tier3_from_contribution_array, tier3_deployed.address, "Contribution can't save tier");

      const tier4_from_contribution_array = await contribution.tiers(3);
      assert.equal(tier4_from_contribution_array, tier4_deployed.address, "Contribution can't save tier");

    });

    it("throws when you try to initialize tier without token initialization", async function () {
      await shouldThrow(contribution.initializeTier, [0, tier1_deployed.address]);
      const tier = await contribution.tiers(0);
      assert.equal(tier, '0x0000000000000000000000000000000000000000');
    });

    it("throws when you try to overwrite tier", async function () {
      await contribution.initializeToken(cnd.address);
      await contribution.initializeTier(
        0, tier1_deployed.address
      );
      await shouldThrow(contribution.initializeTier, [0, '0x0039F22efB07A647557C7C5d17854CFD6D489eF3']);
      const tier = await contribution.tiers(0);
      assert.equal(tier, tier1_deployed.address);
    });

    it("throws when you try to initialize 5 tiers", async function () {
      await deployThreeTiers(contribution.address);
      await contribution.initializeToken(cnd.address);
      await contribution.initializeTier(
        0, tier1_deployed.address
      );
      await contribution.initializeTier(
        1, tier2_deployed.address
      );
      await contribution.initializeTier(
        2, tier3_deployed.address
      );
      await contribution.initializeTier(
        3, tier4_deployed.address
      );
      await shouldThrow(contribution.initializeTier, [4, tier1_deployed.address]);
      await shouldThrow(contribution.tiers, [4]);
    });

    describe('fallback', async function () {
      it('throws when called', async function () {
        await shouldThrow(contribution.send, [tier1_params.minimum]);
        await shouldThrow(tier1_deployed.send, [tier1_params.minimum]);
        await shouldThrow(cnd.send, [tier1_params.minimum]);
        const totalInvested = await tier1_deployed.totalInvestedWei();
        assert.equal(totalInvested, 0);
      })
    });

    describe('#proxyPayment', async function () {

      beforeEach(async function () {
        await contribution.initializeToken(cnd.address);
        await contribution.initializeTier(
          0, tier1_deployed.address
        );
        await contribution.setBlockTimestamp(tier1_params.startTime);
        await contribution.whitelistAddresses([owner, miner], 0, true);
        const isWhitelisted = await contribution.isWhitelisted(owner, 0);
        assert.equal(isWhitelisted, true, 'whitelisting did not go thru');
      });

      it('increments tierCount when tier is bought out', async function(){
        const tierCount = await contribution.tierCount();
        await contribution.buy({from: owner, value: tier1_params.maxInvestorCap});
        await contribution.buy({from: miner, value: tier1_params.maxInvestorCap});
        const isCapReached = await contribution.isCurrentTierCapReached();
        assert.equal(isCapReached, true);
        const tierCountAfter = await contribution.tierCount();
        assert.equal(tierCount.toNumber() + 1, tierCountAfter.toNumber());
        const totalSold = await contribution.totalTokensSold();
        assert.equal(totalSold.toNumber(), tier1_params.totalCap.mul(tier1_params.exchangeRate).toNumber());
        const investedWei = await tier1_deployed.totalInvestedWei();
        assert.equal(investedWei.toNumber(), tier1_params.totalCap.toNumber());
      });

      it('sends any amount after minimum was received', async function(){
        await contribution.buy({from: owner, value: tier1_params.minimum});
        await contribution.buy({from: owner, value: 1});
        const expectedBalance = tier1_params.minimum.add(1).mul(tier1_params.exchangeRate).toString();
        const balanceAfter = await cnd.balanceOf(owner);;
        assert.equal(balanceAfter.toString(), expectedBalance);
      })

      it('sends any amount after minimum was received', async function(){
        await contribution.buy({from: owner, value: tier1_params.maxInvestorCap.sub(1)});
        await contribution.buy({from: owner, value: tier1_params.maxInvestorCap});
        const balanceAfter = await cnd.balanceOf(owner);
        const expectedBalance = tier1_params.maxInvestorCap.mul(tier1_params.exchangeRate).toString();
        assert.equal(balanceAfter.toString(), expectedBalance);
      })

      it('allows to buy 1 whiteslited investor', async function () {
        const pre = await web3.eth.getBalance(owner);
        const weiToSend = tier1_params.minimum.mul(2);
        const contWallBalanceBefore = await web3.eth.getBalance(contributionWallet);
        const txReceipt = await contribution.buy({ from: owner, value: weiToSend });

        const post = await web3.eth.getBalance(owner);
        const postCon = await web3.eth.getBalance(contributionWallet);

        assert(post.toNumber() < pre.toNumber(), 'post is more than pre');
        const contWallBalanceAfter = await web3.eth.getBalance(contributionWallet);
        assert.equal(contWallBalanceAfter.sub(contWallBalanceBefore).toNumber(), weiToSend.toNumber(), 'contributionWallet balance is not equal to weiToSend');
        let totalNow = await tier1_deployed.totalInvestedWei();
        assert.equal(totalNow.toNumber(), weiToSend.toNumber(), 'totalWei is not equal to invested amount');

        const totalSold = await contribution.totalTokensSold();
        const userShouldReceiveTokens = weiToSend.mul(tier1_params.exchangeRate);
        assert.equal(totalSold.toNumber(), userShouldReceiveTokens, 'totalSoldTokens is not equal to how much was sold');
        let tokensLeft = await contribution.investorAmountTokensToBuy(owner);
        assert.equal(tokensLeft.toNumber(), tier1_params.maxInvestorCap.sub(weiToSend).mul(tier1_params.exchangeRate));
        const balance = await cnd.balanceOf(owner);
        assert.equal(balance.toNumber(), userShouldReceiveTokens.toNumber(), 'balanceOf doesnot have right amout of tokens');
      });

      it('buys tokens on the amount available to buy and sends refund if it exceeds maxCapInvestor', async function () {
        const weiToSend = tier1_params.minimum.mul(2);
        const contWallBalanceBefore = await web3.eth.getBalance(contributionWallet);
        const txReceipt = await contribution.proxyPayment(owner, { from: owner, value: weiToSend });
        await contribution.proxyPayment(owner, { from: owner, value: tier1_params.maxInvestorCap });

        const totalNow = await tier1_deployed.totalInvestedWei();
        assert.equal(totalNow.toNumber(), tier1_params.maxInvestorCap.toNumber());

        const tokensLeft = await contribution.investorAmountTokensToBuy(owner);
        assert.equal(tokensLeft.toNumber(), 0);

        const isCapReached = await contribution.isCurrentTierCapReached();
        assert.equal(isCapReached, false, 'capTier should not be full');

        const contWallBalanceAfter = await web3.eth.getBalance(contributionWallet);
        assert.equal(contWallBalanceAfter.sub(contWallBalanceBefore).toNumber(), tier1_params.maxInvestorCap.toNumber(), 'contributionWallet balance is not equal to maxCap');

        const totalSold = await contribution.totalTokensSold();
        const userShouldReceiveTokens = tier1_params.maxInvestorCap.mul(tier1_params.exchangeRate);
        assert.equal(totalSold.toNumber(), userShouldReceiveTokens, 'totalSoldTokens is not equal to how much was sold');

        const balance = await cnd.balanceOf(owner);
        assert.equal(balance.toNumber(), userShouldReceiveTokens.toNumber(), 'balanceOf doesnot have right amout of tokens');
      })

      it('allows to buy with multisig contract', async function () {

        const multiSig = await MultiSigWallet.new([miner, owner], 1);
        await web3.eth.sendTransaction({ from: miner, to: multiSig.address, value: tier1_params.maxInvestorCap.mul(2) });
        await contribution.whitelistAddresses([multiSig.address], 0, true);

        const encodedProxyPaymentCall = contribution.contract.proxyPayment.getData(contribution.address);

        const totalInvestedBefore = await tier1_deployed.totalInvestedWei();
        assert.equal(0, totalInvestedBefore.toNumber());

        await multiSig.submitTransaction(contribution.address, tier1_params.maxInvestorCap, encodedProxyPaymentCall);

        const totalInvestedAfter = await tier1_deployed.totalInvestedWei();
        assert.equal(totalInvestedAfter.toNumber(), tier1_params.maxInvestorCap.toNumber(), 'totalInvested is not equal to MaxCap');

        const balanceOf = await cnd.balanceOf(multiSig.address);
        assert.equal(balanceOf.toNumber(), tier1_params.maxInvestorCap.mul(tier1_params.exchangeRate).toNumber());

      })

      it('throws if maxCapInvestor is reached', async function () {
        await contribution.proxyPayment(owner, { from: owner, value: tier1_params.maxInvestorCap });
        const totalInvestedBefore = await tier1_deployed.totalInvestedWei();
        await shouldThrow(contribution.proxyPayment, [owner, { from: owner, value: 1 }]);
        const totalInvestedAfter = await tier1_deployed.totalInvestedWei();
        assert.equal(totalInvestedAfter.toNumber(), totalInvestedBefore.toNumber());
      });

      it('throws if tier cap is reached', async function () {
        await contribution.whitelistAddresses([advisorsWallet], 0, true);
        await contribution.proxyPayment(owner, { from: owner, value: tier1_params.maxInvestorCap });
        await contribution.proxyPayment(advisorsWallet, { from: advisorsWallet, value: tier1_params.minimum });

        const totalInvestedBefore = await tier1_deployed.totalInvestedWei();
        await shouldThrow(contribution.proxyPayment, [advisorsWallet, { from: advisorsWallet, value: tier1_params.minimum }]);
        const totalInvestedAfter = await tier1_deployed.totalInvestedWei();
        assert.equal(totalInvestedAfter.toNumber(), totalInvestedBefore.toNumber());
      });

      it('throws if not whitelisted', async function () {
        const totalInvestedBefore = await tier1_deployed.totalInvestedWei();
        await shouldThrow(contribution.proxyPayment, [advisorsWallet, { from: advisorsWallet, value: tier1_params.minimum }]);
        const totalInvestedAfter = await tier1_deployed.totalInvestedWei();
        assert.equal(totalInvestedAfter.toNumber(), totalInvestedBefore.toNumber());
      });

      it('throws if endTime is passed', async function () {
        await contribution.setBlockTimestamp(tier1_params.endTime + 1);
        const totalInvestedBefore = await tier1_deployed.totalInvestedWei();
        await shouldThrow(contribution.proxyPayment, [owner, { from: owner, value: tier1_params.maxInvestorCap }]);
        const totalInvestedAfter = await tier1_deployed.totalInvestedWei();
        assert.equal(totalInvestedAfter.toNumber(), totalInvestedBefore.toNumber());
      });
    });

    describe('#finalize', async function () {
      beforeEach(async function () {
        await contribution.initializeToken(cnd.address);
        await contribution.initializeTier(
          0, tier1_deployed.address
        );
        await contribution.setBlockTimestamp(tier1_params.startTime);
        await contribution.whitelistAddresses([owner], 0, true);
        const isWhitelisted = await contribution.isWhitelisted(owner, 0);
        assert.equal(isWhitelisted, true, 'whitelisting did not go thru');
      });

      it('onlyController can call tier.finalize', async function(){
        await shouldThrow(tier1_deployed.finalize,[]);
        let finalized = await tier1_deployed.finalizedTime();
        assert.equal(finalized.toNumber(), 0);
        await contribution.finalize();
        finalized = await tier1_deployed.finalizedTime();
        assert(finalized.toNumber() > 0);
      })

      it('increases tierCount', async function () {
        let tierCount = await contribution.tierCount();
        assert.equal(tierCount.toNumber(), 0);
        await contribution.finalize();
        tierCount = await contribution.tierCount();
        assert.equal(tierCount.toNumber(), 1);

      });
      it('throws when you call finalize on non-existed tier', async function () {
        await contribution.finalize();
        const tierCountBefore = await contribution.tierCount();
        await shouldThrow(contribution.finalize,[]);
        const tierCountAfter = await contribution.tierCount();
        assert.equal(tierCountBefore.toNumber(), tierCountAfter.toNumber());
      });
    });

    describe('#pauseContribution', async function () {
      beforeEach(async function(){
        await contribution.initializeToken(cnd.address);
        await contribution.initializeTier(
          0, tier1_deployed.address
        );
      })
      it('sets paused', async function () {
        let paused = await contribution.paused();
        assert.equal(paused, false);
        await contribution.pauseContribution(true);
        paused = await contribution.paused();
        assert.equal(paused, true);
      })
      it('throws when you proxyBuy with paused state', async function () {
        await contribution.pauseContribution(true);
        await contribution.setBlockTimestamp(tier1_params.startTime);
        await contribution.whitelistAddresses([owner], 0, true);

        const totalInvestedBefore = await tier1_deployed.totalInvestedWei();
        await shouldThrow(contribution.proxyPayment, [owner, { from: owner, value: tier1_params.maxInvestorCap }]);
        const totalInvestedAfter = await tier1_deployed.totalInvestedWei();
        assert.equal(totalInvestedAfter.toNumber(), totalInvestedBefore.toNumber());
      })

      it('throws if non-owner calls it', async function () {
        const before = await contribution.paused();
        await shouldThrow(contribution.pauseContribution, [true, { from: advisorsWallet }]);
        const after = await contribution.paused();
        assert.equal(before, after);
      });
    });

    describe('#allocate', async function () {
      it('happy path', async function () {
        const should = require('chai')
          .use(require('chai-as-promised'))
          .use(require('chai-bignumber')(BigNumber))
          .should()

        await deployThreeTiers(contribution.address);
        await contribution.initializeToken(cnd.address);
        await contribution.initializeTier(
          0, tier1_deployed.address
        );
        await contribution.initializeTier(
          1, tier2_deployed.address
        );
        await contribution.initializeTier(
          2, tier3_deployed.address
        );
        await contribution.initializeTier(
          3, tier4_deployed.address
        );
        await contribution.setBlockTimestamp(tier4_params.startTime);
        await contribution.whitelistAddresses([owner], 0, true);

        await contribution.finalize();
        await contribution.finalize();
        await contribution.finalize();

        await contribution.proxyPayment(owner, { from: owner, value: tier4_params.maxInvestorCap });
        const totalTokenSold = await contribution.totalTokensSold();
        const totalSupply = totalTokenSold.mul(100).div(75);
        const foundersAmount = totalSupply.div(5);
        const advisorsAmount = totalSupply.mul(38).div(1000);
        const bountyAmount = totalSupply.mul(12).div(1000);
        await contribution.finalize();

        //will be succesful
        await contribution.allocate();
        // will be rejected
        await shouldThrow(contribution.allocate,[]);
        const balanceFounders = await cnd.balanceOf(foundersWallet);
        const balanceAdvisors = await cnd.balanceOf(advisorsWallet);
        const balanceBounty = await cnd.balanceOf(bountyWallet);

        foundersAmount.should.be.bignumber.equal(balanceFounders, 0, BigNumber.ROUND_DOWN, 'balanceFounders failed');
        advisorsAmount.should.be.bignumber.equal(advisorsAmount, 0, BigNumber.ROUND_DOWN, 'balanceAdvisors failed');
        bountyAmount.should.be.bignumber.equal(balanceBounty, 0, BigNumber.ROUND_DOWN, 'balanceBounty failed');
      })
    })

    describe('#allowTransfers', async function () {
      beforeEach(async function(){
        await contribution.initializeToken(cnd.address);
        await contribution.initializeTier(
          0, tier1_deployed.address
        );
        await contribution.setBlockTimestamp(tier1_params.startTime);
        await contribution.whitelistAddresses([miner], 0, true);
        await contribution.buy({ from: miner, value: tier1_params.maxInvestorCap });
      })

      it('sets transferrable', async function () {
        let transferable = await contribution.transferable();
        assert.equal(transferable, false);
        await contribution.allowTransfers(true);
        transferable = await contribution.transferable();
        assert.equal(transferable, true);

        let balanceMiner = await cnd.balanceOf(miner);
        const userShouldReceiveTokens = tier1_params.maxInvestorCap.mul(tier1_params.exchangeRate);
        assert.equal(balanceMiner.toNumber(), userShouldReceiveTokens.toNumber(), 'balanceOf doesnot have right amout of tokens');
        await cnd.transfer(foundersWallet, userShouldReceiveTokens, { from: miner });
        const balanceFounder = await cnd.balanceOf(foundersWallet);
        assert.equal(balanceFounder.toNumber(), userShouldReceiveTokens.toNumber(), 'founderwallet did not receive tokens');
        balanceMiner = await cnd.balanceOf(miner);
        assert.equal(balanceMiner.toNumber(), 0);
      })

      it('always allows to transfer after October 12', async function () {
        let transferable = await contribution.transferable();
        assert.equal(transferable, false, 'transferable is true');

        const balanceBeforeMiner = await cnd.balanceOf(miner);
        await shouldThrow(cnd.transfer, [foundersWallet, tier1_params.maxInvestorCap, {from: miner}]);
        let balanceAfterMiner = await cnd.balanceOf(miner);
        assert.equal(balanceAfterMiner.toNumber(), balanceBeforeMiner.toNumber());
        const numberOfTokens = tier1_params.maxInvestorCap.mul(tier1_params.exchangeRate).toNumber();
        assert.equal(balanceBeforeMiner.toNumber(), numberOfTokens);

        const October12_2017_JS = new Date('October 12 2017 14:00:00').getTime()/1000;
        await contribution.setBlockTimestamp(October12_2017_JS);
        const contract_oct12 = await contribution.October12_2017();
        assert(October12_2017_JS >= contract_oct12.toNumber());
        await cnd.transfer(foundersWallet, numberOfTokens, {from: miner});
        balanceAfterMiner = await cnd.balanceOf(miner);
        assert.equal(balanceAfterMiner.toNumber(), 0);
        const balanceFounder = await cnd.balanceOf(foundersWallet);
        assert.equal(balanceFounder.toNumber(), balanceBeforeMiner.toNumber());
      })

    })

    describe('#contributionOpen', async function () {
      beforeEach(async function(){
        await contribution.initializeToken(cnd.address);
        await contribution.initializeTier(
          0, tier1_deployed.address
        );
      })
      it('happy path - returns true', async function () {
        let contributionOpen = await contribution.contributionOpen();
        assert.equal(contributionOpen, false);
        await contribution.setBlockTimestamp(tier1_params.startTime);
        contributionOpen = await contribution.contributionOpen();
        assert.equal(contributionOpen, true);
      });

      it('returns false when endTime passed', async function () {
        let contributionOpen = await contribution.contributionOpen();
        assert.equal(contributionOpen, false);
        await contribution.setBlockTimestamp(tier1_params.endTime + 1);
        contributionOpen = await contribution.contributionOpen();
        assert.equal(contributionOpen, false);
      })

      it('returns false when finalized was called', async function () {
        await contribution.setBlockTimestamp(tier1_params.startTime);
        await contribution.whitelistAddresses([owner, advisorsWallet], 0, true);
        await contribution.buy({ from: owner, value: tier1_params.maxInvestorCap });
        await contribution.buy({ from: advisorsWallet, value: tier1_params.maxInvestorCap });
        const finalizedTime = await tier1_deployed.finalizedTime();
        assert(finalizedTime.toNumber() > 0);
        contributionOpen = await contribution.contributionOpen();
        assert.equal(contributionOpen, false);
      });
    })
  });
});


async function shouldThrow(cb /* function */, params /* array */) {
  const networkId = web3.version.network;
  let txReceipt;
  if (networkId === '123' || networkId === '321') {
    txReceipt = assert.isRejected(cb(...params));
  } else {
    txReceipt = cb(...params);
  }
  return txReceipt;
}

async function deployThreeTiers(contributionAddress) {
  tier2_params = {
    totalCap: new BigNumber(10 ** 18 * 2),
    minimum: new BigNumber(10 ** 18 * 0.01),
    maxInvestorCap: new BigNumber(10 ** 18 * 0.2),
    exchangeRate: 100,
    startTime: latestTime() + duration.minutes(5),
    endTime: latestTime() + duration.weeks(1),
    contributionAddress
  }
  tier2_deployed = await Tier.new(tier2_params.totalCap, tier2_params.minimum, tier2_params.maxInvestorCap, tier2_params.exchangeRate, tier2_params.startTime, tier2_params.endTime);
  await tier2_deployed.changeController(contributionAddress);

  tier3_params = {
    totalCap: new BigNumber(10 ** 18 * 2),
    minimum: new BigNumber(10 ** 18 * 0.01),
    maxInvestorCap: new BigNumber(10 ** 18 * 0.2),
    exchangeRate: 10,
    startTime: latestTime() + duration.minutes(5),
    endTime: latestTime() + duration.weeks(1),
    contributionAddress
  }
  tier3_deployed = await Tier.new(tier3_params.totalCap, tier3_params.minimum, tier3_params.maxInvestorCap, tier3_params.exchangeRate, tier3_params.startTime, tier3_params.endTime);
  await tier3_deployed.changeController(contributionAddress);

  tier4_params = {
    totalCap: new BigNumber(10 ** 18 * 2),
    minimum: new BigNumber(10 ** 18 * 0.01),
    maxInvestorCap: new BigNumber(10 ** 18 * 0.2),
    exchangeRate: 1,
    startTime: latestTime() + duration.minutes(5),
    endTime: latestTime() + duration.weeks(1),
    contributionAddress
  }
  tier4_deployed = await Tier.new(tier4_params.totalCap, tier4_params.minimum, tier4_params.maxInvestorCap, tier4_params.exchangeRate, tier4_params.startTime, tier4_params.endTime);
  await tier4_deployed.changeController(contributionAddress);
}
