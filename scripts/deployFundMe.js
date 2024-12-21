const { ethers } = require("hardhat");

async function main() {
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
  if (hre.network.config.chainId == 11155111 && process.env.ETHERSCAN_API_KEY) {
    console.log("Waiting for 5 confirmations");
    fundMe.deploymentTransaction().wait(5);
    verifyFundMe(fundMe.target, [300]);
  } else {
    console.log("verification skipped..");
  }

  const [firstAccount, secondAccount] = await ethers.getSigner();

  //check balance of contract
  const fundTx1 = await fundMe.fund({ value: ethers.parseEther("0.5") });
  await fundTx1.wait();

  const balance1 = await ethers.provider.getBalance(fundMe.target);
  console.log(`Balance of the contract is ${balance1}`);

  const fundTx2 = await fundMe
    .connect(secondAccount)
    .fund({ value: ethers.parseEther("0.5") });
  await fundTx2.wait();

  const balance2 = await ethers.provider.getBalance(fundMe.target);
  console.log(`Balance of the contract is ${balance2}`);

  //check mapping
  const firstAccountBalance = await fundMe.funderToAmount(firstAccount.address);
  const secondAccountBalance = await fundMe.funderToAmount(
    secondAccount.address
  );
  console.log(
    `Balance of first account ${firstAccount.address} is ${firstAccountBalance}`
  );
  console.log(
    `Balance of second account ${secondAccount.address} is ${secondAccountBalance}`
  );
}

async function verifyFundMe(fundMeAddr, args) {
  await hre.run("verify:verify", {
    address: fundMeAddr,
    constructorArguments: args,
  });
}

main()
  .then()
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
