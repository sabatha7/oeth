// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract OptionBuyer {
	address public buyer;
	address public owner;

    constructor(address _merchant) payable {
        buyer = msg.sender;
		owner = _merchant;
    }
    
    function withdraw(address _recipient) external {
        require(msg.sender == owner, "Only owner can withdraw");
        payable(_recipient).transfer(address(this).balance);
    }
	
	function getBuyer() external view returns (address) {return buyer;}
}