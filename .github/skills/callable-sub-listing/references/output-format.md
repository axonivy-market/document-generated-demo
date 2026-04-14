# Output Format

The generated report is Markdown.

## Sections
- One section per CALLABLE_SUB file:
  - `#### <path>`
- Under each file:
  - `- No CallSubStart with tag connector`
  - or one bullet per connector start:
    - `Signature`
    - `Input`
    - `Result`

## Field Rules
- `Input` is `none` when no parameter config exists.
- `Result` is `none` when no result config exists.

