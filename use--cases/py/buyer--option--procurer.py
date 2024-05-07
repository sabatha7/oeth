import json
from web3 import Web3


EthSepolia = 'https://sepolia.infura.io/v3/704dab21eaf84974a608b3fafdb911a8'

# Ethereum address of the sender account
from_account = '0x43116155838f4E6e721bA23F1712b245b5611712'

private_key = '0x' + '22279e64a1c05f7f4805ad16c7307852e4cda9d8dce468580c3b1aa7f97a62b4'


# Connect to Ganache
web3 = Web3(Web3.HTTPProvider(EthSepolia))

# Get the nonce
nonce = web3.eth.get_transaction_count(from_account)

print(nonce)
# Load compiled bytecode
with open('vyper_contract_byte.txt') as f:
    contract_bytecode = f.read().strip()

# Load contract ABI
with open('vyper_contract_abi.json') as f:
    contract_abi = json.load(f)

SN = web3.eth.contract(abi = contract_abi, bytecode = contract_bytecode)
print(SN)

_seller = "0xFa96e638636c2Df5aB740628834CBB62A0481e84"
_platform = "Binance"
_purchaseProofMessage = "Proof of purchase"
constructor_args = [_seller, _platform, _purchaseProofMessage]

print(web3.eth.gas_price)

# Specify the value to be sent (in Wei)
value_in_wei = web3.toWei(1, 'ether')  # Example: 1 Ether

# Pass constructor arguments individually
try:
    Tx = SN.constructor(_seller, _platform, _purchaseProofMessage).build_transaction(
        {
        'gasPrice': web3.eth.gas_price,
        'chainId': 11155111,
        'from': from_account,
        'nonce': nonce,
        'value': value_in_wei  # Include the value to be sent
        })
    #SignedTx = web3.eth.account.sign_transaction(transaction, private_key = private_key)
    #TxHash = web3.eth.send_raw_transaction(SignedTx.rawTransaction)
    #TxReceipt = web3.eth.wait_for_transaction_receipt(TxHash)
    #ContractInstance = web3.eth.contract(address = TxReceipt.contractAddress, abi = contract_abi)
    
except Exception as e: print(e)

