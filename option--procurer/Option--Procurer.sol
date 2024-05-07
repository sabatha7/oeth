// Option--Procurer.sol
pragma solidity ^0.8.0;

contract OptionProcurer {
    uint256 public balance;
	address public option;
	address public owner;
    address public procurer;
	uint256 public lastKnownLiquidated;
	mapping(uint256 => address) public timestamps;

    constructor(address _merchant, address _option, uint256 _timestamp) payable {
		balance = msg.value;
        option = _option;
        owner = _merchant;
        procurer = msg.sender;
		lastKnownLiquidated = _timestamp;
		timestamps[lastKnownLiquidated] = procurer;
    }
    
    function withdraw() external {
        require(msg.sender == owner || msg.sender == procurer, "Only owner can withdraw");
		if (msg.sender == procurer){require(timestamps[lastKnownLiquidated] != procurer, "Only owner can withdraw");}
        payable(owner).transfer(address(this).balance);
    }
	
	function getProcurer() external view returns (address) {
		return procurer;
    }
	
	function setOwner(address _owner, uint256 _timestamp) external {
		require(msg.sender == owner, "Only owner can withdraw");
		lastKnownLiquidated = _timestamp;
		timestamps[lastKnownLiquidated] = procurer;
		owner = _owner;
		procurer = _owner;
	}
	
	function claimReceivables(address _merchant) external {
		require(msg.sender == procurer, "Only owner can withdraw");
		require(option.getBuyer() == procurer, "Only owner can withdraw");
		owner = _merchant;
		procurer = _merchant;
	}
}