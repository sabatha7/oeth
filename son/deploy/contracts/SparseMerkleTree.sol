// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

abstract contract SparseMerkleTree {
    bytes32 public root;
    mapping(uint256 => bytes32) public nodes;

    bytes32 constant defaultLeaf = keccak256(abi.encodePacked(uint256(0)));

    function initialize() public {
        root = defaultLeaf;
    }

    function verify(bytes32 leaf, uint256 index, bytes32[] memory proof) public view returns (bool) {
        bytes32 currentHash = leaf;
        uint256 idx = index;

        for (uint256 i = 0; i < proof.length; i++) {
            if (idx % 2 == 0) {
                currentHash = keccak256(abi.encodePacked(currentHash, proof));
            } else {
                currentHash = keccak256(abi.encodePacked(proof, currentHash));
            }
            idx /= 2;
        }
        return currentHash == root;
    }
}
