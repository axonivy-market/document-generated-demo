# Output Format Reference

This document defines the concise dialogs-only markdown schema that the `form-components-listing` skill must return.

For each UI dialog the skill should emit a short block with these fields in this order:

- `UI dialog name`: a friendly identifier (folder or view name).
- `namespace`: fully-qualified namespace, if available from `.p.json` or `.d.json` files; otherwise `(unknown)`.
- `start parameter`: the declared process start parameter or method signature used to open the dialog; `(none)` when absent.
- `main feature/logic`: a one- to two-line summary describing the dialog's primary purpose or behavior. This should be inferred from process descriptions, nested components, or adjacent JavaScript files — do not list components themselves.

Example

```
UI dialog name: ViewNotPermittedPage
- namespace: com.axonivy.solutions.process.analyser.ViewNotPermittedPage
- start parameter: (none)
- main feature/logic: Informational page shown when the user lacks access rights; displays reason and link to request permission.
```

Notes
- The format is intentionally compact and human-readable for marketing-style summaries.
- Implementations should treat input paths generically; do not hardcode module names.
# Output Format

The generated report is Markdown.

## Sections
- One section per form directory:
  - `#### <UI form component name>`
- Under each component:
  - one bullet per criteria:
    - `Namespace`
    - `Component type`
    - `Parameter`: list of available parameter (if exist), its type class, and default value.
    - `Main logic/feature included in that UI`: some main features that UI can execute which is extracted via UI process, its managedbean, and additional javascript.
