import subprocess
import json

# Path to your Solidity contract file
solidity_contract_file = "contracts/OptionBuyer.sol"
compiled_contract_byte_file = "OptionBuyer_contract_byte.txt"
compiled_contract_abi_file = "OptionBuyer_contract_abi.json"

# Compile the Solidity contract
try:
    # Run the solc compiler as a subprocess with combined-json output
    result = subprocess.run(
        ['solc', '--combined-json', 'bin,abi', '--optimize', '--overwrite', solidity_contract_file], 
        stdout=subprocess.PIPE, stderr=subprocess.PIPE, check=True
    )
    
    print("Contract compiled successfully!")
    
    # Parse the JSON output from solc
    compiled_output = json.loads(result.stdout.decode())
    
    # Extract contract name
    contract_name = solidity_contract_file.split('/')[-1].split('.')[0]
    contract_key = f"{solidity_contract_file}:{contract_name}"
    
    # Extract compiled bytecode
    compiled_bytecode = compiled_output['contracts'][contract_key]['bin']
    
    # Save compiled bytecode to a file
    with open(compiled_contract_byte_file, 'w') as f:
        f.write(compiled_bytecode)
    
    # Extract and save ABI
    compiled_abi = compiled_output['contracts'][contract_key]['abi']
    
    # Save compiled ABI to a file
    with open(compiled_contract_abi_file, 'w') as f:
        json.dump(compiled_abi, f, indent=4)
    
except subprocess.CalledProcessError as e:
    print("Contract compilation failed:", e)
    if e.stderr:
        print("Solidity compiler error output:", e.stderr.decode())
except KeyError as e:
    print(f"Error in parsing the compiler output: {e}")
except json.JSONDecodeError as e:
    print(f"Error in decoding JSON output: {e}")
