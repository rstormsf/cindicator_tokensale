#!/bin/bash
# ----------------------------------------------------------------------------------------------
# Testing the smart contract
#
# Enjoy. (c) BokkyPooBah / Bok Consulting Pty Ltd 2017. The MIT Licence.
# ----------------------------------------------------------------------------------------------

MODE=${1:-test}

GETHATTACHPOINT=`grep ^IPCFILE= settings.txt | sed "s/^.*=//"`
PASSWORD=`grep ^PASSWORD= settings.txt | sed "s/^.*=//"`

CONTRACTSDIR=`grep ^CONTRACTSDIR= settings.txt | sed "s/^.*=//"`

CNDSOL=`grep ^CNDSOL= settings.txt | sed "s/^.*=//"`
CNDTEMPSOL=`grep ^CNDTEMPSOL= settings.txt | sed "s/^.*=//"`
CNDJS=`grep ^CNDJS= settings.txt | sed "s/^.*=//"`

CONTRIBUTIONSOL=`grep ^CONTRIBUTIONSOL= settings.txt | sed "s/^.*=//"`
CONTRIBUTIONTEMPSOL=`grep ^CONTRIBUTIONTEMPSOL= settings.txt | sed "s/^.*=//"`
CONTRIBUTIONJS=`grep ^CONTRIBUTIONJS= settings.txt | sed "s/^.*=//"`

MINIMETOKENSOL=`grep ^MINIMETOKENSOL= settings.txt | sed "s/^.*=//"`
MINIMETOKENTEMPSOL=`grep ^MINIMETOKENTEMPSOL= settings.txt | sed "s/^.*=//"`
MINIMETOKENJS=`grep ^MINIMETOKENJS= settings.txt | sed "s/^.*=//"`

SAFEMATHSOL=`grep ^SAFEMATHSOL= settings.txt | sed "s/^.*=//"`
SAFEMATHTEMPSOL=`grep ^SAFEMATHTEMPSOL= settings.txt | sed "s/^.*=//"`

TIERSOL=`grep ^TIERSOL= settings.txt | sed "s/^.*=//"`
TIERTEMPSOL=`grep ^TIERTEMPSOL= settings.txt | sed "s/^.*=//"`
TIERJS=`grep ^TIERJS= settings.txt | sed "s/^.*=//"`

DEPLOYMENTDATA=`grep ^DEPLOYMENTDATA= settings.txt | sed "s/^.*=//"`

TEST3OUTPUT=`grep ^TEST3OUTPUT= settings.txt | sed "s/^.*=//"`
TEST3RESULTS=`grep ^TEST3RESULTS= settings.txt | sed "s/^.*=//"`

CURRENTTIME=`date +%s`
CURRENTTIMES=`date -r $CURRENTTIME -u`

# Setting time to be a block representing one day
BLOCKSINDAY=1

if [ "$MODE" == "dev" ]; then
  # Start time now
  STARTTIME=`echo "$CURRENTTIME" | bc`
else
  # Start time 1m 10s in the future
  STARTTIME=`echo "$CURRENTTIME+60*2+10" | bc`
fi
STARTTIME_S=`date -r $STARTTIME -u`
ENDTIME=`echo "$CURRENTTIME+60*6" | bc`
ENDTIME_S=`date -r $ENDTIME -u`

printf "MODE                 = '$MODE'\n" | tee $TEST3OUTPUT
printf "GETHATTACHPOINT      = '$GETHATTACHPOINT'\n" | tee -a $TEST3OUTPUT
printf "PASSWORD             = '$PASSWORD'\n" | tee -a $TEST3OUTPUT

printf "CONTRACTSDIR         = '$CONTRACTSDIR'\n" | tee -a $TEST3OUTPUT

printf "CNDSOL               = '$CNDSOL'\n" | tee -a $TEST3OUTPUT
printf "CNDTEMPSOL           = '$CNDTEMPSOL'\n" | tee -a $TEST3OUTPUT
printf "CNDJS                = '$CNDJS'\n" | tee -a $TEST3OUTPUT

printf "CONTRIBUTIONSOL      = '$CONTRIBUTIONSOL'\n" | tee -a $TEST3OUTPUT
printf "CONTRIBUTIONTEMPSOL  = '$CONTRIBUTIONTEMPSOL'\n" | tee -a $TEST3OUTPUT
printf "CONTRIBUTIONJS       = '$CONTRIBUTIONJS'\n" | tee -a $TEST3OUTPUT

