---
name: product-image-summary
description: Discover and catalog all images (screenshots, diagrams, GIFs) that could be used in readme documentation, generate auto-suggested alt-text, and create markdown snippets ready for readme integration. Use when asked to find, list, or summarize product images or screenshots for documentation.
argument-hint: '[required: exact project directory name] [optional: output file]'
user-invocable: true
---

# Product Image Summary

Given the exact product module name, auto-discover its `images/` subdirectory, group images by folder structure, generate alt-text from filenames, and output ready-to-copy markdown snippets.

## Inputs

- **Required:** Exact product module name (e.g., `open-weather-connector-product`) — the script looks for `{name}/images/` then falls back to `{name}/`
- **Optional:** Output file path — omit to print to stdout

## Usage

Before running, check the current OS. If on Windows, git bash or WSL is recommended to use for best compatibility.
```bash
# Bash (Linux/macOS/WSL)
bash ./.github/skills/product-image-summary/scripts/catalog-images.sh {product module name} docs/product-images.md

## Output

Images grouped by subdirectory under `images/`. Section headers reflect the folder path (e.g., `demo/dashboard/` → `## Demo / Dashboard`). Each entry includes file path, suggested readme placement, alt-text, and a markdown snippet.

See [references/output-format.md](references/output-format.md) for the full output schema and examples.
