---
name: maven-artifact-listing
description: Extract maven artifacts from an Axon Ivy product.json file and generate a clean list with sequential numbering and Maven dependency XML snippets.
argument-hint: '<product.json path> [output file]'
user-invocable: true
---

# Maven Artifact Listing

Generate a clean Maven artifact listing from Axon Ivy product.json files with sequential numbering and raw XML dependency declarations.

## Inputs

- **Required:** Path to `product.json` file (e.g., `docuware-connector-product/product.json`)
- **Optional:** Output file path. If omitted, output prints to stdout

## Features

Extracts artifacts from all installer types:
- **maven-dependency** – Dependencies array
- **maven-import** – Projects array  
- **maven-dropins** – Dropins array

For each artifact, generates:
- Sequential number with artifact name and installer type
- Raw XML `<dependency>` declaration with groupId, artifactId, version, and type

## Prerequisites

- `jq` must be installed. The script exits with a clear error if it is not found.
  Install: `apt install jq` (Linux/WSL) | `brew install jq` (macOS) | `choco install jq` (Windows)

## Usage

### Print to stdout
```bash
bash ./.github/skills/maven-artifact-listing/scripts/extract-maven-artifacts.sh {product json path}
```

### Write to file
```bash
bash ./.github/skills/maven-artifact-listing/scripts/extract-maven-artifacts.sh {product json path} {output file}
```

## Output Format

See [format reference](./references/output-format.md) for detailed output structure and examples.

## Integration

Use this skill when:
- Product.json is modified with new artifacts
- Documentation needs to be refreshed
- Maven dependencies must be shared with users/integrators
- Artifact inventory needs to be generated for CI/CD pipelines
