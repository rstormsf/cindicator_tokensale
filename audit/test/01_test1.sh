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

TEST1OUTPUT=`grep ^TEST1OUTPUT= settings.txt | sed "s/^.*=//"`
TEST1RESULTS=`grep ^TEST1RESULTS= settings.txt | sed "s/^.*=//"`

CURRENTTIME=`date +%s`
CURRENTTIMES=`date -r $CURRENTTIME -u`

# Setting time to be a block representing one day
BLOCKSINDAY=1

if [ "$MODE" == "dev" ]; then
  # Start time now
  STARTTIME=`echo "$CURRENTTIME" | bc`
else
  # Start time 1m 10s in the future
  STARTTIME=`echo "$CURRENTTIME+90" | bc`
fi
STARTTIME_S=`date -r $STARTTIME -u`
ENDTIME=`echo "$CURRENTTIME+60*5" | bc`
ENDTIME_S=`date -r $ENDTIME -u`

printf "MODE                 = '$MODE'\n" | tee $TEST1OUTPUT
printf "GETHATTACHPOINT      = '$GETHATTACHPOINT'\n" | tee -a $TEST1OUTPUT
printf "PASSWORD             = '$PASSWORD'\n" | tee -a $TEST1OUTPUT

printf "CONTRACTSDIR         = '$CONTRACTSDIR'\n" | tee -a $TEST1OUTPUT

printf "CNDSOL               = '$CNDSOL'\n" | tee -a $TEST1OUTPUT
printf "CNDTEMPSOL           = '$CNDTEMPSOL'\n" | tee -a $TEST1OUTPUT
printf "CNDJS                = '$CNDJS'\n" | tee -a $TEST1OUTPUT

printf "CONTRIBUTIONSOL      = '$CONTRIBUTIONSOL'\n" | tee -a $TEST1OUTPUT
printf "CONTRIBUTIONTEMPSOL  = '$CONTRIBUTIONTEMPSOL'\n" | tee -a $TEST1OUTPUT
printf "CONTRIBUTIONJS       = '$CONTRIBUTIONJS'\n" | tee -a $TEST1OUTPUT

printf "MINIMETOKENSOL       = '$MINIMETOKENSOL'\n" | tee -a $TEST1OUTPUT
printf "MINIMETOKENTEMPSOL   = '$MINIMETOKENTEMPSOL'\n" | tee -a $TEST1OUTPUT
printf "MINIMETOKENJS        = '$MINIMETOKENJS'\n" | tee -a $TEST1OUTPUT

printf "SAFEMATHSOL          = '$SAFEMATHSOL'\n" | tee -a $TEST1OUTPUT
printf "SAFEMATHTEMPSOL      = '$SAFEMATHTEMPSOL'\n" | tee -a $TEST1OUTPUT

printf "TIERSOL             = '$TIERSOL'\n" | tee -a $TEST1OUTPUT
printf "TIERTEMPSOL         = '$TIERTEMPSOL'\n" | tee -a $TEST1OUTPUT
printf "TIERJS              = '$TIERJS'\n" | tee -a $TEST1OUTPUT

printf "DEPLOYMENTDATA       = '$DEPLOYMENTDATA'\n" | tee -a $TEST1OUTPUT
printf "TEST1OUTPUT          = '$TEST1OUTPUT'\n" | tee -a $TEST1OUTPUT
printf "TEST1RESULTS         = '$TEST1RESULTS'\n" | tee -a $TEST1OUTPUT
printf "CURRENTTIME          = '$CURRENTTIME' '$CURRENTTIMES'\n" | tee -a $TEST1OUTPUT
printf "STARTTIME            = '$STARTTIME' '$STARTTIME_S'\n" | tee -a $TEST1OUTPUT
printf "ENDTIME              = '$ENDTIME' '$ENDTIME_S'\n" | tee -a $TEST1OUTPUT

