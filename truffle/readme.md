> install truffle env
npm install -g truffle
npm install -g ethereumjs-testrpc

> new truffle project
truffle init

> start test blockchain server
testrpc

> add truffle/migration -> bootstrap OysterPearl.sol
> add trufflecontract -> OysterPearl.sol

> on directory truffle
truffle compile
truffle migrate

truffle console

> on truffle console
OysterPearl.address
JSON.stringify(OysterPearl.abi)