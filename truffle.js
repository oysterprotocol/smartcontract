// Truffle Networking Configuration
// We set live to point to Oysterby Testnet
// Oysterby Port : 8080
// Ganache Port  : 7545
// Deployments using truffle
//
// Migration to live Oysterby private network
// truffle migrate --network live
//
// Migration to test Ganache development network
// truffle migrate --network development
//
// See <http://truffleframework.com/docs/advanced/configuration>
module.exports = {
  networks: {
    live: {
      network_id: 559966,
      host: "54.197.3.171",
      port: 8080   // Different than the default below
    },
    development: {
      network_id: "*", // Match any network id
      host: "127.0.0.1",
      port: 7545,
      gas: 4e6,
      gasPrice: 2e10
    }
  },
  rpc: {
    host: "127.0.0.1",
    port: 7545
  }
};