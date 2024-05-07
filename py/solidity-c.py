import subprocess

# Path to your Solidity contract file
solidity_contract_file = "../option procurer/OptionProcurer.sol"

compiled_contract_byte_file = "solidity_contract_byte.txt"
compiled_contract_abi_file = "solidity_contract_abi.json"

# Compile the Solidity contract
try:
    # Run the solc compiler as a subprocess
    result = subprocess.run(['solc', '--bin', '--abi', '--optimize', '--overwrite', '-o', './', solidity_contract_file], capture_output=True, text=True, check=True)
    
    print("Contract compiled successfully!")
    
    # Extract compiled bytecode
    compiled_bytecode = None
    with open(compiled_contract_byte_file, 'r') as f:
        compiled_bytecode = f.read()
    
    # Extract compiled ABI
    compiled_abi = None
    with open(compiled_contract_abi_file, 'r') as f:
        compiled_abi = f.read()
    
    # Print compiled bytecode and ABI
    print("Compiled Bytecode:", compiled_bytecode)
    print("Compiled ABI:", compiled_abi)
except subprocess.CalledProcessError as e:
    print("Contract compilation failed:", e)
