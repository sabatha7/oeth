import solcx
import json

# Path to your Solidity contract file
solidity_contract_file = "../option--procurer/Option--Procurer.sol"

compiled_contract_byte_file = "solidity_contract_byte.txt"
compiled_contract_abi_file = "solidity_contract_abi.json"

# Compile the Solidity contract
try:
    # Set Solidity compiler version
    solcx.install_solc("0.8.0")
    
    # Compile the contract
    compiled_contract = solcx.compile_files([solidity_contract_file], output_values=["bin-runtime", "abi"], optimize=True)
    
    print("Contract compiled successfully!")
    
    # Extract compiled bytecode and ABI
    compiled_bytecode = compiled_contract[solidity_contract_file + ':OptionProcurer']['bin-runtime']
    compiled_abi = compiled_contract[solidity_contract_file + ':OptionProcurer']['abi']
    
    # Print compiled bytecode and ABI
    print("Compiled Bytecode:", compiled_bytecode)
    print("Compiled ABI:", compiled_abi)
    
    # Save compiled bytecode and ABI to files
    with open(compiled_contract_byte_file, 'w') as f:
        f.write(compiled_bytecode)
    with open(compiled_contract_abi_file, 'w') as f:
        json.dump(compiled_abi, f)
except solcx.exceptions.SolcError as e:
    print("Contract compilation failed:", e)
