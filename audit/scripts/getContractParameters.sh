#!/bin/sh

geth attach << EOF | grep "RESULT: " | sed "s/RESULT: //"

loadScript("deployment.js");

//-----------------------------------------------------------------------------
// Crowdsale Contract
//-----------------------------------------------------------------------------

var crowdsaleFromBlock = 4254698;
function printCrowdsaleContractDetails() {
  console.log("RESULT: crowdsaleContractAddress=" + crowdsaleContractAddress);
  // console.log("RESULT: crowdsaleContractAbi=" + JSON.stringify(crowdsaleContractAbi));
  if (crowdsaleContractAddress != null && crowdsaleContractAbi != null) {
    var contract = eth.contract(crowdsaleContractAbi).at(crowdsaleContractAddress);
    console.log("RESULT: crowdsale.controller=" + contract.controller());
    console.log("RESULT: crowdsale.tierCount=" + contract.tierCount());
    console.log("RESULT: crowdsale.cnd=" + contract.cnd());
    console.log("RESULT: crowdsale.transferable=" + contract.transferable());
    console.log("RESULT: crowdsale.October12_2017=" + contract.October12_2017() + " " + new Date(contract.October12_2017() * 1000).toUTCString());
    console.log("RESULT: crowdsale.contributionWallet=" + contract.contributionWallet());
    console.log("RESULT: crowdsale.foundersWallet=" + contract.foundersWallet());
    console.log("RESULT: crowdsale.advisorsWallet=" + contract.advisorsWallet());
    console.log("RESULT: crowdsale.bountyWallet=" + contract.bountyWallet());
    console.log("RESULT: crowdsale.finalAllocation=" + contract.finalAllocation());
    console.log("RESULT: crowdsale.totalTokensSold=" + contract.totalTokensSold().shift(-18));
    console.log("RESULT: crowdsale.paused=" + contract.paused());

    var latestBlock = eth.blockNumber;
    var i;

    for (i = 0; i < 4; i++) {
      var tierAddress = contract.tiers(i);
      console.log("RESULT: tiers[" + i + "]=" + tierAddress);
      if (tierAddress != "0x0000000000000000000000000000000000000000") {
        var tier = eth.contract(tierAbi).at(tierAddress);
        console.log("RESULT:   .controller=" + tier.controller());
        console.log("RESULT:   .cap=" + tier.cap().shift(-18));
        console.log("RESULT:   .exchangeRate=" + tier.exchangeRate());
        console.log("RESULT:   .minInvestorCap=" + tier.minInvestorCap().shift(-18));
        console.log("RESULT:   .maxInvestorCap=" + tier.maxInvestorCap().shift(-18));
        console.log("RESULT:   .totalInvestedWei=" + tier.totalInvestedWei().shift(-18));
        console.log("RESULT:   .startTime=" + tier.startTime() + " " + new Date(tier.startTime() * 1000).toUTCString());
        console.log("RESULT:   .endTime=" + tier.endTime() + " " + new Date(tier.endTime() * 1000).toUTCString());
        console.log("RESULT:   .initializedTime=" + tier.initializedTime() + " " + new Date(tier.initializedTime() * 1000).toUTCString());
        console.log("RESULT:   .finalizedTime=" + tier.finalizedTime() + " " + new Date(tier.finalizedTime() * 1000).toUTCString());
      }
    }

    var claimedTokensEvents = contract.ClaimedTokens({}, { fromBlock: crowdsaleFromBlock, toBlock: latestBlock });
    i = 0;
    claimedTokensEvents.watch(function (error, result) {
      console.log("RESULT: ClaimedTokens " + i++ + " #" + result.blockNumber + ": " + JSON.stringify(result.args));
    });
    claimedTokensEvents.stopWatching();

    var newSaleEvents = contract.NewSale({}, { fromBlock: crowdsaleFromBlock, toBlock: latestBlock });
    i = 0;
    newSaleEvents.watch(function (error, result) {
      console.log("RESULT: NewSale " + i++ + " #" + result.blockNumber + ": " + JSON.stringify(result.args));
    });
    newSaleEvents.stopWatching();

    var initializedTierEvents = contract.InitializedTier({}, { fromBlock: crowdsaleFromBlock, toBlock: latestBlock });
    i = 0;
    initializedTierEvents.watch(function (error, result) {
      console.log("RESULT: InitializedTier " + i++ + " #" + result.blockNumber + ": " + JSON.stringify(result.args));
    });
    initializedTierEvents.stopWatching();

    var finalizedTierEvents = contract.FinalizedTier({}, { fromBlock: crowdsaleFromBlock, toBlock: latestBlock });
    i = 0;
    finalizedTierEvents.watch(function (error, result) {
      console.log("RESULT: FinalizedTier " + i++ + " #" + result.blockNumber + ": " + JSON.stringify(result.args));
    });
    finalizedTierEvents.stopWatching();

    var refundEvents = contract.Refund({}, { fromBlock: crowdsaleFromBlock, toBlock: latestBlock });
    i = 0;
    refundEvents.watch(function (error, result) {
      console.log("RESULT: Refund " + i++ + " #" + result.blockNumber + ": " + JSON.stringify(result.args));
    });
    refundEvents.stopWatching();

    crowdsaleFromBlock = parseInt(latestBlock) + 1;
  }
}


