import subprocess
import os

# Path to your Vyper contract file
vyper_contract_file = "../option--merchant/Option--Merchant.vy"

compiled_contract_byte_file = "vyper_contract_byte.txt"
compiled_contract_abi_file = "vyper_contract_abi.json"

# Compile the Vyper contract
try:
    # Run the vyper compiler as a subprocess
    Result = subprocess.run(['vyper', vyper_contract_file], capture_output=True, text=True, check=True)
    
    print("Contract compiled successfully!")
    CompiledBytecode = Result.stdout.strip()
    with open(compiled_contract_byte_file, 'w') as f:
        f.write(CompiledBytecode)
except subprocess.CalledProcessError as e:
    print("Contract compilation failed:", e)

# Compile the Vyper abi
try:
    # Run the vyper compiler as a subprocess
    result = subprocess.run(['vyper', '-f', 'json', vyper_contract_file], capture_output=True, text=True, check=True)
    
    print("Contract compiled successfully!")
    
    # Extract compiled output (including ABI)
    compiled_output = result.stdout.strip()
    
    # Save compiled output to a file
    with open(compiled_contract_abi_file, 'w') as f:
        f.write(compiled_output)
except subprocess.CalledProcessError as e:
    print("Contract compilation failed:", e)