printf "MINIMETOKENSOL       = '$MINIMETOKENSOL'\n" | tee -a $TEST3OUTPUT
printf "MINIMETOKENTEMPSOL   = '$MINIMETOKENTEMPSOL'\n" | tee -a $TEST3OUTPUT
printf "MINIMETOKENJS        = '$MINIMETOKENJS'\n" | tee -a $TEST3OUTPUT

printf "SAFEMATHSOL          = '$SAFEMATHSOL'\n" | tee -a $TEST3OUTPUT
printf "SAFEMATHTEMPSOL      = '$SAFEMATHTEMPSOL'\n" | tee -a $TEST3OUTPUT

printf "TIERSOL             = '$TIERSOL'\n" | tee -a $TEST3OUTPUT
printf "TIERTEMPSOL         = '$TIERTEMPSOL'\n" | tee -a $TEST3OUTPUT
printf "TIERJS              = '$TIERJS'\n" | tee -a $TEST3OUTPUT

printf "DEPLOYMENTDATA       = '$DEPLOYMENTDATA'\n" | tee -a $TEST3OUTPUT
printf "TEST3OUTPUT          = '$TEST3OUTPUT'\n" | tee -a $TEST3OUTPUT
printf "TEST3RESULTS         = '$TEST3RESULTS'\n" | tee -a $TEST3OUTPUT
printf "CURRENTTIME          = '$CURRENTTIME' '$CURRENTTIMES'\n" | tee -a $TEST3OUTPUT
printf "STARTTIME            = '$STARTTIME' '$STARTTIME_S'\n" | tee -a $TEST3OUTPUT
printf "ENDTIME              = '$ENDTIME' '$ENDTIME_S'\n" | tee -a $TEST3OUTPUT

# Make copy of SOL file and modify start and end times ---
`cp $CONTRACTSDIR/$CNDSOL $CNDTEMPSOL`
`cp $CONTRACTSDIR/$CONTRIBUTIONSOL $CONTRIBUTIONTEMPSOL`
#`cp modifiedContracts/$CONTRIBUTIONSOL $CONTRIBUTIONTEMPSOL`
# `cp $CONTRACTSDIR/$MINIMETOKENSOL $MINIMETOKENTEMPSOL`
`cp modifiedContracts/$MINIMETOKENSOL $MINIMETOKENTEMPSOL`
`cp $CONTRACTSDIR/$SAFEMATHSOL $SAFEMATHTEMPSOL`
`cp $CONTRACTSDIR/$TIERSOL $TIERTEMPSOL`

# --- Modify dates ---
#`perl -pi -e "s/startTime \= 1498140000;.*$/startTime = $STARTTIME; \/\/ $STARTTIME_S/" $FUNFAIRSALETEMPSOL`
#`perl -pi -e "s/deadline \=  1499436000;.*$/deadline = $ENDTIME; \/\/ $ENDTIME_S/" $FUNFAIRSALETEMPSOL`
#`perl -pi -e "s/\/\/\/ \@return total amount of tokens.*$/function overloadedTotalSupply() constant returns (uint256) \{ return totalSupply; \}/" $DAOCASINOICOTEMPSOL`
#`perl -pi -e "s/BLOCKS_IN_DAY \= 5256;*$/BLOCKS_IN_DAY \= $BLOCKSINDAY;/" $DAOCASINOICOTEMPSOL`

DIFFS1=`diff $CONTRACTSDIR/$CNDSOL $CNDTEMPSOL`
echo "--- Differences $CONTRACTSDIR/$CNDSOL $CNDTEMPSOL ---" | tee -a $TEST3OUTPUT
echo "$DIFFS1" | tee -a $TEST3OUTPUT

DIFFS1=`diff $CONTRACTSDIR/$CONTRIBUTIONSOL $CONTRIBUTIONTEMPSOL`
echo "--- Differences $CONTRACTSDIR/$CONTRIBUTIONSOL $CONTRIBUTIONTEMPSOL ---" | tee -a $TEST3OUTPUT
echo "$DIFFS1" | tee -a $TEST3OUTPUT

DIFFS1=`diff $CONTRACTSDIR/$MINIMETOKENSOL $MINIMETOKENTEMPSOL`
echo "--- Differences $CONTRACTSDIR/$MINIMETOKENSOL $MINIMETOKENTEMPSOL ---" | tee -a $TEST3OUTPUT
echo "$DIFFS1" | tee -a $TEST3OUTPUT

DIFFS1=`diff $CONTRACTSDIR/$TIERSOL $TIERTEMPSOL`
echo "--- Differences $CONTRACTSDIR/$TIERSOL $TIERTEMPSOL ---" | tee -a $TEST3OUTPUT
echo "$DIFFS1" | tee -a $TEST3OUTPUT

