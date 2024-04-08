#!/bin/bash

# Path to your Python script
SCRIPT_PATH="script.py"

# Check if python3 is available
if command -v python3 &>/dev/null; then
    python3 $SCRIPT_PATH
elif command -v python &>/dev/null; then
    python $SCRIPT_PATH
else
    echo "Python is not installed on your system."
    exit 1
fi
