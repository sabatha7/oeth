# Option--Procurer.vy
balance: uint256
option: address
owner: address
procurer: address
lastKnownLiquidated: uint256
timestamps: public(map(uint256, address))

@payable
def __init__(_merchant: address, _option: address, _timestamp: uint256):
    self.balance = msg.value
    self.option = _option
    self.owner = _merchant
    self.procurer = msg.sender
    self.lastKnownLiquidated = _timestamp
    self.timestamps[self.lastKnownLiquidated] = self.procurer

@external
def withdraw():
    assert msg.sender == self.owner or msg.sender == self.procurer, "Only owner can withdraw"
    if msg.sender == self.procurer:
        assert self.timestamps[self.lastKnownLiquidated] != self.procurer, "Only owner can withdraw"
    send(self.owner, self.balance)

@external
@view
def getProcurer() -> address:
    return self.procurer

@external
def setOwner(_owner: address, _timestamp: uint256):
    assert msg.sender == self.owner, "Only owner can withdraw"
    self.lastKnownLiquidated = _timestamp
    self.timestamps[self.lastKnownLiquidated] = self.procurer
    self.owner = _owner
    self.procurer = _owner

@external
def claimReceivables(_merchant: address):
    assert msg.sender == self.procurer, "Only owner can withdraw"
    assert self.option.getBuyer() == self.procurer, "Only owner can withdraw"
    self.owner = _merchant
    self.procurer = _merchant
