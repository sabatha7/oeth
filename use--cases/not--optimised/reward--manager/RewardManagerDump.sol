// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

contract RewardManagerDump {
    address public recipient;
    uint256 public reward;
	
	modifier onlyOwner() {
        require(msg.sender == recipient, "Only owner can call this function");
        _;
    }

    constructor(address _recipient, uint256 _reward) payable {
        require(_recipient != address(0), "Invalid recipient address");
        require(_reward > 0, "Invalid reward amount");
        recipient = _recipient;
        reward = _reward;
    }

    function withdraw() external onlyOwner {
        require(msg.sender == recipient, "Only recipient can withdraw");
        uint256 amount = reward;
        payable(recipient).transfer(amount);
    }
}
