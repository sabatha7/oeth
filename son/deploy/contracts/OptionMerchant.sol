// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract OptionMerchant {
    address public buyerContractBuyer;
    uint256 public initTime;
    uint256 public lastKnownSwapped;
    address public procurerContractProcurer;
	address public owner;

    constructor(address procurer_, address buyer_, uint256 timestamp_) {
		require(procurer_ != address(0), "Invalid procurer address");
		require(buyer_ != address(0), "Invalid buyer address");
        buyerContractBuyer = buyer_;
        procurerContractProcurer = procurer_;
		owner = msg.sender;
		lastKnownSwapped = timestamp_;
        initTime = timestamp_;
    }
	
	function setAtomicSwapped(uint256 timestamp_) external {
		require(msg.sender == owner, "Only owner can participate");
		lastKnownSwapped = timestamp_;
	}
	
	function hasAtomicSwapped() external view returns (bool) {return lastKnownSwapped != initTime;}
}