#!/bin/bash

echo "[+] Installing Dark Net Cleaner..."

# Update packages
pkg update -y
pkg install -y python clang git

# Get the script directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Install dependencies
echo "[+] Installing Python dependencies..."
pip install -r "$SCRIPT_DIR/requirements.txt"

# Check if darknet_cleaner_v3.py exists
if [ ! -f "$SCRIPT_DIR/darknet_cleaner_v3.py" ]; then
    echo "[-] Error: darknet_cleaner_v3.py not found!"
    echo "[*] Make sure the file is in the same directory as install.sh"
    exit 1
fi

echo "[+] Running Cleaner..."
python "$SCRIPT_DIR/darknet_cleaner_v3.py"