# Make copy of SOL file and modify start and end times ---
`cp $CONTRACTSDIR/$CNDSOL $CNDTEMPSOL`
`cp $CONTRACTSDIR/$CONTRIBUTIONSOL $CONTRIBUTIONTEMPSOL`
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
echo "--- Differences $CONTRACTSDIR/$CNDSOL $CNDTEMPSOL ---" | tee -a $TEST1OUTPUT
echo "$DIFFS1" | tee -a $TEST1OUTPUT

DIFFS1=`diff $CONTRACTSDIR/$CONTRIBUTIONSOL $CONTRIBUTIONTEMPSOL`
echo "--- Differences $CONTRACTSDIR/$CONTRIBUTIONSOL $CONTRIBUTIONTEMPSOL ---" | tee -a $TEST1OUTPUT
echo "$DIFFS1" | tee -a $TEST1OUTPUT

DIFFS1=`diff $CONTRACTSDIR/$MINIMETOKENSOL $MINIMETOKENTEMPSOL`
echo "--- Differences $CONTRACTSDIR/$MINIMETOKENSOL $MINIMETOKENTEMPSOL ---" | tee -a $TEST1OUTPUT
echo "$DIFFS1" | tee -a $TEST1OUTPUT

DIFFS1=`diff $CONTRACTSDIR/$TIERSOL $TIERTEMPSOL`
echo "--- Differences $CONTRACTSDIR/$TIERSOL $TIERTEMPSOL ---" | tee -a $TEST1OUTPUT
echo "$DIFFS1" | tee -a $TEST1OUTPUT

echo "var cndOutput=`solc --optimize --combined-json abi,bin,interface $CNDTEMPSOL`;" > $CNDJS

echo "var contribOutput=`solc --optimize --combined-json abi,bin,interface $CONTRIBUTIONTEMPSOL`;" > $CONTRIBUTIONJS

echo "var mmOutput=`solc --optimize --combined-json abi,bin,interface $MINIMETOKENSOL`;" > $MINIMETOKENJS

echo "var tierOutput=`solc --optimize --combined-json abi,bin,interface $TIERTEMPSOL`;" > $TIERJS


