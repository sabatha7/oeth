import json
import os
from dotenv import load_dotenv
#from web3 import Web3

load_dotenv()

# Accessing environment variables
EthSepolia = os.environ.get('Web3HTTPProvider')
from_account = os.environ.get('Web3from_account')
private_key = os.environ.get('Web3private_key')

# Printing to verify
print("EthSepolia:", EthSepolia)
print("from_account:", from_account)
print("private_key:", private_key)

### Connect to Ganache
##web3 = Web3(Web3.HTTPProvider(EthSepolia))
##
### Get the nonce
##nonce = web3.eth.get_transaction_count(from_account)
##
##print(nonce)
### Load compiled bytecode
##with open('vyper_contract_byte.txt') as f:
##    contract_bytecode = f.read().strip()
##
### Load contract ABI
##with open('vyper_contract_abi.json') as f:
##    contract_abi = json.load(f)
##
##SN = web3.eth.contract(abi = contract_abi, bytecode = contract_bytecode)
##print(SN)
##
##_seller = "0xFa96e638636c2Df5aB740628834CBB62A0481e84"
##_platform = "Binance"
##_purchaseProofMessage = "Proof of purchase"
##constructor_args = [_seller, _platform, _purchaseProofMessage]
##
##print(web3.eth.gas_price)
##
### Specify the value to be sent (in Wei)
##value_in_wei = web3.toWei(1, 'ether')  # Example: 1 Ether
##
### Pass constructor arguments individually
##try:
##    Tx = SN.constructor(_seller, _platform, _purchaseProofMessage).build_transaction(
##        {
##        'gasPrice': web3.eth.gas_price,
##        'chainId': 11155111,
##        'from': from_account,
##        'nonce': nonce,
##        'value': value_in_wei  # Include the value to be sent
##        })
##    #SignedTx = web3.eth.account.sign_transaction(transaction, private_key = private_key)
##    #TxHash = web3.eth.send_raw_transaction(SignedTx.rawTransaction)
##    #TxReceipt = web3.eth.wait_for_transaction_receipt(TxHash)
##    #ContractInstance = web3.eth.contract(address = TxReceipt.contractAddress, abi = contract_abi)
##    
##except Exception as e: print(e)
##
##
