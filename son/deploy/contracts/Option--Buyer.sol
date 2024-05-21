// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract OptionBuyer {
	address public immutable buyer;
    address public immutable owner;

    constructor(address merchant_) payable {
		require(merchant_ != address(0), "Invalid merchant address");
		buyer = msg.sender;
        owner = merchant_;
    }

    function withdraw(address recipient_) external {
        require(recipient_ != address(0), "Invalid recipient address");
        require(msg.sender == owner, "Only owner can withdraw");
        payable(recipient_).transfer(address(this).balance);
    }

    function getBuyer() external view returns (address) {
        return buyer;
    }
}