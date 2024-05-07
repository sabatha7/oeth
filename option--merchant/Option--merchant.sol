// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface Option {
    function withdraw(address _recipient) external returns (bool);
}

interface OptionProcurer {
    function setOwner(address _owner) external;
}

contract OptionMerchant {
    address public buyerContractBuyer;
    uint256 public initTime;
    uint256 public lastKnownSwapped;
    address public owner;
    address public procurerContractProcurer;
    Option public buyerContract;
    OptionProcurer public procurerContract;

    constructor(address _procurer, address _buyer, uint256 _timestamp) {
        buyerContractBuyer = _buyer;
        owner = msg.sender;
        procurerContractProcurer = _procurer;
		lastKnownSwapped = _timestamp;
        initTime = _timestamp;
        buyerContract = Option(_buyer);
        procurerContract = OptionProcurer(_procurer);
    }
    
    function atomicSwap(uint256 _timestamp) external {
        require(msg.sender == owner, "Only owner can work");
        require(lastKnownSwapped == initTime, "Only works once"); // become singly // atomic swap succeeds
        lastKnownSwapped = _timestamp;
        // Call withdraw function of the buyer contract
        if (buyerContract.withdraw(procurerContractProcurer)) {
            // Call setOwner function of the procurer contract
            procurerContract.setOwner(buyerContractBuyer);
        }
    }
}
