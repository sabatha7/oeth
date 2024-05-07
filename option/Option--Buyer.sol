// Option--Buyer.sol
pragma solidity ^0.8.0;

contract OptionBuyer {
	uint256 public balance;
	address public buyer;
	address public owner;

    constructor(address _merchant) payable {
		balance = msg.value;
        buyer = msg.sender;
		owner = _merchant;
    }
    
    function withdraw(adress _recipient) external {
        require(msg.sender == owner, "Only owner can withdraw");
        payable(_recipient).transfer(address(this).balance);
    }
	
	function getBuyer() external view returns (address) {
		return buyer;
    }
}