echo "var cndOutput=`solc --optimize --combined-json abi,bin,interface $CNDTEMPSOL`;" > $CNDJS

echo "var contribOutput=`solc --optimize --combined-json abi,bin,interface $CONTRIBUTIONTEMPSOL`;" > $CONTRIBUTIONJS

echo "var mmOutput=`solc --optimize --combined-json abi,bin,interface $MINIMETOKENSOL`;" > $MINIMETOKENJS

echo "var tierOutput=`solc --optimize --combined-json abi,bin,interface $TIERTEMPSOL`;" > $TIERJS


geth --verbosity 3 attach $GETHATTACHPOINT << EOF | tee -a $TEST3OUTPUT
loadScript("$CNDJS");
loadScript("$CONTRIBUTIONJS");
loadScript("$MINIMETOKENJS");
loadScript("$TIERJS");
loadScript("functions.js");

var cndAbi = JSON.parse(cndOutput.contracts["$CNDTEMPSOL:CND"].abi);
var cndBin = "0x" + cndOutput.contracts["$CNDTEMPSOL:CND"].bin;

var contribAbi = JSON.parse(contribOutput.contracts["$CONTRIBUTIONTEMPSOL:Contribution"].abi);
var contribBin = "0x" + contribOutput.contracts["$CONTRIBUTIONTEMPSOL:Contribution"].bin;

var mmtfAbi = JSON.parse(mmOutput.contracts["$MINIMETOKENSOL:MiniMeTokenFactory"].abi);
var mmtfBin = "0x" + mmOutput.contracts["$MINIMETOKENSOL:MiniMeTokenFactory"].bin;

var tierAbi = JSON.parse(tierOutput.contracts["$TIERTEMPSOL:Tier"].abi);
var tierBin = "0x" + tierOutput.contracts["$TIERTEMPSOL:Tier"].bin;

// console.log("DATA: cndAbi=" + JSON.stringify(cndAbi));
// console.log("DATA: cndBin=" + cndBin);
// console.log("DATA: contribAbi=" + JSON.stringify(contribAbi));
// console.log("DATA: contribBin=" + contribBin);
// console.log("DATA: mmtfAbi=" + JSON.stringify(mmtfAbi));
// console.log("DATA: mmtmmtfBinfAbi=" + mmtfBin);
// console.log("DATA: tierAbi=" + JSON.stringify(tierAbi));
// console.log("DATA: tierBin=" + JSON.stringify(tierBin));

unlockAccounts("$PASSWORD");
printBalances();
console.log("RESULT: ");


// -----------------------------------------------------------------------------
var mmtfMessage = "Deploy MiniMeTokenFactory";
// -----------------------------------------------------------------------------
console.log("RESULT: " + mmtfMessage);
var mmtfContract = web3.eth.contract(mmtfAbi);
var mmtfTx = null;
var mmtfAddress = null;
var mmtf = mmtfContract.new({from: contractOwnerAccount, data: mmtfBin, gas: 4000000},
  function(e, contract) {
    if (!e) {
      if (!contract.address) {
        mmtfTx = contract.transactionHash;
      } else {
        mmtfAddress = contract.address;
        addAccount(mmtfAddress, "MiniMeTokenFactory");
        printTxData("mmtfAddress=" + mmtfAddress, mmtfTx);
      }
    }
  }
);
while (txpool.status.pending > 0) {
}
printBalances();
failIfGasEqualsGasUsed(mmtfTx, mmtfMessage);
console.log("RESULT: ");


// -----------------------------------------------------------------------------
var cndMessage = "Deploy CND";
// -----------------------------------------------------------------------------
console.log("RESULT: " + cndMessage);
var cndContract = web3.eth.contract(cndAbi);
var cndTx = null;
var cndAddress = null;
var cnd = cndContract.new(mmtfAddress, {from: contractOwnerAccount, data: cndBin, gas: 4000000},
  function(e, contract) {
    if (!e) {
      if (!contract.address) {
        cndTx = contract.transactionHash;
      } else {
        cndAddress = contract.address;
        addAccount(cndAddress, "CND");
        addTokenContractAddressAndAbi(cndAddress, cndAbi);
        printTxData("cndAddress=" + cndAddress, cndTx);
      }
    }
  }
);
while (txpool.status.pending > 0) {
}
printBalances();
failIfGasEqualsGasUsed(cndTx, cndMessage);
printTokenContractDetails();
console.log("RESULT: ");


