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
