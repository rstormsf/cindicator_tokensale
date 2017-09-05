const Contribution = artifacts.require("./DebugContribution.sol");

const CND = artifacts.require("./CND.sol");
const MiniMeTokenFactory = artifacts.require("MiniMeTokenFactory");
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

contract("Contribution", ([owner, contributionWallet, foundersWallet, advisorsWallet, bountyWallet]) => {
    it("#constructor accepts MiniMe instance", async function () {
        const tokenFactory = await MiniMeTokenFactory.new();
        const cnd = await CND.new(tokenFactory.address);
        const contribution = await Contribution.new(
            cnd.address,
            contributionWallet,
            foundersWallet,
            advisorsWallet,
            bountyWallet
        );
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
    describe("#initializeTier", async function () {
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

        beforeEach(async function () {
            const tokenFactory = await MiniMeTokenFactory.new();
            cnd = await CND.new(tokenFactory.address);
            contribution = await Contribution.new(
                cnd.address,
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

            tier2_params = {
                totalCap: new BigNumber(10 ** 18 * 2),
                minimum: new BigNumber(10 ** 18 * 0.01),
                maxInvestorCap: new BigNumber(10 ** 18 * 0.2),
                exchangeRate: 100,
                startTime: latestTime() + duration.minutes(5),
                endTime: latestTime() + duration.weeks(1),
                contributionAddress: contribution.address
            }
            tier2_deployed = await Tier.new(tier2_params.totalCap, tier2_params.minimum, tier2_params.maxInvestorCap, tier2_params.exchangeRate, tier2_params.startTime, tier2_params.endTime);
            await tier2_deployed.changeController(contribution.address);

            tier3_params = {
                totalCap: new BigNumber(10 ** 18 * 2),
                minimum: new BigNumber(10 ** 18 * 0.01),
                maxInvestorCap: new BigNumber(10 ** 18 * 0.2),
                exchangeRate: 10,
                startTime: latestTime() + duration.minutes(5),
                endTime: latestTime() + duration.weeks(1),
                contributionAddress: contribution.address
            }
            tier3_deployed = await Tier.new(tier3_params.totalCap, tier3_params.minimum, tier3_params.maxInvestorCap, tier3_params.exchangeRate, tier3_params.startTime, tier3_params.endTime);
            await tier3_deployed.changeController(contribution.address);

            tier4_params = {
                totalCap: new BigNumber(10 ** 18 * 2),
                minimum: new BigNumber(10 ** 18 * 0.01),
                maxInvestorCap: new BigNumber(10 ** 18 * 0.2),
                exchangeRate: 1,
                startTime: latestTime() + duration.minutes(5),
                endTime: latestTime() + duration.weeks(1),
                contributionAddress: contribution.address
            }
            tier4_deployed = await Tier.new(tier4_params.totalCap, tier4_params.minimum, tier4_params.maxInvestorCap, tier4_params.exchangeRate, tier4_params.startTime, tier4_params.endTime);
            await tier4_deployed.changeController(contribution.address);
        });

        it("can intialize 4 tiers", async function () {
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

        it("throws when you try to overwrite tier", async function () {
            await contribution.initializeTier(
                0, tier1_deployed.address
            );
            await assert.isRejected(contribution.initializeTier(0, tier1_deployed.address), "invalid opcode");

        });

        it("throws when you try to initialize 5 tiers", async function () {
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
            await assert.isRejected(contribution.initializeTier(4, tier1_deployed.address), "invalid opcode");
        });

        describe('fallback', async function () {
            it('throws when called', async function () {
                await assert.isRejected(contribution.send(tier1_params.minimum));
                await assert.isRejected(tier1_deployed.send(tier1_params.minimum));
                await assert.isRejected(cnd.send(tier1_params.minimum));
            })
        });

        describe('#proxyBuy', async function () {
            beforeEach(async function () {
                await contribution.initializeTier(
                    0, tier1_deployed.address
                );
                await contribution.setBlockTimestamp(tier1_params.startTime);
                await contribution.whitelistAddresses([owner], 0, true);
                const isWhitelisted = await contribution.isWhitelisted(owner, 0);
                assert.equal(isWhitelisted, true, 'whitelisting did not go thru');
            });
            it('allows to buy 1 whiteslited investor', async function () {
                const pre = await web3.eth.getBalance(owner);
                const weiToSend = tier1_params.minimum.mul(2);
                const contWallBalanceBefore = await web3.eth.getBalance(contributionWallet);
                const txReceipt = await contribution.proxyPayment(owner, { from: owner, value: weiToSend });
                const post = await web3.eth.getBalance(owner);

                // cant figure out how to calculate precisely the new balance.
                // I thought that:  `pre - txReceipt.gasUsed * gasPrice + weiToSend` would work
                // assert.equal(post.toNumber(), pre.sub(weiToSend).toNumber(), 'owner balance should have changed');
                assert(post.toNumber() < pre.toNumber());
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

            it('throws if maxCapInvestor is reached', async function () {
                await contribution.proxyPayment(owner, { from: owner, value: tier1_params.maxInvestorCap });
                await assert.isRejected(contribution.proxyPayment(owner, { from: owner, value: 1 }));
            });

            it('throws if tier cap is reached', async function () {
                await contribution.whitelistAddresses([advisorsWallet], 0, true);
                await contribution.proxyPayment(owner, { from: owner, value: tier1_params.maxInvestorCap });
                await contribution.proxyPayment(advisorsWallet, { from: advisorsWallet, value: tier1_params.minimum });
                await assert.isRejected(contribution.proxyPayment(advisorsWallet, { from: advisorsWallet, value: tier1_params.minimum }));
            });

            it('throws if not whitelisted', async function () {
                await assert.isRejected(contribution.proxyPayment(advisorsWallet, { from: advisorsWallet, value: tier1_params.minimum }));
            });

            it('throws if endTime is passed', async function () {
                await contribution.setBlockTimestamp(tier1_params.endTime + 1);
                await assert.isRejected(contribution.proxyPayment(owner, { from: owner, value: tier1_params.maxInvestorCap }));
            });

            it('reach totalCap happy path', async function () {
                await contribution.whitelistAddresses([advisorsWallet], 0, true);

                await contribution.proxyPayment(owner, { from: owner, value: tier1_params.maxInvestorCap });
                await contribution.proxyPayment(advisorsWallet, { from: advisorsWallet, value: tier1_params.maxInvestorCap });
                let totalNow = await tier1_deployed.totalInvestedWei();
                assert.equal(totalNow.toNumber(), tier1_params.totalCap.toNumber());

                let tokensLeftOwner = await contribution.investorAmountTokensToBuy(owner);
                assert.equal(tokensLeftOwner.toNumber(), 0);

                let tokensLeftAdvisor = await contribution.investorAmountTokensToBuy(advisorsWallet);
                // tier cap is 2 eth, we should only process 0.5 eth, so 1 eth * exchangeRate = 3 * 10**18 tokens
                assert.equal(tokensLeftAdvisor.toNumber(), new BigNumber(10 ** 18 * 3));

                const isCapReached = await contribution.isCurrentTierCapReached();
                assert.equal(isCapReached, true);
                const totalSold = await contribution.totalTokensSold();
                assert.equal(totalSold, tier1_params.totalCap.mul(tier1_params.exchangeRate).toNumber());
                const investedWei = await tier1_deployed.totalInvestedWei();
                assert.equal(investedWei.toNumber(), tier1_params.totalCap.toNumber());
            })

        });

        describe('#finalize', async function () {
            it('increases tierCount', async function () {
                await contribution.initializeTier(
                    0, tier1_deployed.address
                );
                let tierCount = await contribution.tierCount();
                assert.equal(tierCount.toNumber(), 0);
                await contribution.setBlockTimestamp(tier1_params.startTime);
                await contribution.finalize();
                tierCount = await contribution.tierCount();
                assert.equal(tierCount.toNumber(), 1);

            });
            it('throws when you call finalize on non-existed tier', async function () {
                await assert.isRejected(contribution.finalize());
            });
        });

        describe('#pauseContribution', async function () {
            it('sets paused', async function () {
                await contribution.initializeTier(
                    0, tier1_deployed.address
                );
                let paused = await contribution.paused();
                assert.equal(paused, false);
                await contribution.pauseContribution(true);
                paused = await contribution.paused();
                assert.equal(paused, true);
            })
            it('throws when you proxyBuy with paused state', async function () {
                await contribution.initializeTier(
                    0, tier1_deployed.address
                );
                await contribution.pauseContribution(true);
                await contribution.setBlockTimestamp(tier1_params.startTime);
                await contribution.whitelistAddresses([owner], 0, true);
                await assert.isRejected(contribution.proxyPayment(owner, { from: owner, value: tier1_params.maxInvestorCap }));
            })

            it('throws if non-owner calls it', async function () {
                await contribution.initializeTier(
                    0, tier1_deployed.address
                );
                await assert.isRejected(contribution.pauseContribution(true, { from: advisorsWallet }));
            });
        });

        describe('#allocate', async function () {
            it('happy path', async function () {
                const should = require('chai')
                    .use(require('chai-as-promised'))
                    .use(require('chai-bignumber')(BigNumber))
                    .should()
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

                await assert.isFulfilled(contribution.allocate());
                await assert.isRejected(contribution.allocate());
                const balanceFounders = await cnd.balanceOf(foundersWallet);
                const balanceAdvisors = await cnd.balanceOf(advisorsWallet);
                const balanceBounty = await cnd.balanceOf(bountyWallet);

                foundersAmount.should.be.bignumber.equal(balanceFounders, 0, BigNumber.ROUND_DOWN, 'balanceFounders failed');
                advisorsAmount.should.be.bignumber.equal(advisorsAmount, 0, BigNumber.ROUND_DOWN, 'balanceAdvisors failed');
                bountyAmount.should.be.bignumber.equal(balanceBounty, 0, BigNumber.ROUND_DOWN, 'balanceBounty failed');

            })
        })

        describe('#allowTransfers', async function () {
            it('sets transferrable', async function () {
                await contribution.initializeTier(
                    0, tier1_deployed.address
                );
                await contribution.setBlockTimestamp(tier1_params.startTime);
                await contribution.whitelistAddresses([owner], 0, true);
                await contribution.proxyPayment(owner, { from: owner, value: tier1_params.maxInvestorCap });

                let transferable = await contribution.transferable();
                assert.equal(transferable, false);
                await contribution.allowTransfers(true);
                transferable = await contribution.transferable();
                assert.equal(transferable, true);

                let balanceOwner = await cnd.balanceOf(owner);
                const userShouldReceiveTokens = tier1_params.maxInvestorCap.mul(tier1_params.exchangeRate);
                assert.equal(balanceOwner.toNumber(), userShouldReceiveTokens.toNumber(), 'balanceOf doesnot have right amout of tokens');
                await assert.isFulfilled(cnd.transfer(foundersWallet, userShouldReceiveTokens));
                const balanceFounder = await cnd.balanceOf(foundersWallet);
                assert.equal(balanceFounder.toNumber(), userShouldReceiveTokens.toNumber());
                balanceOwner = await cnd.balanceOf(owner);
                assert.equal(balanceOwner.toNumber(), 0);
                
            })

            it('always allows to transfer after October 12', async function(){
                await contribution.initializeTier(
                    0, tier1_deployed.address
                );
                await contribution.setBlockTimestamp(tier1_params.startTime);
                await contribution.whitelistAddresses([owner], 0, true);
                await contribution.proxyPayment(owner, { from: owner, value: tier1_params.maxInvestorCap });
                
                await assert.isRejected(cnd.transfer(foundersWallet, tier1_params.maxInvestorCap));
                const October12_2017 = 1507830400;
                await contribution.setBlockTimestamp(October12_2017 + 1);
                await assert.isFulfilled(cnd.transfer(foundersWallet, tier1_params.maxInvestorCap));
            })
        })

        describe('#contributionOpen', async function () {
            it('happy path - returns true', async function () {
                await contribution.initializeTier(
                    0, tier1_deployed.address
                );
                let contributionOpen = await contribution.contributionOpen();
                assert.equal(contributionOpen, false);
                await contribution.setBlockTimestamp(tier1_params.startTime);
                contributionOpen = await contribution.contributionOpen();
                assert.equal(contributionOpen, true);
            });

            it('returns false when endTime passed', async function () {
                await contribution.initializeTier(
                    0, tier1_deployed.address
                );
                let contributionOpen = await contribution.contributionOpen();
                assert.equal(contributionOpen, false);
                await contribution.setBlockTimestamp(tier1_params.endTime + 1);
                contributionOpen = await contribution.contributionOpen();
                assert.equal(contributionOpen, false);
            })

            it('returns false when finalized was called', async function () {
                await contribution.initializeTier(
                    0, tier1_deployed.address
                );
                await contribution.setBlockTimestamp(tier1_params.startTime);
                await contribution.whitelistAddresses([owner, advisorsWallet], 0, true);
                await contribution.proxyPayment(owner, { from: owner, value: tier1_params.maxInvestorCap });
                await contribution.proxyPayment(advisorsWallet, { from: advisorsWallet, value: tier1_params.maxInvestorCap });
                const finalizedTime = await tier1_deployed.finalizedTime();
                assert(finalizedTime.toNumber() > 0);
                contributionOpen = await contribution.contributionOpen();
                assert.equal(contributionOpen, false);
                await assert.isRejected(tier1_deployed.finalize());
            });


        })

    });
});

