var trbgr = artifacts.require('./TRBGR');
var CataBoltSwap = artifacts.require('./CataBoltSwap');
module.exports = function(deployer) {
  deployer.deploy(CataBoltSwap);
};
