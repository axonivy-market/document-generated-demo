---
name: form-components-listing
description: List and summarize available form dialogs and UI components from the main Axon Ivy module(s). Use when asked for a detailed summary, listing, or overview of form components or form dialogs in the project.
argument-hint: '[optional: path to main module src_hd directory, e.g. my-connector/src_hd]'
user-invocable: true
---

# Form Components Summary

Generate a concise, marketing-oriented summary of available form dialog and form components from main module(s) in an Axon Ivy project.

## Inputs
- Optional path to the `src_hd` directory of the main module (e.g. `my-connector/src_hd`). Defaults to scanning the current workspace.

## Usage

**When invoked as a sub-skill** (e.g. from `generate-ivy-readme`): print to stdout — no file is written. The caller injects stdout verbatim into the target placeholder.

**When run directly from CLI:**

```bash
# Full scan report to file
.github/skills/form-components-listing/scripts/form-components-listing.sh {product module}/src_hd --md > .github/skills/form-components-listing/output/ivy-scan.md

# Concise dialogs-only summary to stdout
.github/skills/form-components-listing/scripts/form-components-listing.sh {product module}/src_hd --md --summary
```

The scanner is module-agnostic; pass any `src_hd` directory or top-level UI folder.

## Output
- The skill returns a concise dialogs-only markdown summary. The exact output schema is defined in the reference file:

- [references/output-format.md](references/output-format.md)

Notes:
- The skill accepts an optional input path (module or UI tree) and is not tied to a specific module name; callers may pass any module or top-level UI folder.
- For full component listings or raw scan output, use the scanner script directly (see the "Generated report" section above).
