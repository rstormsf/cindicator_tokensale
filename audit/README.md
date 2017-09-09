# Cindicator Crowdsale Contract Audit

<br />

## Summary

[Cindicator](https://cindicator.com/) intends to run a crowdsale commencing on September 12 2017.

Bok Consulting Pty Ltd was commissioned to perform an audit on the Ethereum smart contracts for Cindicator's crowdsale.

This audit has been conducted on Cindicator's source code in commits [4f9ea74](https://github.com/rstormsf/cindicator_backup/commit/4f9ea745087665f626d0305f45ababa2962f380c),
[ab90a34](https://github.com/rstormsf/cindicator_backup/commit/ab90a3474e6e7493ec1fdc13885e4641af769ddd),
[199b13d](https://github.com/rstormsf/cindicator_backup/commit/199b13de72d589599b150f7f1c967a7fd0889361),
[ded989d](https://github.com/rstormsf/cindicator_backup/commit/ded989ddf12c28980b7f6df839afdd75656993aa),
[d09e018](https://github.com/rstormsf/cindicator_backup/commit/d09e0181e8e3d913cc8def3988f81e43c79b1ce9),
[b1a0a78](https://github.com/rstormsf/cindicator_backup/commit/b1a0a78bd8c26fe1b3ba2189ec5dd8f7968f1679),
[5b3f9b6](https://github.com/rstormsf/cindicator_backup/commit/5b3f9b6120f4a1fd3c040894f8b3efc927c9c6fb) and
[26387dd](https://github.com/rstormsf/cindicator_tokensale/commit/26387ddefd8dbc844ec0789ed56c1d387362d1a5).

No potential vulnerabilities have been identified in the crowdsale and token contract.

Note that crowdsale participants should only call the `buy()` function to contribute to the crowdsale.

<br />

### Crowdsale Mainnet Addresses

The *Contribution* crowdsale contract has been deployed to [0xc22462d4bc50952b061c9e6c585fdd9a04d0d75a](https://etherscan.io/address/0xc22462d4bc50952b061c9e6c585fdd9a04d0d75a#code).

The *CND* token contract has been deployed to [0xd4c435f5b09f855c3317c8524cb1f586e42795fa](https://etherscan.io/address/0xd4c435f5b09f855c3317c8524cb1f586e42795fa#code).

<br />

### Crowdsale Contract

The *Contribution* crowdsale contract will accept ethers (ETH) from Ethereum account transactions executing the
`Contribution.proxyPayment(...)` function.

Accounts contributing to this crowdsale will have to be whitelisted by Cindicator before the contributions are accepted
by this crowdsale contract.

There are four tiers in this crowdsale, each tier with different contribution parameters (cap, minimum contribution, maximum
contribution, tokens per ETH rate, start date and end date). Only one tier is active at any time during the crowdsale
contribution period, and the tiers are activated in sequential order.

Whitelisted accounts will be allocated to one of the four tiers, and can contribute to later tiers.

ETH contributed by participants to the *Contribution* crowdsale contract will result in CND tokens being allocated to the
participant's account in the token contract. The contributed ETHs are immediately transferred to the `contributionWallet`
multisig wallet, reducing the risk of the loss of ETHs in this bespoke smart contract.

The crowdsale contract will generate `Transfer(0x0, participantAddress, tokens)` events during the crowdsale period and this
event is used by token explorers to recognise the token contract and to display the ongoing token minting progress.

<br />

### Token Contract

The *CND* token contract is built on the *MiniMeToken* token contract.

The token contract is [ERC20](https://github.com/ethereum/eips/issues/20) compliant with the following features:

* `decimals` is correctly defined as `uint8` instead of `uint256`
* `transfer(...)` and `transferFrom(...)` will generally return false if there is an error instead of throwing an error
* `transfer(...)` and `transferFrom(...)` have not been built with a check on the size of the data being passed (and this 
  check is not an effective check anyway)
* `approve(...)` requires that a non-zero approval limit be set to 0 before a new non-zero limit can be set

The token contract is built on the *MiniMeToken* token contract that stores snapshots of an account's token balance and 
the `totalSupply()` in history. One side effect of this snapshot feature is that regular transfer operations consume a
little more gas in transaction fees when compared to non-*MiniMeToken* token contracts.

The *MiniMeToken* does not use *SafeMath* but has the checks to handle unsigned integer math overflows and underflows.

This *MiniMeToken* token contract generally has a few features that will reduce the trustlessness of this token contract
such as:

  * The owner of the token contract being able to freeze and unfreeze token transfers
  * The owner of the token contract being able to transfer any accounts's tokens
  * The owner of the token contract being able to mint new tokens
  * The owner of the token contract being able to burn any account's tokens

In this implementation of the *CND* *MiniMeToken* token contract, the developer has assigned the ownership of the
*CND* token contract to the *Contribution* crowdsale contract, even after the crowdsale has completed. This means that
Cindicator will be **unable** to freeze or unfreeze token transfers, transfer any account's tokens, mint new tokens or
burn any account's tokens, as the functions to control these actions has not been built into the *Contribution* contract.

<br />

<hr />

## Table Of Contents

* [Summary](#summary)
  * [Crowdsale Mainnet Addresses](#crowdsale-mainnet-addresses)
  * [Crowdsale Contract](#crowdsale-contract)
  * [Token Contract](#token-contract)
* [Recommendations](#recommendations)
* [Potential Vulnerabilities](#potential-vulnerabilities)
* [Scope](#scope)
* [Limitations](#limitations)
* [Due Diligence](#due-diligence)
* [Risks](#risks)
* [Testing](#testing)
  * [Test 1](#test-1)
  * [Test 2](#test-2)
* [Code Review](#code-review)
* [References](#references)

<br />

<hr />

## Recommendations

* **MEDIUM IMPORTANCE** `Contribution.proxyPayment(...)` overwrites the `_sender` parameter with `_sender = msg.sender;`
  and alters the general meaning of this function. Consider removing the `_sender = msg.sender;` overwrite and add another
  function like `function buy() payable { ... } ` that will call `proxyPayment(msg.sender)`
  * [x] Comment added in [26387dd](https://github.com/rstormsf/cindicator_tokensale/commit/26387ddefd8dbc844ec0789ed56c1d387362d1a5) to
    inform any users not to call `proxyPayment(...)` specifying a different address parameter from the sending account address as the
    generated tokens will be assigned to the sending account address
* **HIGH IMPORTANCE** If a tier is automatically finalised in `Contribution.doBuy()`, the `tierCount` variable is not automatically
  incremented to move to the next tier. Attempts to call `Contribution.finalize()` will always fail as the current tier is already
  finalised. The crowdsale contract will be stuck forever in the tier that was automatically finalised
  * [x] Fixed in [5b3f9b6](https://github.com/rstormsf/cindicator_backup/commit/5b3f9b6120f4a1fd3c040894f8b3efc927c9c6fb)
* **MEDIUM IMPORTANCE** The Tier constructor does not need the `onlyController` modifier
  * [x] Fixed in [199b13d](https://github.com/rstormsf/cindicator_backup/commit/199b13de72d589599b150f7f1c967a7fd0889361)
* **LOW IMPORTANCE** Use the same Solidity version number `pragma solidity ^0.4.15;` across the different .sol files
  * [x] Fixed in [ab90a34](https://github.com/rstormsf/cindicator_backup/commit/ab90a3474e6e7493ec1fdc13885e4641af769ddd)
* **LOW IMPORTANCE** Consider whether `MiniMeToken.claimTokens(...)` should be a *public* function
  * [x] Fixed in [ab90a34](https://github.com/rstormsf/cindicator_backup/commit/ab90a3474e6e7493ec1fdc13885e4641af769ddd)
* **LOW IMPORTANCE** `Contribution.function()` has an incorrect comment *If anybody sends Ether directly to this contract,
  consider he is getting CND*
  * [x] Fixed in [ab90a34](https://github.com/rstormsf/cindicator_backup/commit/ab90a3474e6e7493ec1fdc13885e4641af769ddd)
* **LOW IMPORTANCE** Format and indentation of code, especially in *Contributions*
  * [x] Fixed some in [ab90a34](https://github.com/rstormsf/cindicator_backup/commit/ab90a3474e6e7493ec1fdc13885e4641af769ddd)

<br />

<hr />

## Potential Vulnerabilities

No potential vulnerabilities have been identified in the crowdsale and token contract.

<br />

<hr />

## Scope

This audit is into the technical aspects of the crowdsale contracts. The primary aim of this audit is to ensure that funds
contributed to these contracts are not easily attacked or stolen by third parties. The secondary aim of this audit is that
ensure the coded algorithms work as expected. This audit does not guarantee that that the code is bugfree, but intends to
highlight any areas of weaknesses.

<br />

<hr />

## Limitations

This audit makes no statements or warranties about the viability of the Cindicator's business proposition, the individuals
involved in this business or the regulatory regime for the business model.

<br />

<hr />

## Due Diligence

As always, potential participants in any crowdsale are encouraged to perform their due diligence on the business proposition
before funding any crowdsales.

Potential participants are also encouraged to only send their funds to the official crowdsale Ethereum address, published on
the crowdsale beneficiary's official communication channel.

Scammers have been publishing phishing address in the forums, twitter and other communication channels, and some go as far as
duplicating crowdsale websites. Potential participants should NOT just click on any links received through these messages.
Scammers have also hacked the crowdsale website to replace the crowdsale contract address with their scam address.
 
Potential participants should also confirm that the verified source code on EtherScan.io for the published crowdsale address
matches the audited source code, and that the deployment parameters are correctly set, including the constant parameters.

<br />

<hr />

## Risks

* The risk of funds getting stolen or hacked from the *Contribution* contract is low as the contributed funds are immediately
  transferred to an external multisig, hardware or regular wallet.

* This set of contracts have some complexity in the linkages between the separate *CND* (*MiniMeToken*), *Contribution* and
  *Tier* contracts. The set up of these contracts will need to be carefully verified after deployment to confirm that
  the contracts have been linked and permissioned correctly.

<br />

<hr />

## Testing

### Test 1
The following functions were tested using the script [test/01_test1.sh](test/01_test1.sh) with the summary results saved
in [test/test1results.txt](test/test1results.txt) and the detailed output saved in [test/test1output.txt](test/test1output.txt):

* [x] Deploy *MiniMeTokenFactory* contract
* [x] Deploy *CND* *MiniMeToken* contract
* [x] Deploy *Contribution* crowdsale contract
* [x] Add whitelisted addresses to the *Contribution* crowdsale contract
* [x] Deploy 4 *Tier* contracts
* [x] Assign appropriate ownership and relationships between the different contracts
* [x] Contribute to each of the 4 tiers
* [x] Finalise the crowdsale, including generating the token allocations for the various stakeholders
* [x] `transfer(...)` and `transferFrom(...)` the *CND* tokens

<br />

### Test 2
The following functions were tested using the script [test/02_test2.sh](test/02_test2.sh) with the summary results saved
in [test/test2results.txt](test/test2results.txt) and the detailed output saved in [test/test2output.txt](test/test2output.txt):

* [x] As in [Test 1](#test-1) above, but with different caps and contributions hitting the caps in each tier, with the last tier cap
  contribution being exceeded

<br />

Details of the testing environment can be found in [test](test).

<br />

<hr />

## Code Review

* [x] [code-review/CND.md](code-review/CND.md)
  * [x] contract CND is MiniMeToken
* [x] [code-review/Contribution.md](code-review/Contribution.md)
  * [x] contract Contribution is Controlled, TokenController
* [x] [code-review/MiniMeToken.md](code-review/MiniMeToken.md)
  * [x] contract TokenController
  * [x] contract Controlled
  * [x] contract ApproveAndCallFallBack
  * [x] contract MiniMeToken is Controlled
  * [x] contract MiniMeTokenFactory
* [x] [code-review/SafeMath.md](code-review/SafeMath.md)
  * [x] library SafeMath
* [x] [code-review/Tier.md](code-review/Tier.md)
  * [x] contract Tier is Controlled

<br />

### Not Reviewed

#### ConsenSys Multisig Wallet

[../contracts/MultiSigWallet.sol](../contracts/MultiSigWallet.sol) is outside the scope of this review.

The following are the differences between the version in this repository and the original ConsenSys
[MultiSigWallet.sol](https://raw.githubusercontent.com/ConsenSys/MultiSigWallet/e3240481928e9d2b57517bd192394172e31da487/contracts/solidity/MultiSigWallet.sol):

    $ diff -w OriginalConsenSysMultisigWallet.sol MultiSigWallet.sol
    1c1
    < pragma solidity 0.4.15;
    ---
    > pragma solidity 0.4.4;

The only difference is in the Solidity version number.

<br />

The following are the differences between the version in this repository and the ConsenSys MultiSigWallet deployed 
at [0xa646e29877d52b9e2de457eca09c724ff16d0a2b](https://etherscan.io/address/0xa646e29877d52b9e2de457eca09c724ff16d0a2b#code)
by Status.im and is currently holding 284,732.64 Ether:

    $ diff -w MultiSigWallet.sol StatusConsenSysMultisigWallet.sol 
    1c1
    < pragma solidity 0.4.15;
    ---
    > pragma solidity ^0.4.11;
    10,18c10,18
    <     event Confirmation(address indexed sender, uint indexed transactionId);
    <     event Revocation(address indexed sender, uint indexed transactionId);
    <     event Submission(uint indexed transactionId);
    <     event Execution(uint indexed transactionId);
    <     event ExecutionFailure(uint indexed transactionId);
    <     event Deposit(address indexed sender, uint value);
    <     event OwnerAddition(address indexed owner);
    <     event OwnerRemoval(address indexed owner);
    <     event RequirementChange(uint required);
    ---
    >     event Confirmation(address indexed _sender, uint indexed _transactionId);
    >     event Revocation(address indexed _sender, uint indexed _transactionId);
    >     event Submission(uint indexed _transactionId);
    >     event Execution(uint indexed _transactionId);
    >     event ExecutionFailure(uint indexed _transactionId);
    >     event Deposit(address indexed _sender, uint _value);
    >     event OwnerAddition(address indexed _owner);
    >     event OwnerRemoval(address indexed _owner);
    >     event RequirementChange(uint _required);
    295c295
    <     /// @dev Returns total number of transactions after filers are applied.
    ---
    >     /// @dev Returns total number of transactions after filters are applied.

The only differences are in the Solidity version number and the prefixing of the event variables with `_`s.

This [link](https://etherscan.io/find-similiar-contracts?a=0xa646e29877d52b9e2de457eca09c724ff16d0a2b) will display
79 (currently) other multisig wallet contracts with high similarity to the ConsenSys MultiSigWallet deployed by Status.im .

Some further information on the ConsenSys multisig wallet:

* [The Gnosis MultiSig Wallet and our Commitment to Security](https://blog.gnosis.pm/the-gnosis-multisig-wallet-and-our-commitment-to-security-ce9aca0d17f6)
* [Release of new Multisig Wallet](https://blog.gnosis.pm/release-of-new-multisig-wallet-59b6811f7edc)

An audit on a previous version of this multisig has already been done by [Martin Holst Swende](https://gist.github.com/holiman/77dfe5addab521bf28ea552591ef8ac4).

<br />

#### Unused Testing Framework

The following files are used for the testing framework and are outside the scope of this review:

* [../contracts/DebugContribution.sol](../contracts/DebugContribution.sol)
* [../contracts/Migrations.sol](../contracts/Migrations.sol)

<br />

<hr />

## References

* [Ethereum Contract Security Techniques and Tips](https://github.com/ConsenSys/smart-contract-best-practices)

<br />

<br />

(c) BokkyPooBah / Bok Consulting Pty Ltd for Cindicator - Sep 8 2017. The MIT Licence.