//-----------------------------------------------------------------------------
// Token Contract
//-----------------------------------------------------------------------------
var tokenFromBlock = 4252963;
function printTokenContractDetails() {
  console.log("RESULT: tokenContractAddress=" + tokenContractAddress);
  // console.log("RESULT: tokenContractAbi=" + JSON.stringify(tokenContractAbi));
  if (tokenContractAddress != null && tokenContractAbi != null) {
    var contract = eth.contract(tokenContractAbi).at(tokenContractAddress);
    var decimals = contract.decimals();
    console.log("RESULT: token.controller=" + contract.controller());
    console.log("RESULT: token.symbol=" + contract.symbol());
    console.log("RESULT: token.name=" + contract.name());
    console.log("RESULT: token.decimals=" + decimals);
    console.log("RESULT: token.totalSupply=" + contract.totalSupply().shift(-decimals));
    // console.log("RESULT: token.totalSupplyHistory=" + contract.totalSupplyHistory());
    // console.log("RESULT: token.mintingFinished=" + contract.mintingFinished());

    var latestBlock = eth.blockNumber;
    var i;

    /*
    var totalSupplyHistoryLength = contract.totalSupplyHistoryLength();
    for (i = 0; i < totalSupplyHistoryLength; i++) {
      var e = contract.totalSupplyHistory(i);
      console.log("RESULT: totalSupplyHistory(" + i + ") = " + e[0] + " => " + e[1].shift(-decimals));
    }

    var balanceHistoryLength = contract.balanceHistoryLength(account3);
    for (i = 0; i < balanceHistoryLength; i++) {
      var e = contract.balanceHistory(account3, i);
      console.log("RESULT: balanceHistory(" + account3 + ", " + i + ") = " + e[0] + " => " + e[1].shift(-decimals));
    }

    var balanceHistoryLength = contract.balanceHistoryLength(account4);
    for (i = 0; i < balanceHistoryLength; i++) {
      var e = contract.balanceHistory(account4, i);
      console.log("RESULT: balanceHistory(" + account4 + ", " + i + ") = " + e[0] + " => " + e[1].shift(-decimals));
    }

    var balanceHistoryLength = contract.balanceHistoryLength(account5);
    for (i = 0; i < balanceHistoryLength; i++) {
      var e = contract.balanceHistory(account5, i);
      console.log("RESULT: balanceHistory(" + account5 + ", " + i + ") = " + e[0] + " => " + e[1].shift(-decimals));
    }

    var balanceHistoryLength = contract.balanceHistoryLength(account6);
    for (i = 0; i < balanceHistoryLength; i++) {
      var e = contract.balanceHistory(account6, i);
      console.log("RESULT: balanceHistory(" + account6 + ", " + i + ") = " + e[0] + " => " + e[1].shift(-decimals));
    }
    */

    var approvalEvents = contract.Approval({}, { fromBlock: tokenFromBlock, toBlock: latestBlock });
    i = 0;
    approvalEvents.watch(function (error, result) {
      console.log("RESULT: Approval " + i++ + " #" + result.blockNumber + " _owner=" + result.args._owner + " _spender=" + result.args._spender + " _amount=" +
        result.args._amount.shift(-decimals));
    });
    approvalEvents.stopWatching();

    var transferEvents = contract.Transfer({}, { fromBlock: tokenFromBlock, toBlock: latestBlock });
    i = 0;
    transferEvents.watch(function (error, result) {
      console.log("RESULT: Transfer " + i++ + " #" + result.blockNumber + ": _from=" + result.args._from + " _to=" + result.args._to +
        " _amount=" + result.args._amount.shift(-decimals));
    });
    transferEvents.stopWatching();

    tokenFromBlock = parseInt(latestBlock) + 1;
  }
}

printCrowdsaleContractDetails();
printTokenContractDetails();

EOF
