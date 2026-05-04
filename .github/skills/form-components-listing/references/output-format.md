# Output Format Reference

The `form-components-listing` skill must return a **concise dialogs-only markdown list**. One block per UI dialog, in this exact field order:

- `UI dialog name`: friendly identifier (folder or view name).
- `namespace`: fully-qualified namespace from `.p.json` or `.d.json`; otherwise `(unknown)`.
- `start parameter`: declared process start parameter or method signature used to open the dialog; `(none)` when absent.
- `main feature/logic`: one-to-two line summary of the dialog's primary user-facing purpose. Describe what the user can **do** in the dialog (e.g. "allows filtering by date and exporting CSV", "opens process viewer and lets user navigate task timeline"). Infer from process descriptions, nested components, or adjacent JavaScript — do not list raw component names.

## Example

```
UI dialog name: ViewNotPermittedPage
- namespace: com.axonivy.solutions.process.analyser.ViewNotPermittedPage
- start parameter: (none)
- main feature/logic: Informational page shown when the user lacks access rights; displays reason and link to request permission.
```

## Rules

- Format is intentionally compact and human-readable for README integration.
- Do not use the full component listing / raw scanner schema (with `Component type`, `Parameter` fields) — that is scanner-internal output only.
- Treat input paths generically; do not hardcode module names.
- Prefer action-oriented summaries over technical metadata in `main feature/logic`.
