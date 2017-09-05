#!/bin/sh

sh gethPrivate/00_runGeth.sh & 
sleep 10
./node_modules/.bin/truffle test --network geth
killall geth