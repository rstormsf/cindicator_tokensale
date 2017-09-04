# Cindicator Crowdsale Contract Audit

## Recommendations

* **LOW IMPORTANCE** Use the same Solidity version number `pragma solidity ^0.4.15;` across the different .sol files
* **MEDIUM IMPORTANCE** Consider whether `MiniMeToken.claimTokens(...)` should be a *public* function
* **LOW IMPORTANCE** `Contribution.function()` has an incorrect comment *If anybody sends Ether directly to this contract,
  consider he is getting CND*

<br />

<hr />

## Code Review

* [x] [code-review/CND.md](code-review/CND.md)
  * [x] contract CND is MiniMeToken 
* [ ] [code-review/Contribution.md](code-review/Contribution.md)
  * [ ] contract Contribution is Controlled, TokenController 
* [ ] [code-review/DebugContribution.md](code-review/DebugContribution.md)
  * [ ] contract DebugContribution is Contribution 
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
* [ ] [code-review/MultiSigWallet.md](code-review/MultiSigWallet.md)
  * [ ] contract MultiSigWallet 