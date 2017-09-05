module.exports = {
  networks: {
    kovan: {
      host: "localhost",
      port: 8549,
      network_id: "*",
      // gas: 5010000 // Match any network id
    },
    geth: {
      host: 'localhost',
      port: 8646,
      network_id: "*"
    }
  },
  mocha: {
    reporter: 'mochawesome'
  }
};
