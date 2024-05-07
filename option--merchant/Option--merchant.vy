# Option--Merchant.vy

# Define OptionBuyerInterface within the same script
interface OptionBuyerInterface:
    def withdraw(_recipient: address) -> bool: view

# Define OptionProcurerInterface within the same script
interface OptionProcurerInterface:
    def setOwner(_owner: address) : view

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

# Atomic Swap function
@external
def atomicSwap(_timestamp: uint256):
    assert msg.sender == self.owner, "Only owner can work"
    assert self.lastKnownSwapped == self.initTime, "Only works once"
    self.lastKnownSwapped = _timestamp
    if OptionBuyerInterface(self.buyerContractBuyer).withdraw(self.procurerContractProcurer):
        OptionProcurerInterface(self.procurerContractProcurer).setOwner(self.buyerContractBuyer)
