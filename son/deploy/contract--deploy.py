import json
import os
from dotenv import load_dotenv
from web3 import Web3
from pymerkle import InmemoryTree as MerkleTree
from hashlib import sha3_256

# Load environment variables from .env file
load_dotenv()

# Ethereum provider (e.g., Infura)
EthSepolia = os.environ.get('Web3HTTPProvider')

# Connect to the Ethereum provider
web3 = Web3(Web3.HTTPProvider(EthSepolia))

# Check connection
if not web3.is_connected():
    raise Exception("Failed to connect to the Ethereum node")

# Accessing environment variables
from_account = os.environ.get('Web3from_account')
private_key = os.environ.get('Web3private_key')

# Get the nonce
nonce = web3.eth.get_transaction_count(from_account)

# Load compiled bytecode
with open('reward_manager_contract_byte.txt') as f:
    contract_bytecode = f.read().strip()

# Load contract ABI
with open('reward_manager_contract_abi.json') as f:
    contract_abi = json.load(f)

# Merchant address
_merchant = "0x3593e218AD8b7a72767EeF556afE3a4Dc303560b"

# Generate SHA-3 (keccak256) hash of the merchant address
keccak = sha3_256()
keccak.update(Web3.to_bytes(hexstr=_merchant))
leaf = keccak.hexdigest()

# Convert the leaf to bytes
leaf_bytes = Web3.to_bytes(hexstr=leaf)

# Create Merkle Tree and add leaf
mt = MerkleTree(algorithm='sha3_256')
index = mt.append_entry(leaf_bytes)

# Get Merkle Root
root = mt.get_state()

# Convert the root to bytes
root_bytes = Web3.to_bytes(hexstr=root.hex())

# Initialize the contract
SN = web3.eth.contract(abi=contract_abi, bytecode=contract_bytecode)

# Specify the value to be sent (in Wei)
value_in_wei = web3.to_wei(1, 'ether')

# Build the transaction
try:
    tx = SN.constructor(root_bytes).build_transaction(
        {
            'gasPrice': web3.eth.gas_price,
            'chainId': 80002,  # Replace with the actual chain ID if different 80002 amoy pos and 11155111 sepolia eth
            'from': from_account,
            'nonce': nonce,
            'value': value_in_wei  # Include the value to be sent
        }
    )
    print(tx)

    # Sign the transaction
    # signed_tx = web3.eth.account.sign_transaction(tx, private_key=private_key)
    
    # Send the transaction
    # tx_hash = web3.eth.send_raw_transaction(signed_tx.rawTransaction)
    
    # Wait for the transaction receipt
    # tx_receipt = web3.eth.wait_for_transaction_receipt(tx_hash)
    
    # Get the contract address
    # contract_address = tx_receipt.contractAddress
    # print(f"Contract deployed at address: {contract_address}")

    # Interact with the deployed contract (optional)
    # reward_manager = web3.eth.contract(address=contract_address, abi=contract_abi)

except Exception as e:
    print(e)