// -----------------------------------------------------------------------------
var contribMessage = "Deploy Contribution";
// function Contribution(address _cnd, address _contributionWallet, 
//   address _foundersWallet, address _advisorsWallet, address _bountyWallet)
// -----------------------------------------------------------------------------
console.log("RESULT: " + contribMessage);
var contribContract = web3.eth.contract(contribAbi);
var contribTx = null;
var contribAddress = null;
var contrib = contribContract.new(multisig, foundersWallet, advisorsWallet, bountyWallet,
  {from: contractOwnerAccount, data: contribBin, gas: 4000000},
  function(e, contract) {
    if (!e) {
      if (!contract.address) {
        contribTx = contract.transactionHash;
      } else {
        contribAddress = contract.address;
        addAccount(contribAddress, "Contribution");
        addCrowdsaleContractAddressAndAbi(contribAddress, contribAbi, tierAbi);
        printTxData("contribAddress=" + contribAddress, contribTx);
      }
    }
  }
);
while (txpool.status.pending > 0) {
}
printBalances();
failIfGasEqualsGasUsed(contribTx, contribMessage);
printCrowdsaleContractDetails();
printTokenContractDetails();
console.log("RESULT: ");


// -----------------------------------------------------------------------------
var changeCndControllerMessage = "Change CND Controller";
// -----------------------------------------------------------------------------
console.log("RESULT: " + changeCndControllerMessage);
var changeCndControllerTx = cnd.changeController(contribAddress, {from: contractOwnerAccount, gas: 2000000});
while (txpool.status.pending > 0) {
}
printTxData("changeCndControllerTx", changeCndControllerTx);
printBalances();
failIfGasEqualsGasUsed(changeCndControllerTx, changeCndControllerMessage + " - CND");
printCrowdsaleContractDetails();
printTokenContractDetails();
console.log("RESULT: ");


// -----------------------------------------------------------------------------
var initializeTokenMessage = "Initialise Token";
// -----------------------------------------------------------------------------
console.log("RESULT: " + initializeTokenMessage);
var initializeTokenTx = contrib.initializeToken(cndAddress, 0, true, {from: contractOwnerAccount, gas: 2000000});
while (txpool.status.pending > 0) {
}
printTxData("initializeTokenTx", initializeTokenTx);
printBalances();
failIfGasEqualsGasUsed(initializeTokenTx, initializeTokenMessage);
printCrowdsaleContractDetails();
printTokenContractDetails();
console.log("RESULT: ");


// -----------------------------------------------------------------------------
var whitelistAddressesMessage = "Whitelist Addresses";
// -----------------------------------------------------------------------------
console.log("RESULT: " + whitelistAddressesMessage);
var whitelistAddresse0Tx = contrib.whitelistAddresses([account3, account7], 0, true, {from: contractOwnerAccount, gas: 2000000});
var whitelistAddresse1Tx = contrib.whitelistAddresses([account4, account8], 1, true, {from: contractOwnerAccount, gas: 2000000});
var whitelistAddresse2Tx = contrib.whitelistAddresses([account5, account9], 2, true, {from: contractOwnerAccount, gas: 2000000});
var whitelistAddresse3Tx = contrib.whitelistAddresses([account6, account10], 3, true, {from: contractOwnerAccount, gas: 2000000});
while (txpool.status.pending > 0) {
}
printTxData("whitelistAddresse0Tx", whitelistAddresse0Tx);
printTxData("whitelistAddresse1Tx", whitelistAddresse1Tx);
printTxData("whitelistAddresse2Tx", whitelistAddresse2Tx);
printTxData("whitelistAddresse3Tx", whitelistAddresse3Tx);
printBalances();
failIfGasEqualsGasUsed(whitelistAddresse0Tx, whitelistAddressesMessage + " - Tier0 - ac3 + ac7");
failIfGasEqualsGasUsed(whitelistAddresse1Tx, whitelistAddressesMessage + " - Tier1 - ac3+ac4 + ac7+ac8");
failIfGasEqualsGasUsed(whitelistAddresse2Tx, whitelistAddressesMessage + " - Tier2 - ac3+ac4+ac5 + ac7+ac8+ac9");
failIfGasEqualsGasUsed(whitelistAddresse3Tx, whitelistAddressesMessage + " - Tier3 - ac4+ac4+ac5+ac6 + ac7+ac8+ac9+ac10");
printCrowdsaleContractDetails();
printTokenContractDetails();
console.log("RESULT: ");


