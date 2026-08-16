import subprocess
import sys
import os
import urllib.request
import json

def run_command(cmd, cwd=None):
    print(f"Running command: {' '.join(cmd)}")
    try:
        res = subprocess.run(cmd, check=True, text=True, capture_output=True, cwd=cwd)
        if res.stdout:
            print(res.stdout)
        return True
    except subprocess.CalledProcessError as e:
        print(f"Error: {e.stderr}")
        return False

def main():
    print("Setting up Ollama custom model...")
    # Check if ollama is available in PATH
    try:
        res = subprocess.run(["ollama", "--version"], capture_output=True, text=True)
        print(f"Ollama detected: {res.stdout.strip()}")
    except FileNotFoundError:
        print("Ollama executable not found in PATH.")
        print("Please ensure Ollama is installed and running.")
        sys.exit(1)
        
    # Check if Ollama service is running by requesting local API
    try:
        urllib.request.urlopen("http://localhost:11434/api/tags", timeout=5)
        print("Ollama service is running on localhost:11434")
    except Exception as e:
        print("Error: Could not connect to Ollama service. Please make sure Ollama App is running.")
        sys.exit(1)
        
    # Pull base model
    base_model = "tinyllama"
    print(f"Pulling base model {base_model}...")
    run_command(["ollama", "pull", base_model])
    
    # Create custom model
    print("Creating custom model moneymate-bot...")
    modelfile_path = "Modelfile"
    if not os.path.exists(modelfile_path):
        modelfile_path = os.path.join(os.path.dirname(__file__), "Modelfile")
    
    success = run_command(["ollama", "create", "moneymate-bot", "-f", modelfile_path])
    if success:
        print("Ollama custom model setup complete! Model 'moneymate-bot' is ready.")
    else:
        print("Failed to create custom model.")

if __name__ == "__main__":
    main()
