#!/usr/bin/env bash
solidity_flattener contracts/CND.sol --out flat/cnd_flat.sol
solidity_flattener contracts/Contribution.sol --out flat/cont_flat.sol
solidity_flattener contracts/Tier.sol --out flat/tier_flat.sol