// -----------------------------------------------------------------------------
var deployTiersMessage = "Deploy Tiers";
var _cap0 = web3.toWei("100", "ether");
var _cap1 = web3.toWei("350", "ether");
var _cap2 = web3.toWei("450", "ether");
var _cap3 = web3.toWei("600", "ether");
var _minInvestorCap = web3.toWei("10", "ether");
var _maxInvestorCap0 = web3.toWei("50", "ether");
var _maxInvestorCap1 = web3.toWei("200", "ether"); // Note 175 from Yuri
var _maxInvestorCap2 = web3.toWei("230", "ether"); // Note 225 from Yuri
var _maxInvestorCap3 = web3.toWei("450", "ether"); // Note 400 from Yuri
var _exchangeRate0 = "400";
var _exchangeRate1 = "300";
var _exchangeRate2 = "200";
var _exchangeRate3 = "100";
// -----------------------------------------------------------------------------
console.log("RESULT: " + deployTiersMessage);
var tierContract = web3.eth.contract(tierAbi);
var tier0Tx = null;
var tier1Tx = null;
var tier2Tx = null;
var tier3Tx = null;
var tier0Address = null;
var tier1Address = null;
var tier2Address = null;
var tier3Address = null;
var tier0 = tierContract.new(_cap0, _minInvestorCap, _maxInvestorCap0, _exchangeRate0, $STARTTIME, $ENDTIME, {from: contractOwnerAccount, data: tierBin, gas: 4000000},
  function(e, contract) {
    if (!e) {
      if (!contract.address) {
        tier0Tx = contract.transactionHash;
      } else {
        tier0Address = contract.address;
        addAccount(tier0Address, "Tier0");
        // addPlaceHolderContractAddressAndAbi(phAddress, phAbi);
        printTxData("tier0Address=" + tier0Address, tier0Tx);
      }
    }
  }
);
var tier1 = tierContract.new(_cap1, _minInvestorCap, _maxInvestorCap1, _exchangeRate1, $STARTTIME, $ENDTIME, {from: contractOwnerAccount, data: tierBin, gas: 4000000},
  function(e, contract) {
    if (!e) {
      if (!contract.address) {
        tier1Tx = contract.transactionHash;
      } else {
        tier1Address = contract.address;
        addAccount(tier1Address, "Tier1");
        // addPlaceHolderContractAddressAndAbi(phAddress, phAbi);
        printTxData("tier1Address=" + tier1Address, tier1Tx);
      }
    }
  }
);
var tier2 = tierContract.new(_cap2, _minInvestorCap, _maxInvestorCap2, _exchangeRate2, $STARTTIME, $ENDTIME, {from: contractOwnerAccount, data: tierBin, gas: 4000000},
  function(e, contract) {
    if (!e) {
      if (!contract.address) {
        tier2Tx = contract.transactionHash;
      } else {
        tier2Address = contract.address;
        addAccount(tier2Address, "Tier2");
        // addPlaceHolderContractAddressAndAbi(phAddress, phAbi);
        printTxData("tier2Address=" + tier2Address, tier2Tx);
      }
    }
  }
);
var tier3 = tierContract.new(_cap3, _minInvestorCap, _maxInvestorCap3, _exchangeRate3, $STARTTIME, $ENDTIME, {from: contractOwnerAccount, data: tierBin, gas: 4000000},
  function(e, contract) {
    if (!e) {
      if (!contract.address) {
        tier3Tx = contract.transactionHash;
      } else {
        tier3Address = contract.address;
        addAccount(tier3Address, "Tier3");
        // addPlaceHolderContractAddressAndAbi(phAddress, phAbi);
        printTxData("tier3Address=" + tier3Address, tier3Tx);
      }
    }
  }
);
while (txpool.status.pending > 0) {
}
printBalances();
failIfGasEqualsGasUsed(tier0Tx, deployTiersMessage + " - Tier0");
failIfGasEqualsGasUsed(tier1Tx, deployTiersMessage + " - Tier1");
failIfGasEqualsGasUsed(tier2Tx, deployTiersMessage + " - Tier2");
failIfGasEqualsGasUsed(tier3Tx, deployTiersMessage + " - Tier3");
printCrowdsaleContractDetails();
printTokenContractDetails();
console.log("RESULT: ");


