// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "./SparseMerkleTree.sol";
import "./RewardManagerDump.sol";

contract PrizeManager is SparseMerkleTree {

    constructor(bytes32 _root) payable {
        root = _root;
    }

    function claimReward(bytes32 leaf, uint256 index, bytes32[] calldata proof, uint256 reward) external {
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

        // Check if the contract already exists
        uint256 codeSize;
        assembly { codeSize := extcodesize(predictedAddress) }
        require(codeSize == 0, "Contract already deployed");

        // Deploy the contract
        new RewardManagerDump{salt: salt, value: reward}(msg.sender, reward);
    }

    receive() external payable {}
    fallback() external payable {}
}
