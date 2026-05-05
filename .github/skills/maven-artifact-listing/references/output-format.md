# Output Format Reference

The maven artifact listing generates a sequential numbered list with artifact details and Maven dependency declarations.

## Format Structure

- Sequential numbering: `N.artifactId (installer-type)`
- For each artifact:
  - Artifact name and installer type (maven-dependency, maven-import, or maven-dropins)
  - Raw XML `<dependency>` declaration:
    - `<groupId>` – Maven group ID
    - `<artifactId>` – Maven artifact ID
    - `<type>` – Artifact format (e.g., iar, jar)

## Example Output

```
1.docuware-connector (maven-dependency)
<dependency>
  <groupId>com.axonivy.connector.docuware</groupId>
  <artifactId>docuware-connector</artifactId>
  <type>iar</type>
</dependency>

2.docuware-connector-demo (maven-import)
<dependency>
  <groupId>com.axonivy.connector.docuware</groupId>
  <artifactId>docuware-connector-demo</artifactId>
  <type>iar</type>
</dependency>
```

## Edge Cases

- If no artifacts are found, output is empty
- Artifacts whose `artifactId` ends with `test` are silently excluded from the output
- `maven-dropins` artifacts are listed after optional imports, also without exposing the installer type