// -----------------------------------------------------------------------------
var changeTierControllerMessage = "Change Tier Controller";
// -----------------------------------------------------------------------------
console.log("RESULT: " + changeTierControllerMessage);
var changeTier0ControllerTx = tier0.changeController(contribAddress, {from: contractOwnerAccount, gas: 2000000});
var changeTier1ControllerTx = tier1.changeController(contribAddress, {from: contractOwnerAccount, gas: 2000000});
var changeTier2ControllerTx = tier2.changeController(contribAddress, {from: contractOwnerAccount, gas: 2000000});
var changeTier3ControllerTx = tier3.changeController(contribAddress, {from: contractOwnerAccount, gas: 2000000});
while (txpool.status.pending > 0) {
}
printTxData("changeTier0ControllerTx", changeTier0ControllerTx);
printTxData("changeTier1ControllerTx", changeTier1ControllerTx);
printTxData("changeTier2ControllerTx", changeTier2ControllerTx);
printTxData("changeTier3ControllerTx", changeTier3ControllerTx);
printBalances();
failIfGasEqualsGasUsed(changeTier0ControllerTx, changeTierControllerMessage + " - Tier0");
failIfGasEqualsGasUsed(changeTier1ControllerTx, changeTierControllerMessage + " - Tier1");
failIfGasEqualsGasUsed(changeTier2ControllerTx, changeTierControllerMessage + " - Tier2");
failIfGasEqualsGasUsed(changeTier3ControllerTx, changeTierControllerMessage + " - Tier3");
printCrowdsaleContractDetails();
printTokenContractDetails();
console.log("RESULT: ");


// -----------------------------------------------------------------------------
var initialiseTiersMessage = "Initialise Tiers";
// -----------------------------------------------------------------------------
console.log("RESULT: " + initialiseTiersMessage);
var initialiseTier0Tx = contrib.initializeTier(0, tier0Address, {from: contractOwnerAccount, gas: 2000000});
// var initialiseTier1Tx = contrib.initializeTier(1, tier1Address, {from: contractOwnerAccount, gas: 2000000});
// var initialiseTier2Tx = contrib.initializeTier(2, tier2Address, {from: contractOwnerAccount, gas: 2000000});
// var initialiseTier3Tx = contrib.initializeTier(3, tier3Address, {from: contractOwnerAccount, gas: 2000000});
while (txpool.status.pending > 0) {
}
printTxData("initialiseTier0Tx", initialiseTier0Tx);
// printTxData("initialiseTier1Tx", initialiseTier1Tx);
// printTxData("initialiseTier2Tx", initialiseTier2Tx);
// printTxData("initialiseTier3Tx", initialiseTier3Tx);
printBalances();
failIfGasEqualsGasUsed(initialiseTier0Tx, initialiseTiersMessage + " - Tier0");
// failIfGasEqualsGasUsed(initialiseTier1Tx, initialiseTiersMessage + " - Tier1");
// failIfGasEqualsGasUsed(initialiseTier2Tx, initialiseTiersMessage + " - Tier2");
// failIfGasEqualsGasUsed(initialiseTier3Tx, initialiseTiersMessage + " - Tier3");
printCrowdsaleContractDetails();
printTokenContractDetails();
console.log("RESULT: ");


// -----------------------------------------------------------------------------
// Wait for crowdsale start
// -----------------------------------------------------------------------------
var startTime = $STARTTIME;
var startTimeDate = new Date(startTime * 1000);
console.log("RESULT: Waiting until startTime at " + startTime + " " + startTimeDate +
  " currentDate=" + new Date());
while ((new Date()).getTime() <= startTimeDate.getTime()) {
}
console.log("RESULT: Waited until startTime at " + startTime + " " + startTimeDate +
  " currentDate=" + new Date());
console.log("RESULT: ");


// -----------------------------------------------------------------------------
var contribute0Message = "Contribute Tier0";
// -----------------------------------------------------------------------------
console.log("RESULT: " + contribute0Message);
var contribute0_1Tx = contrib.proxyPayment(account3, {from: account3, gas: 400000, value: web3.toWei("50", "ether")});
// var contribute0_2Tx = contrib.proxyPayment(account4, {from: account4, gas: 400000, value: web3.toWei("100", "ether")});
var contribute0_3Tx = contrib.proxyPayment(account7, {from: account7, gas: 400000, value: web3.toWei("50", "ether")});
while (txpool.status.pending > 0) {
}
printTxData("contribute0_1Tx", contribute0_1Tx);
// printTxData("contribute0_2Tx", contribute0_2Tx);
printTxData("contribute0_3Tx", contribute0_3Tx);
printBalances();
failIfGasEqualsGasUsed(contribute0_1Tx, contribute0Message + " ac3 50 ETH");
// passIfGasEqualsGasUsed(contribute0_2Tx, contribute0Message + " ac4 100 ETH - Expecting failure");
failIfGasEqualsGasUsed(contribute0_3Tx, contribute0Message + " ac7 50 ETH");
printCrowdsaleContractDetails();
printTokenContractDetails();
console.log("RESULT: ");


