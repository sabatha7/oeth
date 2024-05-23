const { expect } = require("chai");
const { ethers, artifacts } = require("hardhat");
const { MerkleTree } = require('merkletreejs');
const keccak256 = require('keccak256');
const fs = require("fs");

function numberToUint8Array(number) {
  // Convert a number to a Uint8Array representation
  const hexString = number.toString(16); // Convert the number to hexadecimal string
  return Uint8Array.from(Buffer.from(hexString, 'hex')); // Convert the hexadecimal string to Uint8Array
}

// not safe
function zeroPad(data, length) {
  /**
   * Pads a byte string with zeros on the left to reach a desired length.
   *
   * @param {number} data - The number to pad (uint).
   * @param {number} length - The desired total length of the padded byte string.
   * @returns {Uint8Array} - A new byte string with leading zeros.
   */
  const byteData = numberToUint8Array(data); // Convert the number to a byte array
  if (byteData.length >= length) {
    return byteData;
  }
  const padding = new Uint8Array(length - byteData.length).fill(0); // Fill the padding with zeros
  const paddedData = new Uint8Array(length); // Create a new Uint8Array of the desired length
  paddedData.set(padding, 0); // Set the padding at the beginning of the new array
  paddedData.set(byteData, padding.length); // Set the original data after the padding
  return paddedData;
}


