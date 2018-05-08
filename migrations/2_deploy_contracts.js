// OysterPearl Artifact
let OysterPearl = artifacts.require("OysterPearl");
let PearlDistributePrice = artifacts.require("PearlDistributePrice");

// OysterPearl Deployer
module.exports = function(deployer, accounts) {
  deployer.deploy(PearlDistributePrice);
  deployer.deploy(OysterPearl);
};