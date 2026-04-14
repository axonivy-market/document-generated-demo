#!/bin/bash
#
# Extract Maven artifacts from product.json
#
# Usage:
#   ./extract-maven-artifacts.sh <path-to-product.json> [pom.xml-path] [output-file]
#
# Example:
#   ./extract-maven-artifacts.sh product.json
#   ./extract-maven-artifacts.sh product.json ../pom.xml
#   ./extract-maven-artifacts.sh product.json ../pom.xml output.md

set -e

# Color codes for terminal output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

# Check arguments
if [ $# -lt 1 ]; then
  echo -e "${RED}Error: Missing required argument${NC}"
  echo "Usage: $0 <path-to-product.json> [pom.xml-path] [output-file]"
  exit 1
fi

PRODUCT_JSON="$1"
POM_FILE="${2:-}"
OUTPUT_FILE="${3:-}"

# If only 2 args and second looks like output file (has extension), treat it as output
if [ $# -eq 2 ] && [[ "$2" == *.md ]]; then
  OUTPUT_FILE="$2"
  POM_FILE=""
fi

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

# Function to extract version from pom.xml
extract_version_from_pom() {
  local pom_path="$1"
  
  if [ ! -f "$pom_path" ]; then
    echo -e "${YELLOW}Warning: pom.xml file not found: $pom_path${NC}" >&2
    echo ""
    return
  fi
  
  # Extract version using grep and sed
  local version=$(grep "<version>" "$pom_path" | head -1 | sed 's/.*<version>\(.*\)<\/version>.*/\1/')
  
  if [ -z "$version" ]; then
    echo -e "${YELLOW}Warning: Could not extract version from pom.xml${NC}" >&2
    echo ""
    return
  fi
  
  # Convert snapshot version to release version
  if [[ "$version" == *"-SNAPSHOT" ]]; then
    version="${version%-SNAPSHOT}"
  fi
  
  echo "$version"
}

# Extract version if pom.xml is provided
VERSION=""
if [ -n "$POM_FILE" ]; then
  VERSION=$(extract_version_from_pom "$POM_FILE")
fi

# Function to generate output
generate_markdown() {
  local json_file="$1"
  local version="${2:-}"
  
  # Build the output with jq - collect all artifacts first, then number them
  jq -r --arg version "$version" '
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
        version: (if $version != "" then $version else $artifact.version end),
        format: $artifact.type
      }
    ] |
    to_entries[] |
    "\(.key + 1).\(.value.artifactId) (\(.value.type))\n" +
    "<dependency>\n" +
    "  <groupId>\(.value.groupId)</groupId>\n" +
    "  <artifactId>\(.value.artifactId)</artifactId>\n" +
    "  <version>\(.value.version)</version>\n" +
    (if .value.format then "  <type>\(.value.format)</type>\n" else "" end) +
    "</dependency>\n"
  ' "$json_file"
}

# Main execution
if [ -z "$OUTPUT_FILE" ]; then
  # Print to stdout
  generate_markdown "$PRODUCT_JSON" "$VERSION"
else
  # Write to file
  generate_markdown "$PRODUCT_JSON" "$VERSION" > "$OUTPUT_FILE"
  echo -e "${GREEN}✓ Artifacts extracted to: $OUTPUT_FILE${NC}"
fi
