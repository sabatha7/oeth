// Option--Merchant.sol
pragma solidity ^0.8.0;

contract OptionMerchant {
	address public buyerContractBuyer;
	int256 public initTime;
	uint256 public lastKnownSwapped;
	address public owner;
	address public procurerContractProcurer;

    constructor(address _procurer, address _buyer, int256 _timestamp) {
		buyerContractBuyer = _buyer;
		owner = msg.sender;
		procurerContractProcurer = _procurer;
		initTime = lastKnownSwapped = _timestamp;
    }
    
	function atomicSwap(int256 _timestamp) external {
		require(msg.sender == owner, "Only owner can work");
		require(lastKnownSwapped == initTime, "Only works once"); // become singly // atomic swap succeeds
		lastKnownSwapped = _timestamp;
		if(buyerContract.withdraw(procurerContractProcurer)){
			procurerContract.setOwner(buyerContractBuyer);
		}
	}
}