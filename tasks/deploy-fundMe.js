const { task } = require("hardhat/config");

task("deploy-fundMe", "deploy with fundMe contract").setAction(
  async (taskArgs, hre) => {
    //create factory
    const fundMeFactory = await ethers.getContractFactory("FundMe");
    console.log("contract deploying");

    //deploy contract from factory
    const fundMe = await fundMeFactory.deploy(300);
    await fundMe.waitForDeployment();
    console.log(
      `contract has been deployed successfully, contract address is ${fundMe.target}`
    );

    //verify fundMe
    if (
      hre.network.config.chainId == 11155111 &&
      process.env.ETHERSCAN_API_KEY
    ) {
      console.log("Waiting for 5 confirmations");
      fundMe.deploymentTransaction().wait(5);
      verifyFundMe(fundMe.target, [300]);
    } else {
      console.log("verification skipped..");
    }
  }
);

async function verifyFundMe(fundMeAddr, args) {
  await hre.run("verify:verify", {
    address: fundMeAddr,
    constructorArguments: args,
  });
}

module.exports = {};