describe("Option Contracts", function () {
  let optionMerchant, optionBuyer, optionProcurer;
  let merchant, buyer, procurer, authority;
  const initialTimestamp = Math.floor(Date.now() / 1000);
  let merkleData;
  let rewardManager;

  const rewardAmount = ethers.parseEther(".2");

  beforeEach(async function () {
    const signers = await ethers.getSigners();
    [merchant, buyer, procurer, authority] = signers;

    // Deploy OptionBuyer contract
    const OptionBuyer = await ethers.getContractFactory("OptionBuyer");
    optionBuyer = await OptionBuyer.connect(buyer).deploy(await merchant.getAddress(), { value: ethers.parseEther(".4") });
    await optionBuyer.waitForDeployment();

    // Deploy OptionProcurer contract
    const OptionProcurer = await ethers.getContractFactory("OptionProcurer");
    optionProcurer = await OptionProcurer.connect(procurer).deploy(await merchant.getAddress(), initialTimestamp, { value: ethers.parseEther(".1") });
    await optionProcurer.waitForDeployment();

    // Deploy OptionMerchant contract
    const OptionMerchant = await ethers.getContractFactory("OptionMerchant");
    optionMerchant = await OptionMerchant.deploy(await optionProcurer.getAddress(), await optionBuyer.getAddress(), initialTimestamp);
    await optionMerchant.waitForDeployment();

    const leaves = [keccak256(await merchant.getAddress())];
    const tree = new MerkleTree(leaves, keccak256, { sortPairs: true });
    const root = tree.getRoot().toString('hex');
    const leaf = keccak256(await merchant.getAddress());
    const proof = tree.getProof(leaf).map(x => x.data);

    //console.log('Merkle Root:', root);
    //console.log('Proof:', proof);
    merkleData = { root, leaf, proof };

    const rootHex = '0x' + merkleData.root.toString('hex');
    const RewardManager = await ethers.getContractFactory("RewardManager");
    rewardManager = await RewardManager.connect(authority).deploy(rootHex, { value: rewardAmount });
    await rewardManager.waitForDeployment();
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
  });

  it("should allow atomic swap and track changes", async function () {
    const newTimestamp = initialTimestamp + 1000;
    await optionMerchant.setAtomicSwapped(newTimestamp);
    expect(await optionMerchant.hasAtomicSwapped()).to.be.true;
    expect(await optionMerchant.lastKnownSwapped()).to.equal(newTimestamp);

    await optionProcurer.connect(merchant).setOwner(await buyer.getAddress(), newTimestamp);
    expect(await optionProcurer.owner()).to.equal(await buyer.getAddress());
  });

  it("should allow buyer or merchant to withdraw funds", async function () {
    await optionBuyer.connect(merchant).withdraw(await procurer.getAddress());
    expect(await ethers.provider.getBalance(await optionBuyer.getAddress())).to.equal(0);
  });

  it("should allow merchant to withdraw funds", async function () {
    await optionProcurer.connect(merchant).withdraw();
    expect(await ethers.provider.getBalance(await optionProcurer.getAddress())).to.equal(0);
  });

  it("should allow merchant to claim reward using Merkle proof", async function () {
    const newTimestamp = initialTimestamp + 1000;
    await optionMerchant.setAtomicSwapped(newTimestamp);
    await optionProcurer.connect(merchant).setOwner(await buyer.getAddress(), newTimestamp);
    await optionBuyer.connect(merchant).withdraw(await procurer.getAddress());
    await optionProcurer.connect(buyer).claimReceivables(await merchant.getAddress(), await buyer.getAddress());

    // Prepare the Merkle leaf and proof
    const leafHex = '0x' + merkleData.leaf.toString('hex');
    const proofArray = merkleData.proof.map(p => ethers.utils.arrayify(p));

    // Claim the reward using the Merkle proof
    //await rewardManager.connect(merchant).claimReward(leafHex, 0, proofArray, rewardAmount);
	
	// Call the claimReward function
	await rewardManager.connect(merchant).claimReward(leafHex, 0, proofArray, rewardAmount);
	
	//console.log(await rewardManager.connect(merchant).showPredictedAddress());
	//console.log(await rewardManager.connect(merchant).actualPredictedAddress());


    // Verify that the contract was deployed
	//console.log("Address:", await merchant.getAddress());
	//console.log("Reward Amount:", rewardAmount);
    const salt = ethers.solidityPackedKeccak256(["address", "uint256"], [await merchant.getAddress(), rewardAmount]);
	//console.log('local salt:', salt);
	//console.log('onchain salt:', await rewardManager.connect(merchant).actualSalt());

    // Replace 'RewardManagerDump' with the actual contract name and creation code
	// Path to the JSON file for RewardManagerDump
	const rewardManagerDumpArtifactPath = 'C:\\Users\\SABATHA\\oeth\\son\\deploy\\artifacts\\contracts\\RewardManagerDump.sol\\RewardManagerDump.json';

	// Read the JSON file
	const rewardManagerDumpArtifact = JSON.parse(fs.readFileSync(rewardManagerDumpArtifactPath, "utf8"));

	// Extract the bytecode
	const rewardManagerDumpBytecode = rewardManagerDumpArtifact.bytecode;
	//console.log("artifacts:", artifacts);
	
	// Remove '0x' prefix
	const withoutPrefix = ethers.solidityPacked(['address', 'uint256'], [await merchant.getAddress(), rewardAmount]).slice(2);

	// Add 24 zeros to the end
	const padded = '0'.repeat(24) + withoutPrefix;

	// Add '0x' prefix back
	const compliantValue = '0x' + padded;

    const predictedAddress = ethers.getCreate2Address(
      await rewardManager.getAddress(),
      salt,
      ethers.keccak256(ethers.solidityPacked(['bytes', 'bytes'], [rewardManagerDumpBytecode, compliantValue]))
    );
	
	//console.log('local rewardManagerDumpCreationCode:', rewardManagerDumpBytecode);
	//console.log('onchain rewardManagerDumpCreationCode:', await rewardManager.connect(merchant).rewardManagerDumpCreationCode());
	
	//console.log('local innerEncodePacked:', ethers.solidityPacked(['bytes', 'bytes'], [rewardManagerDumpBytecode, compliantValue]));
	//console.log('onchain innerEncodePacked:', await rewardManager.connect(merchant).innerEncodePacked());
	
	//const addressBytes = ethers.getBytes(await merchant.getAddress());
	//const rewardAmountBytes = zeroPad(rewardAmount, 32);

	// Concatenate the byte arrays
	//const packedBytes = ethers.concat([addressBytes, rewardAmountBytes]);
	//console.log('local deeperEncodePacked packed Bytes', packedBytes);

	//console.log('local deeperEncodePacked', compliantValue);
	//console.log('onchain deeperEncodePacked', await rewardManager.connect(merchant).deeperEncodePacked());
	//console.log(predictedAddress)

    const codeSize = await ethers.provider.getCode(predictedAddress);
    expect(codeSize).to.not.equal("0x");
  });
});