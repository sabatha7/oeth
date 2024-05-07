# Option--Buyer.vy
#balanceAmount: uint256
buyer: address
owner: address

@deploy
@payable
def __init__(_merchant: address):
    #self.balanceAmount = msg.value
    self.buyer = msg.sender
    self.owner = _merchant

@external
def withdraw(_recipient: address):
    assert msg.sender == self.owner, "Only owner can withdraw"
    send(_recipient, self.balance)

@external
@view
def getBuyer() -> address:
    return self.buyer
