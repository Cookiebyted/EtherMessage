// Compile the contract 'WavePortal' and generate the necessary files needed for the contract in artifacts folder
// Hardhat creates a Local Ethereum network just for the contract, and once script is complete, the local network is destroyed.
// e.g Every contract run = fresh new blockchain

// Async wait until the contract is officially deployed to our local blockchain
// Contract constructor runs once we actually deploy
// Print out Deployed Contract address

// HRE object is built using the hardhat.config everytime a terminal command starts with npx hardhat gets run
// This means we don't need any require hardhat code

const main = async () => {
  const waveContractFactory = await hre.ethers.getContractFactory('WavePortal');
  const waveContract = await waveContractFactory.deploy({
    value: hre.ethers.utils.parseEther('0.1'),        // Deploy contract and fund it with ETH
  });
  await waveContract.deployed();
  console.log('Contract address:', waveContract.address);

  /*
   * Get Contract balance
   */
  let contractBalance = await hre.ethers.provider.getBalance(     // getBalance function accepts contract's address to return address balance
    waveContract.address
  );
  console.log(
    'Contract balance:',
    hre.ethers.utils.formatEther(contractBalance)     // Formats and prints out contract balance
  );

  /*
   * Send Wave
   */
  const waveTxn = await waveContract.wave('This is wave #1');
  await waveTxn.wait();

  const waveTxn2 = await waveContract.wave('This is wave #2');
  await waveTxn2.wait();

  /*
   * Get Contract balance to see what happened!
   */
  contractBalance = await hre.ethers.provider.getBalance(waveContract.address);
  console.log(
    'Contract balance:',
    hre.ethers.utils.formatEther(contractBalance)
  );

  let allWaves = await waveContract.getAllWaves();
  console.log(allWaves);
};

const runMain = async () => {
  try {
    await main();
    process.exit(0);
  } catch (error) {
    console.log(error);
    process.exit(1);
  }
};

runMain();