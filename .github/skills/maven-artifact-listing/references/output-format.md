# Output Format Reference

The maven artifact listing generates a sequential numbered list with artifact details and Maven dependency declarations.

## Format Structure

- Sequential numbering: `N.artifactId (installer-type)`
- For each artifact:
  - Artifact name and installer type (maven-dependency, maven-import, or maven-dropins)
  - Raw XML `<dependency>` declaration:
    - `<groupId>` – Maven group ID
    - `<artifactId>` – Maven artifact ID
    - `<version>` – Version (extracted from pom.xml if provided, or ${version} placeholder)
    - `<type>` – Artifact format (e.g., iar, jar)

## Example Output

```
1.docuware-connector (maven-dependency)
<dependency>
  <groupId>com.axonivy.connector.docuware</groupId>
  <artifactId>docuware-connector</artifactId>
  <version>13.2.4</version>
  <type>iar</type>
</dependency>

2.docuware-connector-demo (maven-import)
<dependency>
  <groupId>com.axonivy.connector.docuware</groupId>
  <artifactId>docuware-connector-demo</artifactId>
  <version>13.2.4</version>
  <type>iar</type>
</dependency>
```

## Version Handling

- **With pom.xml**: Extracts actual version and converts snapshots to release versions
  - Example: `1.0.0-SNAPSHOT` → `1.0.0`
- **Without pom.xml**: Preserves `${version}` placeholders from product.json
  - Example: `${version}` (unchanged)

## Edge Cases

- If no artifacts are found, output is empty
- If pom.xml cannot be read or version is not found, placeholders are preserved with a warning message to stderr