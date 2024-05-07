# Option--Procurer.vy

# Define OptionBuyerInterface within the same script
interface OptionBuyerInterface:
    def getBuyer() -> address: view

# Define your OptionProcurer
#balanceAmount: uint256
option: OptionBuyerInterface
owner: address
procurer: address
lastKnownLiquidated: uint256
timestamps: public(HashMap[uint256, address])

# Constructor
@payable
@deploy
def __init__(_merchant: address, _option: address, _timestamp: uint256):
    #self.balanceAmount = msg.value
    self.option = OptionBuyerInterface(_option)
    self.owner = _merchant
    self.procurer = msg.sender
    self.lastKnownLiquidated = _timestamp

# Withdraw function
@external
def withdraw():
    assert msg.sender == self.owner or msg.sender == self.procurer, "Only owner can withdraw"
    if msg.sender == self.procurer:
        assert self.timestamps[self.lastKnownLiquidated] != self.procurer, "Only owner can withdraw"
    send(self.owner, self.balance)

# Get Procurer function
@external
@view
def getProcurer() -> address:
    return self.procurer

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
def claimReceivables(_merchant: address):
    assert msg.sender == self.procurer, "Only owner can withdraw"
    assert self.option.getBuyer() == self.procurer, "Only owner can withdraw"
    self.owner = _merchant
    self.procurer = _merchant
