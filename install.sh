#!/bin/bash

echo "[+] Installing Dark Net Cleaner..."

pkg update -y
pkg install -y python clang

pip install -r requirements.txt

echo "[+] Running Cleaner..."
python darknet_cleaner_v3.py
