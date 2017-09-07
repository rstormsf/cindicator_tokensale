module.exports = {
  norpc: true,
  testCommand: 'node --max-old-space-size=4096 ../node_modules/.bin/truffle test --network coverage',
  skipFiles: ['Migrations.sol', 'DebugContribution.sol', 'MultiSigWallet.sol', 'SafeMath.sol'],
  testrpcOptions: '--port 8555 -i 321'
}