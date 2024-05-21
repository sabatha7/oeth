const { expect } = require("chai");
const { ethers } = require("hardhat");
const { signers } = require("hardhat");

describe("Option Contracts", function () {
  let optionMerchant, optionBuyer, optionProcurer;
  let merchant, buyer, procurer;
  const initialTimestamp = Math.floor(Date.now() / 1000);
  
  let rewardContract, rewardContractDump;

  beforeEach(async function () {
    const signers = await ethers.getSigners();
	[merchant, buyer, procurer] = signers;

    // Deploy OptionBuyer contract
    const OptionBuyer = await ethers.getContractFactory("OptionBuyer");
    optionBuyer = await OptionBuyer.connect(buyer).deploy(await merchant.getAddress(), { value: ethers.parseEther(".4")});
	await optionBuyer.waitForDeployment();

    // Deploy OptionProcurer contract
    const OptionProcurer = await ethers.getContractFactory("OptionProcurer");
    optionProcurer = await OptionProcurer.connect(procurer).deploy(await merchant.getAddress(), initialTimestamp, { value: ethers.parseEther(".1")});
	await optionProcurer.waitForDeployment();
    
    // Deploy OptionMerchant contract
    const OptionMerchant = await ethers.getContractFactory("OptionMerchant");
    optionMerchant = await OptionMerchant.deploy(await optionProcurer.getAddress(), await optionBuyer.getAddress(), initialTimestamp);
    await optionMerchant.waitForDeployment();
  });

  it("should set initial values correctly", async function () {
    expect(await optionMerchant.buyerContractBuyer()).to.equal(await optionBuyer.getAddress());
    expect(await optionMerchant.procurerContractProcurer()).to.equal(await optionProcurer.getAddress());
    expect(await optionMerchant.initTime()).to.equal(initialTimestamp);
    expect(await optionMerchant.lastKnownSwapped()).to.equal(initialTimestamp);

    expect(await optionBuyer.buyer()).to.equal(await buyer.getAddress());
    expect(await optionBuyer.owner()).to.equal(await merchant.getAddress());

    expect(await optionProcurer.owner()).to.equal(await merchant.getAddress());
    expect(await optionProcurer.procurer()).to.equal(await procurer.getAddress());
    expect(await optionProcurer.lastKnownLiquidated()).to.equal(initialTimestamp);
	//console.log("optionMerchant.buyerContractBuyer:", await optionMerchant.buyerContractBuyer());
    //console.log("optionBuyer.getAddress():", await optionBuyer.getAddress());

    //console.log("optionMerchant.procurerContractProcurer:", await optionMerchant.procurerContractProcurer());
    //console.log("optionProcurer.getAddress():", await optionProcurer.getAddress());

    //console.log("optionMerchant.initTime:", await optionMerchant.initTime());
    //console.log("initialTimestamp:", initialTimestamp);

    //console.log("optionMerchant.lastKnownSwapped:", await optionMerchant.lastKnownSwapped());
    //console.log("initialTimestamp:", initialTimestamp);

    //console.log("optionBuyer.buyer:", await optionBuyer.buyer());
    //console.log("buyer.getAddress():", await buyer.getAddress());

    //console.log("optionBuyer.owner:", await optionBuyer.owner());
    //console.log("optionMerchant.getAddress():", await optionMerchant.getAddress());

    //console.log("optionProcurer.owner:", await optionProcurer.owner());
    //console.log("optionMerchant.getAddress():", await optionMerchant.getAddress());

    //console.log("optionProcurer.procurer:", await optionProcurer.procurer());
    //console.log("procurer.getAddress():", await procurer.getAddress());

    //console.log("optionProcurer.lastKnownLiquidated:", await optionProcurer.lastKnownLiquidated());
    //console.log("initialTimestamp:", initialTimestamp);
  });

  it("should allow atomic swap and track changes", async function () {
    const newTimestamp = initialTimestamp + 1000;
    await optionMerchant.setAtomicSwapped(newTimestamp);
    expect(await optionMerchant.hasAtomicSwapped()).to.be.true;
    expect(await optionMerchant.lastKnownSwapped()).to.equal(newTimestamp);
	await optionProcurer.connect(merchant).setOwner(await buyer.getAddress(), newTimestamp);
    expect(await optionProcurer.owner()).to.equal(await buyer.getAddress());
  });

  it("should allow buyer to withdraw funds", async function () {
    await optionBuyer.connect(merchant).withdraw(await procurer.getAddress());
    expect(await ethers.provider.getBalance(await optionBuyer.getAddress())).to.equal(0);
  });

  it("should allow merchant to withdraw funds", async function () {
    await optionProcurer.connect(merchant).withdraw();
    expect(await ethers.provider.getBalance(await optionProcurer.getAddress())).to.equal(0);
  });
  
  it("should allow merchant to claim reward using Merkle proof", async function () {
    const rewardAmount = ethers.parseEther(".2");

    // Generate Merkle proof off-chain (replace with your proof generation logic)
    const leaf = keccak256(abi.encodePacked(merchant.address, rewardAmount));
    const proof = [/* Your generated Merkle proof here */];
    const index = 0; // Assuming the merchant's claim is at index 0 in the Merkle tree

    // Claim the reward
    await optionMerchant.connect(merchant).claimReward(leaf, index, proof, rewardAmount);

    // Check predictable contract deployment
    const predictedAddress = await optionMerchant.getPredictedContractAddress(rewardAmount);
    const deployedContract = await ethers.getContractAt("RewardManagerDump", predictedAddress);

    // Verify the deployed contract has the expected recipient and reward
    expect(await deployedContract.recipient()).to.equal(merchant.address);
    expect(await deployedContract.reward()).to.equal(rewardAmount);

    // Withdraw the reward
    await deployedContract.connect(merchant).withdraw();

    // Check merchant's balance after withdrawal (optional)
    const merchantBalance = await ethers.provider.getBalance(merchant.getAddress());
    expect(merchantBalance).to.be.gt(ethers.parseEther(0)); // Should be greater than 0 after withdrawal
  });
});
