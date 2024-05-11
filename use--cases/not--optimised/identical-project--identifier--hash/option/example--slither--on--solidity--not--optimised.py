import subprocess
import os

# Define the source and destination paths (modify as needed)
source_file = r"Option--Buyer.sol"
destination_file = r"ast--not--optimised.json"


# Use subprocess for robust and reliable AST extraction
slither_command = ["slither", source_file]

try:
    extraction_process = subprocess.Popen(slither_command, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    stdout, stderr = extraction_process.communicate()
    f.write(stdout.decode('utf-8'))
except Exception as e:print(e)

