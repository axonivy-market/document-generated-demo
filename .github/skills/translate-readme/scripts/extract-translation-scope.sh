#!/bin/bash
#
# Extract translation scope from a product README.md
#
# Outputs all lines from line 1 up to (but NOT including) the first top-level
# ## heading (e.g. ## Demo, ## Setup, ## Components).
#
# Usage:
#   ./extract-translation-scope.sh <path-to-README.md>
#
# Output:
#   Prints the extracted lines to stdout.
#   Exits with code 1 if the file is not found or is empty.
#
# Example:
#   ./extract-translation-scope.sh my-connector-product/README.md

set -e

RED='\033[0;31m'
NC='\033[0m'

if [ $# -lt 1 ]; then
  echo -e "${RED}Error: Missing required argument${NC}"
  echo "Usage: $0 <path-to-README.md>"
  exit 1
fi

README="$1"

if [ ! -f "$README" ]; then
  echo -e "${RED}Error: File not found: $README${NC}"
  exit 1
fi

# Print all lines before the first top-level ## heading.
# Stops at the first line that starts with '## ' (two hashes + space).
awk '/^## /{exit} {print}' "$README"