// -----------------------------------------------------------------------------
var finalise0Message = "Finalise Tier0";
// -----------------------------------------------------------------------------
if (tier0.finalizedTime() != 0) {
  console.log("RESULT: " + finalise0Message + " - ALREADY AUTOMATICALLY FINALISED");
} else {
  console.log("RESULT: " + finalise0Message);
  var finalise0Tx = contrib.finalize({from: contractOwnerAccount, gas: 4000000});
  while (txpool.status.pending > 0) {
  }
  printTxData("finalise0Tx", finalise0Tx);
  printBalances();
  failIfGasEqualsGasUsed(finalise0Tx, finalise0Message);
  printCrowdsaleContractDetails();
  printTokenContractDetails();
}
console.log("RESULT: ");


// -----------------------------------------------------------------------------
var contribute1Message = "Contribute Tier1";
// -----------------------------------------------------------------------------
console.log("RESULT: " + contribute1Message);
var contribute1_1Tx = contrib.proxyPayment(account4, {from: account4, gas: 400000, value: web3.toWei("160", "ether")});
// var contribute1_2Tx = contrib.proxyPayment(account5, {from: account5, gas: 400000, value: web3.toWei("100", "ether")});
var contribute1_3Tx = contrib.proxyPayment(account8, {from: account8, gas: 400000, value: web3.toWei("190", "ether")});
while (txpool.status.pending > 0) {
}
printTxData("contribute1_1Tx", contribute1_1Tx);
// printTxData("contribute1_2Tx", contribute1_2Tx);
printTxData("contribute1_3Tx", contribute1_3Tx);
printBalances();
failIfGasEqualsGasUsed(contribute1_1Tx, contribute1Message + " ac4 160 ETH");
// passIfGasEqualsGasUsed(contribute1_2Tx, contribute1Message + " ac5 100 ETH - Expecting failure");
failIfGasEqualsGasUsed(contribute1_3Tx, contribute1Message + " ac8 190 ETH");
printCrowdsaleContractDetails();
printTokenContractDetails();
console.log("RESULT: ");


// -----------------------------------------------------------------------------
var finalise1Message = "Finalise Tier1";
// -----------------------------------------------------------------------------
if (tier1.finalizedTime() != 0) {
  console.log("RESULT: " + finalise1Message + " - ALREADY AUTOMATICALLY FINALISED");
} else {
  console.log("RESULT: " + finalise1Message);
  var finalise1Tx = contrib.finalize({from: contractOwnerAccount, gas: 4000000});
  while (txpool.status.pending > 0) {
  }
  printTxData("finalise1Tx", finalise1Tx);
  printBalances();
  failIfGasEqualsGasUsed(finalise1Tx, finalise1Message);
  printCrowdsaleContractDetails();
  printTokenContractDetails();
}
console.log("RESULT: ");


// -----------------------------------------------------------------------------
var contribute2Message = "Contribute Tier2";
// -----------------------------------------------------------------------------
console.log("RESULT: " + contribute2Message);
var contribute2_1Tx = contrib.proxyPayment(account5, {from: account5, gas: 400000, value: web3.toWei("230", "ether")});
// var contribute2_2Tx = contrib.proxyPayment(account6, {from: account6, gas: 400000, value: web3.toWei("100", "ether")});
var contribute2_3Tx = contrib.proxyPayment(account9, {from: account9, gas: 400000, value: web3.toWei("230", "ether")});
while (txpool.status.pending > 0) {
}
printTxData("contribute2_1Tx", contribute2_1Tx);
// printTxData("contribute2_2Tx", contribute2_2Tx);
printTxData("contribute2_3Tx", contribute2_3Tx);
printBalances();
failIfGasEqualsGasUsed(contribute2_1Tx, contribute2Message + " ac5 230 ETH");
// passIfGasEqualsGasUsed(contribute2_2Tx, contribute2Message + " ac6 100 ETH - Expecting failure");
failIfGasEqualsGasUsed(contribute2_3Tx, contribute2Message + " ac9 210 ETH");
printCrowdsaleContractDetails();
printTokenContractDetails();
console.log("RESULT: ");


// -----------------------------------------------------------------------------
var finalise2Message = "Finalise Tier2";
// -----------------------------------------------------------------------------
if (tier2.finalizedTime() != 0) {
  console.log("RESULT: " + finalise2Message + " - ALREADY AUTOMATICALLY FINALISED");
} else {
  console.log("RESULT: " + finalise2Message);
  var finalise2Tx = contrib.finalize({from: contractOwnerAccount, gas: 4000000});
  while (txpool.status.pending > 0) {
  }
  printTxData("finalise2Tx", finalise2Tx);
  printBalances();
  failIfGasEqualsGasUsed(finalise2Tx, finalise2Message);
  printCrowdsaleContractDetails();
  printTokenContractDetails();
}
console.log("RESULT: ");


