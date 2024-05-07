from dotenv import load_dotenv
import os
from web3 import Web3
from web3.contract import ConciseContract

# Load environment variables from .env file
load_dotenv()

# Accessing environment variables
EthSepolia = os.environ.get('Web3HTTPProvider')
from_account = os.environ.get('Web3from_account')
private_key = os.environ.get('Web3private_key')

# Define the contract ABIs and addresses
option_buyer_abi = [...]  # Replace [...] with the OptionBuyer contract ABI
option_buyer_address = '0x...'  # Replace '0x...' with the OptionBuyer contract address
option_procurer_abi = [...]  # Replace [...] with the OptionProcurer contract ABI
option_procurer_address = '0x...'  # Replace '0x...' with the OptionProcurer contract address
option_merchant_abi = [...]  # Replace [...] with the OptionProcurer contract ABI
option_merchant_address = '0x...'  # Replace '0x...' with the OptionProcurer contract address

# Connect to Ethereum node
w3 = Web3(Web3.HTTPProvider(EthSepolia))

# Set default account
w3.eth.defaultAccount = from_account

# Load contracts
option_buyer_contract = w3.eth.contract(address=option_buyer_address, abi=option_buyer_abi)
option_procurer_contract = w3.eth.contract(address=option_procurer_address, abi=option_procurer_abi)
option_merchant_contract = w3.eth.contract(address=option_merchant_address, abi=option_merchant_abi)

# Atomic swap function
def atomic_swap(_timestamp, _ethRecipient, _paymentProofRecipient):
    if option_merchant_contract.hasAtomicSwapped():return False
    
    # Call OptionProcurer setOwner function
    option_procurer_contract.functions.setOwner(_paymentProofRecipient, _timestamp).transact()

    # Call OptionBuyer withdraw function
    option_buyer_contract.functions.withdraw(_ethRecipient).transact()

    option_merchant_contract.setAtomicSwapped(_timestamp)

    return True

# Call atomic swap function
atomic_swap(timestamp)
