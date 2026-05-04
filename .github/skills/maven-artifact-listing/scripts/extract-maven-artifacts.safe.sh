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

  # Collect all artifacts in priority order:
  #   1. maven-dependency (always required)
  #   2. maven-import with importInWorkspace != false  (required imports)
  #   3. maven-import with importInWorkspace == false  (optional imports)
  # Installer type is NOT exposed in the output.
  # Artifacts ending with 'test' are excluded.
  # Version is always output as ${version} regardless of the value in product.json.
  jq -r '
    [
      # --- required dependencies (maven-dependency installer) ---
      (.installers[] | select(.id == "maven-dependency") | .data.dependencies[]? | select(.artifactId | endswith("test") | not)) as $a |
      { groupId: $a.groupId, artifactId: $a.artifactId, format: $a.type, optional: false }
    ] +
    [
      # --- required imports (importInWorkspace omitted or true) ---
      (.installers[] | select(.id == "maven-import") | .data.projects[]? | select(.importInWorkspace != false) | select(.artifactId | endswith("test") | not)) as $a |
      { groupId: $a.groupId, artifactId: $a.artifactId, format: $a.type, optional: false }
    ] +
    [
      # --- optional imports (importInWorkspace == false) ---
      (.installers[] | select(.id == "maven-import") | .data.projects[]? | select(.importInWorkspace == false) | select(.artifactId | endswith("test") | not)) as $a |
      { groupId: $a.groupId, artifactId: $a.artifactId, format: $a.type, optional: true }
    ] |
    to_entries[] |
    "\(.key + 1). \(.value.artifactId)" +
    (if .value.optional then " *(optional)*" else "" end) + "\n" +
    "```xml\n" +
    "<dependency>\n" +
    "  <groupId>\(.value.groupId)</groupId>\n" +
    "  <artifactId>\(.value.artifactId)</artifactId>\n" +
    "  <version>${version}</version>\n" +
    (if .value.format then "  <type>\(.value.format)</type>\n" else "" end) +
    "</dependency>\n" +
    "```\n"
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
