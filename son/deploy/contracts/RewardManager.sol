// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "./SparseMerkleTree.sol";
import "./RewardManagerDump.sol";

contract RewardManager is SparseMerkleTree {

	//address public showPredictedAddress;
	//address public actualPredictedAddress;
	//bytes32 public actualSalt;
	//bytes public innerEncodePacked;
	//bytes public deeperEncodePacked;
	//bytes public rewardManagerDumpCreationCode;

    constructor(bytes32 _root) payable {
        root = _root;
    }

    function claimReward(bytes32 leaf, uint256 index, bytes32[] memory proof, uint256 reward) external {
        require(verify(leaf, index, proof), "Invalid Merkle proof");

        bytes32 salt = keccak256(abi.encodePacked(msg.sender, reward));
        address predictedAddress = address(uint160(uint256(keccak256(
            abi.encodePacked(
                bytes1(0xff),
                address(this),
                salt,
                keccak256(abi.encodePacked(
                    type(RewardManagerDump).creationCode,
                    abi.encode(msg.sender, reward)
                ))
            )
        ))));
		
		//showPredictedAddress = predictedAddress;

        // Check if the contract already exists
        uint256 codeSize;
        assembly { codeSize := extcodesize(predictedAddress) }
        require(codeSize == 0, "Contract already deployed");

        // Deploy the contract
        //RewardManagerDump newContract = new RewardManagerDump{salt: salt, value: reward}(msg.sender, reward);
		new RewardManagerDump{salt: salt, value: reward}(msg.sender, reward);
		
		//actualPredictedAddress = address(newContract);
		//actualSalt = salt;
		//innerEncodePacked = abi.encodePacked(type(RewardManagerDump).creationCode,abi.encode(msg.sender, reward));
		//deeperEncodePacked = abi.encode(msg.sender, reward);
		//rewardManagerDumpCreationCode = type(RewardManagerDump).creationCode;
    }

    receive() external payable {}
    fallback() external payable {}
}