geth --verbosity 3 attach $GETHATTACHPOINT << EOF | tee -a $TEST1OUTPUT
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
var contrib = contribContract.new(cndAddress, multisig, foundersWallet, advisorsWallet, bountyWallet,
  {from: contractOwnerAccount, data: contribBin, gas: 4000000},
  function(e, contract) {
    if (!e) {
      if (!contract.address) {
        contribTx = contract.transactionHash;
      } else {
        contribAddress = contract.address;
        addAccount(contribAddress, "Contribution");
        addCrowdsaleContractAddressAndAbi(contribAddress, contribAbi);
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
var deployTiersMessage = "Deploy Tiers";
var _cap = "1000000000000000000000"; // 1000
var _minInvestorCap = "1000000000000000000"; // 1
var _maxInvestorCap0 = "500000000000000000000"; // 500
var _maxInvestorCap1 = "200000000000000000000"; // 200
var _maxInvestorCap2 = "200000000000000000000"; // 200
var _maxInvestorCap3 = "200000000000000000000"; // 200
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
var tier0 = tierContract.new(_cap, _minInvestorCap, _maxInvestorCap0, _exchangeRate0, $STARTTIME, $ENDTIME, {from: contractOwnerAccount, data: tierBin, gas: 4000000},
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
var tier1 = tierContract.new(_cap, _minInvestorCap, _maxInvestorCap1, _exchangeRate1, $STARTTIME, $ENDTIME, {from: contractOwnerAccount, data: tierBin, gas: 4000000},
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
var tier2 = tierContract.new(_cap, _minInvestorCap, _maxInvestorCap2, _exchangeRate2, $STARTTIME, $ENDTIME, {from: contractOwnerAccount, data: tierBin, gas: 4000000},
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
var tier3 = tierContract.new(_cap, _minInvestorCap, _maxInvestorCap3, _exchangeRate3, $STARTTIME, $ENDTIME, {from: contractOwnerAccount, data: tierBin, gas: 4000000},
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
var initialiseTier1Tx = contrib.initializeTier(1, tier1Address, {from: contractOwnerAccount, gas: 2000000});
var initialiseTier2Tx = contrib.initializeTier(2, tier2Address, {from: contractOwnerAccount, gas: 2000000});
var initialiseTier3Tx = contrib.initializeTier(3, tier3Address, {from: contractOwnerAccount, gas: 2000000});
while (txpool.status.pending > 0) {
}
printTxData("initialiseTier0Tx", initialiseTier0Tx);
printTxData("initialiseTier1Tx", initialiseTier1Tx);
printTxData("initialiseTier2Tx", initialiseTier2Tx);
printTxData("initialiseTier3Tx", initialiseTier3Tx);
printBalances();
failIfGasEqualsGasUsed(initialiseTier0Tx, initialiseTiersMessage + " - Tier0");
failIfGasEqualsGasUsed(initialiseTier1Tx, initialiseTiersMessage + " - Tier1");
failIfGasEqualsGasUsed(initialiseTier2Tx, initialiseTiersMessage + " - Tier2");
failIfGasEqualsGasUsed(initialiseTier3Tx, initialiseTiersMessage + " - Tier3");
printCrowdsaleContractDetails();
printTokenContractDetails();
console.log("RESULT: ");


exit;


// -----------------------------------------------------------------------------
var phMessage = "Deploy PlaceHolder";
// -----------------------------------------------------------------------------
console.log("RESULT: " + phMessage);
var phContract = web3.eth.contract(phAbi);
var phTx = null;
var phAddress = null;
var ph = phContract.new(aptAddress, {from: contractOwnerAccount, data: phBin, gas: 4000000},
  function(e, contract) {
    if (!e) {
      if (!contract.address) {
        phTx = contract.transactionHash;
      } else {
        phAddress = contract.address;
        addAccount(phAddress, "PlaceHolder");
        addPlaceHolderContractAddressAndAbi(phAddress, phAbi);
        printTxData("phAddress=" + phAddress, phTx);
      }
    }
  }
);
while (txpool.status.pending > 0) {
}
printBalances();
failIfGasEqualsGasUsed(phTx, phMessage);
printCrowdsaleContractDetails();
printPlaceHolderContractDetails();
printTokenContractDetails();
console.log("RESULT: ");


// -----------------------------------------------------------------------------
var aptChangeControllerMessage = "APT ChangeController To PreSale";
// -----------------------------------------------------------------------------
console.log("RESULT: " + aptChangeControllerMessage);
var aptChangeControllerTx = apt.changeController(psAddress, {from: contractOwnerAccount, gas: 2000000});
while (txpool.status.pending > 0) {
}
printTxData("aptChangeControllerTx", aptChangeControllerTx);
printBalances();
failIfGasEqualsGasUsed(aptChangeControllerTx, aptChangeControllerMessage);
printCrowdsaleContractDetails();
printPlaceHolderContractDetails();
printTokenContractDetails();
console.log("RESULT: ");


// -----------------------------------------------------------------------------
var initialisePresaleMessage = "Initialise PreSale";
// -----------------------------------------------------------------------------
var maxSupply = "1000000000000000000000000";
// Minimum investment in wei
var minimumInvestment = 10;
var startBlock = parseInt(eth.blockNumber) + 5;
var endBlock = parseInt(eth.blockNumber) + 20;
console.log("RESULT: " + initialisePresaleMessage);
var initialisePresaleTx = ps.initialize(multisig, maxSupply, minimumInvestment, startBlock, endBlock,
  {from: contractOwnerAccount, gas: 2000000});
while (txpool.status.pending > 0) {
}
printTxData("initialisePresaleTx", initialisePresaleTx);
printBalances();
failIfGasEqualsGasUsed(initialisePresaleTx, initialisePresaleMessage);
printCrowdsaleContractDetails();
printPlaceHolderContractDetails();
printTokenContractDetails();
console.log("RESULT: ");


// -----------------------------------------------------------------------------
// Wait until startBlock 
// -----------------------------------------------------------------------------
console.log("RESULT: Waiting until startBlock #" + startBlock + " currentBlock=" + eth.blockNumber);
while (eth.blockNumber <= startBlock) {
}
console.log("RESULT: Waited until startBlock #" + startBlock + " currentBlock=" + eth.blockNumber);
console.log("RESULT: ");


// -----------------------------------------------------------------------------
var validContribution1Message = "Send Valid Contribution - 100 ETH From Account3";
// -----------------------------------------------------------------------------
console.log("RESULT: " + validContribution1Message);
var validContribution1Tx = eth.sendTransaction({from: account3, to: psAddress, gas: 400000, value: web3.toWei("87", "ether")});
var validContribution2Tx = eth.sendTransaction({from: account4, to: aptAddress, gas: 400000, value: web3.toWei("10", "ether")});
while (txpool.status.pending > 0) {
}
printTxData("validContribution1Tx", validContribution1Tx);
printTxData("validContribution2Tx", validContribution2Tx);
printBalances();
failIfGasEqualsGasUsed(validContribution1Tx, validContribution1Message + " ac3->ps 100 ETH");
failIfGasEqualsGasUsed(validContribution2Tx, validContribution1Message + " ac4->apt 10 ETH");
printCrowdsaleContractDetails();
printPlaceHolderContractDetails();
printTokenContractDetails();
console.log("RESULT: ");


// -----------------------------------------------------------------------------
var validContribution2Message = "Send Valid Contribution - 1 ETH From Account3";
// -----------------------------------------------------------------------------
console.log("RESULT: " + validContribution2Message);
var validContribution3Tx = eth.sendTransaction({from: account3, to: psAddress, gas: 400000, value: web3.toWei("1", "ether")});
while (txpool.status.pending > 0) {
}
printTxData("validContribution3Tx", validContribution3Tx);
printBalances();
failIfGasEqualsGasUsed(validContribution3Tx, validContribution2Message + " ac3->ps 1 ETH");
printCrowdsaleContractDetails();
printPlaceHolderContractDetails();
printTokenContractDetails();
console.log("RESULT: ");


// -----------------------------------------------------------------------------
var validContribution3Message = "Send Valid Contribution - 3 ETH From Account3";
// -----------------------------------------------------------------------------
console.log("RESULT: " + validContribution3Message);
var validContribution4Tx = eth.sendTransaction({from: account3, to: psAddress, gas: 400000, value: web3.toWei("3", "ether")});
while (txpool.status.pending > 0) {
}
printTxData("validContribution4Tx", validContribution4Tx);
printBalances();
failIfGasEqualsGasUsed(validContribution4Tx, validContribution3Message + " ac3->ps 3 ETH");
printCrowdsaleContractDetails();
printPlaceHolderContractDetails();
printTokenContractDetails();
console.log("RESULT: ");


// -----------------------------------------------------------------------------
// Wait until endBlock 
// -----------------------------------------------------------------------------
console.log("RESULT: Waiting until endBlock #" + endBlock + " currentBlock=" + eth.blockNumber);
while (eth.blockNumber <= endBlock) {
}
console.log("RESULT: Waited until endBlock #" + endBlock + " currentBlock=" + eth.blockNumber);
console.log("RESULT: ");


// -----------------------------------------------------------------------------
var claimEthersMessage = "Claim Ethers But No Ethers";
// -----------------------------------------------------------------------------
console.log("RESULT: " + claimEthersMessage);
var claimEthersTx = ps.claimTokens(0, {from: contractOwnerAccount, gas: 2000000});
while (txpool.status.pending > 0) {
}
printTxData("claimEthersTx", claimEthersTx);
printBalances();
passIfGasEqualsGasUsed(claimEthersTx, claimEthersMessage);
printCrowdsaleContractDetails();
printPlaceHolderContractDetails();
printTokenContractDetails();
console.log("RESULT: ");


// -----------------------------------------------------------------------------
var finalisePresaleMessage = "Finalise PreSale";
// -----------------------------------------------------------------------------
console.log("RESULT: " + finalisePresaleMessage);
var finalisePresaleTx = ps.finalize({from: contractOwnerAccount, gas: 2000000});
while (txpool.status.pending > 0) {
}
printTxData("finalisePresaleTx", finalisePresaleTx);
printBalances();
failIfGasEqualsGasUsed(finalisePresaleTx, finalisePresaleMessage);
printCrowdsaleContractDetails();
printPlaceHolderContractDetails();
printTokenContractDetails();
console.log("RESULT: ");


// -----------------------------------------------------------------------------
var generateTokensMessage = "Generate Tokens After Finalisation";
// -----------------------------------------------------------------------------
console.log("RESULT: " + generateTokensMessage);
var generateTokensTx = ph.generateTokens(account5, "1000000000000000000000000", {from: contractOwnerAccount, gas: 2000000});
while (txpool.status.pending > 0) {
}
printTxData("generateTokensTx", generateTokensTx);
printBalances();
failIfGasEqualsGasUsed(generateTokensTx, generateTokensMessage);
printCrowdsaleContractDetails();
printPlaceHolderContractDetails();
printTokenContractDetails();
console.log("RESULT: ");


// -----------------------------------------------------------------------------
var cannotTransferMessage = "Cannot Move Tokens Before allowTransfers(...)";
// -----------------------------------------------------------------------------
console.log("RESULT: " + cannotTransferMessage);
var cannotTransfer1Tx = apt.transfer(account6, "1000000000000", {from: account4, gas: 100000});
var cannotTransfer2Tx = apt.approve(account7,  "30000000000000000", {from: account5, gas: 100000});
while (txpool.status.pending > 0) {
}
var cannotTransfer3Tx = apt.transferFrom(account5, account7, "30000000000000000", {from: account7, gas: 200000});
while (txpool.status.pending > 0) {
}
printTxData("cannotTransfer1Tx", cannotTransfer1Tx);
printTxData("cannotTransfer2Tx", cannotTransfer2Tx);
printTxData("cannotTransfer3Tx", cannotTransfer3Tx);
printBalances();
passIfGasEqualsGasUsed(cannotTransfer1Tx, cannotTransferMessage + " - transfer 0.000001 tokens ac4 -> ac6. CHECK no movement");
passIfGasEqualsGasUsed(cannotTransfer2Tx, cannotTransferMessage + " - approve 0.03 tokens ac5 -> ac7");
failIfGasEqualsGasUsed(cannotTransfer3Tx, cannotTransferMessage + " - transferFrom 0.03 tokens ac5 -> ac7. CHECK no movement");
printCrowdsaleContractDetails();
printPlaceHolderContractDetails();
printTokenContractDetails();
console.log("RESULT: ");


// -----------------------------------------------------------------------------
var allowTransfersMessage = "Allow Transfers";
// -----------------------------------------------------------------------------
console.log("RESULT: " + generateTokensMessage);
var allowTransfersTx = ph.allowTransfers(true, {from: contractOwnerAccount, gas: 2000000});
while (txpool.status.pending > 0) {
}
printTxData("allowTransfersTx", allowTransfersTx);
printBalances();
failIfGasEqualsGasUsed(allowTransfersTx, allowTransfersMessage);
printCrowdsaleContractDetails();
printPlaceHolderContractDetails();
printTokenContractDetails();
console.log("RESULT: ");


// -----------------------------------------------------------------------------
var canTransferMessage = "Can Move Tokens After allowTransfers(...)";
// -----------------------------------------------------------------------------
console.log("RESULT: " + canTransferMessage);
var canTransfer1Tx = apt.transfer(account6, "1000000000000", {from: account4, gas: 100000});
var canTransfer2Tx = apt.approve(account7,  "30000000000000000", {from: account5, gas: 100000});
while (txpool.status.pending > 0) {
}
var canTransfer3Tx = apt.transferFrom(account5, account7, "30000000000000000", {from: account7, gas: 200000});
while (txpool.status.pending > 0) {
}
printTxData("canTransfer1Tx", canTransfer1Tx);
printTxData("canTransfer2Tx", canTransfer2Tx);
printTxData("canTransfer3Tx", canTransfer3Tx);
printBalances();
failIfGasEqualsGasUsed(canTransfer1Tx, canTransferMessage + " - transfer 0.000001 tokens ac4 -> ac6. CHECK for movement");
failIfGasEqualsGasUsed(canTransfer2Tx, canTransferMessage + " - approve 0.03 tokens ac5 -> ac7");
failIfGasEqualsGasUsed(canTransfer3Tx, canTransferMessage + " - transferFrom 0.03 tokens ac5 -> ac7. CHECK for movement");
printCrowdsaleContractDetails();
printPlaceHolderContractDetails();
printTokenContractDetails();
console.log("RESULT: ");


// -----------------------------------------------------------------------------
var changeControllerMessage = "Change Controller";
// -----------------------------------------------------------------------------
console.log("RESULT: " + changeControllerMessage);
var changeControllerTx = ph.changeAPTController(contractOwnerAccount, {from: contractOwnerAccount, gas: 2000000});
while (txpool.status.pending > 0) {
}
printTxData("changeControllerTx", changeControllerTx);
printBalances();
failIfGasEqualsGasUsed(changeControllerTx, changeControllerMessage);
printCrowdsaleContractDetails();
printPlaceHolderContractDetails();
printTokenContractDetails();
console.log("RESULT: ");


// -----------------------------------------------------------------------------
var canTransfer2Message = "Can Move Tokens After Change Controller";
// -----------------------------------------------------------------------------
console.log("RESULT: " + canTransferMessage);
var canTransfer4Tx = apt.transfer(account6, "1000000000000", {from: account4, gas: 100000});
var canTransfer5Tx = apt.approve(account7,  "30000000000000000", {from: account5, gas: 100000});
while (txpool.status.pending > 0) {
}
var canTransfer6Tx = apt.transferFrom(account5, account7, "30000000000000000", {from: account7, gas: 200000});
while (txpool.status.pending > 0) {
}
printTxData("canTransfer4Tx", canTransfer4Tx);
printTxData("canTransfer5Tx", canTransfer5Tx);
printTxData("canTransfer6Tx", canTransfer6Tx);
printBalances();
failIfGasEqualsGasUsed(canTransfer4Tx, canTransfer2Message + " - transfer 0.000001 tokens ac4 -> ac6. CHECK for movement");
failIfGasEqualsGasUsed(canTransfer5Tx, canTransfer2Message + " - approve 0.03 tokens ac5 -> ac7");
failIfGasEqualsGasUsed(canTransfer6Tx, canTransfer2Message + " - transferFrom 0.03 tokens ac5 -> ac7. CHECK for movement");
printCrowdsaleContractDetails();
printPlaceHolderContractDetails();
printTokenContractDetails();
console.log("RESULT: ");


// -----------------------------------------------------------------------------
var canBurnMessage = "Owner Can Burn Tokens";
// -----------------------------------------------------------------------------
console.log("RESULT: " + canBurnMessage);
var canBurnTx = apt.destroyTokens(account5, "100000000000000000000000", {from: contractOwnerAccount, gas: 200000});
while (txpool.status.pending > 0) {
}
printTxData("canBurnTx", canBurnTx);
printBalances();
failIfGasEqualsGasUsed(canBurnTx, canBurnMessage);
printCrowdsaleContractDetails();
printPlaceHolderContractDetails();
printTokenContractDetails();
console.log("RESULT: ");


EOF
grep "DATA: " $TEST1OUTPUT | sed "s/DATA: //" > $DEPLOYMENTDATA
cat $DEPLOYMENTDATA
grep "RESULT: " $TEST1OUTPUT | sed "s/RESULT: //" > $TEST1RESULTS
cat $TEST1RESULTS
