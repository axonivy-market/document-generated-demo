---
name: form-components-listing
description: Use when asked for a detailed summary, listing, or overview of form components or form dialogs in the project.
argument-hint: '[optional: path to main module src_hd directory, e.g. my-connector/src_hd]'
user-invocable: true
---

# Form Components Summary

Generate a concise, marketing-oriented summary of available form dialog and form components from main module(s) in an Axon Ivy project.

## Inputs
- Optional path to the `src_hd` directory of the main module (e.g. `my-connector/src_hd`). Defaults to scanning the current workspace.

## Usage
Before running, check the current OS. If on Windows, git bash or WSL is recommended to use for best compatibility.
### Print to stdout
```bash
bash ./.github/skills/form-components-listing/scripts/form-components-listing.sh '<src_hd path>'
```

### Write to file
```bash
bash ./.github/skills/form-components-listing/scripts/form-components-listing.sh '<src_hd path>' 'docs/form-components.md'
```

The scanner is module-agnostic; pass any `src_hd` directory or top-level UI folder.

## Output
- The skill returns a concise dialogs-only markdown summary. The exact output schema is defined in the reference file:

- [references/output-format.md](references/output-format.md)

Notes:
- The skill accepts an optional input path (module or UI tree) and is not tied to a specific module name; callers may pass any module or top-level UI folder.
- For full component listings or raw scan output, use the scanner script directly (see the "Generated report" section above).
Additional guidance for `main feature/logic`:
- The `main feature/logic` field should describe user-facing actions or interactions available in the dialog (for example: "allows filtering by date and exporting CSV", "opens process viewer and lets user navigate task timeline").
- Prefer short action-oriented summaries (one or two lines) rather than raw technical metadata.
