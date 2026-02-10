#!/bin/bash
# Run unit tests for trading analyzer

# Navigate to the script's directory
cd "$(dirname "$0")"

# Run pytest with verbose output
pytest test_analyze.py -v

# Exit with pytest's exit code
exit $?
