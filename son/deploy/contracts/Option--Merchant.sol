// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract OptionMerchant {
    address public buyerContractBuyer;
    uint256 public initTime;
    uint256 public lastKnownSwapped;
    address public procurerContractProcurer;

    constructor(address procurer_, address buyer_, uint256 timestamp_) {
		require(procurer_ != address(0), "Invalid procurer address");
		require(buyer_ != address(0), "Invalid buyer address");
        buyerContractBuyer = buyer_;
        procurerContractProcurer = procurer_;
		lastKnownSwapped = timestamp_;
        initTime = timestamp_;
    }
	
	function setAtomicSwapped(uint256 timestamp_) external {lastKnownSwapped = timestamp_;}
	
	function hasAtomicSwapped() external view returns (bool) {return lastKnownSwapped != initTime;}
}