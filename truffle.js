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
    },
    coverage: {
      host: "localhost",
      network_id: "321", 
      port: 8555,         
      gas: 0xfffffffffff, 
      gasPrice: 0x01      
    },
    testrpc: {
      host: 'localhost',
      network_id: "123", 
      port: 8545,         
      gas: 0xfffffffffff, 
      gasPrice: 0x01   
    }
  },
  
  mocha: {
    reporter: 'mochawesome'
  }
};
