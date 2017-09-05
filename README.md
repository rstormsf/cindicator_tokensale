# cindicator-contracts

cindicator Ethereum smart contracts


## To Run tests:

```
yarn test
```

## To Deploy in mainnet: 

1. Change 
```
const FOUNDERS_WALLET_ADDRESS = "0x0039F22efB07A647557C7C5d17854CFD6D489eF3";
const ADVISORS_WALLET_ADDRESS = "0x456";
const BOUNTY_WALLET_ADDRESS = "0x321";

```
in [migration_file](migrations/2_deploy_contracts.js)

2. Change parameters for Tier1 in [migration_file](migrations/2_deploy_contracts.js)

3. Specify network in [truffle.js](truffle.js)

4. Run
```
yarn truffle migrate --network mainnet
```

5. Run [solidity_flattener](https://github.com/BlockCatIO/solidity-flattener)
for every contract to flatten them out.

6. Use output from migration script for encoded params in order to verify contracts on
etherscan.io

7. Enjoy!
