# Cindicator Crowdsale Contract Audit

Status: Work in progress

## Summary

[Cindicator](https://cindicator.com/) intends to run a crowdsale commencing on September 12 2017.

Bok Consulting Pty Ltd was commissioned to perform an audit on the Ethereum smart contracts for Cindicator's crowdsale.

This audit has been conducted on Cindicator's source code in commits [4f9ea74](https://github.com/rstormsf/cindicator_backup/commit/4f9ea745087665f626d0305f45ababa2962f380c),
[ab90a34](https://github.com/rstormsf/cindicator_backup/commit/ab90a3474e6e7493ec1fdc13885e4641af769ddd) and
[199b13d](https://github.com/rstormsf/cindicator_backup/commit/199b13de72d589599b150f7f1c967a7fd0889361).

No potential vulnerabilities have been identified in the presale and token contract.

<br />

### Crowdsale Mainnet Addresses

`{TBA}`

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

This *MiniMeToken* token contract generally has a few features that will reduce the trustlessness of this token contract
such as:

  * The owner of the token contract being able to freeze and unfreeze token transfers
  * The owner of the token contract being able to transfer any accounts's tokens
  * The owner of the token contract being able to mint new tokens
  * The owner of the token contract being able to burn any account's tokens

In this implementation of the *CND* *MiniMeToken* token contract, the developer has assigned the ownership of the
*CND* token contract to the *Contribution* crowdsale contract, even after the crowdsale has completed. This means that
the Cindicator will be **unable** to freeze or unfreeze token transfers, transfer any account's tokens, mint new tokens or
burn any account's tokens. 

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
* [Code Review](#code-review)
* [References](#references)

<br />

<hr />

## Recommendations

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
  the contracts have been linked correctly.

<br />

<hr />

## Testing

The following functions were tested using the script [test/01_test1.sh](test/01_test1.sh) with the results saved in [test/test1results.txt](test/test1results.txt):

* [x] Deploy *MiniMeTokenFactory* contract
* [x] Deploy *CND* *MiniMeToken* contract
* [x] Deploy *Contribution* crowdsale contract
* [x] Add whitelisted addresses to the *Contribution* crowdsale contract
* [x] Deploy 4 *Tier* contracts
* [x] Assign appropriate ownership and relationships between the different contracts
* [x] Contribute to each of the 4 tiers
* [x] Finalise the crowdsale, including generating the token allocations for the various stakeholders
* [x] `transfer(...)` and `transferFrom(...)` the *CND* tokens

Details of the testing environment can be found in [test](test).

<br />

<hr />

## Code Review

* [x] [code-review/CND.md](code-review/CND.md)
  * [x] contract CND is MiniMeToken
* [x] [code-review/Contribution.md](code-review/Contribution.md)
  * [x] contract Contribution is Controlled, TokenController
* [ ] [code-review/MiniMeToken.md](code-review/MiniMeToken.md)
  * [ ] contract TokenController
  * [x] contract Controlled
  * [ ] contract ApproveAndCallFallBack
  * [ ] contract MiniMeToken is Controlled
  * [ ] contract MiniMeTokenFactory
* [x] [code-review/SafeMath.md](code-review/SafeMath.md)
  * [x] library SafeMath
* [x] [code-review/Tier.md](code-review/Tier.md)
  * [x] contract Tier is Controlled

<br />

### Not Reviewed

* [ ] [code-review/Migrations.md](code-review/Migrations.md)
  * [ ] contract Migrations
* [ ] [code-review/DebugContribution.md](code-review/DebugContribution.md)
  * [ ] contract DebugContribution is Contribution
* [ ] [code-review/MultiSigWallet.md](code-review/MultiSigWallet.md)
  * [ ] contract MultiSigWallet

<br />

<hr />

## References

* [Ethereum Contract Security Techniques and Tips](https://github.com/ConsenSys/smart-contract-best-practices)

<br />

<br />

(c) BokkyPooBah / Bok Consulting Pty Ltd for Cindicator - Sep 6 2017. The MIT Licence.