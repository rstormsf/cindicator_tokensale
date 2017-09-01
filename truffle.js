module.exports = {
  networks: {
    kovan: {
      host: "localhost",
      port: 8549,
      network_id: "*",
      // gas: 5010000 // Match any network id
    },
    testrpc: {
      host: 'localhost',
      port: 8545,
      network_id: "*"
      // gas: 6010000 // Match any network id
    }
  }
};