// -----------------------------------------------------------------------------
var contribute3Message = "Contribute Tier3";
// -----------------------------------------------------------------------------
console.log("RESULT: " + contribute3Message);
var contribute3_1Tx = contrib.proxyPayment(account6, {from: account6, gas: 400000, value: web3.toWei("350", "ether")});
// var contribute3_2Tx = contrib.proxyPayment(account7, {from: account7, gas: 400000, value: web3.toWei("100", "ether")});
var contribute3_3Tx = contrib.proxyPayment(account10, {from: account10, gas: 400000, value: web3.toWei("450", "ether")});
while (txpool.status.pending > 0) {
}
printTxData("contribute3_1Tx", contribute3_1Tx);
// printTxData("contribute3_2Tx", contribute3_2Tx);
printTxData("contribute3_3Tx", contribute3_3Tx);
printBalances();
failIfGasEqualsGasUsed(contribute3_1Tx, contribute3Message + " ac6 350 ETH");
// passIfGasEqualsGasUsed(contribute3_2Tx, contribute3Message + " ac7 100 ETH - Expecting failure");
failIfGasEqualsGasUsed(contribute3_3Tx, contribute3Message + " ac10 450 ETH");
printCrowdsaleContractDetails();
printTokenContractDetails();
console.log("RESULT: ");


// -----------------------------------------------------------------------------
var finalise3Message = "Finalise Tier3";
// -----------------------------------------------------------------------------
if (tier3.finalizedTime() != 0) {
  console.log("RESULT: " + finalise3Message + " - ALREADY AUTOMATICALLY FINALISED");
} else {
  console.log("RESULT: " + finalise3Message);
  var finalise3Tx = contrib.finalize({from: contractOwnerAccount, gas: 4000000});
  while (txpool.status.pending > 0) {
  }
  printTxData("finalise3Tx", finalise3Tx);
  printBalances();
  failIfGasEqualsGasUsed(finalise3Tx, finalise3Message);
  printCrowdsaleContractDetails();
  printTokenContractDetails();
}
console.log("RESULT: ");


// -----------------------------------------------------------------------------
var closeMessage = "Close Crowdsale";
// -----------------------------------------------------------------------------
console.log("RESULT: " + closeMessage);
var allocateTx = contrib.allocate({from: contractOwnerAccount, gas: 4000000});
var allowTransfersTx = contrib.allowTransfers(true, {from: contractOwnerAccount, gas: 4000000});
while (txpool.status.pending > 0) {
}
printTxData("allocateTx", allocateTx);
printTxData("allowTransfersTx", allowTransfersTx);
printBalances();
failIfGasEqualsGasUsed(allocateTx, closeMessage + " - Allocate Tokens");
failIfGasEqualsGasUsed(allowTransfersTx, closeMessage + " - Allow Transfers");
printCrowdsaleContractDetails();
printTokenContractDetails();
console.log("RESULT: ");


// -----------------------------------------------------------------------------
var transferMessage = "Transfers";
// -----------------------------------------------------------------------------
console.log("RESULT: " + transferMessage);
var transfer1Tx = cnd.transfer(account6, "1000000000000", {from: account4, gas: 100000});
var transfer2Tx = cnd.approve(account7,  "30000000000000000", {from: account5, gas: 100000});
while (txpool.status.pending > 0) {
}
var transfer3Tx = cnd.transferFrom(account5, account8, "30000000000000000", {from: account7, gas: 200000});
while (txpool.status.pending > 0) {
}
printTxData("transfer1Tx", transfer1Tx);
printTxData("transfer2Tx", transfer2Tx);
printTxData("transfer3Tx", transfer3Tx);
printBalances();
failIfGasEqualsGasUsed(transfer1Tx, transferMessage + " - transfer 0.000001 tokens ac4 -> ac6. CHECK for movement");
failIfGasEqualsGasUsed(transfer2Tx, transferMessage + " - approve 0.03 tokens ac5 -> ac7");
failIfGasEqualsGasUsed(transfer3Tx, transferMessage + " - transferFrom 0.03 tokens ac5 -> ac8 by ac7. CHECK for movement");
printCrowdsaleContractDetails();
printTokenContractDetails();
console.log("RESULT: ");


EOF
grep "DATA: " $TEST3OUTPUT | sed "s/DATA: //" > $DEPLOYMENTDATA
cat $DEPLOYMENTDATA
grep "RESULT: " $TEST3OUTPUT | sed "s/RESULT: //" > $TEST3RESULTS
cat $TEST3RESULTS
