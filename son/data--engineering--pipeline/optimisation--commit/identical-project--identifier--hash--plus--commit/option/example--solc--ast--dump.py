from subprocess import run
import json

source_file = "Option--Buyer.sol"
destination_file = "ast--not--optimised.json"

try:
  command = ["solc", "--ast-compact-json", source_file]
  result = run(command, capture_output=True, text=True)
  ast_json = result.stdout
  with open(destination_file, "w") as f:f.write(ast_json)
  print(f"AST successfully extracted and saved to: {destination_file}")
except Exception as e:print(e)
