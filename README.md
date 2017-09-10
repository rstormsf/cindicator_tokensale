# cindicator-contracts

cindicator Ethereum smart contracts

## Mainnet addresses:
Contribution: https://etherscan.io/address/0xc22462d4bc50952b061c9e6c585fdd9a04d0d75a#readContract
CND Token: https://etherscan.io/address/0xd4c435f5b09f855c3317c8524cb1f586e42795fa
Tier-1: https://etherscan.io/address/0x0cf3da2058c228328a2427abbcb25f3dc5c14db3

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


## Encoded buy method to use for crowdsale:
`0xa6f2ae3a` used from: web3 1.0 version:

```
 web3.eth.abi.encodeFunctionCall({
      "constant": false,
      "inputs": [],
      "name": "buy",
      "outputs": [],
      "payable": true,
      "type": "function"
    }, [])
 ```