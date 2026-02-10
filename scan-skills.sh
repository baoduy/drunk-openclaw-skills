#!/bin/bash

# VirusTotal Skills Scanner
# Scans all folders in the skills directory using vt-cli

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "VirusTotal Skills Scanner"
echo "=========================="
echo ""

# Check if vt-cli is installed
if ! command -v vt &> /dev/null; then
    echo -e "${RED}Error: vt-cli is not installed${NC}"
    echo "Please rebuild the devcontainer to install vt-cli"
    exit 1
fi

# Check if API key is set
if [ -z "$VT_API_KEY" ]; then
    echo -e "${YELLOW}Warning: VT_API_KEY environment variable is not set${NC}"
    echo ""
    echo "To set your VirusTotal API key, run:"
    echo "  export VT_API_KEY='your-api-key-here'"
    echo ""
    echo "Or add it to your shell profile (~/.bashrc or ~/.zshrc):"
    echo "  echo 'export VT_API_KEY=\"your-api-key-here\"' >> ~/.bashrc"
    echo ""
    echo "Get your API key at: https://www.virustotal.com/gui/my-apikey"
    exit 1
fi

# Initialize vt-cli with API key
vt init --apikey "$VT_API_KEY" 2>/dev/null || true

echo "Scanning skills folders..."
echo ""

# Create a results directory
RESULTS_DIR="/code/vt-scan-results"
mkdir -p "$RESULTS_DIR"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

# Find all directories in skills/
for skill_dir in /code/skills/*/; do
    if [ -d "$skill_dir" ]; then
        skill_name=$(basename "$skill_dir")
        
        echo -e "${GREEN}Scanning: ${skill_name}${NC}"
        
        # Create a tarball of the skill directory
        TARBALL="/tmp/${skill_name}.tar.gz"
        tar -czf "$TARBALL" -C "/code/skills" "$skill_name"
        
        # Get file hash
        HASH=$(sha256sum "$TARBALL" | cut -d' ' -f1)
        
        # Scan the file
        echo "  File: $TARBALL"
        echo "  SHA256: $HASH"
        echo "  Uploading to VirusTotal..."
        
        # Try to get existing report first
        REPORT_FILE="${RESULTS_DIR}/${skill_name}_${TIMESTAMP}.json"
        if vt file "$HASH" --output json > "$REPORT_FILE" 2>&1; then
            echo -e "  ${GREEN}✓ Report retrieved (file already scanned)${NC}"
        else
            # File not found, upload for scanning
            echo "  File not found in VT database, uploading..."
            vt scan file "$TARBALL" --output json > "$REPORT_FILE" 2>&1 || true
            echo -e "  ${YELLOW}⏳ File uploaded for scanning${NC}"
            echo "  Note: Analysis may take a few minutes. Check the report later with:"
            echo "       vt file $HASH"
        fi
        
        # Clean up tarball
        rm -f "$TARBALL"
        
        echo "  Report saved to: $REPORT_FILE"
        echo ""
    fi
done

echo -e "${GREEN}Scan complete!${NC}"
echo "Results saved to: $RESULTS_DIR"
echo ""
echo "To check individual file results:"
echo "  vt file <sha256-hash>"
echo ""
echo "To view saved reports:"
echo "  cat $RESULTS_DIR/*.json | jq ."
