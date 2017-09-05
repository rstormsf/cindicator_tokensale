# Cindicator Crowdsale Contract Audit

## Summary

Commits [4f9ea74](https://github.com/rstormsf/cindicator_backup/commit/4f9ea745087665f626d0305f45ababa2962f380c),
[ab90a34](https://github.com/rstormsf/cindicator_backup/commit/ab90a3474e6e7493ec1fdc13885e4641af769ddd)

## Recommendations

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