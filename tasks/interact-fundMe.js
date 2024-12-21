const { task } = require("hardhat/config");

task("interact-fundMe", "interact with fundMe contract")
  .addParam("addr", "fundMe contract address")
  .setAction(async (taskArgs, hre) => {
    const fundMeFactory = await ethers.getContractFactory("FundMe");
    const fundMe = fundMeFactory.attach(taskArgs.addr);

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
    const firstAccountBalance = await fundMe.funderToAmount(
      firstAccount.address
    );
    const secondAccountBalance = await fundMe.funderToAmount(
      secondAccount.address
    );
    console.log(
      `Balance of first account ${firstAccount.address} is ${firstAccountBalance}`
    );
    console.log(
      `Balance of second account ${secondAccount.address} is ${secondAccountBalance}`
    );
  });

module.exports = {};
