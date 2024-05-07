// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract OptionMerchant {
    address public buyerContractBuyer;
    uint256 public initTime;
    uint256 public lastKnownSwapped;
    address public owner;
    address public procurerContractProcurer;

    constructor(address _procurer, address _buyer, uint256 _timestamp) {
        buyerContractBuyer = _buyer;
        owner = msg.sender;
        procurerContractProcurer = _procurer;
		lastKnownSwapped = _timestamp;
        initTime = _timestamp;
    }
	
	function setAtomicSwapped(uint256 _timestamp) external {lastKnownSwapped = _timestamp;}
	
	function hasAtomicSwapped() external view returns (bool) {return lastKnownSwapped == initTime;}
}
