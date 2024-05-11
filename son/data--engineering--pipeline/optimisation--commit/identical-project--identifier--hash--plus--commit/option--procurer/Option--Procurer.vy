# Option--Procurer.vy
balanceAmount: uint256
owner: address
procurer: address
lastKnownLiquidated: uint256
timestamps: public(HashMap[uint256, address])

# Constructor
@payable
@deploy
def __init__(_merchant: address, _timestamp: uint256):
    self.owner = _merchant
    self.procurer = msg.sender
    self.lastKnownLiquidated = _timestamp

# Withdraw function
@external
def withdraw():
    assert msg.sender == self.owner or msg.sender == self.procurer, "Only owner can withdraw"
    if msg.sender == self.procurer:assert self.timestamps[self.lastKnownLiquidated] != self.procurer, "Only owner can withdraw"
    send(self.procurer, self.balance)

# Set Owner function
@external
def setOwner(_owner: address, _timestamp: uint256):
    assert msg.sender == self.owner, "Only owner can withdraw"
    self.lastKnownLiquidated = _timestamp
    self.timestamps[self.lastKnownLiquidated] = self.procurer
    self.owner = _owner
    self.procurer = _owner

# Claim Receivables function
@external
def claimReceivables(_merchant: address, _buyer: address):
    assert msg.sender == self.procurer, "Only owner can withdraw"
    assert _buyer == self.procurer, "Only owner can withdraw"
    self.owner = _merchant
    self.procurer = _merchant
