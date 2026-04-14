---
name: form-components-listing
description: give me a detailed summary about available form components from main module(s)?
argument-hint: '[optional: main module name]'
user-invocable: true
---

# Form Components Summary

Generate a concise, marketing-oriented summary of available form dialog and form components from main module(s) in an Axon Ivy project.

## Inputs
- Optional path to UI dialog directory of main module(s).

## Generated report
----------------

When invoked, this skill runs the scanner script and writes a Markdown report to:

- `.github/skills/form-components-listing/output/ivy-scan.md` (full scan report)
- `.github/skills/form-components-listing/output/ivy-summary.md` (concise marketing summary)

You can regenerate the reports locally by running the scanner script included in the repository:

```
.github/skills/form-components-listing/scripts/form-components-listing.sh {product module}/src_hd --md > .github/skills/form-components-listing/output/ivy-scan.md
```

To produce the concise dialogs-only summary and print it to stdout, run the scanner with the `--summary` flag (no separate helper required):

```
.github/skills/form-components-listing/scripts/form-components-listing.sh {product module} --md --summary
```

The generated reports can be saved under `.github/skills/form-components-listing/output/` if desired. The scanner and summary options are module-agnostic; callers may pass any module or top-level UI folder.

## Output
- The skill returns a concise dialogs-only markdown summary. The exact output schema is defined in the reference file:

- [references/output-format.md](references/output-format.md)

Notes:
- The skill accepts an optional input path (module or UI tree) and is not tied to a specific module name; callers may pass any module or top-level UI folder.
- For full component listings or raw scan output, use the scanner script directly (see the "Generated report" section above).
Additional guidance for `main feature/logic`:
- The `main feature/logic` field should describe user-facing actions or interactions available in the dialog (for example: "allows filtering by date and exporting CSV", "opens process viewer and lets user navigate task timeline").
- Prefer short action-oriented summaries (one or two lines) rather than raw technical metadata.
