import subprocess

# Path to your Vyper contract file
vyper_contract_file = "../option--merchant/Option--Merchant.vy"
compiled_contract_byte_file = "vyper_contract_byte.txt"
compiled_contract_abi_file = "vyper_contract_abi.json"

# Compile the Vyper contract
try:
    # Run the vyper compiler as a subprocess
    result = subprocess.run(['vyper', vyper_contract_file], stdout=subprocess.PIPE, stderr=subprocess.PIPE, check=True)
    
    print("Contract compiled successfully!")
    
    # Extract and decode compiled bytecode
    compiled_bytecode = result.stdout.decode().strip()
    
    # Save compiled bytecode to a file
    with open(compiled_contract_byte_file, 'w') as f:
        f.write(compiled_bytecode)
except subprocess.CalledProcessError as e:
    print("Contract compilation failed:", e)
    if e.stderr:
        print("Vyper compiler error output:", e.stderr.decode())

# Compile the Vyper ABI
try:
    # Run the vyper compiler as a subprocess
    result = subprocess.run(['vyper', '-f', 'json', vyper_contract_file], stdout=subprocess.PIPE, stderr=subprocess.PIPE, check=True)
    
    print("ABI compiled successfully!")
    
    # Extract and decode compiled output (including ABI)
    compiled_output = result.stdout.decode().strip()
    
    # Save compiled output to a file
    with open(compiled_contract_abi_file, 'w') as f:
        f.write(compiled_output)
except subprocess.CalledProcessError as e:
    print("ABI compilation failed:", e)
    if e.stderr:
        print("Vyper compiler error output:", e.stderr.decode())
