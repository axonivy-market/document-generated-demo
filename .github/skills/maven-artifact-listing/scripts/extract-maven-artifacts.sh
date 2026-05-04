#!/bin/bash
#
# Extract Maven artifacts from product.json
#
# Usage:
#   ./extract-maven-artifacts.sh <path-to-product.json> [output-file]
#
# Example:
#   ./extract-maven-artifacts.sh product.json
#   ./extract-maven-artifacts.sh product.json output.md

set -e

# Color codes for terminal output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

# Check arguments
if [ $# -lt 1 ]; then
  echo -e "${RED}Error: Missing required argument${NC}"
  echo "Usage: $0 <path-to-product.json> [output-file]"
  exit 1
fi

PRODUCT_JSON="$1"
OUTPUT_FILE="${2:-}"

# Check if product.json exists
if [ ! -f "$PRODUCT_JSON" ]; then
  echo -e "${RED}Error: product.json file not found: $PRODUCT_JSON${NC}"
  exit 1
fi

# Check if jq is installed
if ! command -v jq &> /dev/null; then
  echo -e "${RED}Error: jq is not installed. Please install jq to continue.${NC}"
  exit 1
fi

# Function to generate output
generate_markdown() {
  local json_file="$1"
  
  # Build the output with jq - collect all artifacts first, then number them
  jq -r '
    [
      .installers[] as $installer |
      $installer.id as $type |
      (
        if $type == "maven-dependency" then
          $installer.data.dependencies[]?
        elif $type == "maven-import" then
          $installer.data.projects[]?
        elif $type == "maven-dropins" then
          $installer.data.dropins[]?
        else
          empty
        end
      ) as $artifact |
      {
        artifactId: $artifact.artifactId,
        type: $type,
        groupId: $artifact.groupId,
        format: $artifact.type
      }
    ] |
    to_entries[] |
    "\(.key + 1).\(.value.type):\n" +
    "<dependency>\n" +
    "  <groupId>\(.value.groupId)</groupId>\n" +
    "  <artifactId>\(.value.artifactId)</artifactId>\n" +
    (if .value.format then "  <type>\(.value.format)</type>\n" else "" end) +
    "</dependency>\n"
  ' "$json_file"
}

# Main execution
if [ -z "$OUTPUT_FILE" ]; then
  # Print to stdout
  generate_markdown "$PRODUCT_JSON"
else
  # Write to file
  generate_markdown "$PRODUCT_JSON" > "$OUTPUT_FILE"
  echo -e "${GREEN}✓ Artifacts extracted to: $OUTPUT_FILE${NC}"
fi
