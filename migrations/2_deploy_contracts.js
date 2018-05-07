// OysterPearl Artifact
let OysterPearl = artifacts.require("OysterPearl");

// OysterPearl Deployer
module.exports = function(deployer) {
  deployer.deploy(OysterPearl);
};