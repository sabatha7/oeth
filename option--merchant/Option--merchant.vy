# Option--Merchant.vy
buyerContractBuyer: address
initTime: int128
lastKnownSwapped: uint256
owner: address
procurerContractProcurer: address

@external
def __init__(_procurer: address, _buyer: address, _timestamp: int128):
    self.buyerContractBuyer = _buyer
    self.owner = msg.sender
    self.procurerContractProcurer = _procurer
    self.initTime = self.lastKnownSwapped = _timestamp

@external
def atomicSwap(_timestamp: int128):
    assert msg.sender == self.owner, "Only owner can work"
    assert self.lastKnownSwapped == self.initTime, "Only works once"
    self.lastKnownSwapped = _timestamp
    if self.buyerContract.withdraw(self.procurerContractProcurer):
        self.procurerContract.setOwner(self.buyerContractBuyer)
