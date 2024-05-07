# Option--Merchant.vy

# State variables
buyerContractBuyer: address
initTime: uint256
lastKnownSwapped: uint256
owner: address
procurerContractProcurer: address

# Constructor
@deploy
@payable
def __init__(_procurer: address, _buyer: address, _timestamp: uint256):
    self.buyerContractBuyer = _buyer
    self.owner = msg.sender
    self.procurerContractProcurer = _procurer
    self.lastKnownSwapped = _timestamp
    self.initTime = _timestamp
	
@external
def setAtomicSwapped(_timestamp: uint256):self.lastKnownSwapped = _timestamp
	
@external
@view
def hasAtomicSwapped() -> bool:return self.lastKnownSwapped == self.initTime
