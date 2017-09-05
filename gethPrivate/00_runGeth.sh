#!/bin/sh

rm -rf ./gethPrivate/testchain/geth/chaindata/*

geth --datadir ./gethPrivate/testchain init ./gethPrivate/genesis.json
sleep 5
geth --datadir ./gethPrivate/testchain --unlock 0 --password ./gethPrivate/testpassword --rpc --rpccorsdomain '*' --rpcport 8646 --rpcapi "eth,net,web3,debug,personal" --port 32323 --mine --minerthreads 8 --maxpeers 0 --targetgaslimit 994712388 2>> /dev/null >> logs.txt