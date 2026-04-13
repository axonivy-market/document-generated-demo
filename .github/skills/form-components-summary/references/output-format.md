# Output Format

The generated report is Markdown.

## Sections
- Top heading: `# Axon Ivy Form Component`
- One section per form directory:
  - `## <UI form component name>`
- Under each componet:
  - one bullet per criteria:
    - `Namespace`
    - `Component type`
    - `Parameter`: list of available parameter (if exist), its tpe class, and default value.
    - `Main logic/feature included in that UI`: some main feautes that UI can execute which is extracted via UI process, its managedbean, and additional javascript.
